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

  /// 由「当前孕周」反推 dueDate（用户输入孕周时用）。
  static DateTime dueDateFromCurrentWeek(int week, {DateTime? now}) {
    final today = now ?? DateTime.now();
    // 把 today 视为孕第 `week` 周第 0 天，预产期 = today + (40-week)*7
    final remainingDays = (40 - week) * 7;
    return today.add(Duration(days: remainingDays));
  }
}
