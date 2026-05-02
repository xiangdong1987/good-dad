import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile.dart';
import '../profile/profile_repository.dart';
import '../skill/skill_output.dart';
import '../skill/skill_runner.dart';
import '../storage/database.dart';

/// 一个清单（实例）+ 所有 items 一起的视图。
class ChecklistView {
  final ChecklistInstanceRow instance;
  final List<ChecklistItemRow> items;
  const ChecklistView({required this.instance, required this.items});

  int get totalItems => items.length;
  int get doneItems => items.where((i) => i.checked).length;

  /// 按 sort 划分组：items 里以「## 标题」开头的项作为 section 头，
  /// 后续连续的非头项都属于这个 section。
  List<ChecklistGroup> get groups {
    final out = <ChecklistGroup>[];
    ChecklistGroup? current;
    for (final it in items) {
      if (it.parentId == null && it.title.startsWith('## ')) {
        current = ChecklistGroup(
            title: it.title.substring(3).trim(), items: []);
        out.add(current);
      } else {
        current ??= ChecklistGroup(title: '清单', items: []);
        if (out.isEmpty) out.add(current);
        current.items.add(it);
      }
    }
    return out;
  }
}

class ChecklistGroup {
  final String title;
  final List<ChecklistItemRow> items;
  ChecklistGroup({required this.title, required this.items});
}

class ChecklistRepository {
  final AppDatabase _db;
  final SkillRunner? _runner;
  final FamilyProfile _profile;

  ChecklistRepository({
    required AppDatabase db,
    required SkillRunner? runner,
    required FamilyProfile profile,
  })  : _db = db,
        _runner = runner,
        _profile = profile;

