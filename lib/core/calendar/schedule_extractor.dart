import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_task.dart';
import 'daily_task_repository.dart';

/// 从 chat 助手输出里抠出 schedule_candidates JSON，自动写 daily_tasks。
///
/// 协议（chat SKILL.md 里规定）：
/// 助手回复末尾追加一段 ```json ... ``` 块（或纯 JSON 段），含：
/// {
///   "schedule_candidates": [
///     {"date": "YYYY-MM-DD", "time": "HH:MM" (可选), "title": "...",
///      "kind": "todo|checkup|milestone|note", "notes": "..." (可选)}
///   ]
/// }
class ScheduleExtractor {
  final DailyTaskRepository repo;
  ScheduleExtractor(this.repo);

  /// 解析 + 入库。返回成功写入的 DailyTask 列表。
  Future<List<DailyTask>> extractAndPersist(String assistantMessage) async {
    final candidates = parse(assistantMessage);
    if (candidates.isEmpty) return const [];
    final out = <DailyTask>[];
    for (final c in candidates) {
      try {
        await repo.add(c);
        out.add(c);
      } catch (_) {
        // 单条失败不影响其它
      }
    }
    return out;
  }

  /// 从一段文本里抠出所有 schedule 候选项，纯函数，可单测。
  static List<DailyTask> parse(String raw) {
    final blocks = _extractJsonBlocks(raw);
    final out = <DailyTask>[];
    for (final block in blocks) {
      Map<String, dynamic>? json;
      try {
        final v = jsonDecode(block);
        if (v is Map<String, dynamic>) json = v;
      } catch (_) {}
      if (json == null) continue;

      final list = json['schedule_candidates'];
      if (list is! List) continue;
      for (final item in list) {
        if (item is! Map) continue;
        final dateStr = item['date']?.toString();
        final title = (item['title'] ?? '').toString().trim();
        if (dateStr == null || title.isEmpty) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        // time 可选，存在时把它拼到 title 里方便用户看
        final timeStr = item['time']?.toString();
        final fullTitle = (timeStr == null || timeStr.isEmpty)
            ? title
            : '$title · $timeStr';
        final kind = TaskKind.parse(item['kind']?.toString());
        final notes = item['notes']?.toString();
        out.add(DailyTask(
          title: fullTitle,
          notes: notes,
          forDate: DailyTask.atMidnight(date),
          kind: kind,
        ));
      }
    }
    return out;
  }

  /// 把所有 ```json ... ``` 围栏 + 看起来像 `{ ... }` 的裸块都抠出来。
  static List<String> _extractJsonBlocks(String raw) {
    final blocks = <String>[];

    // 1. fenced ```json ... ```
    final fencedRe = RegExp(
      r'```\s*json\s*\n([\s\S]*?)```',
      caseSensitive: false,
    );
    for (final m in fencedRe.allMatches(raw)) {
      blocks.add(m.group(1)!.trim());
    }

    // 2. 没找到围栏时退化：找最外层 { ... }
    if (blocks.isEmpty) {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        blocks.add(raw.substring(start, end + 1));
      }
    }
    return blocks;
  }
}

final scheduleExtractorProvider = Provider<ScheduleExtractor>((ref) {
  return ScheduleExtractor(ref.watch(dailyTaskRepositoryProvider));
});
