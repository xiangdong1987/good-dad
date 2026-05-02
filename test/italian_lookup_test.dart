import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/italian_license/italian_lookup_runner.dart';

void main() {
  group('ItalianLookupRunner.parseResult', () {
    test('完整 JSON 解析所有字段', () {
      const raw = '''
{
  "word_it": "divieto",
  "word_zh": "禁止；禁令",
  "pos": "m. 名词",
  "examples": [
    {"it": "divieto di sosta", "zh": "禁止停车"},
    {"it": "rispettare il divieto", "zh": "遵守禁令"}
  ],
  "grammar": "通常和 di + 名词搭配",
  "related": ["obbligo (m. 必须)", "vietato (a. 被禁止的)"],
  "not_found": false
}
''';
      final r = ItalianLookupRunner.parseResult(raw);
      expect(r.wordIt, 'divieto');
      expect(r.wordZh, '禁止；禁令');
      expect(r.pos, 'm. 名词');
      expect(r.examples, hasLength(2));
      expect(r.examples.first.it, 'divieto di sosta');
      expect(r.related, hasLength(2));
      expect(r.notFound, false);
    });

    test('被 markdown 围栏包裹也能扣出 JSON', () {
      const raw = '```json\n{"word_it":"sì","word_zh":"是的","pos":"avv.",'
          '"examples":[],"grammar":"","related":[],"not_found":false}\n```';
      final r = ItalianLookupRunner.parseResult(raw);
      expect(r.wordIt, 'sì');
      expect(r.wordZh, '是的');
    });

    test('not_found = true 兜底', () {
      const raw =
          '{"word_it":"","word_zh":"","pos":"","examples":[],"grammar":"没识别出来","related":[],"not_found":true}';
      final r = ItalianLookupRunner.parseResult(raw);
      expect(r.notFound, true);
      expect(r.grammar, '没识别出来');
    });

    test('完全不是 JSON 时返回兜底空结果但保留 raw', () {
      const raw = '抱歉无法回答';
      final r = ItalianLookupRunner.parseResult(raw);
      expect(r.wordIt, '');
      expect(r.notFound, false);
      expect(r.rawText, raw);
    });

    test('toVocab 把 pos + grammar 拼成 note', () {
      const raw = '''
{
  "word_it": "sorpasso",
  "word_zh": "超车",
  "pos": "m. 名词",
  "examples": [],
  "grammar": "divieto di sorpasso = 禁止超车",
  "related": [],
  "not_found": false
}
''';
      final r = ItalianLookupRunner.parseResult(raw);
      final v = r.toVocab();
      expect(v.it, 'sorpasso');
      expect(v.zh, '超车');
      expect(v.note, 'm. 名词 · divieto di sorpasso = 禁止超车');
    });
  });
}
