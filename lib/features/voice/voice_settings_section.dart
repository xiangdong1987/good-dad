import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/llm_config_provider.dart';
import '../../core/config/voice_config.dart';
import '../../core/config/voice_config_provider.dart';
import '../../core/voice/mimo_tts_client.dart';
import '../../core/voice/voice_providers.dart';

/// 设置页里的「语音」段。
///
/// baseURL / apiKey / 多模态模型都复用「LLM 服务」段的配置（视觉模型 = 多模态模型）；
/// 这里只剩 TTS 特有的两项：声音 id + 语速 + 麦权限测试。
class VoiceSettingsSection extends ConsumerStatefulWidget {
  const VoiceSettingsSection({super.key});

  @override
  ConsumerState<VoiceSettingsSection> createState() =>
      _VoiceSettingsSectionState();
}

class _VoiceSettingsSectionState
    extends ConsumerState<VoiceSettingsSection> {
  final _ttsVoiceIdCtl = TextEditingController();
  double _speed = 1.0;

  bool _hydrated = false;
  bool _busy = false;
  String? _result;
  bool _ok = false;

  @override
  void dispose() {
    _ttsVoiceIdCtl.dispose();
    super.dispose();
  }

  void _hydrate(VoiceConfig cfg) {
    _ttsVoiceIdCtl.text = cfg.ttsVoiceId;
    _speed = cfg.speed;
    _hydrated = true;
  }

  Future<void> _save() async {
    final cfg = VoiceConfig(
      ttsVoiceId: _ttsVoiceIdCtl.text.trim(),
      speed: _speed,
    );
    await ref.read(voiceConfigProvider.notifier).save(cfg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
    }
  }

  Future<void> _previewTts() async {
    setState(() {
      _busy = true;
      _result = null;
    });
    await _save();
    final tts = ref.read(mimoTtsClientProvider);
    if (tts == null) {
      final llm = ref.read(llmConfigProvider).valueOrNull;
      String why;
      if (llm == null || llm.baseUrl.isEmpty || llm.apiKey.isEmpty) {
        why = '先去上面「LLM 服务」段把 baseURL + apiKey 填好';
      } else if (_ttsVoiceIdCtl.text.trim().isEmpty) {
        why = '声音 id 不能为空';
      } else {
        why = '配置不完整';
      }
      setState(() {
        _busy = false;
        _ok = false;
        _result = '❌ $why';
      });
      return;
    }
    try {
      final bytes =
          await tts.synthesize('你好，我是奶油爸爸语音助手，听到我说话了吗？');
      final player = ref.read(audioPlayerProvider);
      await player.playBytes(bytes);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _ok = true;
        _result = '✅ 试听完成（${bytes.length ~/ 1024} KB）';
      });
    } on MimoTtsException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _ok = false;
        _result = '❌ ${e.statusCode ?? ''} ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _ok = false;
        _result = '❌ $e';
      });
    }
  }

  Future<void> _testMicPermission() async {
    final granted =
        await ref.read(micPermissionProvider).ensureGranted();
    if (!mounted) return;
    setState(() {
      _ok = granted;
      _result = granted
          ? '✅ 麦克风权限已授予'
          : '❌ 麦克风权限被拒，去系统设置打开 GoodDad 的麦克风';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfgAsync = ref.watch(voiceConfigProvider);
    return cfgAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('读取语音配置失败: $e'),
      data: (cfg) {
        if (!_hydrated) _hydrate(cfg);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'baseURL / apiKey / 多模态模型 都复用上面「LLM 服务」段的配置（视觉模型 = 多模态模型）。这里只填 TTS 特有的声音 id 和语速。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ttsVoiceIdCtl,
              decoration: const InputDecoration(
                labelText: 'TTS 声音 id',
                hintText: '例如 cream-male / warm-female',
              ),
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 8),
                const Text('语速', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 20,
                    label: _speed.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _speed = v),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(_speed.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('保存'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _previewTts,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up_outlined),
                    label: const Text('试听'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _testMicPermission,
              icon: const Icon(Icons.mic_outlined),
              label: const Text('测试麦克风权限'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _ok
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.errorContainer,
                ),
                child: Text(_result!),
              ),
            ],
          ],
        );
      },
    );
  }
}
