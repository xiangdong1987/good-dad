import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/voice/tools/date_parser_zh.dart';

void main() {
  // 锚定一个固定的 "now" 让测试可重复：2026-05-09（周六，weekday=6）
  final now = DateTime(2026, 5, 9);

  group('parseChineseDate', () {
    test('今天 / today / 空字符串', () {
      expect(parseChineseDate('今天', now: now), DateTime(2026, 5, 9));
      expect(parseChineseDate('today', now: now), DateTime(2026, 5, 9));
      expect(parseChineseDate('', now: now), DateTime(2026, 5, 9));
    });

    test('明天 / tomorrow', () {
      expect(parseChineseDate('明天', now: now), DateTime(2026, 5, 10));
      expect(parseChineseDate('tomorrow', now: now),
          DateTime(2026, 5, 10));
    });

    test('后天 / 大后天', () {
      expect(parseChineseDate('后天', now: now), DateTime(2026, 5, 11));
      expect(parseChineseDate('大后天', now: now), DateTime(2026, 5, 12));
    });

    test('昨天 / 前天', () {
      expect(parseChineseDate('昨天', now: now), DateTime(2026, 5, 8));
      expect(parseChineseDate('前天', now: now), DateTime(2026, 5, 7));
    });

    test('ISO YYYY-MM-DD / YYYY/MM/DD', () {
      expect(parseChineseDate('2026-12-31', now: now),
          DateTime(2026, 12, 31));
      expect(parseChineseDate('2026/06/01', now: now),
          DateTime(2026, 6, 1));
    });

    test('M月D日 / M月D号', () {
      expect(parseChineseDate('5月10日', now: now), DateTime(2026, 5, 10));
      expect(parseChineseDate('12月25号', now: now),
          DateTime(2026, 12, 25));
    });

    test('M月D日 早于今天 30 天以上视为下一年', () {
      // now = 2026-05-09，1月 1 日已过期 > 30 天，应跳到 2027
      expect(parseChineseDate('1月1日', now: now), DateTime(2027, 1, 1));
    });

    test('M/D 不带年份，按当年解析', () {
      expect(parseChineseDate('6/15', now: now), DateTime(2026, 6, 15));
    });

    test('周一 — 取下一个周一（now=周六）', () {
      // now = 周六，下一个周一 = 5/11
      expect(parseChineseDate('周一', now: now), DateTime(2026, 5, 11));
    });

    test('下周一 — 跳一周', () {
      // 周六 → 下下周一 = 5/18
      expect(parseChineseDate('下周一', now: now), DateTime(2026, 5, 18));
    });

    test('星期日 = 周日', () {
      // now = 周六，下一个周日 = 5/10
      expect(parseChineseDate('星期日', now: now), DateTime(2026, 5, 10));
      expect(parseChineseDate('星期天', now: now), DateTime(2026, 5, 10));
    });

    test('无法识别 → 兜底今天', () {
      expect(parseChineseDate('啊嗯哦', now: now), DateTime(2026, 5, 9));
    });
  });

  group('formatChineseShort', () {
    test('5月9日格式', () {
      expect(formatChineseShort(DateTime(2026, 5, 9)), '5月9日');
      expect(formatChineseShort(DateTime(2026, 12, 25)), '12月25日');
    });
  });
}
