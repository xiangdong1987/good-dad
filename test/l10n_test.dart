import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/core/i18n/app_locale.dart';
import 'package:good_dad/core/i18n/l10n.dart';

void main() {
  group('L10n.t', () {
    test('已知 key 命中当前 locale', () {
      final en = L10n(AppLocale.en);
      expect(en.t('common.save'), 'Save');
    });

    test('当前 locale 缺 key 时回退到 zh-CN', () {
      // ja 字典里没有 'common.error'，应该用中文
      final ja = L10n(AppLocale.ja);
      expect(ja.t('common.error'), '出错了');
    });

    test('完全不存在的 key 返回 key 本身', () {
      final zh = L10n(AppLocale.zhCN);
      expect(zh.t('nope.does_not_exist'), 'nope.does_not_exist');
    });

    test('支持参数插值 {name}', () {
      final zh = L10n(AppLocale.zhCN);
      expect(zh.t('home.greeting', {'name': '老周'}), '嘿，老周');
      final en = L10n(AppLocale.en);
      expect(en.t('home.greeting', {'name': 'James'}), 'Hi, James');
    });
  });

  group('AppLocale.parse', () {
    test('已知 code', () {
      expect(AppLocale.parse('en'), AppLocale.en);
      expect(AppLocale.parse('zh-TW'), AppLocale.zhTW);
    });
    test('未知 / null 兜底中文', () {
      expect(AppLocale.parse(null), AppLocale.zhCN);
      expect(AppLocale.parse(''), AppLocale.zhCN);
      expect(AppLocale.parse('weird'), AppLocale.zhCN);
    });
  });
}
