import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fitness_calc.dart';
import 'fitness_llm.dart';
import 'fitness_models.dart';
import 'fitness_repository.dart';

/// 调 LLM 生成一天的计划。留成函数而不是直接依赖 [FitnessLlm]，
/// 测试就不必构造整套 LLM 基础设施。
typedef PlanGenerator = Future<TomorrowPlan> Function({
  required FitnessProfile profile,
  required DayTotals totals,
  required bool trainingDone,
});

/// 计划生成的编排：判断该给哪天生成、取前一天的数据、调 LLM、落库。
///
/// 不依赖 BuildContext，所以 App 启动与恢复前台时都能跑——原先这段逻辑
/// 埋在 fitness_page 的 initState 里，不进那一页就永远不生成。
class FitnessPlanService {
  final FitnessRepository repo;

  /// null 表示 LLM 还没配好。
  final PlanGenerator? generate;

  const FitnessPlanService({required this.repo, required this.generate});

  /// 按需生成计划，返回生成的目标日期；没生成则返回 null。
  Future<String?> ensurePlan({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final today = FitnessCalc.isoDate(at);
    final tomorrow = FitnessCalc.isoDate(at.add(const Duration(days: 1)));

    final target = FitnessCalc.planDateToGenerate(
      today: today,
      tomorrow: tomorrow,
      hasPlanForToday: await repo.planForDate(today) != null,
      hasPlanForTomorrow: await repo.planForDate(tomorrow) != null,
      hour: at.hour,
    );
    if (target == null) return null;

    final gen = generate;
    if (gen == null) return null;

    final profile = await repo.loadProfile();
    if (!profile.isComplete) return null;

    final source = FitnessCalc.sourceDateFor(target);
    final meals = await repo.mealsForDate(source);
    final totals = FitnessCalc.sumDay(meals
        .map((m) => MealAnalysis(
            kcal: m.kcal, proteinG: m.proteinG, carbG: m.carbG, fatG: m.fatG))
        .toList());
    final training = await repo.trainingForDate(source);

    try {
      final plan = await gen(
        profile: profile,
        totals: totals,
        trainingDone: training?.done ?? false,
      );
      await repo.savePlan(target, plan);
      return target;
    } catch (_) {
      // 生成失败静默：页面照常展示已有数据，下次打开再试。
      return null;
    }
  }
}

final fitnessPlanServiceProvider = Provider<FitnessPlanService>((ref) {
  final llm = ref.watch(fitnessLlmProvider);
  return FitnessPlanService(
    repo: ref.watch(fitnessRepositoryProvider),
    generate: llm == null
        ? null
        : ({required profile, required totals, required trainingDone}) =>
            llm.generateTomorrowPlan(
              profile: profile,
              totals: totals,
              trainingDone: trainingDone,
            ),
  );
});
