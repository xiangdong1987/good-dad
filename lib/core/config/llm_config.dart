/// 纯数据类——不依赖 Flutter 或 Riverpod，方便 CLI / test 直接用。
/// Riverpod 包装见 `llm_config_provider.dart`。
class LlmConfig {
  final String baseUrl;
  final String apiKey;
  final String chatModel;
  final String visionModel;

  const LlmConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.chatModel,
    required this.visionModel,
  });

  static const empty = LlmConfig(
    baseUrl: '',
    apiKey: '',
    chatModel: '',
    visionModel: '',
  );

  bool get isComplete =>
      baseUrl.isNotEmpty &&
      apiKey.isNotEmpty &&
      chatModel.isNotEmpty &&
      visionModel.isNotEmpty;

  LlmConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? chatModel,
    String? visionModel,
  }) {
    return LlmConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      chatModel: chatModel ?? this.chatModel,
      visionModel: visionModel ?? this.visionModel,
    );
  }
}
