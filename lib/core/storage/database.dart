import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'good_dad.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  ChatSessions,
  Messages,
  Memories,
  SkillRuns,
  BellyPhotos,
  PregnancyProfile,
  ChecklistTemplates,
  ChecklistInstances,
  ChecklistItems,
  DailyTasks,
  WeeklyBriefs,
  FitnessProfiles,
  MealLogs,
  TrainingLogs,
  DailyPlans,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.test(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(pregnancyProfile, pregnancyProfile.dadName);
            await m.addColumn(pregnancyProfile, pregnancyProfile.momName);
          }
          if (from < 3) {
            await m.createTable(dailyTasks);
          }
          if (from < 4) {
            await m.createTable(weeklyBriefs);
          }
          if (from < 5) {
            await m.createTable(fitnessProfiles);
            await m.createTable(mealLogs);
            await m.createTable(trainingLogs);
            await m.createTable(dailyPlans);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
