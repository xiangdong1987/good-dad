enum TaskKind {
  todo,
  checkup,
  milestone,
  note;

  static TaskKind parse(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'checkup':
        return TaskKind.checkup;
      case 'milestone':
        return TaskKind.milestone;
      case 'note':
        return TaskKind.note;
      case 'todo':
      default:
        return TaskKind.todo;
    }
  }

  String get label => switch (this) {
        TaskKind.todo => '待办',
        TaskKind.checkup => '产检',
        TaskKind.milestone => '里程碑',
        TaskKind.note => '备注',
      };

  String get emoji => switch (this) {
        TaskKind.todo => '✅',
        TaskKind.checkup => '🩺',
        TaskKind.milestone => '🎉',
        TaskKind.note => '📝',
      };
}

class DailyTask {
  final int? id;
  final String title;
  final String? notes;
  final bool done;
  final DateTime forDate;
  final TaskKind kind;
  final DateTime? createdAt;

  const DailyTask({
    this.id,
    required this.title,
    this.notes,
    this.done = false,
    required this.forDate,
    this.kind = TaskKind.todo,
    this.createdAt,
  });

  DailyTask copyWith({
    int? id,
    String? title,
    String? notes,
    bool? done,
    DateTime? forDate,
    TaskKind? kind,
  }) =>
      DailyTask(
        id: id ?? this.id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        done: done ?? this.done,
        forDate: forDate ?? this.forDate,
        kind: kind ?? this.kind,
        createdAt: createdAt,
      );

  /// 工具：把任意 DateTime 归一化到当地零点，方便按天匹配。
  static DateTime atMidnight(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
