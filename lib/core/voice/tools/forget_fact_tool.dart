import '../../memory/memory_repository.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 「忘掉花生过敏那条」「把驾照单词的记忆删了」之类的语音命令。
///
/// 模糊匹配 `MemoryEntry.name` 或 `description`，命中第一条就软删（status 设 deleted
/// 不存在的话直接 delete）。撤销 SnackBar 让爸爸反悔时能恢复。
class ForgetFactTool extends AgentTool {
  @override
  String get name => 'forget_fact';

  @override
  String get descriptionZh => '从记忆库删一条事实（按关键词模糊匹配）';

  @override
  String get argsHint => 'match:string(关键词或 name 模式，例 partner.allergies、花生)';

  @override
  bool get writes => true;

  @override
  List<ToolExample> get examples => const [
        ToolExample('把花生过敏那条忘了', {'match': '花生'}),
        ToolExample('删掉关于夜班的记忆', {'match': 'shift'}),
        ToolExample('忘记妈妈过敏', {'match': 'partner.allergies'}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final match = (args['match'] ?? '').toString().trim();
    if (match.isEmpty) {
      return const ToolResult(speakText: '没听清要忘哪一条');
    }

    final repo = ctx.ref.read(memoryRepositoryProvider);
    // 先按 name 通配匹配（partner.* 这种）
    final byName = await repo.findActiveLikeNames(['%$match%']);
    var hit = byName.isNotEmpty ? byName.first : null;
    if (hit == null) {
      // 没命中 name，再用 body 关键词扫一次。MemoryRepository 没现成的
      // body 模糊查询；这里降级用 watchAll 一次性拉 active 列表（数量有限）。
      try {
        final all = await repo.watchAll().first;
        for (final e in all) {
          if (e.body.contains(match) || e.description.contains(match)) {
            hit = e;
            break;
          }
        }
      } catch (_) {}
    }

    if (hit == null || hit.id == null) {
      return ToolResult(speakText: '没找到跟"$match"相关的记忆');
    }

    final id = hit.id!;
    final desc = hit.description.isEmpty ? hit.name : hit.description;
    final hitForUndo = hit;
    await repo.delete(id);

    return ToolResult(
      speakText: '好的，已经把"$desc"忘掉了',
      undo: UndoSnack(
        label: '已忘记 · 撤销',
        // delete 后 id 不能复活；我们恢复为同名 pending 让用户在 /memory 页 confirm 回来。
        undo: () => repo.upsert(hitForUndo.copyWith(id: null)),
      ),
    );
  }
}
