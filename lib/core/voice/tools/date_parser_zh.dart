/// 中文相对/绝对日期解析。给 voice agent 工具用。
///
/// 接受：
/// - 'today' / 'tomorrow' / 'yesterday'
/// - '今天' / '明天' / '后天' / '大后天' / '昨天' / '前天'
/// - '下周一'…'下周日' / '周一'…'周日'
/// - 'YYYY-MM-DD' / 'YYYY/MM/DD' / 'M月D日' / 'M/D'
///
/// 解析失败返回 [now] 当天零点。
DateTime parseChineseDate(String input, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final raw = input.trim();
  if (raw.isEmpty) return today;
  final lower = raw.toLowerCase();

  // 简单关键词
  switch (lower) {
    case 'today':
    case '今天':
    case '今日':
      return today;
    case 'tomorrow':
    case '明天':
    case '明日':
      return today.add(const Duration(days: 1));
    case 'yesterday':
    case '昨天':
      return today.subtract(const Duration(days: 1));
    case '后天':
      return today.add(const Duration(days: 2));
    case '大后天':
      return today.add(const Duration(days: 3));
    case '前天':
      return today.subtract(const Duration(days: 2));
  }

  // ISO 格式 YYYY-MM-DD / YYYY/MM/DD
  final iso = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$');
  final mIso = iso.firstMatch(raw);
  if (mIso != null) {
    final y = int.parse(mIso.group(1)!);
    final m = int.parse(mIso.group(2)!);
    final d = int.parse(mIso.group(3)!);
    return DateTime(y, m, d);
  }

  // M月D日 / M月D号
  final cn = RegExp(r'^(\d{1,2})月(\d{1,2})[日号]?$');
  final mCn = cn.firstMatch(raw);
  if (mCn != null) {
    final m = int.parse(mCn.group(1)!);
    final d = int.parse(mCn.group(2)!);
    var y = n.year;
    final candidate = DateTime(y, m, d);
    // 已过期且差距大于 30 天，理解为下一年
    if (candidate.isBefore(today.subtract(const Duration(days: 30)))) {
      y += 1;
    }
    return DateTime(y, m, d);
  }

  // M/D（不带年份）
  final md = RegExp(r'^(\d{1,2})/(\d{1,2})$');
  final mMd = md.firstMatch(raw);
  if (mMd != null) {
    final m = int.parse(mMd.group(1)!);
    final d = int.parse(mMd.group(2)!);
    return DateTime(n.year, m, d);
  }

  // 周一/下周一
  final weekday = _parseWeekday(raw);
  if (weekday != null) {
    final isNextWeek = raw.contains('下');
    var diff = weekday - n.weekday;
    if (diff <= 0) diff += 7;
    if (isNextWeek && diff < 7) diff += 7;
    return today.add(Duration(days: diff));
  }

  return today;
}

int? _parseWeekday(String s) {
  if (s.contains('周一') || s.contains('星期一')) return DateTime.monday;
  if (s.contains('周二') || s.contains('星期二')) return DateTime.tuesday;
  if (s.contains('周三') || s.contains('星期三')) return DateTime.wednesday;
  if (s.contains('周四') || s.contains('星期四')) return DateTime.thursday;
  if (s.contains('周五') || s.contains('星期五')) return DateTime.friday;
  if (s.contains('周六') || s.contains('星期六')) return DateTime.saturday;
  if (s.contains('周日') || s.contains('星期日') || s.contains('星期天')) {
    return DateTime.sunday;
  }
  return null;
}

/// 把 DateTime 转成「5月9日」这种短中文日期，给口播用。
String formatChineseShort(DateTime d) => '${d.month}月${d.day}日';
