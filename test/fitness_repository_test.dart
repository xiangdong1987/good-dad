import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/storage/database.dart';
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
}
