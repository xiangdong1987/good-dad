import 'package:flutter_test/flutter_test.dart';

import 'package:good_dad/core/memory/memory.dart';

void main() {
  group('MemoryType.parse', () {
    test('已知值', () {
      expect(MemoryType.parse('user'), MemoryType.user);
      expect(MemoryType.parse('feedback'), MemoryType.feedback);
      expect(MemoryType.parse('project'), MemoryType.project);
      expect(MemoryType.parse('reference'), MemoryType.reference);
    });
    test('未知值兜底为 user', () {
      expect(MemoryType.parse(null), MemoryType.user);
      expect(MemoryType.parse(''), MemoryType.user);
      expect(MemoryType.parse('weird'), MemoryType.user);
    });
  });

  test('MemoryEntry.copyWith 保留未指定字段', () {
    final e = MemoryEntry(
      id: 1,
      type: MemoryType.user,
      name: 'partner.due_date',
      description: '老婆预产期',
      body: '2026-08-15',
    );
    final updated = e.copyWith(body: '2026-09-01');
    expect(updated.body, '2026-09-01');
    expect(updated.name, e.name);
    expect(updated.id, e.id);
  });
}
