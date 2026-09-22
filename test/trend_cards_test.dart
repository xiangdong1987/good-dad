import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/widgets/intake_trend_card.dart';
import 'package:good_dad/features/fitness/widgets/training_streak_card.dart';
import 'package:good_dad/features/fitness/widgets/weight_trend_card.dart';
import 'package:good_dad/ui/theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  group('WeightTrendCard', () {
    testWidgets('三天以上才画图，并给出当前体重与每周变化', (tester) async {
      await _pump(
        tester,
        const WeightTrendCard(
          weights: {
            '2026-09-07': 95.5,
            '2026-09-14': 94.8,
            '2026-09-21': 94.1,
          },
          goal: Goal.cut,
        ),
      );

      expect(find.textContaining('94.1'), findsWidgets);
      expect(find.textContaining('每周'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('不足三天不画图，给出还差几天的提示', (tester) async {
      await _pump(
        tester,
        const WeightTrendCard(
          weights: {'2026-09-21': 94.1},
          goal: Goal.cut,
        ),
      );

      expect(find.textContaining('再记'), findsOneWidget);
      expect(find.textContaining('每周'), findsNothing);
    });

    testWidgets('一次没称过也不是空白，而是引导去称', (tester) async {
      await _pump(
        tester,
        const WeightTrendCard(weights: {}, goal: Goal.cut),
      );
      expect(find.textContaining('再记'), findsOneWidget);
    });
  });

  group('IntakeTrendCard', () {
    testWidgets('三天以上画柱状图并给出达标天数', (tester) async {
      await _pump(
        tester,
        const IntakeTrendCard(
          intake: {
            '2026-09-19': 1900,
            '2026-09-20': 2310,
            '2026-09-21': 1840,
          },
          targets: {
            '2026-09-19': 2000,
            '2026-09-20': 2000,
            '2026-09-21': 2000,
          },
        ),
      );

      // 3 天里 2 天达标
      expect(find.textContaining('2'), findsWidgets);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('不足三天不画图', (tester) async {
      await _pump(
        tester,
        const IntakeTrendCard(
          intake: {'2026-09-21': 1840},
          targets: {'2026-09-21': 2000},
        ),
      );
      expect(find.textContaining('再记'), findsOneWidget);
    });
  });

  group('TrainingStreakCard', () {
    testWidgets('给出当前连续、最长连续与本月次数', (tester) async {
      await _pump(
        tester,
        const TrainingStreakCard(
          trainings: {
            '2026-09-19': true,
            '2026-09-20': true,
            '2026-09-21': true,
          },
          today: '2026-09-21',
          days: 30,
        ),
      );

      expect(find.textContaining('连续'), findsWidgets);
      expect(find.textContaining('本月'), findsOneWidget);
    });

    testWidgets('方格数量等于所选跨度天数', (tester) async {
      await _pump(
        tester,
        const TrainingStreakCard(
          trainings: {'2026-09-21': true},
          today: '2026-09-21',
          days: 7,
        ),
      );

      expect(
        find.byKey(const ValueKey('streak-cells')),
        findsOneWidget,
      );
      final wrap =
          tester.widget<Wrap>(find.byKey(const ValueKey('streak-cells')));
      expect(wrap.children, hasLength(7));
    });

    testWidgets('一次都没练时给引导而不是空方格阵', (tester) async {
      await _pump(
        tester,
        const TrainingStreakCard(
          trainings: {},
          today: '2026-09-21',
          days: 30,
        ),
      );
      expect(find.textContaining('练一次'), findsOneWidget);
    });
  });
}
