import '../agent/agent_tool.dart';
import '../agent/page_context_provider.dart';
import '../voice_types.dart';

class ReadItalianQuestionTool extends AgentTool {
  @override
  String get name => 'read_italian_question';

  @override
  String get descriptionZh =>
      '在意大利驾照页念出当前题目（意大利语原文）。仅当 page kind = "italian_license" 时可用。';

  @override
  String get argsHint => '无参数';

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final pc = ctx.ref.read(pageContextProvider);
    if (pc == null || pc.kind != 'italian_license') {
      return const ToolResult(
        speakText: '当前页没有题目可念，先打开意大利驾照页吧',
      );
    }
    final questionIt =
        (pc.payload['questionIt'] ?? '').toString().trim();
    if (questionIt.isEmpty) {
      return const ToolResult(speakText: '当前题目还没出来，等一下再试');
    }
    final options = pc.payload['options'];
    final optionsText =
        (options is List && options.isNotEmpty)
            ? '\n选项：${options.join('；')}'
            : '';
    return ToolResult(
      speakText: '题目是：$questionIt$optionsText',
    );
  }
}
