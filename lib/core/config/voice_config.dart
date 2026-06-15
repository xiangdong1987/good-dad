/// 语音 agent 的「TTS 部分」配置。
///
/// baseURL / apiKey / 多模态模型 id 都复用 [LlmConfig]（视觉模型即多模态模型）；
/// 这里只剩 TTS 特有的字段：endpoint 路径、声音 id、语速。
class VoiceConfig {
  /// TTS HTTP 路径（拼到 LLM baseURL 后面）。
  /// 默认走 OpenAI 兼容 `/v1/audio/speech`；xiaomimimo 实际路径可能不同
  /// （如 `/v1/tts` / `/v2.5/audio/speech` / `/openapi/tts`），按厂商文档改。
  final String ttsPath;

  /// TTS 声音 id（如 cream-male / warm-female）。
  final String ttsVoiceId;

  /// TTS 语速 0.5–1.5。
  final double speed;

  const VoiceConfig({
    required this.ttsPath,
    required this.ttsVoiceId,
    required this.speed,
  });

  static const defaultTtsPath = '/v1/audio/speech';

  static const empty = VoiceConfig(
    ttsPath: defaultTtsPath,
    ttsVoiceId: '',
    speed: 1.0,
  );

  bool get hasTtsVoice => ttsVoiceId.isNotEmpty;

  VoiceConfig copyWith({String? ttsPath, String? ttsVoiceId, double? speed}) =>
      VoiceConfig(
        ttsPath: ttsPath ?? this.ttsPath,
        ttsVoiceId: ttsVoiceId ?? this.ttsVoiceId,
        speed: speed ?? this.speed,
      );
}
