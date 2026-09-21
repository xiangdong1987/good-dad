import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_trends.dart';

/// 构造一条餐记录的最小输入。
DayMeal _m(String date, int kcal) => DayMeal(date: date, kcal: kcal);

void main() {
  group('dayLabel', () {
    test('中文月日 + 星期', () {
      // 2026-09-18 是周五（真机截图里系统显示「9月18日星期五」）
      expect(FitnessTrends.dayLabel('2026-09-18'), '9月18日 周五');
      expect(FitnessTrends.dayLabel('2026-09-21'), '9月21日 周一');
    });

    test('周日不写成周七', () {
      expect(FitnessTrends.dayLabel('2026-09-20'), contains('周日'));
    });
  });

  group('daySummaries', () {
    test('按日期倒序，最近的在上', () {
      final list = FitnessTrends.daySummaries(
        meals: [_m('2026-09-19', 700), _m('2026-09-21', 400)],
        trainings: const {},
        weights: const {},
      );
      expect(list.map((d) => d.date), ['2026-09-21', '2026-09-19']);
    });

    test('同一天多餐累加', () {
      final list = FitnessTrends.daySummaries(
        meals: [_m('2026-09-21', 400), _m('2026-09-21', 700)],
        trainings: const {},
        weights: const {},
      );
      expect(list.single.intakeKcal, 1100);
      expect(list.single.mealCount, 2);
    });

    test('完全没记录的日子直接跳过，不生成空行', () {
      final list = FitnessTrends.daySummaries(
        meals: [_m('2026-09-21', 400)],
        trainings: const {},
        weights: const {},
      );
      // 只有 21 号，19、20 号不出现
      expect(list, hasLength(1));
    });

    test('那天没记餐则摄入为 null，而不是 0', () {
      final list = FitnessTrends.daySummaries(
        meals: const [],
        trainings: const {'2026-09-21': true},
        weights: const {},
      );
      expect(list.single.intakeKcal, isNull);
      expect(list.single.trainingDone, isTrue);
    });

    test('那天没有训练记录则为 null，区别于「练了但没完成」', () {
      final list = FitnessTrends.daySummaries(
        meals: [_m('2026-09-21', 400)],
        trainings: const {'2026-09-20': false},
        weights: const {},
      );
      final d21 = list.firstWhere((d) => d.date == '2026-09-21');
      final d20 = list.firstWhere((d) => d.date == '2026-09-20');
      expect(d21.trainingDone, isNull);
      expect(d20.trainingDone, isFalse);
    });

    test('体重并进当天那一行', () {
      final list = FitnessTrends.daySummaries(
        meals: [_m('2026-09-21', 400)],
        trainings: const {},
        weights: const {'2026-09-21': 94.1},
      );
      expect(list.single.weightKg, 94.1);
    });

    test('只称了体重那天也算有记录', () {
      final list = FitnessTrends.daySummaries(
        meals: const [],
        trainings: const {},
        weights: const {'2026-09-21': 94.1},
      );
      expect(list, hasLength(1));
      expect(list.single.intakeKcal, isNull);
    });

    test('全空时返回空列表', () {
      expect(
        FitnessTrends.daySummaries(
            meals: const [], trainings: const {}, weights: const {}),
        isEmpty,
      );
    });

    test('三种记录各占一天时都出现', () {
      final list = FitnessTrends.daySummaries(
        meals: [_m('2026-09-19', 700)],
        trainings: const {'2026-09-20': true},
        weights: const {'2026-09-21': 94.1},
      );
      expect(list.map((d) => d.date),
          ['2026-09-21', '2026-09-20', '2026-09-19']);
    });
  });

  group('weightSummary', () {
    test('给出起止、净变化与平均每周变化', () {
      // 9/07 → 9/21 共 14 天跨度，掉了 1.4kg → 每周 0.7kg
      final w = FitnessTrends.weightSummary(const {
        '2026-09-07': 95.5,
        '2026-09-21': 94.1,
      });
      expect(w.startKg, 95.5);
      expect(w.currentKg, 94.1);
      expect(w.deltaKg, closeTo(-1.4, 0.001));
      expect(w.weeklyRateKg, closeTo(-0.7, 0.001));
      expect(w.points, 2);
    });

    test('只有一个点时算不出变化速率', () {
      final w = FitnessTrends.weightSummary(const {'2026-09-21': 94.1});
      expect(w.currentKg, 94.1);
      expect(w.deltaKg, isNull);
      expect(w.weeklyRateKg, isNull);
    });

    test('一个点都没有时全是 null', () {
      final w = FitnessTrends.weightSummary(const {});
      expect(w.currentKg, isNull);
      expect(w.points, 0);
    });

    test('乱序输入也按日期取首末', () {
      final w = FitnessTrends.weightSummary(const {
        '2026-09-21': 94.1,
        '2026-09-07': 95.5,
        '2026-09-14': 94.8,
      });
      expect(w.startKg, 95.5);
      expect(w.currentKg, 94.1);
      expect(w.points, 3);
    });

    test('同一天两个点不会算出除零', () {
      final w = FitnessTrends.weightSummary(const {'2026-09-21': 94.1});
      expect(w.weeklyRateKg, isNull);
    });
  });

  group('intakeVsTarget', () {
    test('按日期升序给出每天摄入与目标', () {
      final list = FitnessTrends.intakeVsTarget(
        intake: const {'2026-09-21': 1840, '2026-09-20': 2310},
        targets: const {'2026-09-21': 2000, '2026-09-20': 2000},
      );
      expect(list.map((e) => e.date), ['2026-09-20', '2026-09-21']);
      expect(list.last.kcal, 1840);
      expect(list.last.target, 2000);
    });

    test('没超目标算达标，超了不算', () {
      final list = FitnessTrends.intakeVsTarget(
        intake: const {'2026-09-21': 1840, '2026-09-20': 2310},
        targets: const {'2026-09-21': 2000, '2026-09-20': 2000},
      );
      expect(list.firstWhere((e) => e.date == '2026-09-21').onTarget, isTrue);
      expect(list.firstWhere((e) => e.date == '2026-09-20').onTarget, isFalse);
      expect(FitnessTrends.onTargetDays(list), 1);
    });

    test('那天没有目标时不判达标与否', () {
      final list = FitnessTrends.intakeVsTarget(
        intake: const {'2026-09-21': 1840},
        targets: const {},
      );
      expect(list.single.target, isNull);
      expect(list.single.onTarget, isNull);
      expect(FitnessTrends.onTargetDays(list), 0);
    });

    test('只有目标没吃饭的日子不进列表', () {
      final list = FitnessTrends.intakeVsTarget(
        intake: const {},
        targets: const {'2026-09-21': 2000},
      );
      expect(list, isEmpty);
    });
  });

  group('trainingStreak', () {
    test('今天练了就从今天开始数连续天数', () {
      final s = FitnessTrends.trainingStreak(
        const {
          '2026-09-19': true,
          '2026-09-20': true,
          '2026-09-21': true,
        },
        today: '2026-09-21',
      );
      expect(s.current, 3);
      expect(s.longest, 3);
    });

    test('今天还没练时从昨天数起，不让白天显示 0 打击人', () {
      final s = FitnessTrends.trainingStreak(
        const {'2026-09-19': true, '2026-09-20': true},
        today: '2026-09-21',
      );
      expect(s.current, 2);
    });

    test('昨天也没练则连续中断', () {
      final s = FitnessTrends.trainingStreak(
        const {'2026-09-18': true, '2026-09-19': true},
        today: '2026-09-21',
      );
      expect(s.current, 0);
      expect(s.longest, 2);
    });

    test('记了但没完成同样中断连续', () {
      final s = FitnessTrends.trainingStreak(
        const {'2026-09-20': false, '2026-09-21': true},
        today: '2026-09-21',
      );
      expect(s.current, 1);
    });

    test('最长连续取整段范围内的最大值', () {
      final s = FitnessTrends.trainingStreak(
        const {
          '2026-09-01': true,
          '2026-09-02': true,
          '2026-09-03': true,
          '2026-09-04': true,
          '2026-09-20': true,
        },
        today: '2026-09-21',
      );
      expect(s.longest, 4);
      expect(s.current, 1);
    });

    test('本月完成次数只数当月', () {
      final s = FitnessTrends.trainingStreak(
        const {
          '2026-08-31': true,
          '2026-09-01': true,
          '2026-09-20': true,
        },
        today: '2026-09-21',
      );
      expect(s.monthCount, 2);
    });

    test('一次都没练时全为 0', () {
      final s = FitnessTrends.trainingStreak(const {}, today: '2026-09-21');
      expect(s.current, 0);
      expect(s.longest, 0);
      expect(s.monthCount, 0);
    });
  });
}
