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

  /// 身体数据的合理范围。超出就当脏数据，不拿去算。
  static const minHeightCm = 100, maxHeightCm = 250;
  static const minWeightKg = 30.0, maxWeightKg = 300.0;
  static const minAge = 14, maxAge = 100;

  /// 身高体重年龄是否都齐全且在人类范围内。
  ///
  /// 表单历史上没做范围校验，库里可能存着 age=402 这种值：
  /// -5*402 会把 Mifflin-St Jeor 压成个位数，基础代谢显示成 10 大卡。
  static bool hasPlausibleBody(FitnessProfile p) {
    final h = p.heightCm, w = p.weightKg, a = p.age;
    if (h == null || w == null || a == null) return false;
    return h >= minHeightCm &&
        h <= maxHeightCm &&
        w >= minWeightKg &&
        w <= maxWeightKg &&
        a >= minAge &&
        a <= maxAge;
  }

  /// 92.0 显示成 92，92.3 保留一位。
  static String weightText(double kg) => _trim(kg);

  /// 与上次的差值文案。没变化时不说数字。
  static String weightDeltaLabel(double deltaKg) {
    if (deltaKg == 0) return '和上次一样';
    final sign = deltaKg < 0 ? '−' : '+';
    return '比上次 $sign${_trim(deltaKg.abs())} kg';
  }

  /// 变化是否朝着目标走。没变化或目标是保持时返回 null（不判好坏）。
  static bool? isFavorableWeightChange({
    required double deltaKg,
    required Goal goal,
  }) {
    if (deltaKg == 0 || goal == Goal.maintain) return null;
    return goal == Goal.cut ? deltaKg < 0 : deltaKg > 0;
  }

  /// 单日体重跳变阈值：超过就让用户二次确认。
  static const maxWeightSwingKg = 5.0;

  /// 体重与上次相差过大时的二次确认文案；正常波动返回 null。
  ///
  /// 范围校验（[minWeightKg]–[maxWeightKg]）拦不住「92 打成 9.2」这类错，
  /// 跳变检测能。
  static String? weightSwingWarning({
    required double newKg,
    required double? lastKg,
  }) {
    if (lastKg == null) return null;
    final diff = newKg - lastKg;
    if (diff.abs() <= maxWeightSwingKg) return null;
    final verb = diff < 0 ? '少了' : '多了';
    return '确定是 ${_trim(newKg)} kg 吗，比上次$verb ${_trim(diff.abs())} kg';
  }

  /// 92.0 显示成 92，92.3 保留一位。
  static String _trim(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  /// 单独校验体重，返回问题文案；合理则返回 null。
  static String? weightInputError(double? weightKg) =>
      (weightKg == null || weightKg < minWeightKg || weightKg > maxWeightKg)
          ? '体重填 ${minWeightKg.round()}–${maxWeightKg.round()} kg 之间'
          : null;

  /// 保存前校验身体数据，返回第一条问题文案；都合理则返回 null。
  ///
  /// 指名道姓说是哪个字段不对，别让爸爸自己猜。
  static String? bodyInputError({
    required int? heightCm,
    required double? weightKg,
    required int? age,
  }) {
    if (heightCm == null || heightCm < minHeightCm || heightCm > maxHeightCm) {
      return '身高填 $minHeightCm–$maxHeightCm cm 之间';
    }
    final weightErr = weightInputError(weightKg);
    if (weightErr != null) return weightErr;
    if (age == null || age < minAge || age > maxAge) {
      return '年龄填 $minAge–$maxAge 之间';
    }
    return null;
  }

  /// Mifflin-St Jeor 基础代谢，不含活动系数。
  /// 资料不全或超出人类范围则回退安全默认。
  static double bmr(FitnessProfile p) {
    if (!hasPlausibleBody(p)) return fallbackBmr;
    final s = p.sex == Sex.male ? 5 : -161;
    return 10 * p.weightKg! + 6.25 * p.heightCm! - 5 * p.age! + s;
  }

  /// BMR → 活动系数 1.375（轻度活动）→ 按目标增减。
  /// 资料不全则回退安全默认。
  static MacroTargets defaultTargets(FitnessProfile p) {
    if (!hasPlausibleBody(p)) {
      return const MacroTargets(
          kcal: 2000, proteinG: 100, carbG: 220, fatG: 65);
    }
    final w = p.weightKg!;
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
