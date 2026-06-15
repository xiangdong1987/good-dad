import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../agent_config/agent_loader.dart';
import '../agent_config/agent_profile_repository.dart';
import '../config/llm_config_provider.dart';
import '../config/voice_config_provider.dart';
import '../llm/llm_providers.dart';
import '../llm/openai_compatible_client.dart';
import '../llm_log/llm_log_repository.dart';
import '../memory/memory_injector.dart';
import '../profile/profile_repository.dart';
import 'agent/agent_tool_registry.dart';
import 'audio_player_service.dart';
import 'audio_recorder_service.dart';
import 'harness/mimo_reasoner.dart';
import 'harness/openai_reasoner.dart';
import 'harness/reasoner.dart';
import 'harness/system_prompt_builder.dart';
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

/// 实时录音音量 0-1，UI 拿来画波形。非录音时流没事件 → UI 用 0 兜底。
final voiceAmplitudeProvider = StreamProvider<double>((ref) {
  return ref.watch(audioRecorderProvider).amplitudeStream();
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
    path: voice.ttsPath,
    speed: voice.speed,
    logger: ref.watch(llmLogRepositoryProvider),
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
    logger: ref.watch(llmLogRepositoryProvider),
  );
});

/// Voice 路径用 —— 包装 mimo 多模态 client。
final mimoReasonerProvider = Provider<HarnessReasoner?>((ref) {
  final client = ref.watch(mimoAgentClientProvider);
  if (client == null) return null;
  return MimoReasoner(client);
});

/// Text/Image 路径用 —— 包装用户配的 LLM client。
final openAIReasonerProvider = Provider<HarnessReasoner?>((ref) {
  final client = ref.watch(llmClientProvider);
  if (client == null) return null;
  if (client is! OpenAICompatibleClient) return null;
  return OpenAIReasoner(client);
});

/// system prompt 拼装器；orchestrator 每个 turn 调一次。
///
/// 异步装载 AGENT.md + profile.md，订阅 voice_config 这两个 source：
/// 改动会自动重 build provider。
final systemPromptBuilderProvider =
    FutureProvider<SystemPromptBuilder>((ref) async {
  final agentDoc = await ref.watch(agentDocProvider.future);
  final profileText = await ref.watch(agentProfileProvider.future);
  final family = ref.watch(profileProvider).valueOrNull;
  final injector = ref.watch(memoryInjectorProvider);
  final registry = ref.watch(agentToolRegistryProvider);
  return SystemPromptBuilder(
    agentDoc: agentDoc,
    profileText: profileText,
    familyProfile: family,
    memoryInjector: injector,
    registry: registry,
  );
});
