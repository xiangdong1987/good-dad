import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/widgets/weight_card.dart';
import 'package:good_dad/ui/theme.dart';

Future<void> _pump(
  WidgetTester tester, {
  WeightEntry? today,
  WeightEntry? previous,
  Goal goal = Goal.cut,
  VoidCallback? onRecord,
}) =>
    tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: WeightCard(
            today: today,
            previous: previous,
            goal: goal,
            onRecord: onRecord ?? () {},
          ),
        ),
      ),
    ));

void main() {
  testWidgets('今天没称时提示去称，点按钮触发记录', (tester) async {
    var tapped = false;
    await _pump(tester, onRecord: () => tapped = true);

    expect(find.textContaining('今天称了吗'), findsOneWidget);
    await tester.tap(find.text('记一下'));
    expect(tapped, isTrue);
  });

  testWidgets('今天称过就显示体重和与上次的差值', (tester) async {
    await _pump(
      tester,
      today: const WeightEntry(date: '2026-09-18', weightKg: 92.3),
      previous: const WeightEntry(date: '2026-09-11', weightKg: 92.7),
    );

    expect(find.textContaining('92.3'), findsOneWidget);
    expect(find.textContaining('0.4'), findsOneWidget);
    expect(find.textContaining('今天称了吗'), findsNothing);
  });

  testWidgets('第一次称重没有对比基准，不显示差值', (tester) async {
    await _pump(
      tester,
      today: const WeightEntry(date: '2026-09-18', weightKg: 92.3),
      previous: null,
    );

    expect(find.textContaining('92.3'), findsOneWidget);
    expect(find.textContaining('比上次'), findsNothing);
  });

  testWidgets('减脂目标下变轻走 mint、变重走 lemon', (tester) async {
    await _pump(
      tester,
      today: const WeightEntry(date: '2026-09-18', weightKg: 92.3),
      previous: const WeightEntry(date: '2026-09-11', weightKg: 92.7),
      goal: Goal.cut,
    );
    expect(
      tester.widget<Text>(find.textContaining('比上次')).style?.color,
      AppColors.mint700,
    );

    await _pump(
      tester,
      today: const WeightEntry(date: '2026-09-18', weightKg: 93.5),
      previous: const WeightEntry(date: '2026-09-11', weightKg: 92.7),
      goal: Goal.cut,
    );
    expect(
      tester.widget<Text>(find.textContaining('比上次')).style?.color,
      AppColors.lemon500,
    );
  });

  testWidgets('增肌目标下涨秤才是好消息，配色反过来', (tester) async {
    await _pump(
      tester,
      today: const WeightEntry(date: '2026-09-18', weightKg: 93.5),
      previous: const WeightEntry(date: '2026-09-11', weightKg: 92.7),
      goal: Goal.gain,
    );
    expect(
      tester.widget<Text>(find.textContaining('比上次')).style?.color,
      AppColors.mint700,
    );
  });

  testWidgets('体重没变时不判好坏，走中性色', (tester) async {
    await _pump(
      tester,
      today: const WeightEntry(date: '2026-09-18', weightKg: 92.7),
      previous: const WeightEntry(date: '2026-09-11', weightKg: 92.7),
      goal: Goal.cut,
    );
    expect(
      tester.widget<Text>(find.textContaining('和上次一样')).style?.color,
      AppColors.ink600,
    );
  });
}
