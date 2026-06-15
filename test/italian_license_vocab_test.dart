import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/memory/memory.dart';
import 'package:good_dad/features/italian_license/italian_license_models.dart';
import 'package:good_dad/features/italian_license/italian_license_vocab.dart';

void main() {
  group('ItalianLicenseVocab.slugify', () {
    test('小写 + 单词级空格变下划线', () {
      expect(ItalianLicenseVocab.slugify('Divieto di sosta'),
          'divieto_di_sosta');
    });

    test('保留重音字母', () {
      expect(ItalianLicenseVocab.slugify('precedenza è'), 'precedenza_è');
    });

    test('多种标点合并成一个下划线', () {
      expect(ItalianLicenseVocab.slugify('andare-via, subito!'),
          'andare_via_subito');
    });

    test('首尾下划线被去掉', () {
      expect(ItalianLicenseVocab.slugify('  ciao  '), 'ciao');
    });
  });

  group('ItalianLicenseVocab.toEntry', () {
    test('生成 reference 类型 + namePrefix + 完整 body', () {
      final v = const LicenseVocab(
        it: 'sorpasso',
        zh: '超车',
        note: 'm. 名词，divieto di sorpasso = 禁止超车',
      );
      final entry = ItalianLicenseVocab.toEntry(v);

      expect(entry.type, MemoryType.reference);
      expect(entry.name, 'vocab.it.sorpasso');
      expect(entry.description, 'sorpasso · 超车');
      expect(entry.body, contains('it: sorpasso'));
      expect(entry.body, contains('zh: 超车'));
      expect(entry.body, contains('source: italian-license'));
    });

    test('description 超长会被截断到 36 字符以内', () {
      final v = const LicenseVocab(
        it: 'una frase molto molto molto molto lunga',
        zh: '一段非常非常非常非常长的话',
        note: '',
      );
      final entry = ItalianLicenseVocab.toEntry(v);
      expect(entry.description.length, lessThanOrEqualTo(36));
    });
  });
}
