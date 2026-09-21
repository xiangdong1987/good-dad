import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_trends.dart';
import 'package:good_dad/features/fitness/widgets/day_summary_tile.dart';
import 'package:good_dad/ui/theme.dart';

Future<int> _pump(WidgetTester tester, DaySummary s) async {
  var taps = 0;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: DaySummaryTile(summary: s, onTap: () => taps++),
    ),
  ));
  return taps;
}

void main() {
  testWidgets('一行里给出日期、摄入、训练、体重', (tester) async {
    await _pump(
      tester,
      const DaySummary(
        date: '2026-09-21',
        intakeKcal: 1840,
        mealCount: 3,
        trainingDone: true,
        weightKg: 94.1,
      ),
    );

    expect(find.textContaining('9月21日'), findsOneWidget);
    expect(find.textContaining('1840'), findsOneWidget);
    expect(find.textContaining('94.1'), findsOneWidget);
  });

  testWidgets('那天没记餐显示「—」，不显示 0 大卡', (tester) async {
    await _pump(
      tester,
      const DaySummary(date: '2026-09-21', trainingDone: true),
    );

    expect(find.textContaining('0 大卡'), findsNothing);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('那天没称体重就不显示体重那一栏', (tester) async {
    await _pump(
      tester,
      const DaySummary(date: '2026-09-21', intakeKcal: 1840),
    );

    expect(find.textContaining('kg'), findsNothing);
  });

  testWidgets('训练完成与未完成的标记不同', (tester) async {
    await _pump(tester,
        const DaySummary(date: '2026-09-21', trainingDone: true));
    expect(find.text('已完成'), findsOneWidget);

    await _pump(tester,
        const DaySummary(date: '2026-09-21', trainingDone: false));
    expect(find.text('没练'), findsOneWidget);
  });

  testWidgets('点一下能翻到当天明细', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: DaySummaryTile(
          summary: const DaySummary(date: '2026-09-21', intakeKcal: 1840),
          onTap: () => taps++,
        ),
      ),
    ));

    await tester.tap(find.byType(DaySummaryTile));
    await tester.pump();
    expect(taps, 1);
  });
}
