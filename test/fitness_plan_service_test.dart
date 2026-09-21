import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/storage/database.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/fitness_plan_service.dart';
import 'package:good_dad/features/fitness/fitness_repository.dart';

const _profile = FitnessProfile(
  heightCm: 178,
  weightKg: 92,
  age: 35,
  kettlebellsKg: [16],
);

const _plan = TomorrowPlan(
  trainingPlan: [
    TrainingMove(move: '壶铃摆荡', sets: 5, reps: 15, weightKg: 16),
  ],
  dietGuidance: '多吃点蛋白',
  targets: MacroTargets(kcal: 2100, proteinG: 150, carbG: 240, fatG: 60),
);

void main() {
  late AppDatabase db;
  late FitnessRepository repo;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    repo = FitnessRepository(db);
  });
  tearDown(() => db.close());

  test('今天缺计划时立刻补，不管几点', () async {
    await repo.saveProfile(_profile);
    var calls = 0;
    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async {
        calls++;
        return _plan;
      },
    );

    final target = await svc.ensurePlan(now: DateTime(2026, 9, 21, 8));

    expect(target, '2026-09-21');
    expect(calls, 1);
    expect(await repo.planForDate('2026-09-21'), isNotNull);
  });

  test('补今天的计划要用昨天的实际数据', () async {
    await repo.saveProfile(_profile);
    // 昨天吃了 1800，今天到现在才 300
    await repo.saveMeal(
      date: '2026-09-20',
      meal: Meal.dinner,
      analysis: const MealAnalysis(kcal: 1800, proteinG: 120),
      photoPath: null,
      edited: false,
    );
    await repo.saveMeal(
      date: '2026-09-21',
      meal: Meal.breakfast,
      analysis: const MealAnalysis(kcal: 300, proteinG: 20),
      photoPath: null,
      edited: false,
    );

    DayTotals? seen;
    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async {
        seen = totals;
        return _plan;
      },
    );

    await svc.ensurePlan(now: DateTime(2026, 9, 21, 8));

    expect(seen!.kcal, 1800);
    expect(seen!.proteinG, 120);
  });

  test('今天有计划、过了阈值就备明天的', () async {
    await repo.saveProfile(_profile);
    await repo.savePlan('2026-09-21', _plan);

    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async =>
          _plan,
    );

    expect(
      await svc.ensurePlan(now: DateTime(2026, 9, 21, 21)),
      '2026-09-22',
    );
  });

  test('两天都有计划时不再调 LLM', () async {
    await repo.saveProfile(_profile);
    await repo.savePlan('2026-09-21', _plan);
    await repo.savePlan('2026-09-22', _plan);

    var calls = 0;
    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async {
        calls++;
        return _plan;
      },
    );

    expect(await svc.ensurePlan(now: DateTime(2026, 9, 21, 23)), isNull);
    expect(calls, 0);
  });

  test('资料不全时不生成，也不调 LLM', () async {
    var calls = 0;
    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async {
        calls++;
        return _plan;
      },
    );

    expect(await svc.ensurePlan(now: DateTime(2026, 9, 21, 8)), isNull);
    expect(calls, 0);
  });

  test('LLM 没配好时安静跳过', () async {
    await repo.saveProfile(_profile);
    final svc = FitnessPlanService(repo: repo, generate: null);

    expect(await svc.ensurePlan(now: DateTime(2026, 9, 21, 8)), isNull);
  });

  test('生成失败时吞掉异常，不让页面炸', () async {
    await repo.saveProfile(_profile);
    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async =>
          throw Exception('网络挂了'),
    );

    expect(await svc.ensurePlan(now: DateTime(2026, 9, 21, 8)), isNull);
    expect(await repo.planForDate('2026-09-21'), isNull);
  });

  test('把昨天练没练传给 LLM', () async {
    await repo.saveProfile(_profile);
    await repo.markTrainingDone('2026-09-20', '[]');

    bool? seen;
    final svc = FitnessPlanService(
      repo: repo,
      generate: ({required profile, required totals, required trainingDone}) async {
        seen = trainingDone;
        return _plan;
      },
    );

    await svc.ensurePlan(now: DateTime(2026, 9, 21, 8));
    expect(seen, isTrue);
  });
}
