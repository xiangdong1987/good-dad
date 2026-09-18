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

  group('bmr 输入校验', () {
    // 真机上出现过 age=402 的脏数据：-5*402 把整个式子压到个位数，
    // 今日消耗卡显示「基础代谢 10 大卡」。
    test('年龄荒谬时回退兜底，不吐出个位数的基础代谢', () {
      const p = FitnessProfile(
        heightCm: 178,
        weightKg: 92,
        age: 402,
        sex: Sex.male,
        kettlebellsKg: [16],
      );
      expect(FitnessCalc.bmr(p), FitnessCalc.fallbackBmr);
    });

    test('年龄过小也回退', () {
      const p = FitnessProfile(
          heightCm: 178, weightKg: 92, age: 3, kettlebellsKg: [16]);
      expect(FitnessCalc.bmr(p), FitnessCalc.fallbackBmr);
    });

    test('身高体重超出人类范围时回退', () {
      const tall = FitnessProfile(
          heightCm: 900, weightKg: 92, age: 35, kettlebellsKg: [16]);
      const heavy = FitnessProfile(
          heightCm: 178, weightKg: 900, age: 35, kettlebellsKg: [16]);
      const light = FitnessProfile(
          heightCm: 178, weightKg: 2, age: 35, kettlebellsKg: [16]);
      expect(FitnessCalc.bmr(tall), FitnessCalc.fallbackBmr);
      expect(FitnessCalc.bmr(heavy), FitnessCalc.fallbackBmr);
      expect(FitnessCalc.bmr(light), FitnessCalc.fallbackBmr);
    });

    test('正常范围内照常按公式算', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        kettlebellsKg: [16],
      );
      expect(FitnessCalc.bmr(p), closeTo(1648.75, 0.01));
    });

    test('边界值算作有效', () {
      const young = FitnessProfile(
          heightCm: 100, weightKg: 30, age: 14, kettlebellsKg: [16]);
      const old = FitnessProfile(
          heightCm: 250, weightKg: 300, age: 100, kettlebellsKg: [16]);
      expect(FitnessCalc.bmr(young), isNot(FitnessCalc.fallbackBmr));
      expect(FitnessCalc.bmr(old), isNot(FitnessCalc.fallbackBmr));
    });

    test('脏数据下热量目标也走安全默认，不给出荒谬目标', () {
      const p = FitnessProfile(
        heightCm: 178,
        weightKg: 92,
        age: 402,
        goal: Goal.cut,
        kettlebellsKg: [16],
      );
      expect(FitnessCalc.defaultTargets(p).kcal, 2000);
    });

    test('今日消耗在脏数据下不会低到离谱', () {
      const p = FitnessProfile(
        heightCm: 178,
        weightKg: 92,
        age: 402,
        kettlebellsKg: [16],
      );
      final burn =
          FitnessCalc.dayBurn(profile: p, trainingKcal: 0, activityKcal: 0);
      expect(burn.restingKcal, greaterThan(1000));
    });
  });

  group('bodyInputError', () {
    test('正常数据没有错误', () {
      expect(
        FitnessCalc.bodyInputError(heightCm: 175, weightKg: 70, age: 30),
        isNull,
      );
    });

    test('年龄越界时指名道姓说是年龄', () {
      final msg =
          FitnessCalc.bodyInputError(heightCm: 175, weightKg: 70, age: 402);
      expect(msg, isNotNull);
      expect(msg, contains('年龄'));
      expect(msg, contains('14'));
      expect(msg, contains('100'));
    });

    test('身高越界时说身高', () {
      final msg =
          FitnessCalc.bodyInputError(heightCm: 17, weightKg: 70, age: 30);
      expect(msg, contains('身高'));
    });

    test('体重越界时说体重', () {
      final msg =
          FitnessCalc.bodyInputError(heightCm: 175, weightKg: 700, age: 30);
      expect(msg, contains('体重'));
    });

    test('没填的字段也拦下来，提示去填', () {
      final msg =
          FitnessCalc.bodyInputError(heightCm: null, weightKg: 70, age: 30);
      expect(msg, contains('身高'));
    });
  });
}
