import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/database.dart';
import 'memory.dart';

/// 记忆 CRUD 仓库。
class MemoryRepository {
  final AppDatabase _db;
  MemoryRepository(this._db);

  // ── 读 ─────────────────────────────────────────────────────────

  Stream<List<MemoryEntry>> watchAll({
    MemoryType? type,
    MemoryStatus? status,
  }) {
    final q = _db.select(_db.memories)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (type != null) q.where((t) => t.type.equals(type.name));
    if (status != null) q.where((t) => t.status.equals(status.name));
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<MemoryEntry>> findActiveByNames(List<String> names) async {
    if (names.isEmpty) return const [];
    final q = _db.select(_db.memories)
      ..where((t) =>
          t.name.isIn(names) & t.status.equals(MemoryStatus.active.name))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    final rows = await q.get();
    return rows.map(_fromRow).toList();
  }

  Future<List<MemoryEntry>> findActiveLikeNames(List<String> patterns) async {
    if (patterns.isEmpty) return const [];
    Expression<bool>? expr;
    for (final p in patterns) {
      final clause = _db.memories.name.like(p);
      expr = expr == null ? clause : expr | clause;
    }
    final q = _db.select(_db.memories)
      ..where((t) =>
          (expr ?? const Constant(false)) &
          t.status.equals(MemoryStatus.active.name))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    final rows = await q.get();
    return rows.map(_fromRow).toList();
  }

  Future<int> countByStatus(MemoryStatus status) async {
    final cnt = countAll();
    final q = _db.selectOnly(_db.memories)
      ..addColumns([cnt])
      ..where(_db.memories.status.equals(status.name));
    final row = await q.getSingle();
    return row.read(cnt) ?? 0;
  }

  // ── 写 ─────────────────────────────────────────────────────────

  Future<int> upsert(MemoryEntry e) async {
    final now = DateTime.now();
    return _db.into(_db.memories).insertOnConflictUpdate(
          MemoriesCompanion(
            id: e.id == null ? const Value.absent() : Value(e.id!),
            type: Value(e.type.name),
            name: Value(e.name),
            description: Value(e.description),
            body: Value(e.body),
            status: Value(e.status.name),
            createdAt:
                e.createdAt == null ? Value(now) : Value(e.createdAt!),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> setStatus(int id, MemoryStatus status) async {
    await (_db.update(_db.memories)..where((t) => t.id.equals(id))).write(
      MemoriesCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.memories)..where((t) => t.id.equals(id))).go();
  }

  // ── helpers ───────────────────────────────────────────────────

  static MemoryEntry _fromRow(MemoryRow r) => MemoryEntry(
        id: r.id,
        type: MemoryType.parse(r.type),
        name: r.name,
        description: r.description,
        body: r.body,
        status: MemoryStatus.parse(r.status),
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );
}

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(ref.watch(appDatabaseProvider));
});

final pendingMemoryCountProvider =
    StreamProvider.autoDispose<int>((ref) async* {
  final repo = ref.watch(memoryRepositoryProvider);
  // 简单实现：监听全表，filter pending
  await for (final list in repo.watchAll(status: MemoryStatus.pending)) {
    yield list.length;
  }
});
