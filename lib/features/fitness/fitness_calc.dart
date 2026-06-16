import 'fitness_models.dart';

/// 纯计算：热量/宏量目标、当日合计、是否该生成明日计划。无任何框架依赖。
class FitnessCalc {
  /// 生成时间阈值（小时）：到了晚上这个点才在 App 内现场生成明日计划。
  static const generateAfterHour = 21;

  /// Mifflin-St Jeor 估 BMR → 活动系数 1.375（轻度活动）→ 按目标增减。
  /// 资料不全则回退安全默认。
  static MacroTargets defaultTargets(FitnessProfile p) {
    final h = p.heightCm, w = p.weightKg, a = p.age;
    if (h == null || w == null || a == null) {
      return const MacroTargets(
          kcal: 2000, proteinG: 100, carbG: 220, fatG: 65);
    }
    final s = p.sex == Sex.male ? 5 : -161;
    final bmr = 10 * w + 6.25 * h - 5 * a + s;
    final tdee = bmr * 1.375;
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
}
