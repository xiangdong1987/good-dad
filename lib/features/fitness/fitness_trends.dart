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

class FitnessTrends {
  static const _weekdayZh = ['一', '二', '三', '四', '五', '六', '日'];

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
