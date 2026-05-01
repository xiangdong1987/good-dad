/// 单户家庭画像：爸爸 + 妈妈 + 当前孕周（推算自 dueDate）。
class FamilyProfile {
  final String? dadName;
  final String? momName;
  final DateTime? dueDate;

  const FamilyProfile({this.dadName, this.momName, this.dueDate});

  static const empty = FamilyProfile();

  bool get isComplete =>
      (dadName?.trim().isNotEmpty ?? false) &&
      (momName?.trim().isNotEmpty ?? false) &&
      dueDate != null;

  /// 当前孕周（向下取整）。无预产期时返回 null。
  int? currentWeek({DateTime? now}) {
    if (dueDate == null) return null;
    final today = now ?? DateTime.now();
    final lmp = dueDate!.subtract(const Duration(days: 280));
    final days = today.difference(lmp).inDays;
    if (days < 0) return 0;
    final w = (days / 7).floor();
    return w > 42 ? 42 : w;
  }

  /// 当前孕周里的「第几天」（0-6）。
  int? currentDayInWeek({DateTime? now}) {
    if (dueDate == null) return null;
    final today = now ?? DateTime.now();
    final lmp = dueDate!.subtract(const Duration(days: 280));
    final days = today.difference(lmp).inDays;
    if (days < 0) return 0;
    return days % 7;
  }

  /// 距离预产期还有多少周（向下取整）。
  int? weeksToDue({DateTime? now}) {
    final w = currentWeek(now: now);
    if (w == null) return null;
    return (40 - w).clamp(0, 40);
  }

  /// 由「当前 X 周 Y 天」反推 dueDate。
  ///
  /// 推算路径：
  /// - LMP = today - (week*7 + dayInWeek)
  /// - dueDate = LMP + 280 天
  ///
  /// 这样无论用户填的是「24 周」还是「24 周 3 天」，
  /// 后续 [currentWeek] / [currentDayInWeek] 都能精确每天推进。
  static DateTime dueDateFromCurrentWeek(
    int week, {
    int dayInWeek = 0,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final clampedDay = dayInWeek.clamp(0, 6);
    final daysSinceLmp = week * 7 + clampedDay;
    final lmp = today.subtract(Duration(days: daysSinceLmp));
    return lmp.add(const Duration(days: 280));
  }
}
