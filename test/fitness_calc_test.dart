import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_calc.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';

void main() {
  group('defaultTargets (Mifflin-St Jeor)', () {
    test('男性减脂目标低于维持热量，蛋白按体重 1.6g/kg', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        goal: Goal.cut,
        kettlebellsKg: [16],
      );
      final t = FitnessCalc.defaultTargets(p);
      // BMR = 10*70 + 6.25*175 - 5*30 + 5 = 1648.75; TDEE = *1.375 = 2267; cut -400
      expect(t.kcal, 1867);
      expect(t.proteinG, 112); // 70 * 1.6
      expect(t.kcal, lessThan(2267));
    });

    test('资料不全时回退到安全默认 2000 kcal', () {
      final t = FitnessCalc.defaultTargets(FitnessProfile.empty);
      expect(t.kcal, 2000);
    });
  });

  group('sumDay', () {
    test('累加多餐的热量与宏量', () {
      const a = MealAnalysis(kcal: 500, proteinG: 30, carbG: 60, fatG: 15);
      const b = MealAnalysis(kcal: 300, proteinG: 20, carbG: 40, fatG: 8);
      final total = FitnessCalc.sumDay([a, b]);
      expect(total.kcal, 800);
      expect(total.proteinG, 50);
      expect(total.carbG, 100);
      expect(total.fatG, 23);
    });

    test('空列表得到全 0', () {
      final total = FitnessCalc.sumDay([]);
      expect(total.kcal, 0);
    });
  });

  group('needsPlanGeneration', () {
    test('明日已有缓存计划则不需要再生成', () {
      expect(
        FitnessCalc.needsPlanGeneration(
            hasPlanForTomorrow: true, hour: 22),
        isFalse,
      );
    });

    test('晚上 21 点后且无缓存则需要生成', () {
      expect(
        FitnessCalc.needsPlanGeneration(
            hasPlanForTomorrow: false, hour: 21),
        isTrue,
      );
    });

    test('白天无缓存也不主动生成（等晚上）', () {
      expect(
        FitnessCalc.needsPlanGeneration(
            hasPlanForTomorrow: false, hour: 10),
        isFalse,
      );
    });
  });

  group('bmr', () {
    test('Mifflin-St Jeor 男性公式，不含活动系数', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        kettlebellsKg: [16],
      );
      // 10*70 + 6.25*175 - 5*30 + 5 = 1648.75
      expect(FitnessCalc.bmr(p), closeTo(1648.75, 0.01));
    });

    test('女性公式常数项为 -161', () {
      const male = FitnessProfile(
          heightCm: 170, weightKg: 60, age: 30, sex: Sex.male);
      const female = FitnessProfile(
          heightCm: 170, weightKg: 60, age: 30, sex: Sex.female);
      expect(FitnessCalc.bmr(male) - FitnessCalc.bmr(female), closeTo(166, 0.01));
    });

    test('资料不全时回退到安全默认值', () {
      expect(FitnessCalc.bmr(FitnessProfile.empty), FitnessCalc.fallbackBmr);
    });
  });

  group('dayBurn', () {
    test('今日消耗 = 全天基础代谢 + 训练 + 日常活动', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        kettlebellsKg: [16],
      );
      final burn = FitnessCalc.dayBurn(
        profile: p,
        trainingKcal: 113,
        activityKcal: 60,
      );
      expect(burn.restingKcal, 1649); // BMR 取整
      expect(burn.trainingKcal, 113);
      expect(burn.activityKcal, 60);
      expect(burn.total, 1649 + 113 + 60);
    });

    test('没练也没活动时只剩基础代谢', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        kettlebellsKg: [16],
      );
      final burn =
          FitnessCalc.dayBurn(profile: p, trainingKcal: 0, activityKcal: 0);
      expect(burn.trainingKcal, 0);
      expect(burn.total, burn.restingKcal);
    });

    test('主动消耗只算训练与日常，不含基础代谢', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        kettlebellsKg: [16],
      );
      final burn = FitnessCalc.dayBurn(
        profile: p,
        trainingKcal: 113,
        activityKcal: 60,
      );
      expect(burn.activeKcal, 173);
    });
  });

  group('burnCompareText', () {
    test('把主动消耗换算成米饭碗数，让数字有体感', () {
      // 173 / 230 ≈ 0.8 碗
      expect(FitnessCalc.burnCompareText(173), contains('0.8 碗米饭'));
      expect(FitnessCalc.burnCompareText(173), contains('170 大卡'));
    });

    test('没动的时候给鼓励而不是 0 大卡', () {
      final text = FitnessCalc.burnCompareText(0);
      expect(text, isNot(contains('0 大卡')));
      expect(text, contains('还没动'));
    });

    test('文案最多一个感叹号', () {
      for (final kcal in [0, 50, 173, 600]) {
        expect('!'.allMatches(FitnessCalc.burnCompareText(kcal)).length,
            lessThanOrEqualTo(1));
        expect('！'.allMatches(FitnessCalc.burnCompareText(kcal)).length,
            lessThanOrEqualTo(1));
      }
    });
  });
}
