import 'dart:convert';

import 'skill.dart';

/// SkillRunner 的统一返回值。
///
/// 不同 outputFormat 下，调用方关心的字段不同：
/// - plain      → 用 [rawText]
/// - structured → 用 [structuredJson]（解析失败时 fallback 给 rawText）
/// - checklist  → 用 [checklistSections]
class SkillRunResult {
  final Skill skill;
  final String rawText;
  final Map<String, dynamic>? structuredJson;
  final List<ChecklistSection>? checklistSections;
  final int latencyMs;
  final int? skillRunId;
  final int? promptTokens;
  final int? completionTokens;

  const SkillRunResult({
    required this.skill,
    required this.rawText,
    this.structuredJson,
    this.checklistSections,
    required this.latencyMs,
    this.skillRunId,
    this.promptTokens,
    this.completionTokens,
  });
}

class ChecklistSection {
  final String title;
  final List<ChecklistEntry> items;
  const ChecklistSection({required this.title, required this.items});
}

class ChecklistEntry {
  final String text;
  final bool checked;
  const ChecklistEntry({required this.text, this.checked = false});
}

/// 解析工具：根据 skill.outputFormat 把 LLM 原文转成结构化数据。
class SkillOutputParser {
  /// 宽容 JSON 解析：直解 → 抠 `{...}` → 失败返回 null。
  static Map<String, dynamic>? parseJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start >= 0 && end > start) {
      try {
        final decoded = jsonDecode(raw.substring(start, end + 1));
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  /// 解析 markdown checklist：
  /// ```
  /// ## 妈妈用
  /// - [ ] 哺乳文胸 × 2
  /// - [x] 产褥垫
  /// ```
  static List<ChecklistSection> parseChecklist(String raw) {
    final lines = raw.split(RegExp(r'\r?\n'));
    final sections = <ChecklistSection>[];
    String? currentTitle;
    var currentItems = <ChecklistEntry>[];

    void flush() {
      final t = currentTitle;
      if (t != null && currentItems.isNotEmpty) {
        sections.add(
          ChecklistSection(title: t, items: currentItems),
        );
        currentItems = [];
      }
    }

    final headingRe = RegExp(r'^\s*#{2,3}\s+(.+?)\s*$');
    final itemRe = RegExp(r'^\s*[-*]\s*\[(?<chk>[ xX])\]\s*(?<text>.+?)\s*$');

    for (final line in lines) {
      final h = headingRe.firstMatch(line);
      if (h != null) {
        flush();
        currentTitle = h.group(1);
        continue;
      }
      final m = itemRe.firstMatch(line);
      if (m != null) {
        currentItems.add(ChecklistEntry(
          text: m.namedGroup('text') ?? '',
          checked: (m.namedGroup('chk') ?? ' ').toLowerCase() == 'x',
        ));
      }
    }
    flush();

    // 没有标题但有 items：放到「未命名」段
    if (sections.isEmpty && currentItems.isNotEmpty) {
      sections.add(ChecklistSection(title: '清单', items: currentItems));
    }
    return sections;
  }
}
