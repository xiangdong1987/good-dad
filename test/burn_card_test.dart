import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_calc.dart';
import 'package:good_dad/features/fitness/fitness_met.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/widgets/burn_card.dart';
import 'package:good_dad/ui/theme.dart';

Future<void> _pump(
  WidgetTester tester, {
  required DayBurn burn,
  double trainingMinutes = 0,
  List<ActivityEntry> activities = const [],
  ValueChanged<int>? onDelete,
}) =>
    tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: BurnCard(
            burn: burn,
            trainingMinutes: trainingMinutes,
            activities: activities,
            onAdd: () {},
            onDelete: onDelete ?? (_) {},
          ),
        ),
      ),
    ));

void main() {
  const burn =
      DayBurn(restingKcal: 1649, trainingKcal: 113, activityKcal: 60);

  testWidgets('三条消耗来源与总计都渲染出来', (tester) async {
    await _pump(tester, burn: burn, trainingMinutes: 15.5);

    expect(find.text('今日消耗'), findsOneWidget);
    expect(find.text('基础代谢'), findsOneWidget);
    expect(find.text('壶铃训练'), findsOneWidget);
    expect(find.text('日常活动'), findsOneWidget);
    // 总计 1822 → 展示取整到 1820
    expect(find.text('1820'), findsOneWidget);
  });

  testWidgets('练过就显示时长，没练显示提示而不是 0 分钟', (tester) async {
    await _pump(tester, burn: burn, trainingMinutes: 15.5);
    expect(find.text('约 16 分钟'), findsOneWidget);

    await _pump(
        tester,
        burn: const DayBurn(restingKcal: 1649),
        trainingMinutes: 0);
    expect(find.text('今天还没练'), findsOneWidget);
  });

  testWidgets('带上诚实对比文案，不让爸爸以为练完能多吃一顿', (tester) async {
    await _pump(tester, burn: burn, trainingMinutes: 15.5);

    expect(
      find.textContaining('差不多 0.8 碗米饭'),
      findsOneWidget,
    );
    expect(find.textContaining('真正决定体重的'), findsOneWidget);
  });

  testWidgets('长按已记的活动触发删除', (tester) async {
    int? deleted;
    await _pump(
      tester,
      burn: burn,
      activities: const [
        ActivityEntry(id: 7, kind: ActivityKind.walk, minutes: 30, kcal: 66),
      ],
      onDelete: (id) => deleted = id,
    );

    expect(find.textContaining('快走 30分'), findsOneWidget);

    // 轻点不能删——误触会把记录弄丢
    await tester.tap(find.textContaining('快走 30分'));
    await tester.pump();
    expect(deleted, isNull);

    await tester.longPress(find.textContaining('快走 30分'));
    expect(deleted, 7);
  });

  testWidgets('没有日常活动时不显示删除提示', (tester) async {
    await _pump(tester, burn: const DayBurn(restingKcal: 1649));
    expect(find.text('长按一条可以删掉'), findsNothing);
    expect(find.text('走路、爬楼、抱娃都算'), findsOneWidget);
  });
}
