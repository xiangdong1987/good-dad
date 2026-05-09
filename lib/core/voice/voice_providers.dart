import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/llm_config_provider.dart';
import '../config/voice_config_provider.dart';
import 'audio_player_service.dart';
import 'audio_recorder_service.dart';
import 'mic_permission_service.dart';
import 'mimo_agent_client.dart';
import 'mimo_tts_client.dart';
import 'system_tts_service.dart';

/// 单例：录音服务（持有 record 包的 AudioRecorder）。
final audioRecorderProvider = Provider<AudioRecorderService>((ref) {
  final svc = AudioRecorderService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// 单例：播放服务（持有 just_audio 的 AudioPlayer）。
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final svc = AudioPlayerService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// 单例：麦克风权限服务。
final micPermissionProvider = Provider<MicPermissionService>(
  (ref) => MicPermissionService(),
);

/// 单例：系统 TTS 兜底（mimo TTS 不可用时用）。
final systemTtsProvider = Provider<SystemTtsService>((ref) {
  final svc = SystemTtsService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// xiaomimimo TTS client。baseURL/apiKey 来自 LLM 配置；声音 id/语速来自 voice 配置。
final mimoTtsClientProvider = Provider<MimoTtsClient?>((ref) {
  final llm = ref.watch(llmConfigProvider).valueOrNull;
  final voice = ref.watch(voiceConfigProvider).valueOrNull;
  if (llm == null || voice == null) return null;
  if (llm.baseUrl.isEmpty || llm.apiKey.isEmpty) return null;
  if (voice.ttsVoiceId.isEmpty) return null;
  return MimoTtsClient(
    baseUrl: llm.baseUrl,
    apiKey: llm.apiKey,
    voiceId: voice.ttsVoiceId,
    speed: voice.speed,
  );
});

/// xiaomimimo 多模态音频理解 client。
/// baseURL/apiKey 来自 LLM 配置；模型 id 用 visionModel（视觉 = 多模态）。
/// voiceId 来自 voice 配置；有就启用模型直接吐音频（modalities: text+audio）。
final mimoAgentClientProvider = Provider<MimoAgentClient?>((ref) {
  final llm = ref.watch(llmConfigProvider).valueOrNull;
  final voice = ref.watch(voiceConfigProvider).valueOrNull;
  if (llm == null) return null;
  if (llm.baseUrl.isEmpty || llm.apiKey.isEmpty) return null;
  final model = llm.visionModel.isNotEmpty ? llm.visionModel : llm.chatModel;
  if (model.isEmpty) return null;
  return MimoAgentClient(
    baseUrl: llm.baseUrl,
    apiKey: llm.apiKey,
    model: model,
    voiceId: voice?.ttsVoiceId,
  );
});
