import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 兜底：模型直接给了 speakText 当做回答。
/// 这个 tool 只是把 speakText 透传过去，让 orchestrator 用 TTS 念。
class ChatFallbackTool extends AgentTool {
  @override
  String get name => 'chat_fallback';

  @override
  String get descriptionZh =>
      '其它意图都用这个：直接给用户口语回答，不调任何工具。';

  @override
  String get argsHint => '不需要参数；speak 字段就是口语回答';

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    // 让 orchestrator 用 AgentResponse.speakText 念。
    return const ToolResult();
  }
}
