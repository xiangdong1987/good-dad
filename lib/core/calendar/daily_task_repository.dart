import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/database.dart';
import 'daily_task.dart';

class DailyTaskRepository {
  final AppDatabase _db;
  DailyTaskRepository(this._db);

  Stream<List<DailyTask>> watchForDate(DateTime date) {
    final start = DailyTask.atMidnight(date);
    final end = start.add(const Duration(days: 1));
    final q = _db.select(_db.dailyTasks)
      ..where((t) =>
          t.forDate.isBiggerOrEqualValue(start) &
          t.forDate.isSmallerThanValue(end))
      ..orderBy([
        (t) => OrderingTerm.asc(t.done),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Stream<Map<DateTime, int>> watchCountsForMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final q = _db.select(_db.dailyTasks)
      ..where((t) =>
          t.forDate.isBiggerOrEqualValue(start) &
          t.forDate.isSmallerThanValue(end));
    return q.watch().map((rows) {
      final m = <DateTime, int>{};
      for (final r in rows) {
        final d = DailyTask.atMidnight(r.forDate);
        m[d] = (m[d] ?? 0) + 1;
      }
      return m;
    });
  }

  Future<int> add(DailyTask task) async {
    return _db.into(_db.dailyTasks).insert(
          DailyTasksCompanion.insert(
            title: task.title,
            notes: task.notes == null ? const Value.absent() : Value(task.notes),
            done: Value(task.done),
            forDate: DailyTask.atMidnight(task.forDate),
            kind: Value(task.kind.name),
          ),
        );
  }

  Future<void> setDone(int id, bool done) async {
    await (_db.update(_db.dailyTasks)..where((t) => t.id.equals(id))).write(
      DailyTasksCompanion(done: Value(done)),
    );
  }

  Future<void> updateTitle(int id, String title) async {
    await (_db.update(_db.dailyTasks)..where((t) => t.id.equals(id))).write(
      DailyTasksCompanion(title: Value(title)),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.dailyTasks)..where((t) => t.id.equals(id))).go();
  }

  static DailyTask _fromRow(DailyTaskRow r) => DailyTask(
        id: r.id,
        title: r.title,
        notes: r.notes,
        done: r.done,
        forDate: r.forDate,
        kind: TaskKind.parse(r.kind),
        createdAt: r.createdAt,
      );
}

final dailyTaskRepositoryProvider = Provider<DailyTaskRepository>(
    (ref) => DailyTaskRepository(ref.watch(appDatabaseProvider)));

/// 今天的任务流。
final todayTasksProvider =
    StreamProvider.autoDispose<List<DailyTask>>((ref) {
  final repo = ref.watch(dailyTaskRepositoryProvider);
  return repo.watchForDate(DateTime.now());
});
