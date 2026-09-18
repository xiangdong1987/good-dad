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

/// 每周孕期简报缓存（每周一行，pregnancy-week skill 跑出来的结构化结果）。
@DataClassName('WeeklyBriefRow')
class WeeklyBriefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// 孕周 1-42，唯一。
  IntColumn get week => integer()();
  TextColumn get rawText => text()();
  TextColumn get structuredJson => text().nullable()();
  DateTimeColumn get generatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {week},
      ];
}

/// 用户每天的待办 / 提醒（可关联到日历某一天）。
/// kind 用枚举字符串：todo / checkup / milestone / note。
@DataClassName('DailyTaskRow')
class DailyTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  /// 该任务关联的日期（取当地零点；用 epoch ms 存）。
  DateTimeColumn get forDate => dateTime()();
  TextColumn get kind => text().withDefault(const Constant('todo'))();
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

/// 爸爸健身资料（单行，固定 id=1）。
@DataClassName('FitnessProfileRow')
class FitnessProfiles extends Table {
  IntColumn get id => integer()(); // 固定 1
  IntColumn get heightCm => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get sex => text().withDefault(const Constant('male'))(); // male/female
  /// 手边壶铃重量列表 JSON，如 "[8,12,16]"
  TextColumn get kettlebellsKg => text().withDefault(const Constant('[]'))();
  TextColumn get experience => text().withDefault(const Constant('novice'))(); // novice/intermediate
  IntColumn get dailyMinutes => integer().withDefault(const Constant(20))();
  TextColumn get goal => text().withDefault(const Constant('maintain'))(); // cut/gain/maintain
  TextColumn get injuries => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 每日某餐的拍照记录 + AI 估算。
@DataClassName('MealLogRow')
class MealLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // yyyy-MM-dd
  TextColumn get meal => text()(); // breakfast/lunch/dinner/snack
  TextColumn get photoPath => text().nullable()();
  /// 食物清单 JSON，如 [{"name":"米饭","grams":150}]
  TextColumn get foodsJson => text().withDefault(const Constant('[]'))();
  IntColumn get kcal => integer().withDefault(const Constant(0))();
  IntColumn get proteinG => integer().withDefault(const Constant(0))();
  IntColumn get carbG => integer().withDefault(const Constant(0))();
  IntColumn get fatG => integer().withDefault(const Constant(0))();
  BoolColumn get edited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 每日训练记录。
@DataClassName('TrainingLogRow')
class TrainingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // yyyy-MM-dd，唯一
  TextColumn get planJson => text().withDefault(const Constant('[]'))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get feeling => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date},
      ];
}

/// 明日计划缓存（每个目标日期一行）。
@DataClassName('DailyPlanRow')
class DailyPlans extends Table {
  TextColumn get targetDate => text()(); // yyyy-MM-dd，主键
  /// 训练动作 JSON，如 [{"move":"高脚杯深蹲","sets":3,"reps":10,"weightKg":12,"note":""}]
  TextColumn get trainingPlanJson => text().withDefault(const Constant('[]'))();
  TextColumn get dietGuidance => text().withDefault(const Constant(''))();
  IntColumn get kcalTarget => integer().withDefault(const Constant(0))();
  IntColumn get proteinTarget => integer().withDefault(const Constant(0))();
  IntColumn get carbTarget => integer().withDefault(const Constant(0))();
  IntColumn get fatTarget => integer().withDefault(const Constant(0))();
  TextColumn get deficitSummary => text().withDefault(const Constant(''))();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {targetDate};
}

/// 日常活动记录（手动记：走路/跑步/骑行/爬楼/抱娃）。
///
/// 与三餐不同，同一天可以记多条，不做 upsert 覆盖。
@DataClassName('ActivityLogRow')
class ActivityLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // yyyy-MM-dd
  TextColumn get kind => text()(); // ActivityKind.name
  IntColumn get minutes => integer().withDefault(const Constant(0))();
  IntColumn get kcal => integer().withDefault(const Constant(0))(); // 净消耗
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