  /// 监听某个 skill 的当前 instance（如果有就拿最新一条）。
  Stream<ChecklistView?> watchCurrent(String skillName) async* {
    // 查找这个 skill 已经创建的最新 instance
    final tplStream = (_db.select(_db.checklistTemplates)
          ..where((t) => t.skillName.equals(skillName))
          ..limit(1))
        .watchSingleOrNull();

    await for (final tpl in tplStream) {
      if (tpl == null) {
        yield null;
        continue;
      }
      final instStream = (_db.select(_db.checklistInstances)
            ..where((t) => t.templateId.equals(tpl.id))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .watchSingleOrNull();

      yield* instStream.asyncExpand((inst) {
        if (inst == null) return Stream.value(null);
        final itemsStream = (_db.select(_db.checklistItems)
              ..where((t) => t.instanceId.equals(inst.id))
              ..orderBy([(t) => OrderingTerm.asc(t.sort)]))
            .watch();
        return itemsStream.map(
          (items) => ChecklistView(instance: inst, items: items),
        );
      });
    }
  }

  /// 让 AI 生成（或重生成）一个 skill 的 checklist：调 SkillRunner，
  /// 解析 sections，落 template + instance + items。
  Future<int> generate(String skillName, {String? userText}) async {
    final runner = _runner;
    if (runner == null) {
      throw Exception('LLM 未配置');
    }
    final result = await runner.run(
      skillName,
      text: userText,
      profile: _profile,
    );
    final sections = result.checklistSections ?? const <ChecklistSection>[];
    if (sections.isEmpty) {
      throw Exception('AI 这次没返回有效的 checklist 格式：\n${result.rawText}');
    }

    return _writeSections(skillName, sections, mergeInto: null);
  }

  /// 在已有 instance 上让 AI 增量补充：调 skill，把新的（按 title 去重）item 插到对应 section。
  Future<int> augment(String skillName, {String? hint}) async {
    final runner = _runner;
    if (runner == null) {
      throw Exception('LLM 未配置');
    }
    final view = await _currentView(skillName);
    if (view == null) {
      // 没有现成的就直接生成
      return generate(skillName);
    }

    final existing = view.items
        .map((i) => i.title.trim())
        .where((s) => s.isNotEmpty)
        .toSet();

    final result = await runner.run(
      skillName,
      text: '请补充一些之前没列出来的项${hint == null ? '' : '（$hint）'}。'
          '已经在清单里的请不要重复：\n${existing.join("、")}',
      profile: _profile,
    );
    final sections = result.checklistSections ?? const <ChecklistSection>[];
    if (sections.isEmpty) return 0;

    // 过滤掉重复项
    final newSections = sections
        .map((s) => ChecklistSection(
              title: s.title,
              items: s.items
                  .where((i) => !existing.contains(i.text.trim()))
                  .toList(),
            ))
        .where((s) => s.items.isNotEmpty)
        .toList();

    if (newSections.isEmpty) return 0;
    return _writeSections(skillName, newSections, mergeInto: view.instance.id);
  }

  Future<void> setItemDone(int itemId, bool done) async {
    await (_db.update(_db.checklistItems)
          ..where((t) => t.id.equals(itemId)))
        .write(ChecklistItemsCompanion(checked: Value(done)));
  }

  Future<void> deleteItem(int itemId) async {
    await (_db.delete(_db.checklistItems)..where((t) => t.id.equals(itemId)))
        .go();
  }

  Future<void> updateItemNotes(int itemId, String notes) async {
    await (_db.update(_db.checklistItems)
          ..where((t) => t.id.equals(itemId)))
        .write(ChecklistItemsCompanion(notes: Value(notes)));
  }

  // ── helpers ────────────────────────────────────────────────────────

  Future<ChecklistView?> _currentView(String skillName) async {
    final tpl = await (_db.select(_db.checklistTemplates)
          ..where((t) => t.skillName.equals(skillName)))
        .getSingleOrNull();
    if (tpl == null) return null;
    final inst = await (_db.select(_db.checklistInstances)
          ..where((t) => t.templateId.equals(tpl.id))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    if (inst == null) return null;
    final items = await (_db.select(_db.checklistItems)
          ..where((t) => t.instanceId.equals(inst.id))
          ..orderBy([(t) => OrderingTerm.asc(t.sort)]))
        .get();
    return ChecklistView(instance: inst, items: items);
  }

  /// 把一组 sections 写到 DB。如果 [mergeInto] 给了 instance id，
  /// 就在那个 instance 后面追加；否则新建 template/instance。
  Future<int> _writeSections(
    String skillName,
    List<ChecklistSection> sections, {
    int? mergeInto,
  }) async {
    return _db.transaction(() async {
      // 1. template
      final tpl = await (_db.select(_db.checklistTemplates)
            ..where((t) => t.skillName.equals(skillName)))
          .getSingleOrNull();
      final templateId = tpl?.id ??
          await _db.into(_db.checklistTemplates).insert(
                ChecklistTemplatesCompanion.insert(
                  skillName: skillName,
                  title: skillName,
                  bodyMd: sections
                      .map((s) =>
                          '## ${s.title}\n${s.items.map((i) => '- [ ] ${i.text}').join('\n')}')
                      .join('\n\n'),
                ),
              );

      // 2. instance
      final int instanceId = mergeInto ??
          await _db.into(_db.checklistInstances).insert(
                ChecklistInstancesCompanion.insert(
                  templateId: Value(templateId),
                  title: '清单',
                ),
              );

      // 3. items（含 section 头作为 parent_id IS NULL + title 以「## 」开头的标记项）
      var sort = mergeInto == null
          ? 0
          : await _maxSort(instanceId) + 1;
      var inserted = 0;
      for (final section in sections) {
        // 写 section 头
        await _db.into(_db.checklistItems).insert(
              ChecklistItemsCompanion.insert(
                instanceId: instanceId,
                title: '## ${section.title}',
                sort: Value(sort++),
              ),
            );
        for (final entry in section.items) {
          await _db.into(_db.checklistItems).insert(
                ChecklistItemsCompanion.insert(
                  instanceId: instanceId,
                  title: entry.text,
                  checked: Value(entry.checked),
                  sort: Value(sort++),
                ),
              );
          inserted++;
        }
      }
      return inserted;
    });
  }

  Future<int> _maxSort(int instanceId) async {
    final m = _db.checklistItems.sort.max();
    final row = (await (_db.selectOnly(_db.checklistItems)
              ..addColumns([m])
              ..where(_db.checklistItems.instanceId.equals(instanceId)))
            .getSingle())
        .read(m);
    return row ?? 0;
  }
}

final checklistRepositoryProvider =
    Provider<ChecklistRepository>((ref) {
  return ChecklistRepository(
    db: ref.watch(appDatabaseProvider),
    runner: ref.watch(skillRunnerProvider),
    profile: ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty,
  );
});

final checklistViewProvider = StreamProvider.autoDispose
    .family<ChecklistView?, String>((ref, skillName) {
  return ref.watch(checklistRepositoryProvider).watchCurrent(skillName);
});
