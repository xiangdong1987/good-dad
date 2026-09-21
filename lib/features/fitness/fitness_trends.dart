/// 纯计算：把按日期存的记录聚合成「一天一行」。无任何框架依赖。
///
/// 图表 widget 只负责画，不负责算——与 FitnessMet / FitnessCalc 的分工一致。
library;

/// 聚合输入：一条餐记录里趋势关心的部分。
class DayMeal {
  final String date;
  final int kcal;
  const DayMeal({required this.date, required this.kcal});
}

/// 某一天的汇总。null 表示那天**没记**，而不是记了 0。
class DaySummary {
  final String date;

  /// 当天摄入合计；没记餐则为 null。
  final int? intakeKcal;

  /// 当天记了几餐。
  final int mealCount;

  /// 是否完成训练；那天没有训练记录则为 null
  /// ——「没记」和「记了但没练」是两回事。
  final bool? trainingDone;

  /// 当天体重；没称则为 null。
  final double? weightKg;

  const DaySummary({
    required this.date,
    this.intakeKcal,
    this.mealCount = 0,
    this.trainingDone,
    this.weightKg,
  });
}


/// 体重区间概况。null 表示数据不足以得出该值。
class WeightSummary {
  final double? startKg;
  final double? currentKg;

  /// 净变化 = 末 − 首；只有一个点时为 null。
  final double? deltaKg;

  /// 平均每周变化；跨度为 0 天时为 null（避免除零）。
  final double? weeklyRateKg;

  final int points;

  const WeightSummary({
    this.startKg,
    this.currentKg,
    this.deltaKg,
    this.weeklyRateKg,
    this.points = 0,
  });
}

/// 某天的摄入与当日目标对比。
class IntakeCompare {
  final String date;
  final int kcal;

  /// 那天的热量目标；没有计划则为 null。
  final int? target;

  const IntakeCompare(
      {required this.date, required this.kcal, this.target});

  /// 没超目标算达标；没有目标则不判好坏。
  bool? get onTarget => target == null ? null : kcal <= target!;
}

/// 训练坚持度。
class StreakSummary {
  /// 当前连续天数。
  final int current;

  /// 区间内最长连续天数。
  final int longest;

  /// 当月完成次数。
  final int monthCount;

  const StreakSummary({
    this.current = 0,
    this.longest = 0,
    this.monthCount = 0,
  });
}

class FitnessTrends {
  static const _weekdayZh = ['一', '二', '三', '四', '五', '六', '日'];


  /// 体重区间概况。
  static WeightSummary weightSummary(Map<String, double> weights) {
    if (weights.isEmpty) return const WeightSummary();
    final dates = weights.keys.toList()..sort();
    final start = weights[dates.first]!;
    final current = weights[dates.last]!;
    if (dates.length == 1) {
      return WeightSummary(
          startKg: start, currentKg: current, points: 1);
    }
    final spanDays = DateTime.parse(dates.last)
        .difference(DateTime.parse(dates.first))
        .inDays;
    final delta = current - start;
    return WeightSummary(
      startKg: start,
      currentKg: current,
      deltaKg: delta,
      weeklyRateKg: spanDays == 0 ? null : delta / spanDays * 7,
      points: dates.length,
    );
  }

  /// 每天摄入 vs 当日目标，按日期升序。只列出真吃了的日子。
  static List<IntakeCompare> intakeVsTarget({
    required Map<String, int> intake,
    required Map<String, int> targets,
  }) {
    final dates = intake.keys.toList()..sort();
    return dates
        .map((d) => IntakeCompare(
            date: d, kcal: intake[d]!, target: targets[d]))
        .toList();
  }

  static int onTargetDays(List<IntakeCompare> list) =>
      list.where((e) => e.onTarget == true).length;

  /// 训练坚持度。
  ///
  /// 当前连续：今天练了就从今天数起；今天还没练则从昨天数起——
  /// 白天还没开练就显示 0 只会打击人。
  static StreakSummary trainingStreak(
    Map<String, bool> trainings, {
    required String today,
  }) {
    final done = trainings.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();
    if (done.isEmpty) return const StreakSummary();

    final t = DateTime.parse(today);
    var cursor = done.contains(today) ? t : t.subtract(const Duration(days: 1));
    var current = 0;
    while (done.contains(isoDate(cursor))) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final sorted = done.toList()..sort();
    var longest = 1, run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = DateTime.parse(sorted[i])
          .difference(DateTime.parse(sorted[i - 1]))
          .inDays;
      run = gap == 1 ? run + 1 : 1;
      if (run > longest) longest = run;
    }

    final prefix = today.substring(0, 7); // yyyy-MM
    final monthCount = done.where((d) => d.startsWith(prefix)).length;

    return StreakSummary(
        current: current, longest: longest, monthCount: monthCount);
  }

  /// yyyy-MM-dd。
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// yyyy-MM-dd → 「9月21日 周一」。
  static String dayLabel(String isoDate) {
    final d = DateTime.parse(isoDate);
    return '${d.month}月${d.day}日 周${_weekdayZh[d.weekday - 1]}';
  }

  /// 聚合成按日期倒序的列表（最近的在上）。
  ///
  /// **只列出有任何记录的日子**：90 天里大半是空行只会淹没信息，
  /// 日期出现断档本身就说明那几天没记。
  static List<DaySummary> daySummaries({
    required List<DayMeal> meals,
    required Map<String, bool> trainings,
    required Map<String, double> weights,
  }) {
    final intake = <String, int>{};
    final counts = <String, int>{};
    for (final m in meals) {
      intake[m.date] = (intake[m.date] ?? 0) + m.kcal;
      counts[m.date] = (counts[m.date] ?? 0) + 1;
    }

    final dates = <String>{
      ...intake.keys,
      ...trainings.keys,
      ...weights.keys,
    }.toList()
      ..sort((a, b) => b.compareTo(a));

    return dates
        .map((d) => DaySummary(
              date: d,
              intakeKcal: intake[d],
              mealCount: counts[d] ?? 0,
              trainingDone: trainings[d],
              weightKg: weights[d],
            ))
        .toList();
  }
}
