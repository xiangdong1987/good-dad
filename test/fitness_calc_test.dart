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
}
