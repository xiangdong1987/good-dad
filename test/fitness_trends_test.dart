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
}
