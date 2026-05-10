import '../agent/agent_tool.dart';
import '../agent/page_context_provider.dart';
import '../voice_types.dart';

class ExplainItalianQuestionTool extends AgentTool {
  @override
  String get name => 'explain_italian_question';

  @override
  String get descriptionZh => '讲解当前意大利驾照题目（中文）';

  @override
  String get argsHint => '';

  @override
  String? get requiresPageKind => 'italian_license';

  @override
  List<ToolExample> get examples => const [
        ToolExample('为什么选 B', {}),
        ToolExample('讲一下这道', {}),
        ToolExample('解释下', {}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final pc = ctx.ref.read(pageContextProvider);
    if (pc == null || pc.kind != 'italian_license') {
      return const ToolResult(
        speakText: '当前页没有题目可讲解，先打开意大利驾照页吧',
      );
    }
    final answer = (pc.payload['answer'] ?? '').toString().trim();
    final explanation =
        (pc.payload['explanationZh'] ?? '').toString().trim();
    if (explanation.isEmpty) {
      return const ToolResult(speakText: '当前题目还没生成讲解');
    }
    final speak = answer.isEmpty
        ? explanation
        : '答案是 $answer。$explanation';
    return ToolResult(speakText: speak);
  }
}
