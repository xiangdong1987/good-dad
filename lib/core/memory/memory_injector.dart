import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../skill/skill.dart';
import 'memory.dart';
import 'memory_repository.dart';

/// 把活跃记忆按 skill 的 `context.memory_keys` 过滤后拼成 markdown 块，
/// SkillRunner 在生成 system prompt 时会调用这里，把结果作为「## 记忆」段插入。
class MemoryInjector {
  final MemoryRepository repo;
  MemoryInjector(this.repo);

  /// 返回一段可直接拼到 system prompt 末尾的字符串。
  /// 没有命中时返回 null（调用方判空跳过）。
  Future<String?> buildBlock(Skill skill) async {
    final keysRaw = skill.frontmatter['context'] is Map
        ? (skill.frontmatter['context'] as Map)['memory_keys']
        : null;
    if (keysRaw is! List) return null;

    final patterns = <String>[];
    final exact = <String>[];
    for (final k in keysRaw) {
      final s = k.toString();
      if (s.contains('*') || s.contains('%')) {
        patterns.add(s.replaceAll('*', '%'));
      } else {
        exact.add(s);
      }
    }

    final List<MemoryEntry> entries = [
      ...await repo.findActiveByNames(exact),
      ...await repo.findActiveLikeNames(patterns),
    ];
    if (entries.isEmpty) return null;

    final topkRaw = (skill.frontmatter['context'] as Map?)?['memory_topk'];
    final topk = topkRaw is num ? topkRaw.toInt() : 8;

    // 去重 + 截断 top-K
    final seen = <int>{};
    final picked = <MemoryEntry>[];
    for (final e in entries) {
      if (e.id != null && seen.add(e.id!)) {
        picked.add(e);
        if (picked.length >= topk) break;
      }
    }
    if (picked.isEmpty) return null;

    final sb = StringBuffer('## 记忆（之前的对话或设置里得到的事实，请基于此回答）\n');
    for (final e in picked) {
      sb.writeln('- **${e.name}**: ${e.body.trim()}');
    }
    return sb.toString().trimRight();
  }
}

final memoryInjectorProvider = Provider<MemoryInjector>(
    (ref) => MemoryInjector(ref.watch(memoryRepositoryProvider)));
