import '../voice_types.dart';
import 'harness_input.dart';

/// 推理器抽象。
///
/// 负责「编 input → 编 LLM 请求 → 调 LLM → 解 response → 出 [AgentResponse]」。
/// 不参与 tool 执行 / 状态机 / TTS 播放 —— 这些都是 orchestrator 的事。
///
/// 两个具体实现：
/// - [MimoReasoner]：吃 [VoiceHarnessInput]（audio bytes），调小米多模态接口
/// - [OpenAIReasoner]：吃 [TextHarnessInput]（text + 可选 image），调用户配的 LLM
abstract class HarnessReasoner {
  /// 名字，用于 debug 日志。
  String get name;

  /// 是否能处理这个 input。
  bool canHandle(HarnessInput input);

  /// 推理一轮。
  Future<AgentResponse> reason({
    required HarnessInput input,
    required String systemPrompt,
    PageContext? pageContext,
  });
}

class ReasonerException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;
  const ReasonerException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'ReasonerException: $message';
}
