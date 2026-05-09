import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mimo_agent_client.dart';
import '../mimo_tts_client.dart';
import '../voice_keys.dart';
import '../voice_providers.dart';
import '../voice_types.dart';
import 'agent_tool.dart';
import 'agent_tool_registry.dart';
import 'page_context_provider.dart';

void _vlog(String msg) => debugPrint('[VoiceAgent] $msg');

/// 串联：录音 → 多模态理解 → 工具分发 → TTS → 播放，集中管理状态。
class AgentOrchestrator extends Notifier<VoiceState> {
  bool _busy = false;

  @override
  VoiceState build() => VoiceState.idle;

  /// 用户按下麦克风：检查权限 + 开始录音。
  Future<void> startRecording() async {
    _vlog('startRecording invoked, busy=$_busy status=${state.status}');
    if (_busy) return;
    if (state.status == VoiceStatus.recording) return;

    _busy = true;
    state = state.copyWith(
      status: VoiceStatus.requestingPermission,
      clearError: true,
      clearTranscript: true,
    );
    try {
      final granted =
          await ref.read(micPermissionProvider).ensureGranted();
      _vlog('mic permission granted=$granted');
      if (!granted) {
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '需要麦克风权限',
        );
        return;
      }
      // 如果在播 TTS，先停。
      await ref.read(audioPlayerProvider).stop();
      await ref.read(audioRecorderProvider).start();
      _vlog('recorder started');
      state = state.copyWith(status: VoiceStatus.recording);
    } catch (e, st) {
      _vlog('startRecording error: $e\n$st');
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: '开始录音失败: $e',
      );
    } finally {
      _busy = false;
    }
  }

  /// 用户松开麦克风：停录 → 调 mimo → 派 tool → TTS → 播。
  Future<void> stopAndSubmit() async {
    _vlog('stopAndSubmit invoked, status=${state.status}');
    if (state.status != VoiceStatus.recording) return;
    if (_busy) return;
    _busy = true;
    try {
      state = state.copyWith(status: VoiceStatus.thinking);

      final audio = await ref.read(audioRecorderProvider).stop();
      _vlog('recorder stopped, audio bytes=${audio?.bytes.length ?? 0} mime=${audio?.mimeType}');
      if (audio == null || audio.bytes.isEmpty) {
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '没录到声音',
        );
        return;
      }

      final agent = ref.read(mimoAgentClientProvider);
      if (agent == null) {
        _vlog('agent client null — config incomplete');
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '语音 agent 未配置（先去设置填 LLM baseURL/apiKey/视觉模型）',
        );
        return;
      }

      final pageCtx = ref.read(pageContextProvider);
      final registry = ref.read(agentToolRegistryProvider);
      _vlog('calling mimo understand … pageCtx kind=${pageCtx?.kind}');

      AgentResponse resp;
      try {
        resp = await agent.understand(
          audio: audio,
          systemPrompt: _composeSystemPrompt(registry),
          pageContext: pageCtx,
        );
        _vlog('mimo returned: tool=${resp.toolName} args=${resp.args} '
            'transcript="${resp.transcript}" speak="${resp.speakText}"');
      } on MimoAgentException catch (e) {
        _vlog('mimo error code=${e.statusCode} msg=${e.message}');
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: 'agent 调用失败: ${e.statusCode ?? ''} ${e.message}',
        );
        return;
      }

      // 派工具。
      final tool = resp.toolName == null
          ? registry.find('chat_fallback')
          : registry.find(resp.toolName!);
      _vlog('dispatching tool=${tool?.name ?? "<none>"}');

      String spokenText = resp.speakText;
      if (tool != null) {
        state = state.copyWith(
          status: VoiceStatus.executing,
          currentTool: tool.name,
          transcript: resp.transcript,
          speakText: resp.speakText,
        );
        try {
          final result = await tool.invoke(
            resp.args,
            AgentContext(
              ref: ref,
              contextResolver: () => voiceMessengerKey.currentContext,
            ),
          );
          _vlog('tool ${tool.name} done; speakOverride=${result.speakText} undo=${result.undo != null} silent=${result.silent}');
          if (result.speakText != null && result.speakText!.isNotEmpty) {
            spokenText = result.speakText!;
          }
          if (result.undo != null) {
            _showUndoSnack(result.undo!);
          }
          if (result.silent) {
            state = state.copyWith(status: VoiceStatus.idle);
            return;
          }
        } catch (e, st) {
          _vlog('tool ${tool.name} threw: $e\n$st');
          state = state.copyWith(
            status: VoiceStatus.error,
            errorMessage: '执行 ${tool.name} 失败：$e',
          );
          return;
        }
      } else {
        state = state.copyWith(
          status: VoiceStatus.executing,
          transcript: resp.transcript,
          speakText: resp.speakText,
        );
      }

      // 播放：优先级 模型直接吐的音频 > mimo TTS 单独合成 > 系统 TTS 兜底。
      state = state.copyWith(
        status: VoiceStatus.synthesizing,
        speakText: spokenText,
      );

      // 1) 模型直接吐了音频（modalities: text+audio）。
      if (resp.audioBytes != null && resp.audioBytes!.isNotEmpty) {
        _vlog('playing inline audio from model: ${resp.audioBytes!.length}B');
        state = state.copyWith(status: VoiceStatus.speaking);
        try {
          await ref.read(audioPlayerProvider).playBytes(
                resp.audioBytes!,
                contentType: resp.audioMime,
              );
          _vlog('inline audio playback done');
        } catch (e) {
          _vlog('inline audio play error: $e — fallback to system TTS');
          await _speakWithSystemTts(spokenText);
        }
        state = state.copyWith(status: VoiceStatus.idle);
        return;
      }

      if (spokenText.trim().isEmpty) {
        _vlog('empty speak — back to idle');
        state = state.copyWith(status: VoiceStatus.idle);
        return;
      }

      // 2) mimo TTS 单独合成（如果有配 voiceId 但模型没直接吐音频）。
      final tts = ref.read(mimoTtsClientProvider);
      if (tts != null) {
        try {
          _vlog('TTS synthesize len=${spokenText.length} …');
          final bytes = await tts.synthesize(spokenText);
          _vlog('TTS got ${bytes.length} bytes, playing …');
          state = state.copyWith(status: VoiceStatus.speaking);
          await ref.read(audioPlayerProvider).playBytes(bytes);
          _vlog('TTS playback done');
          state = state.copyWith(status: VoiceStatus.idle);
          return;
        } on MimoTtsException catch (e) {
          _vlog('TTS error code=${e.statusCode} msg=${e.message} — fallback to system TTS');
        } catch (e) {
          _vlog('TTS unexpected: $e — fallback to system TTS');
        }
      }

      // 3) 系统 TTS 兜底（让 voice loop 永远闭环）。
      _vlog('using system TTS fallback');
      state = state.copyWith(status: VoiceStatus.speaking);
      await _speakWithSystemTts(spokenText);
      state = state.copyWith(status: VoiceStatus.idle);
    } catch (e, st) {
      _vlog('stopAndSubmit unexpected: $e\n$st');
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: '出错了: $e',
      );
    } finally {
      _busy = false;
    }
  }

  /// 取消录音（不提交）或打断当前播放。
  Future<void> cancel() async {
    final s = state.status;
    if (s == VoiceStatus.recording) {
      try {
        await ref.read(audioRecorderProvider).cancel();
      } catch (_) {}
    }
    if (s == VoiceStatus.speaking || s == VoiceStatus.synthesizing) {
      try {
        await ref.read(audioPlayerProvider).stop();
      } catch (_) {}
    }
    state = VoiceState.idle;
    _busy = false;
  }

  String _composeSystemPrompt(AgentToolRegistry registry) {
    return '''
你是 good-dad 准爸爸 app 的语音助手。请听用户说话，判断他想做什么，然后**只输出 JSON**：
{"action":"<工具名>","args":{...},"speak":"<给用户念的回答，简体中文，最多 2 句>","transcript":"<我听到的用户原话>"}

回复规则：
- 默认中文，口语化、温柔不卖萌
- 严格 JSON，不要 markdown 代码围栏
- 拿不准就用 chat_fallback 直接答
- 涉及医学话题保守："这个我不敢替医生说"

${registry.describeForPrompt()}
''';
  }

  Future<void> _speakWithSystemTts(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await ref.read(systemTtsProvider).speak(text);
    } catch (e) {
      _vlog('system TTS error: $e');
    }
  }

  void _showUndoSnack(UndoSnack undo) {
    final messenger = voiceMessengerKey.currentState;
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: undo.window,
        content: Text(undo.label),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () async {
            try {
              await undo.undo();
            } catch (_) {}
          },
        ),
      ),
    );
  }
}

final agentOrchestratorProvider =
    NotifierProvider<AgentOrchestrator, VoiceState>(AgentOrchestrator.new);
