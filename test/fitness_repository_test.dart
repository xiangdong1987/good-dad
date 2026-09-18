import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/storage/database.dart';
import 'package:good_dad/features/fitness/fitness_met.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/fitness_repository.dart';

void main() {
  late AppDatabase db;
  late FitnessRepository repo;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    repo = FitnessRepository(db);
  });
  tearDown(() => db.close());

  test('profile 单行 upsert：保存后读回一致', () async {
    expect((await repo.loadProfile()).isComplete, isFalse);
    const p = FitnessProfile(
      heightCm: 175,
      weightKg: 70.5,
      age: 30,
      kettlebellsKg: [12, 16],
      goal: Goal.cut,
      injuries: '腰',
    );
    await repo.saveProfile(p);
    final back = await repo.loadProfile();
    expect(back.heightCm, 175);
    expect(back.weightKg, 70.5);
    expect(back.kettlebellsKg, [12, 16]);
    expect(back.goal, Goal.cut);
    expect(back.injuries, '腰');
    expect(back.isComplete, isTrue);

    // 再存一次仍只有一行
    await repo.saveProfile(p.copyWith(age: 31));
    expect((await repo.loadProfile()).age, 31);
  });

  test('meal_log 按日期查询', () async {
    await repo.saveMeal(
      date: '2026-06-16',
      meal: Meal.lunch,
      analysis: const MealAnalysis(kcal: 500, proteinG: 30, carbG: 60, fatG: 15),
      photoPath: null,
      edited: false,
    );
    await repo.saveMeal(
      date: '2026-06-16',
      meal: Meal.dinner,
      analysis: const MealAnalysis(kcal: 300, proteinG: 20, carbG: 40, fatG: 8),
      photoPath: null,
      edited: false,
    );
    await repo.saveMeal(
      date: '2026-06-15',
      meal: Meal.lunch,
      analysis: const MealAnalysis(kcal: 999),
      photoPath: null,
      edited: false,
    );
    final today = await repo.mealsForDate('2026-06-16');
    expect(today.length, 2);
  });

  test('同一天同一餐重拍：替换而非累加', () async {
    await repo.saveMeal(
      date: '2026-06-16',
      meal: Meal.lunch,
      analysis: const MealAnalysis(kcal: 500, proteinG: 30, carbG: 60, fatG: 15),
      photoPath: null,
      edited: false,
    );
    await repo.saveMeal(
      date: '2026-06-16',
      meal: Meal.lunch,
      analysis: const MealAnalysis(kcal: 700, proteinG: 40, carbG: 80, fatG: 20),
      photoPath: null,
      edited: true,
    );
    final lunches = await repo.mealsForDate('2026-06-16');
    expect(lunches.length, 1);
    expect(lunches.single.kcal, 700);
  });

  test('daily_plan 缓存命中', () async {
    expect(await repo.planForDate('2026-06-17'), isNull);
    await repo.savePlan(
      '2026-06-17',
      const TomorrowPlan(
        dietGuidance: '加蛋',
        targets: MacroTargets(kcal: 1900, proteinG: 120, carbG: 190, fatG: 55),
        deficitSummary: '差30g蛋白',
      ),
    );
    final row = await repo.planForDate('2026-06-17');
    expect(row, isNotNull);
    expect(row!.kcalTarget, 1900);
    expect(row.dietGuidance, '加蛋');
  });

  group('activity_log', () {
    test('日常活动按日期追加，同一天多条不互相覆盖', () async {
      await repo.addActivity(
          date: '2026-09-18', kind: ActivityKind.walk, minutes: 30, kcal: 66);
      await repo.addActivity(
          date: '2026-09-18', kind: ActivityKind.stairs, minutes: 5, kcal: 46);

      final list = await repo.activitiesOn('2026-09-18');
      expect(list, hasLength(2));
      expect(list.map((a) => a.kind),
          containsAll([ActivityKind.walk, ActivityKind.stairs]));
      expect(list.fold<int>(0, (sum, a) => sum + a.kcal), 112);
    });

    test('只返回当天的活动', () async {
      await repo.addActivity(
          date: '2026-09-17', kind: ActivityKind.walk, minutes: 30, kcal: 66);
      await repo.addActivity(
          date: '2026-09-18', kind: ActivityKind.bike, minutes: 20, kcal: 142);

      final today = await repo.activitiesOn('2026-09-18');
      expect(today, hasLength(1));
      expect(today.single.kind, ActivityKind.bike);
      expect(today.single.minutes, 20);
    });

    test('删除后不再返回', () async {
      final id = await repo.addActivity(
          date: '2026-09-18', kind: ActivityKind.chores, minutes: 40, kcal: 53);
      expect(await repo.activitiesOn('2026-09-18'), hasLength(1));

      await repo.deleteActivity(id);
      expect(await repo.activitiesOn('2026-09-18'), isEmpty);
    });

    test('没记录的日期返回空列表', () async {
      expect(await repo.activitiesOn('2026-09-18'), isEmpty);
    });
  });

  group('weight_log', () {
    test('同一天重复称重替换旧值，不累加成两条', () async {
      await repo.saveWeight(date: '2026-09-18', weightKg: 92.5);
      await repo.saveWeight(date: '2026-09-18', weightKg: 92.1);

      final list = await repo.weightsBetween('2026-09-01', '2026-09-30');
      expect(list, hasLength(1));
      expect(list.single.weightKg, 92.1);
    });

    test('saveWeight 回写 profile，否则 BMR 还在用旧体重算', () async {
      await repo.saveProfile(const FitnessProfile(
        heightCm: 178,
        weightKg: 95,
        age: 35,
        kettlebellsKg: [16],
      ));
      await repo.saveWeight(date: '2026-09-18', weightKg: 92.1);

      final p = await repo.loadProfile();
      expect(p.weightKg, 92.1);
      // 其余资料不能被冲掉
      expect(p.heightCm, 178);
      expect(p.age, 35);
      expect(p.kettlebellsKg, [16]);
    });

    test('latestWeight 取日期最新的一条，不是插入最新的', () async {
      await repo.saveWeight(date: '2026-09-18', weightKg: 92.1);
      await repo.saveWeight(date: '2026-09-10', weightKg: 94.0);

      final latest = await repo.latestWeight();
      expect(latest!.date, '2026-09-18');
      expect(latest.weightKg, 92.1);
    });

    test('范围查询含两端，按日期升序', () async {
      await repo.saveWeight(date: '2026-09-10', weightKg: 94.0);
      await repo.saveWeight(date: '2026-09-18', weightKg: 92.1);
      await repo.saveWeight(date: '2026-09-25', weightKg: 91.0);

      final list = await repo.weightsBetween('2026-09-10', '2026-09-18');
      expect(list.map((w) => w.date), ['2026-09-10', '2026-09-18']);
    });

    test('没有记录时 latestWeight 为 null，范围查询为空', () async {
      expect(await repo.latestWeight(), isNull);
      expect(await repo.weightsBetween('2026-09-01', '2026-09-30'), isEmpty);
    });
  });
}
