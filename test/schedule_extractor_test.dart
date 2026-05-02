import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/core/calendar/daily_task.dart';
import 'package:good_dad/core/calendar/schedule_extractor.dart';

void main() {
  group('ScheduleExtractor.parse', () {
    test('围栏 JSON 提取一条产检', () {
      const raw = '''
好的，已经记下来了：

```json
{"schedule_candidates":[{"date":"2026-05-07","time":"09:00","title":"产检","kind":"checkup","notes":"陪老婆"}]}
```
''';
      final list = ScheduleExtractor.parse(raw);
      expect(list.length, 1);
      expect(list[0].title, '产检 · 09:00');
      expect(list[0].kind, TaskKind.checkup);
      expect(list[0].forDate, DateTime(2026, 5, 7));
      expect(list[0].notes, '陪老婆');
    });

    test('裸 JSON（无围栏）也能提', () {
      const raw =
          '记好啦。{"schedule_candidates":[{"date":"2026-05-10","title":"买叶酸","kind":"todo"}]}';
      final list = ScheduleExtractor.parse(raw);
      expect(list.length, 1);
      expect(list[0].title, '买叶酸');
      expect(list[0].kind, TaskKind.todo);
    });

    test('多条一起提', () {
      const raw = '''
```json
{"schedule_candidates":[
  {"date":"2026-05-07","time":"09:00","title":"产检","kind":"checkup"},
  {"date":"2026-05-08","title":"买待产包","kind":"todo"}
]}
```
''';
      final list = ScheduleExtractor.parse(raw);
      expect(list.length, 2);
      expect(list[0].kind, TaskKind.checkup);
      expect(list[1].kind, TaskKind.todo);
    });

    test('没 schedule_candidates 字段返回空', () {
      const raw = '今天天气不错';
      expect(ScheduleExtractor.parse(raw), isEmpty);
    });

    test('date 解析失败的项被丢弃', () {
      const raw =
          '{"schedule_candidates":[{"date":"明天","title":"产检"},{"date":"2026-05-07","title":"复查"}]}';
      final list = ScheduleExtractor.parse(raw);
      expect(list.length, 1);
      expect(list[0].title, '复查');
    });

    test('date + 没 time 时 title 不带分隔符', () {
      const raw =
          '{"schedule_candidates":[{"date":"2026-05-07","title":"产检","kind":"checkup"}]}';
      final list = ScheduleExtractor.parse(raw);
      expect(list[0].title, '产检');
    });
  });
}
