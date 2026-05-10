import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../memory/memory_extractor.dart';
import '../harness/harness_input.dart';
import '../harness/reasoner.dart';
import '../mimo_tts_client.dart';
import '../voice_keys.dart';
import '../voice_providers.dart';
import '../voice_types.dart';
import 'agent_tool.dart';
import 'agent_tool_registry.dart';
import 'page_context_provider.dart';

void _vlog(String msg) => debugPrint('[Harness] $msg');

/// 防 LLM 死循环：单 turn 最多调几次 tool。v1 单步推理实际只会 ≤1，留个常量给 v2。
// ignore: unused_element
const int _maxToolCalls = 3;

/// 串联：录音/文字 → 多模态理解 → 工具分发 → TTS → 播放，集中管理状态。
///
/// 两条入口：
/// - voice 路径：`startRecording` / `stopAndSubmit` → MimoAgentClient
/// - text 路径：`submitText({text, imageBytes})` → OpenAICompatibleClient
///
/// 都汇到 `_dispatchAndSpeak` 共享：工具派发 + 音频播放 + 错误态。
class AgentOrchestrator extends Notifier<VoiceState> {
  bool _busy = false;

  @override
  VoiceState build() => VoiceState.idle;

  // ─────────────────────────────────────────────────────────────
  // VOICE 路径
  // ─────────────────────────────────────────────────────────────

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
      final granted = await ref.read(micPermissionProvider).ensureGranted();
      _vlog('mic permission granted=$granted');
      if (!granted) {
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '需要麦克风权限',
        );
        return;
      }
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
      _vlog('recorder stopped, audio bytes=${audio?.bytes.length ?? 0} '
          'mime=${audio?.mimeType}');
      if (audio == null || audio.bytes.isEmpty) {
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '没录到声音',
        );
        return;
      }

      final reasoner = ref.read(mimoReasonerProvider);
      if (reasoner == null) {
        _vlog('mimo reasoner null — config incomplete');
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '语音 agent 未配置（先去设置填 LLM baseURL/apiKey/视觉模型）',
        );
        return;
      }

      final pageCtx = ref.read(pageContextProvider);
      final registry = ref.read(agentToolRegistryProvider);
      final systemPrompt = await _buildSystemPrompt(pageCtx);
      _vlog('reason via reasoner=${reasoner.name} pageCtx=${pageCtx?.kind} '
          'prompt=${systemPrompt.length}c');

      final input = VoiceHarnessInput(audio);
      AgentResponse resp;
      try {
        resp = await reasoner.reason(
          input: input,
          systemPrompt: systemPrompt,
          // pageContext 已经被 builder 拼到 systemPrompt 里，这里传 null 避免重复。
          pageContext: null,
        );
        _vlog('reasoner returned: tool=${resp.toolName} args=${resp.args} '
            'transcript="${resp.transcript}" speak="${resp.speakText}"');
      } on ReasonerException catch (e) {
        _vlog('reasoner error code=${e.statusCode} msg=${e.message}');
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: 'agent 调用失败: ${e.statusCode ?? ''} ${e.message}',
        );
        return;
      }

      await _dispatchAndSpeak(resp, registry);
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
  ///
  /// 任何状态下都强制停**两个音频源**（mimo/inline 走 audioPlayer，兜底走 systemTts），
  /// 之前只 stop 了 audioPlayer，导致系统 TTS 兜底播放时点不动。
  Future<void> cancel() async {
    _vlog('cancel from status=${state.status}');
    final s = state.status;
    // 同时停两个：不知道当前在播哪个就两个都停。
    try {
      await ref.read(audioPlayerProvider).stop();
    } catch (_) {}
    try {
      await ref.read(systemTtsProvider).stop();
    } catch (_) {}
    if (s == VoiceStatus.recording) {
      try {
        await ref.read(audioRecorderProvider).cancel();
      } catch (_) {}
    }
    state = VoiceState.idle;
    _busy = false;
  }

  // ─────────────────────────────────────────────────────────────
  // TEXT 路径
  // ─────────────────────────────────────────────────────────────

  /// 文字 / 文字+图片 入口（ComposerSheet 调）。走用户配置的 LLM。
  Future<void> submitText({
    required String text,
    Uint8List? imageBytes,
  }) async {
    _vlog('submitText invoked, text="${_truncate(text, 60)}" '
        'image=${imageBytes?.length ?? 0}B');
    if (_busy) return;
    if (state.status != VoiceStatus.idle &&
        state.status != VoiceStatus.error) {
      _vlog('busy with ${state.status}, ignoring');
      return;
    }
    if (text.trim().isEmpty && (imageBytes == null || imageBytes.isEmpty)) {
      return;
    }
    _busy = true;
    try {
      // 打断 TTS（如果在播）
      try {
        await ref.read(audioPlayerProvider).stop();
        await ref.read(systemTtsProvider).stop();
      } catch (_) {}

      state = state.copyWith(
        status: VoiceStatus.thinking,
        transcript: text,
        clearError: true,
      );

      final reasoner = ref.read(openAIReasonerProvider);
      if (reasoner == null) {
        _vlog('openai reasoner null — config incomplete');
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: '请先去设置填 LLM baseURL / apiKey / 模型',
        );
        return;
      }

      final pageCtx = ref.read(pageContextProvider);
      final registry = ref.read(agentToolRegistryProvider);
      final systemPrompt = await _buildSystemPrompt(pageCtx);
      _vlog('reason via reasoner=${reasoner.name} pageCtx=${pageCtx?.kind} '
          'prompt=${systemPrompt.length}c');

      final input = TextHarnessInput(text: text, image: imageBytes);
      AgentResponse resp;
      try {
        resp = await reasoner.reason(
          input: input,
          systemPrompt: systemPrompt,
          // pageContext 已经被 builder 拼到 systemPrompt 里，这里传 null 避免重复。
          pageContext: null,
        );
        _vlog('reasoner returned: tool=${resp.toolName} args=${resp.args} '
            'speak="${_truncate(resp.speakText, 80)}"');
      } on ReasonerException catch (e) {
        _vlog('reasoner error: ${e.statusCode} ${e.message}');
        state = state.copyWith(
          status: VoiceStatus.error,
          errorMessage: 'LLM 调用失败: ${e.statusCode ?? ''} ${e.message}',
        );
        return;
      }

      await _dispatchAndSpeak(resp, registry);
    } catch (e, st) {
      _vlog('submitText unexpected: $e\n$st');
      state = state.copyWith(
        status: VoiceStatus.error,
        errorMessage: '出错了: $e',
      );
    } finally {
      _busy = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 共享：工具派发 + 音频播放
  // ─────────────────────────────────────────────────────────────

  Future<void> _dispatchAndSpeak(
    AgentResponse resp,
    AgentToolRegistry registry,
  ) async {
    final tool = resp.toolName == null
        ? registry.find('chat_fallback')
        : registry.find(resp.toolName!);
    _vlog('dispatching tool=${tool?.name ?? "<none>"}');

    final userMessage = (resp.transcript ?? '').trim();
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
        _vlog('tool ${tool.name} done; speakOverride=${result.speakText} '
            'undo=${result.undo != null} silent=${result.silent}');
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

    // 播放：模型直接吐的音频 > mimo TTS > 系统 TTS。
    state = state.copyWith(
      status: VoiceStatus.synthesizing,
      speakText: spokenText,
    );

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
      _fireMemoryExtraction(userMessage, spokenText);
      return;
    }

    if (spokenText.trim().isEmpty) {
      _vlog('empty speak — back to idle');
      state = state.copyWith(status: VoiceStatus.idle);
      return;
    }

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
        _fireMemoryExtraction(userMessage, spokenText);
        return;
      } on MimoTtsException catch (e) {
        _vlog('TTS error code=${e.statusCode} msg=${e.message} — fallback to system TTS');
      } catch (e) {
        _vlog('TTS unexpected: $e — fallback to system TTS');
      }
    }

    _vlog('using system TTS fallback');
    state = state.copyWith(status: VoiceStatus.speaking);
    await _speakWithSystemTts(spokenText);
    state = state.copyWith(status: VoiceStatus.idle);
    _fireMemoryExtraction(userMessage, spokenText);
  }

  /// 把这一轮的「用户原话 + assistant 回复」喂给 MemoryExtractor 异步抽取事实。
  /// fire-and-forget；抽不出就静默落空。跟 chat skill 行为一致。
  ///
  /// 跳过：
  /// - userMessage 太短（< 4 字符，多半是噪音/打断）
  /// - LLM 没配（extractor 是 null）
  void _fireMemoryExtraction(String userMessage, String spokenText) {
    if (userMessage.trim().length < 4) return;
    final extractor = ref.read(memoryExtractorProvider);
    if (extractor == null) return;
    unawaited(() async {
      try {
        final n = await extractor.extractFromTurn(
          userMessage: userMessage,
          assistantMessage: spokenText,
        );
        if (n > 0) _vlog('memory extractor wrote $n pending facts');
      } catch (e) {
        _vlog('memory extractor failed: $e');
      }
    }());
  }

  Future<String> _buildSystemPrompt(PageContext? pageCtx) async {
    try {
      final builder =
          await ref.read(systemPromptBuilderProvider.future);
      return await builder.build(pageContext: pageCtx);
    } catch (e) {
      _vlog('system prompt builder failed: $e — using minimal fallback');
      final registry = ref.read(agentToolRegistryProvider);
      // 兜底 prompt（builder 出错时仍然能跑）
      return '''
你是 good-dad 准爸爸 app 的语音助手。请直接输出 JSON：
{"action":"<工具名>","args":{...},"speak":"<给用户念的回答>","transcript":"<原话>"}

${registry.describeForPrompt()}
''';
    }
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

  String _truncate(String s, int n) =>
      s.length <= n ? s : '${s.substring(0, n)}…';
}

final agentOrchestratorProvider =
    NotifierProvider<AgentOrchestrator, VoiceState>(AgentOrchestrator.new);
