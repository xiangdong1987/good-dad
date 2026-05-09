/// 语音 agent 的「TTS 部分」配置。
///
/// baseURL / apiKey / 多模态模型 id 都复用 [LlmConfig]（视觉模型即多模态模型）；
/// 这里只剩 TTS 特有的两项：声音 id 和语速。
class VoiceConfig {
  /// TTS 声音 id（如 cream-male / warm-female）。
  final String ttsVoiceId;

  /// TTS 语速 0.5–1.5。
  final double speed;

  const VoiceConfig({
    required this.ttsVoiceId,
    required this.speed,
  });

  static const empty = VoiceConfig(ttsVoiceId: '', speed: 1.0);

  bool get hasTtsVoice => ttsVoiceId.isNotEmpty;

  VoiceConfig copyWith({String? ttsVoiceId, double? speed}) =>
      VoiceConfig(
        ttsVoiceId: ttsVoiceId ?? this.ttsVoiceId,
        speed: speed ?? this.speed,
      );
}
