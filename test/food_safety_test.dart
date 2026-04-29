import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/features/food_safety/food_safety_models.dart';
import 'package:good_dad/features/food_safety/food_safety_runner.dart';

void main() {
  group('FoodSafetyRunner.parseModelOutput', () {
    test('纯 JSON 直接解析', () {
      final r = FoodSafetyRunner.parseModelOutput('''
{
  "verdict": "avoid",
  "name": "螃蟹",
  "reason": "性偏寒，孕期不建议",
  "dos": [],
  "donts": ["生食", "蟹黄"],
  "alternatives": ["三文鱼", "鳕鱼"]
}
''');
      expect(r.verdict, FoodVerdict.avoid);
      expect(r.name, '螃蟹');
      expect(r.donts.length, 2);
      expect(r.alternatives, ['三文鱼', '鳕鱼']);
    });

    test('被 markdown 围栏包裹仍能抠出 JSON', () {
      const raw = '''
好的：

```json
{"verdict":"safe","name":"牛油果","reason":"营养丰富","dos":["每天半个"],"donts":[],"alternatives":[]}
```
''';
      final r = FoodSafetyRunner.parseModelOutput(raw);
      expect(r.verdict, FoodVerdict.safe);
      expect(r.name, '牛油果');
      expect(r.dos, ['每天半个']);
    });

    test('完全不是 JSON 则返回 unknown 但保留原文', () {
      const raw = '抱歉我看不出这是什么';
      final r = FoodSafetyRunner.parseModelOutput(raw);
      expect(r.verdict, FoodVerdict.unknown);
      expect(r.rawText, raw);
    });

    test('verdict 字段大小写/空格容错', () {
      final r = FoodSafetyRunner.parseModelOutput(
          '{"verdict":" CAUTION ","name":"咖啡","reason":"<200mg/d","dos":[],"donts":[],"alternatives":[]}');
      expect(r.verdict, FoodVerdict.caution);
    });
  });
}
