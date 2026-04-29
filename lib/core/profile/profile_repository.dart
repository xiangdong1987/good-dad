import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/database.dart';
import 'profile.dart';

/// 单例 profile：固定 id=1，不存在就插入空行。
class ProfileRepository {
  final AppDatabase _db;
  static const _singletonId = 1;

  ProfileRepository(this._db);

  Future<FamilyProfile> load() async {
    final row = await (_db.select(_db.pregnancyProfile)
          ..where((t) => t.id.equals(_singletonId)))
        .getSingleOrNull();
    if (row == null) return FamilyProfile.empty;
    return FamilyProfile(
      dadName: row.dadName,
      momName: row.momName,
      dueDate: row.dueDate,
    );
  }

  Future<void> save(FamilyProfile profile) async {
    await _db.into(_db.pregnancyProfile).insertOnConflictUpdate(
          PregnancyProfileCompanion.insert(
            id: const Value(_singletonId),
            dadName: Value(profile.dadName),
            momName: Value(profile.momName),
            dueDate: Value(profile.dueDate),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}

class ProfileController extends AsyncNotifier<FamilyProfile> {
  late final ProfileRepository _repo;

  @override
  Future<FamilyProfile> build() async {
    _repo = ProfileRepository(ref.watch(appDatabaseProvider));
    return _repo.load();
  }

  Future<void> save(FamilyProfile next) async {
    state = AsyncData(next);
    await _repo.save(next);
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileController, FamilyProfile>(
        ProfileController.new);
