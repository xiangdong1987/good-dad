import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile.dart';
import '../profile/profile_repository.dart';
import '../skill/skill_runner.dart';
import '../storage/database.dart';
import 'weekly_brief.dart';

/// 周建议仓库：CRUD + 调 SkillRunner 生成。
class WeeklyBriefRepository {
  final AppDatabase _db;
  final SkillRunner? _runner;
  final FamilyProfile _profile;

  WeeklyBriefRepository({
    required AppDatabase db,
    required SkillRunner? runner,
    required FamilyProfile profile,
  })  : _db = db,
        _runner = runner,
        _profile = profile;

  Stream<WeeklyBrief?> watchByWeek(int week) {
    final q = _db.select(_db.weeklyBriefs)
      ..where((t) => t.week.equals(week))
      ..limit(1);
    return q.watchSingleOrNull().map((row) => row == null ? null : _from(row));
  }

  Future<WeeklyBrief?> get(int week) async {
    final q = _db.select(_db.weeklyBriefs)
      ..where((t) => t.week.equals(week))
      ..limit(1);
    final row = await q.getSingleOrNull();
    return row == null ? null : _from(row);
  }

  /// 调 pregnancy-week skill 为指定 week 生成（或重生成）一条简报。
  /// 返回写入的 brief。
  Future<WeeklyBrief> generate(int week) async {
    final runner = _runner;
    if (runner == null) {
      throw Exception('LLM 未配置');
    }

    // 合成一个「孕周 = week」的 profile 快照传给 skill，
    // 这样 skill 的「## 家庭信息」段会自动填入正确的孕周。
    final profileForWeek = FamilyProfile(
      dadName: _profile.dadName,
      momName: _profile.momName,
      dueDate: FamilyProfile.dueDateFromCurrentWeek(week),
    );

    final result = await runner.run(
      'pregnancy-week',
      text: '请输出第 $week 周的简报',
      profile: profileForWeek,
    );

    final encodedJson =
        result.structuredJson == null ? null : jsonEncode(result.structuredJson);

    await _db.into(_db.weeklyBriefs).insertOnConflictUpdate(
          WeeklyBriefsCompanion.insert(
            week: week,
            rawText: result.rawText,
            structuredJson:
                encodedJson == null ? const Value.absent() : Value(encodedJson),
            generatedAt: Value(DateTime.now()),
          ),
        );
    return (await get(week))!;
  }

  Future<void> delete(int week) async {
    await (_db.delete(_db.weeklyBriefs)..where((t) => t.week.equals(week)))
        .go();
  }

  WeeklyBrief _from(WeeklyBriefRow r) {
    Map<String, dynamic>? parsed;
    final js = r.structuredJson;
    if (js != null && js.isNotEmpty) {
      try {
        final decoded = jsonDecode(js);
        if (decoded is Map<String, dynamic>) parsed = decoded;
      } catch (_) {}
    }
    return WeeklyBrief(
      id: r.id,
      week: r.week,
      rawText: r.rawText,
      data: WeeklyBriefData.fromJson(parsed, r.week),
      generatedAt: r.generatedAt,
    );
  }
}

final weeklyBriefRepositoryProvider =
    Provider<WeeklyBriefRepository>((ref) {
  return WeeklyBriefRepository(
    db: ref.watch(appDatabaseProvider),
    runner: ref.watch(skillRunnerProvider),
    profile: ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty,
  );
});

final weeklyBriefProvider =
    StreamProvider.autoDispose.family<WeeklyBrief?, int>((ref, week) {
  return ref.watch(weeklyBriefRepositoryProvider).watchByWeek(week);
});
