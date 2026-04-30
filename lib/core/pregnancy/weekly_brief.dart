/// 每周孕期简报：从 pregnancy-week skill 跑出来的结构化结果。
///
/// schema（与 SKILL.md 对齐）：
/// - week: int
/// - baby_size: string         （宝宝大致大小，类比，如「像玉米」）
/// - baby_dev: string          （发育要点）
/// - mom_changes: string       （孕妈身体变化）
/// - nutrition: string[]
/// - todos: string[]
/// - warnings: string[]
/// - husband_can_do: string[]
class WeeklyBrief {
  final int? id;
  final int week;
  final String rawText;
  final WeeklyBriefData? data;
  final DateTime? generatedAt;

  const WeeklyBrief({
    this.id,
    required this.week,
    required this.rawText,
    this.data,
    this.generatedAt,
  });
}

class WeeklyBriefData {
  final int week;
  final String babySize;
  final String babyDev;
  final String momChanges;
  final List<String> nutrition;
  final List<String> todos;
  final List<String> warnings;
  final List<String> husbandCanDo;

  const WeeklyBriefData({
    required this.week,
    required this.babySize,
    required this.babyDev,
    required this.momChanges,
    required this.nutrition,
    required this.todos,
    required this.warnings,
    required this.husbandCanDo,
  });

  static List<String> _list(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  static WeeklyBriefData? fromJson(Map<String, dynamic>? json, int fallbackWeek) {
    if (json == null) return null;
    return WeeklyBriefData(
      week: (json['week'] as num?)?.toInt() ?? fallbackWeek,
      babySize: (json['baby_size'] ?? '').toString(),
      babyDev: (json['baby_dev'] ?? '').toString(),
      momChanges: (json['mom_changes'] ?? '').toString(),
      nutrition: _list(json['nutrition']),
      todos: _list(json['todos']),
      warnings: _list(json['warnings']),
      husbandCanDo:
          _list(json['husband_can_do']) + _list(json['husbandCanDo']),
    );
  }
}
