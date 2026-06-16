import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/database.dart';
import 'fitness_models.dart';

/// fitness 模块的所有 drift 读写。单行 profile + meal/training/plan。
class FitnessRepository {
  final AppDatabase _db;
  static const _profileId = 1;

  FitnessRepository(this._db);

  // ── profile（单行 id=1）────────────────────────────────────
  Future<FitnessProfile> loadProfile() async {
    final row = await (_db.select(_db.fitnessProfiles)
          ..where((t) => t.id.equals(_profileId)))
        .getSingleOrNull();
    if (row == null) return FitnessProfile.empty;
    final kb = (jsonDecode(row.kettlebellsKg) as List)
        .map((e) => (e as num).round())
        .toList();
    return FitnessProfile(
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      age: row.age,
      sex: Sex.parse(row.sex),
      kettlebellsKg: kb,
      experience: Experience.parse(row.experience),
      dailyMinutes: row.dailyMinutes,
      goal: Goal.parse(row.goal),
      injuries: row.injuries,
    );
  }

  Future<void> saveProfile(FitnessProfile p) async {
    await _db.into(_db.fitnessProfiles).insertOnConflictUpdate(
          FitnessProfilesCompanion.insert(
            id: const Value(_profileId),
            heightCm: Value(p.heightCm),
            weightKg: Value(p.weightKg),
            age: Value(p.age),
            sex: Value(p.sex.name),
            kettlebellsKg: Value(jsonEncode(p.kettlebellsKg)),
            experience: Value(p.experience.name),
            dailyMinutes: Value(p.dailyMinutes),
            goal: Value(p.goal.name),
            injuries: Value(p.injuries),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  // ── meal_log ───────────────────────────────────────────────
  Future<int> saveMeal({
    required String date,
    required Meal meal,
    required MealAnalysis analysis,
    required String? photoPath,
    required bool edited,
  }) {
    return _db.into(_db.mealLogs).insert(
          MealLogsCompanion.insert(
            date: date,
            meal: meal.name,
            photoPath: Value(photoPath),
            foodsJson: Value(analysis.foodsJson()),
            kcal: Value(analysis.kcal),
            proteinG: Value(analysis.proteinG),
            carbG: Value(analysis.carbG),
            fatG: Value(analysis.fatG),
            edited: Value(edited),
          ),
        );
  }

  Future<List<MealLogRow>> mealsForDate(String date) {
    return (_db.select(_db.mealLogs)
          ..where((t) => t.date.equals(date))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<MealLogRow>> watchMealsForDate(String date) {
    return (_db.select(_db.mealLogs)
          ..where((t) => t.date.equals(date))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  // ── training_log（每日唯一）─────────────────────────────────
  Future<TrainingLogRow?> trainingForDate(String date) {
    return (_db.select(_db.trainingLogs)..where((t) => t.date.equals(date)))
        .getSingleOrNull();
  }

  Future<void> markTrainingDone(String date, String planJson) async {
    await _db.into(_db.trainingLogs).insertOnConflictUpdate(
          TrainingLogsCompanion.insert(
            date: date,
            planJson: Value(planJson),
            done: const Value(true),
          ),
        );
  }

  // ── daily_plan ─────────────────────────────────────────────
  Future<DailyPlanRow?> planForDate(String date) {
    return (_db.select(_db.dailyPlans)
          ..where((t) => t.targetDate.equals(date)))
        .getSingleOrNull();
  }

  Future<void> savePlan(String targetDate, TomorrowPlan plan) async {
    await _db.into(_db.dailyPlans).insertOnConflictUpdate(
          DailyPlansCompanion.insert(
            targetDate: targetDate,
            trainingPlanJson: Value(plan.trainingPlanJson()),
            dietGuidance: Value(plan.dietGuidance),
            kcalTarget: Value(plan.targets.kcal),
            proteinTarget: Value(plan.targets.proteinG),
            carbTarget: Value(plan.targets.carbG),
            fatTarget: Value(plan.targets.fatG),
            deficitSummary: Value(plan.deficitSummary),
            generatedAt: Value(DateTime.now()),
          ),
        );
  }
}

final fitnessRepositoryProvider = Provider<FitnessRepository>(
    (ref) => FitnessRepository(ref.watch(appDatabaseProvider)));
