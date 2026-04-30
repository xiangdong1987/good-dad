import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/core/skill/skill_output.dart';

void main() {
  group('SkillOutputParser.parseChecklist', () {
    test('多分组 + 勾选/未勾选都识别', () {
      const md = '''
## 妈妈用
- [x] 产褥垫
- [ ] 哺乳文胸 × 2

## 宝宝用
- [ ] 包巾 × 2
- [X] 纸尿裤
''';
      final secs = SkillOutputParser.parseChecklist(md);
      expect(secs.length, 2);
      expect(secs[0].title, '妈妈用');
      expect(secs[0].items.length, 2);
      expect(secs[0].items[0].checked, true);
      expect(secs[0].items[0].text, '产褥垫');
      expect(secs[0].items[1].checked, false);
      expect(secs[1].title, '宝宝用');
      expect(secs[1].items[1].checked, true);
    });

    test('没有标题时也能解析为单段', () {
      const md = '- [ ] 一项\n- [x] 另一项';
      final secs = SkillOutputParser.parseChecklist(md);
      expect(secs.length, 1);
      expect(secs[0].title, '清单');
      expect(secs[0].items.length, 2);
    });
  });

  group('SkillOutputParser.parseJson', () {
    test('正常 JSON 解析', () {
      final m = SkillOutputParser.parseJson('{"a":1,"b":"x"}');
      expect(m, isNotNull);
      expect(m!['a'], 1);
    });

    test('被 markdown 围栏包住也能抠出来', () {
      const raw = '看一下：\n```json\n{"verdict":"safe"}\n```\n done';
      final m = SkillOutputParser.parseJson(raw);
      expect(m?['verdict'], 'safe');
    });

    test('完全不是 JSON 时返回 null', () {
      expect(SkillOutputParser.parseJson('hello world'), isNull);
    });
  });
}
