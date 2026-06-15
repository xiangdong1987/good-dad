import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 兜底：模型直接给了 speakText 当做回答。
/// 这个 tool 只是把 speakText 透传过去，让 orchestrator 用 TTS 念。
class ChatFallbackTool extends AgentTool {
  @override
  String get name => 'chat_fallback';

  @override
  String get descriptionZh => '兜底：用 speak 字段直接答；不调具体工具';

  @override
  String get argsHint => '';

  @override
  List<ToolExample> get examples => const [
        ToolExample('我现在几周了', {}),
        ToolExample('生鱼片能吃吗', {}),
        ToolExample('宝宝什么时候开始踢肚子', {}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    // 让 orchestrator 用 AgentResponse.speakText 念。
    return const ToolResult();
  }
}
