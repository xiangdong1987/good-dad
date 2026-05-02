import 'italian_license_models.dart';

class LookupExample {
  final String it;
  final String zh;
  const LookupExample({required this.it, required this.zh});

  Map<String, dynamic> toJson() => {'it': it, 'zh': zh};
}

class LookupResult {
  final String wordIt;
  final String wordZh;
  final String pos;
  final List<LookupExample> examples;
  final String grammar;
  final List<String> related;
  final bool notFound;
  final String rawText;

  const LookupResult({
    required this.wordIt,
    required this.wordZh,
    required this.pos,
    required this.examples,
    required this.grammar,
    required this.related,
    required this.notFound,
    required this.rawText,
  });

  /// 把查词结果映射成可保存到单词表的 [LicenseVocab]。
  LicenseVocab toVocab() {
    final note = [
      if (pos.isNotEmpty) pos,
      if (grammar.isNotEmpty) grammar,
    ].join(' · ');
    return LicenseVocab(
      it: wordIt,
      zh: wordZh,
      note: note,
    );
  }

  Map<String, dynamic> toJson() => {
        'word_it': wordIt,
        'word_zh': wordZh,
        'pos': pos,
        'examples': examples.map((e) => e.toJson()).toList(),
        'grammar': grammar,
        'related': related,
        'not_found': notFound,
      };
}
