import '../../core/memory/memory.dart';
import 'italian_license_models.dart';

/// 把意大利语词汇映射为可写入 memory 表的 `MemoryEntry`。
///
/// 约定：
/// - 名称槽（slug）= `vocab.it.<sanitized>`，全局通过 `vocab.it.%` like 查询
/// - 类型 = [MemoryType.reference]（单词本质是参考资料，不是家人画像/偏好）
/// - description = `<it> · <zh>`，截到 36 字符内（UI 列表里显示一行）
/// - body = 结构化多行文本，方便后续 LLM 学习时直接读
class ItalianLicenseVocab {
  static const String namePrefix = 'vocab.it.';
  static const String namePattern = '$namePrefix%';

  /// 把意大利语原词转为 slug：小写 + 非字母数字（含重音字母）替换为 `_`。
  static String slugify(String raw) {
    final lower = raw.toLowerCase().trim();
    final replaced = lower.replaceAll(
      RegExp(r'[^\p{L}\p{N}]+', unicode: true),
      '_',
    );
    return replaced.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String slugFor(LicenseVocab v) => '$namePrefix${slugify(v.it)}';

  static MemoryEntry toEntry(LicenseVocab v, {String source = 'italian-license'}) {
    final desc = _truncate('${v.it} · ${v.zh}', 36);
    final body = [
      'it: ${v.it}',
      if (v.zh.isNotEmpty) 'zh: ${v.zh}',
      if (v.note.isNotEmpty) 'note: ${v.note}',
      'source: $source',
    ].join('\n');

    return MemoryEntry(
      type: MemoryType.reference,
      name: slugFor(v),
      description: desc,
      body: body,
    );
  }

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';
}
