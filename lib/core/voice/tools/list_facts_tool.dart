import '../../memory/memory.dart';
import '../../memory/memory_repository.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 「你都记住了我什么」「我之前告诉过你哪些事」之类的语音命令。
///
/// 读最近 N 条 active 记忆，按 type 简短分组，让 TTS 能一两句念完。
/// 不展开每条 body，因为 TTS 念全部太冗长 —— 想看详情让爸爸去 `/memory`。
class ListFactsTool extends AgentTool {
  static const _maxItems = 6;

  @override
  String get name => 'list_facts';

  @override
  String get descriptionZh => '念最近记住的事实清单（一两句概览，详情让爸爸去 /memory 页看）';

  @override
  String get argsHint => '';

  @override
  List<ToolExample> get examples => const [
        ToolExample('你都记住了我什么', {}),
        ToolExample('我之前告诉过你哪些事', {}),
        ToolExample('记忆里有啥', {}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final repo = ctx.ref.read(memoryRepositoryProvider);
    List<MemoryEntry> all;
    try {
      all = await repo.watchAll(status: MemoryStatus.active).first;
    } catch (_) {
      return const ToolResult(speakText: '记忆库现在读不出来');
    }
    if (all.isEmpty) {
      return const ToolResult(speakText: '现在还没记住什么，要不要现在告诉我点啥？');
    }

    final picked = all.take(_maxItems).toList();
    final descs = picked
        .map((e) => e.description.isEmpty ? e.name : e.description)
        .toList();

    final more = all.length > _maxItems ? '，还有 ${all.length - _maxItems} 条' : '';
    final speak = '记得这些：${descs.join('，')}$more。详情可以去记忆页看';

    return ToolResult(speakText: speak);
  }
}
