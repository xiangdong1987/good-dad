import 'package:drift/drift.dart';

@DataClassName('ChatSessionRow')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get skillName => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MessageRow')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ChatSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get skillRunId => integer().nullable()();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
  DateTimeColumn get ts => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MemoryRow')
class Memories extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// user | feedback | project | reference
  TextColumn get type => text()();
  /// e.g. partner.due_date
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get body => text()();
  /// active | pending (候选记忆抽屉里的，等用户确认)
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {type, name},
      ];
}

@DataClassName('SkillRunRow')
class SkillRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get skillName => text()();
  TextColumn get inputJson => text()();
  TextColumn get outputJson => text().nullable()();
  IntColumn get latencyMs => integer().nullable()();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BellyPhotoRow')
class BellyPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get takenAt => dateTime()();
  IntColumn get pregnancyWeek => integer().nullable()();
  TextColumn get imagePath => text()();
  TextColumn get aiComment => text().nullable()();
}

@DataClassName('PregnancyProfileRow')
class PregnancyProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dadName => text().nullable()();
  TextColumn get momName => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get lastPeriod => dateTime().nullable()();
  TextColumn get partnerInfoJson => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChecklistTemplateRow')
class ChecklistTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get skillName => text()();
  TextColumn get title => text()();
  TextColumn get bodyMd => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {skillName},
      ];
}

@DataClassName('ChecklistInstanceRow')
class ChecklistInstances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer()
      .nullable()
      .references(ChecklistTemplates, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChecklistItemRow')
class ChecklistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get instanceId => integer()
      .references(ChecklistInstances, #id, onDelete: KeyAction.cascade)();
  IntColumn get parentId => integer().nullable()();
  TextColumn get title => text()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get sort => integer().withDefault(const Constant(0))();
}
