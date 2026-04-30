enum MemoryType {
  user,
  feedback,
  project,
  reference;

  static MemoryType parse(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'feedback':
        return MemoryType.feedback;
      case 'project':
        return MemoryType.project;
      case 'reference':
        return MemoryType.reference;
      case 'user':
      default:
        return MemoryType.user;
    }
  }

  String get label => switch (this) {
        MemoryType.user => '家人画像',
        MemoryType.feedback => '我的偏好',
        MemoryType.project => '当前阶段',
        MemoryType.reference => '资源/资料',
      };

  String get emoji => switch (this) {
        MemoryType.user => '👨‍👩‍👧',
        MemoryType.feedback => '🪶',
        MemoryType.project => '📅',
        MemoryType.reference => '🔗',
      };
}

enum MemoryStatus {
  active,
  pending;

  static MemoryStatus parse(String? raw) =>
      raw == 'pending' ? MemoryStatus.pending : MemoryStatus.active;
}

class MemoryEntry {
  final int? id;
  final MemoryType type;
  /// 唯一短标识，例 `partner.due_date`、`baby.allergies`。
  final String name;
  /// 一行标题（≤20 字）。
  final String description;
  /// 详细内容。
  final String body;
  final MemoryStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MemoryEntry({
    this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.body,
    this.status = MemoryStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  MemoryEntry copyWith({
    int? id,
    MemoryType? type,
    String? name,
    String? description,
    String? body,
    MemoryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      body: body ?? this.body,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'description': description,
        'body': body,
        'status': status.name,
      };
}
