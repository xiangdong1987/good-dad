import 'fitness_met.dart';
import 'fitness_models.dart';

/// 纯计算：热量/宏量目标、当日合计、是否该生成明日计划。无任何框架依赖。
class FitnessCalc {
  /// 生成时间阈值（小时）：到了晚上这个点才在 App 内现场生成明日计划。
  static const generateAfterHour = 21;

  /// 资料不全时的 BMR 兜底（≈ 默认目标 2000 kcal / 1.375）。
  static const fallbackBmr = 1450.0;

  /// 资料不全时估消耗用的体重兜底。
  static const fallbackWeightKg = 70.0;

  /// Mifflin-St Jeor 基础代谢，不含活动系数。资料不全则回退安全默认。
  static double bmr(FitnessProfile p) {
    final h = p.heightCm, w = p.weightKg, a = p.age;
    if (h == null || w == null || a == null) return fallbackBmr;
    final s = p.sex == Sex.male ? 5 : -161;
    return 10 * w + 6.25 * h - 5 * a + s;
  }

  /// BMR → 活动系数 1.375（轻度活动）→ 按目标增减。
  /// 资料不全则回退安全默认。
  static MacroTargets defaultTargets(FitnessProfile p) {
    final w = p.weightKg;
    if (p.heightCm == null || w == null || p.age == null) {
      return const MacroTargets(
          kcal: 2000, proteinG: 100, carbG: 220, fatG: 65);
    }
    final tdee = bmr(p) * 1.375;
    final kcal = switch (p.goal) {
      Goal.cut => tdee - 400,
      Goal.gain => tdee + 300,
      Goal.maintain => tdee,
    };
    final protein = (w * 1.6).round();
    final fat = (kcal * 0.25 / 9).round();
    final carb = ((kcal - protein * 4 - fat * 9) / 4).round();
    return MacroTargets(
      kcal: kcal.round(),
      proteinG: protein,
      carbG: carb < 0 ? 0 : carb,
      fatG: fat,
    );
  }

  static DayTotals sumDay(List<MealAnalysis> meals) {
    var kcal = 0, p = 0, c = 0, f = 0;
    for (final m in meals) {
      kcal += m.kcal;
      p += m.proteinG;
      c += m.carbG;
      f += m.fatG;
    }
    return DayTotals(kcal: kcal, proteinG: p, carbG: c, fatG: f);
  }

  /// 进入页面时是否该现场生成明日计划：晚上阈值后且尚无缓存。
  static bool needsPlanGeneration({
    required bool hasPlanForTomorrow,
    required int hour,
  }) =>
      !hasPlanForTomorrow && hour >= generateAfterHour;

  /// 今日消耗拆解：全天基础代谢 + 训练 + 日常活动。
  ///
  /// 只用于展示。热量目标仍走 [defaultTargets] 的 TDEE（含 1.375 活动系数），
  /// 把训练消耗再加进目标会与活动系数重复计算。
  static DayBurn dayBurn({
    required FitnessProfile profile,
    required int trainingKcal,
    required int activityKcal,
  }) =>
      DayBurn(
        restingKcal: bmr(profile).round(),
        trainingKcal: trainingKcal,
        activityKcal: activityKcal,
      );
  /// 一碗米饭约 230 大卡——把消耗换算成爸爸有体感的单位。
  static const kcalPerRiceBowl = 230;

  /// 主动消耗的诚实对比文案。
  ///
  /// 训练消耗占 TDEE 的比例很小，说清楚比让爸爸误以为"练完能多吃一顿"要好。
  static String burnCompareText(int activeKcal) {
    if (activeKcal <= 0) return '今天还没动 —— 走两步、抱抱娃都算数';
    final bowls = (activeKcal / kcalPerRiceBowl).toStringAsFixed(1);
    final shown = FitnessMet.displayKcal(activeKcal);
    return '今天动出来约 $shown 大卡，差不多 $bowls 碗米饭';
  }

}

/// 一天的消耗拆解。
class DayBurn {
  /// 全天基础代谢。
  final int restingKcal;

  /// 训练净消耗。
  final int trainingKcal;

  /// 日常活动净消耗。
  final int activityKcal;

  const DayBurn({
    this.restingKcal = 0,
    this.trainingKcal = 0,
    this.activityKcal = 0,
  });

  /// 主动消耗：爸爸今天靠动换来的部分。
  int get activeKcal => trainingKcal + activityKcal;

  int get total => restingKcal + activeKcal;
}
