import '../../agent_config/agent_profile_repository.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 让爸爸用语音「调教」助手个性 —— 追加一条偏好到 profile.md。
///
/// 例：
/// - "以后回答都短点" → 追加 `- 回答尽量短`
/// - "记住别叫我大宝叫老张" → 追加 `- 别叫大宝，叫老张`
/// - "讲解时多举例子" → 追加 `- 讲解时多举例子`
///
/// 写到 `getApplicationSupportDirectory()/agent/profile.md`，
/// 跟设置页「Agent 个性」编辑器是同一份文件，下一句对话立即生效。
///
/// 区别于一次性请求："这次回答短点"（一次性 → 不调）vs "以后回答都短点"（长期 → 调）。
class UpdatePersonaTool extends AgentTool {
  @override
  String get name => 'update_persona';

  @override
  String get descriptionZh =>
      '调教助手长期个性 / 风格 / 称呼。仅在爸爸明示"以后/总是/记住下次/调整你"等长期意图时调，一次性请求不调';

  @override
  String get argsHint =>
      'note:string(要追加的偏好，简短一句)、'
      'mode?:add|remove (默认 add；remove 时 note 是要删的关键词)';

  @override
  bool get writes => true;

  @override
  List<ToolExample> get examples => const [
        ToolExample('以后回答都短点', {'note': '回答尽量短', 'mode': 'add'}),
        ToolExample('记住别叫我大宝叫老张', {'note': '别叫大宝，叫老张', 'mode': 'add'}),
        ToolExample('我喜欢你讲解时多举例子', {'note': '讲解时多举例子', 'mode': 'add'}),
        ToolExample('忘了那条短回答的偏好', {'note': '短', 'mode': 'remove'}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final note = (args['note'] ?? '').toString().trim();
    final mode = (args['mode'] ?? 'add').toString().trim().toLowerCase();

    if (note.isEmpty) {
      return const ToolResult(speakText: '没听清要怎么调，能再说一遍吗');
    }

    final controller = ctx.ref.read(agentProfileProvider.notifier);

    if (mode == 'remove') {
      final removed = await controller.removeLine(note);
      if (removed == null) {
        return ToolResult(speakText: '没找到跟"$note"相关的偏好');
      }
      final cleanRemoved = removed.replaceFirst(RegExp(r'^[\s-]*'), '');
      return ToolResult(
        speakText: '好的，把"$cleanRemoved"那条忘了',
        undo: UndoSnack(
          label: '已忘 · 撤销',
          undo: () => controller.appendLine(cleanRemoved),
        ),
      );
    }

    // add (default)
    await controller.appendLine(note);
    return ToolResult(
      speakText: '好的，记下这个偏好：$note',
      undo: UndoSnack(
        label: '已加 · 撤销',
        undo: () => controller.removeLine(note),
      ),
    );
  }
}
