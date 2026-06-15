import '../../memory/memory.dart';
import '../../memory/memory_repository.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 「记住我对花生过敏」「记得妈妈喜欢吃素」之类的语音命令。
///
/// 写到 `MemoryRepository`，默认 `pending` 状态 —— 进 `/memory` 页面 confirm
/// 才生效到 system prompt 里。这跟 chat skill 的记忆候选行为一致，避免
/// 误识别污染长期记忆。
class RememberFactTool extends AgentTool {
  @override
  String get name => 'remember_fact';

  @override
  String get descriptionZh => '把爸爸/妈妈/宝宝相关的长期事实写进记忆库（默认待确认）';

  @override
  String get argsHint =>
      'name:string(短标识，如 partner.allergies、self.shift)、'
      'description:string(≤20 字标题)、'
      'body:string(详细内容)、'
      'category?:partner|self|baby|preference';

  @override
  bool get writes => true;

  @override
  List<ToolExample> get examples => const [
        ToolExample('记住妈妈对花生过敏', {
          'name': 'partner.allergies',
          'description': '妈妈过敏源',
          'body': '花生',
          'category': 'partner',
        }),
        ToolExample('我夜班上 12 小时，记一下', {
          'name': 'self.shift',
          'description': '爸爸夜班',
          'body': '夜班 12 小时',
          'category': 'self',
        }),
        ToolExample('宝宝预产期是 2026 年 8 月 15 号', {
          'name': 'baby.due_date',
          'description': '宝宝预产期',
          'body': '2026-08-15',
          'category': 'baby',
        }),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final name = (args['name'] ?? '').toString().trim();
    final desc = (args['description'] ?? '').toString().trim();
    final body = (args['body'] ?? '').toString().trim();
    final category = (args['category'] ?? '').toString().trim();

    if (name.isEmpty || body.isEmpty) {
      return const ToolResult(speakText: '没听清要记什么，再说一遍？');
    }

    // 自动归类到 MemoryType：
    // partner/self/baby → user（家人画像）
    // preference → feedback（我的偏好）
    // 其它 → user
    final type = switch (category) {
      'preference' => MemoryType.feedback,
      _ => MemoryType.user,
    };

    final entry = MemoryEntry(
      type: type,
      name: name,
      description: desc.isEmpty ? body.split('\n').first : desc,
      body: body,
      status: MemoryStatus.pending, // 等用户在 /memory 页 confirm
    );

    final repo = ctx.ref.read(memoryRepositoryProvider);
    final id = await repo.upsert(entry);

    return ToolResult(
      speakText: '好的，记下了：${desc.isEmpty ? body : desc}',
      undo: UndoSnack(
        label: '已记下 · 撤销',
        undo: () => repo.delete(id),
      ),
    );
  }
}
