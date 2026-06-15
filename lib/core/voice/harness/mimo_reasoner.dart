import '../mimo_agent_client.dart';
import '../voice_types.dart';
import 'harness_input.dart';
import 'reasoner.dart';

/// 包装 [MimoAgentClient] —— 只吃 [VoiceHarnessInput]（audio）。
///
/// 文字模式的输入交给 [OpenAIReasoner]，省 mimo 的额度也避免双路逻辑漂移。
class MimoReasoner implements HarnessReasoner {
  final MimoAgentClient client;

  const MimoReasoner(this.client);

  @override
  String get name => 'mimo';

  @override
  bool canHandle(HarnessInput input) => input is VoiceHarnessInput;

  @override
  Future<AgentResponse> reason({
    required HarnessInput input,
    required String systemPrompt,
    PageContext? pageContext,
  }) async {
    if (input is! VoiceHarnessInput) {
      throw ReasonerException('MimoReasoner cannot handle ${input.runtimeType}');
    }
    try {
      return await client.understand(
        audio: input.audio,
        systemPrompt: systemPrompt,
        pageContext: pageContext,
      );
    } on MimoAgentException catch (e) {
      throw ReasonerException(
        e.message,
        statusCode: e.statusCode,
        cause: e,
      );
    }
  }
}
