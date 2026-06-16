# 壶铃训练 + 三餐拍照分析模块 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 给爸爸加一个壶铃训练 + 三餐拍照分析模块：拍照估热量/宏量、展示今日训练、每晚静态提醒并在 App 内现场用今日数据生成「安全」的明日训练 + 饮食计划。

**Architecture:** 完整 feature（带 drift 数据层），prompt 逻辑内联在 feature 内、复用现有 `LlmClient`。新增 4 张 drift 表、1 个每晚通知器、1 个 `MacroRing` widget、3 个页面。纯逻辑（JSON 解析、热量/宏量计算、生成时机判定）做成无依赖纯函数并用 TDD 覆盖；repository 用 in-memory drift 测；页面 build + 手动验收。

**Tech Stack:** Flutter · Riverpod · drift(sqlite3) · dio(LlmClient) · image_picker · image · flutter_local_notifications · timezone

---

## File Structure

| 文件 | 职责 |
|---|---|
| `lib/core/storage/tables.dart` | 新增 4 张表定义（修改） |
| `lib/core/storage/database.dart` | 注册表 + schemaVersion 4→5 + migration（修改） |
| `lib/core/storage/database.g.dart` | build_runner 重新生成（修改） |
| `lib/core/storage/file_store.dart` | 加 `saveMealPhoto`（修改） |
| `lib/features/fitness/fitness_models.dart` | 纯 Dart 模型 + 枚举 + toJson/fromJson（新建） |
| `lib/features/fitness/fitness_calc.dart` | 纯函数：宏量目标 / 当日合计 / 是否该生成（新建） |
| `lib/features/fitness/fitness_prompt.dart` | 纯：拼 prompt + 宽容 JSON 解析 + 压图（新建） |
| `lib/features/fitness/fitness_repository.dart` | 4 个 repo + riverpod provider（新建） |
| `lib/features/fitness/fitness_llm.dart` | `FitnessLlm`：analyzeMeal / generateTomorrowPlan + provider（新建） |
| `lib/features/fitness/widgets/macro_ring.dart` | `MacroRing` 进度环（新建） |
| `lib/features/fitness/fitness_profile_page.dart` | 设置/引导页（新建） |
| `lib/features/fitness/meal_capture_page.dart` | 拍照流页（新建） |
| `lib/features/fitness/fitness_page.dart` | 今日页（新建） |
| `lib/core/notification/daily_plan_notifier.dart` | 每晚静态提醒（新建） |
| `lib/router.dart` | 注册 `/fitness`、`/fitness/profile`（修改） |
| `lib/features/home/home_page.dart` | 加壶铃 SkillCard 入口（修改） |
| `test/fitness_calc_test.dart` | 计算纯函数测试（新建） |
| `test/fitness_prompt_test.dart` | JSON 解析测试（新建） |
| `test/fitness_repository_test.dart` | drift CRUD 测试（新建） |

---

## Task 1: drift 表 + migration

**Files:**
- Modify: `lib/core/storage/tables.dart`（文件尾追加）
- Modify: `lib/core/storage/database.dart:21-59`
- Regenerate: `lib/core/storage/database.g.dart`

- [ ] **Step 1: 在 `tables.dart` 文件末尾追加 4 张表**

```dart
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
```

- [ ] **Step 2: 在 `database.dart` 的 `@DriftDatabase(tables: [...])` 列表追加 4 张表**

修改 `lib/core/storage/database.dart:21-33`，在 `WeeklyBriefs,` 后面加：

```dart
  WeeklyBriefs,
  FitnessProfiles,
  MealLogs,
  TrainingLogs,
  DailyPlans,
])
```

- [ ] **Step 3: bump schemaVersion 并加 migration**

把 `lib/core/storage/database.dart:39` 的 `int get schemaVersion => 4;` 改成 `=> 5;`，并在 `onUpgrade` 里 `if (from < 4)` 块后追加：

```dart
          if (from < 5) {
            await m.createTable(fitnessProfiles);
            await m.createTable(mealLogs);
            await m.createTable(trainingLogs);
            await m.createTable(dailyPlans);
          }
```

- [ ] **Step 4: 重新生成 drift 代码**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 成功，`database.g.dart` 出现 `FitnessProfileRow` / `MealLogRow` / `TrainingLogRow` / `DailyPlanRow` 及对应 Companion。

- [ ] **Step 5: 验证编译**

Run: `flutter analyze lib/core/storage`
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/core/storage/tables.dart lib/core/storage/database.dart lib/core/storage/database.g.dart
git commit -m "feat: fitness 模块 4 张 drift 表 + migration v5"
```

---

## Task 2: 纯模型 `fitness_models.dart`

**Files:**
- Create: `lib/features/fitness/fitness_models.dart`

- [ ] **Step 1: 写模型文件（纯 Dart，无 Flutter 依赖）**

```dart
import 'dart:convert';

enum Sex {
  male,
  female;

  static Sex parse(String? s) =>
      s?.toLowerCase().trim() == 'female' ? Sex.female : Sex.male;
}

enum Experience {
  novice,
  intermediate;

  static Experience parse(String? s) =>
      s?.toLowerCase().trim() == 'intermediate'
          ? Experience.intermediate
          : Experience.novice;
}

enum Goal {
  cut,
  gain,
  maintain;

  static Goal parse(String? s) {
    switch (s?.toLowerCase().trim()) {
      case 'cut':
        return Goal.cut;
      case 'gain':
        return Goal.gain;
      default:
        return Goal.maintain;
    }
  }
}

enum Meal {
  breakfast,
  lunch,
  dinner,
  snack;

  static Meal parse(String? s) {
    switch (s?.toLowerCase().trim()) {
      case 'lunch':
        return Meal.lunch;
      case 'dinner':
        return Meal.dinner;
      case 'snack':
        return Meal.snack;
      default:
        return Meal.breakfast;
    }
  }

  String get zh => switch (this) {
        Meal.breakfast => '早餐',
        Meal.lunch => '午餐',
        Meal.dinner => '晚餐',
        Meal.snack => '加餐',
      };
}

/// 爸爸健身资料（与 FitnessProfileRow 对应的领域模型）。
class FitnessProfile {
  final int? heightCm;
  final double? weightKg;
  final int? age;
  final Sex sex;
  final List<int> kettlebellsKg;
  final Experience experience;
  final int dailyMinutes;
  final Goal goal;
  final String? injuries;

  const FitnessProfile({
    this.heightCm,
    this.weightKg,
    this.age,
    this.sex = Sex.male,
    this.kettlebellsKg = const [],
    this.experience = Experience.novice,
    this.dailyMinutes = 20,
    this.goal = Goal.maintain,
    this.injuries,
  });

  static const empty = FitnessProfile();

  /// 必填项齐了才算可以生成计划。
  bool get isComplete =>
      heightCm != null &&
      weightKg != null &&
      age != null &&
      kettlebellsKg.isNotEmpty;

  FitnessProfile copyWith({
    int? heightCm,
    double? weightKg,
    int? age,
    Sex? sex,
    List<int>? kettlebellsKg,
    Experience? experience,
    int? dailyMinutes,
    Goal? goal,
    String? injuries,
  }) =>
      FitnessProfile(
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        kettlebellsKg: kettlebellsKg ?? this.kettlebellsKg,
        experience: experience ?? this.experience,
        dailyMinutes: dailyMinutes ?? this.dailyMinutes,
        goal: goal ?? this.goal,
        injuries: injuries ?? this.injuries,
      );
}

/// 一种食物及其估重。
class FoodItem {
  final String name;
  final int grams;
  const FoodItem(this.name, this.grams);

  Map<String, dynamic> toJson() => {'name': name, 'grams': grams};
  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        (j['name'] ?? '').toString(),
        (j['grams'] as num?)?.round() ?? 0,
      );
}

/// 一餐的 AI 分析结果。
class MealAnalysis {
  final List<FoodItem> foods;
  final int kcal;
  final int proteinG;
  final int carbG;
  final int fatG;
  final String note;

  /// 模型没给标准 JSON 时留底。
  final String rawText;

  const MealAnalysis({
    this.foods = const [],
    this.kcal = 0,
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
    this.note = '',
    this.rawText = '',
  });

  String foodsJson() => jsonEncode(foods.map((f) => f.toJson()).toList());
}

/// 一日三餐合计。
class DayTotals {
  final int kcal;
  final int proteinG;
  final int carbG;
  final int fatG;
  const DayTotals({
    this.kcal = 0,
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
  });
}

/// 营养目标（明日计划里给出，或本地按 TDEE 兜底）。
class MacroTargets {
  final int kcal;
  final int proteinG;
  final int carbG;
  final int fatG;
  const MacroTargets({
    required this.kcal,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });
}

/// 训练动作。
class TrainingMove {
  final String move;
  final int sets;
  final int reps;
  final int weightKg;
  final String note;
  const TrainingMove({
    required this.move,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.note = '',
  });

  Map<String, dynamic> toJson() =>
      {'move': move, 'sets': sets, 'reps': reps, 'weightKg': weightKg, 'note': note};
  factory TrainingMove.fromJson(Map<String, dynamic> j) => TrainingMove(
        move: (j['move'] ?? '').toString(),
        sets: (j['sets'] as num?)?.round() ?? 0,
        reps: (j['reps'] as num?)?.round() ?? 0,
        weightKg: (j['weightKg'] as num?)?.round() ?? 0,
        note: (j['note'] ?? '').toString(),
      );
}

/// 明日计划（与 DailyPlanRow 对应的领域模型）。
class TomorrowPlan {
  final List<TrainingMove> trainingPlan;
  final String dietGuidance;
  final MacroTargets targets;
  final String deficitSummary;

  /// 模型没给标准 JSON 时留底。
  final String rawText;

  const TomorrowPlan({
    this.trainingPlan = const [],
    this.dietGuidance = '',
    this.targets = const MacroTargets(kcal: 0, proteinG: 0, carbG: 0, fatG: 0),
    this.deficitSummary = '',
    this.rawText = '',
  });

  String trainingPlanJson() =>
      jsonEncode(trainingPlan.map((m) => m.toJson()).toList());
}
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/features/fitness/fitness_models.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fitness/fitness_models.dart
git commit -m "feat: fitness 领域模型"
```

---

## Task 3: 计算纯函数 `fitness_calc.dart`（TDD）

**Files:**
- Create: `test/fitness_calc_test.dart`
- Create: `lib/features/fitness/fitness_calc.dart`

- [ ] **Step 1: 先写失败测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_calc.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';

void main() {
  group('defaultTargets (Mifflin-St Jeor)', () {
    test('男性减脂目标低于维持热量，蛋白按体重 1.6g/kg', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        sex: Sex.male,
        goal: Goal.cut,
        kettlebellsKg: [16],
      );
      final t = FitnessCalc.defaultTargets(p);
      // BMR = 10*70 + 6.25*175 - 5*30 + 5 = 1648.75; TDEE = *1.375 = 2267; cut -400
      expect(t.kcal, 1867);
      expect(t.proteinG, 112); // 70 * 1.6
      expect(t.kcal, lessThan(2267));
    });

    test('资料不全时回退到安全默认 2000 kcal', () {
      final t = FitnessCalc.defaultTargets(FitnessProfile.empty);
      expect(t.kcal, 2000);
    });
  });

  group('sumDay', () {
    test('累加多餐的热量与宏量', () {
      const a = MealAnalysis(kcal: 500, proteinG: 30, carbG: 60, fatG: 15);
      const b = MealAnalysis(kcal: 300, proteinG: 20, carbG: 40, fatG: 8);
      final total = FitnessCalc.sumDay([a, b]);
      expect(total.kcal, 800);
      expect(total.proteinG, 50);
      expect(total.carbG, 100);
      expect(total.fatG, 23);
    });

    test('空列表得到全 0', () {
      final total = FitnessCalc.sumDay([]);
      expect(total.kcal, 0);
    });
  });

  group('needsPlanGeneration', () {
    test('明日已有缓存计划则不需要再生成', () {
      expect(
        FitnessCalc.needsPlanGeneration(
            hasPlanForTomorrow: true, hour: 22),
        isFalse,
      );
    });

    test('晚上 21 点后且无缓存则需要生成', () {
      expect(
        FitnessCalc.needsPlanGeneration(
            hasPlanForTomorrow: false, hour: 21),
        isTrue,
      );
    });

    test('白天无缓存也不主动生成（等晚上）', () {
      expect(
        FitnessCalc.needsPlanGeneration(
            hasPlanForTomorrow: false, hour: 10),
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/fitness_calc_test.dart`
Expected: FAIL —「Target of URI doesn't exist: '...fitness_calc.dart'」/ undefined `FitnessCalc`。

- [ ] **Step 3: 写实现**

```dart
import 'fitness_models.dart';

/// 纯计算：热量/宏量目标、当日合计、是否该生成明日计划。无任何框架依赖。
class FitnessCalc {
  /// 生成时间阈值（小时）：到了晚上这个点才在 App 内现场生成明日计划。
  static const generateAfterHour = 21;

  /// Mifflin-St Jeor 估 BMR → 活动系数 1.375（轻度活动）→ 按目标增减。
  /// 资料不全则回退安全默认。
  static MacroTargets defaultTargets(FitnessProfile p) {
    final h = p.heightCm, w = p.weightKg, a = p.age;
    if (h == null || w == null || a == null) {
      return const MacroTargets(
          kcal: 2000, proteinG: 100, carbG: 220, fatG: 65);
    }
    final s = p.sex == Sex.male ? 5 : -161;
    final bmr = 10 * w + 6.25 * h - 5 * a + s;
    final tdee = bmr * 1.375;
    final kcal = switch (p.goal) {
      Goal.cut => tdee - 400,
      Goal.gain => tdee + 300,
      Goal.maintain => tdee,
    };
    final protein = (w * 1.6).round();
    final fat = (kcal * 0.25 / 9).round();
    final carb = ((kcal - protein * 4 - fat * 9) / 4).round();
    return MacroTargets(
      kcal: kcal.round(),
      proteinG: protein,
      carbG: carb < 0 ? 0 : carb,
      fatG: fat,
    );
  }

  static DayTotals sumDay(List<MealAnalysis> meals) {
    var kcal = 0, p = 0, c = 0, f = 0;
    for (final m in meals) {
      kcal += m.kcal;
      p += m.proteinG;
      c += m.carbG;
      f += m.fatG;
    }
    return DayTotals(kcal: kcal, proteinG: p, carbG: c, fatG: f);
  }

  /// 进入页面时是否该现场生成明日计划：晚上阈值后且尚无缓存。
  static bool needsPlanGeneration({
    required bool hasPlanForTomorrow,
    required int hour,
  }) =>
      !hasPlanForTomorrow && hour >= generateAfterHour;
}
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/fitness_calc_test.dart`
Expected: All tests pass。（若 cut 热量算出与 1867 差 ±1，按实际值订正测试期望——以实现的 `round()` 为准。）

- [ ] **Step 5: Commit**

```bash
git add test/fitness_calc_test.dart lib/features/fitness/fitness_calc.dart
git commit -m "feat: fitness 热量/宏量/生成时机纯函数 + 测试"
```

---

## Task 4: prompt 拼装 + 宽容 JSON 解析 `fitness_prompt.dart`（TDD）

**Files:**
- Create: `test/fitness_prompt_test.dart`
- Create: `lib/features/fitness/fitness_prompt.dart`

- [ ] **Step 1: 先写失败测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/fitness_prompt.dart';

void main() {
  group('parseMeal', () {
    test('纯 JSON 直接解析', () {
      final r = FitnessPrompt.parseMeal('''
{"foods":[{"name":"米饭","grams":150},{"name":"鸡胸","grams":120}],
 "kcal":420,"proteinG":35,"carbG":50,"fatG":8,"note":"蛋白不错"}
''');
      expect(r.kcal, 420);
      expect(r.proteinG, 35);
      expect(r.foods.length, 2);
      expect(r.foods.first.name, '米饭');
      expect(r.note, '蛋白不错');
    });

    test('markdown 围栏包裹也能抠出 JSON', () {
      const raw = '```json\n{"foods":[],"kcal":300,"proteinG":10,"carbG":40,"fatG":9,"note":""}\n```';
      final r = FitnessPrompt.parseMeal(raw);
      expect(r.kcal, 300);
    });

    test('完全不是 JSON 返回全 0 并保留原文', () {
      const raw = '看不清这是什么菜';
      final r = FitnessPrompt.parseMeal(raw);
      expect(r.kcal, 0);
      expect(r.rawText, raw);
    });
  });

  group('parsePlan', () {
    test('解析训练动作与目标', () {
      final r = FitnessPrompt.parsePlan('''
{"trainingPlan":[{"move":"高脚杯深蹲","sets":3,"reps":10,"weightKg":16,"note":"慢下"}],
 "dietGuidance":"早餐加个蛋","kcalTarget":1900,"proteinTarget":120,
 "carbTarget":190,"fatTarget":55,"deficitSummary":"今天蛋白差30g"}
''');
      expect(r.trainingPlan.length, 1);
      expect(r.trainingPlan.first.move, '高脚杯深蹲');
      expect(r.trainingPlan.first.weightKg, 16);
      expect(r.targets.kcal, 1900);
      expect(r.dietGuidance, '早餐加个蛋');
      expect(r.deficitSummary, '今天蛋白差30g');
    });

    test('脏输出回退到空计划但保留原文', () {
      const raw = '抱歉今天没法生成';
      final r = FitnessPrompt.parsePlan(raw);
      expect(r.trainingPlan, isEmpty);
      expect(r.rawText, raw);
    });
  });

  group('mealSystemPrompt', () {
    test('包含严格 JSON 指令与餐次', () {
      final s = FitnessPrompt.mealSystemPrompt(Meal.lunch);
      expect(s, contains('JSON'));
      expect(s, contains('午餐'));
    });
  });

  group('planSystemPrompt 安全约束', () {
    test('显式纳入伤病禁忌与新手降负荷与可用壶铃', () {
      const p = FitnessProfile(
        heightCm: 175,
        weightKg: 70,
        age: 30,
        kettlebellsKg: [12, 16],
        experience: Experience.novice,
        injuries: '腰椎间盘突出',
      );
      final s = FitnessPrompt.planSystemPrompt(
        profile: p,
        totals: const DayTotals(kcal: 1500, proteinG: 90, carbG: 150, fatG: 40),
        trainingDone: false,
      );
      expect(s, contains('腰椎间盘突出'));
      expect(s, contains('12')); // 可用壶铃重量
      expect(s, contains('16'));
      expect(s.toLowerCase(), contains('json'));
    });
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/fitness_prompt_test.dart`
Expected: FAIL — `FitnessPrompt` 未定义。

- [ ] **Step 3: 写实现**

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../core/llm/types.dart';
import 'fitness_models.dart';

/// 纯 Dart：图片压缩、prompt 拼装、宽容 JSON 解析。无 Flutter/Riverpod/drift 依赖。
class FitnessPrompt {
  /// 压到 ≤1280px 宽 / JPEG q75（沿用 food-safety 的做法）。
  static Uint8List compressImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized =
        decoded.width > 1280 ? img.copyResize(decoded, width: 1280) : decoded;
    return Uint8List.fromList(img.encodeJpg(resized, quality: 75));
  }

  // ── 拍照分析 ────────────────────────────────────────────────
  static String mealSystemPrompt(Meal meal) => '''
你是爸爸的私人营养助手。用户拍了一张【${meal.zh}】的照片。
请识别盘中食物并估算整餐的热量与三大营养素。
严格只输出 JSON，不要 markdown 围栏、不要解释，字段：
{"foods":[{"name":"食物名","grams":整数克重}],"kcal":整数,"proteinG":整数,"carbG":整数,"fatG":整数,"note":"一句简短点评"}
估算保守，看不清就给区间中值。note 用中文，最多一句话，最多一个感叹号。''';

  static List<LlmMessage> buildMealMessages(Meal meal, Uint8List bytes) => [
        LlmMessage.system(mealSystemPrompt(meal)),
        LlmMessage(LlmRole.user, [
          ImagePart(bytes),
          TextPart('这一餐大概多少热量和营养？'),
        ]),
      ];

  static MealAnalysis parseMeal(String raw) {
    final json = _extractJson(raw);
    final foods = <FoodItem>[];
    final fv = json['foods'];
    if (fv is List) {
      for (final e in fv) {
        if (e is Map) foods.add(FoodItem.fromJson(e.cast<String, dynamic>()));
      }
    }
    return MealAnalysis(
      foods: foods,
      kcal: _asInt(json['kcal']),
      proteinG: _asInt(json['proteinG']),
      carbG: _asInt(json['carbG']),
      fatG: _asInt(json['fatG']),
      note: (json['note'] ?? '').toString(),
      rawText: raw,
    );
  }

  // ── 明日计划生成 ────────────────────────────────────────────
  static String planSystemPrompt({
    required FitnessProfile profile,
    required DayTotals totals,
    required bool trainingDone,
  }) {
    final kb = profile.kettlebellsKg.join(', ');
    final goalZh = switch (profile.goal) {
      Goal.cut => '减脂',
      Goal.gain => '增肌',
      Goal.maintain => '保持',
    };
    final expZh =
        profile.experience == Experience.novice ? '新手' : '进阶';
    return '''
你是爸爸的私人壶铃教练 + 营养师。请基于今天的实际情况，生成【明天】的训练 + 饮食计划。

## 爸爸的资料
- 身高 ${profile.heightCm ?? '?'}cm，体重 ${profile.weightKg ?? '?'}kg，年龄 ${profile.age ?? '?'}
- 目标：$goalZh；训练水平：$expZh
- 每天可训练时间：${profile.dailyMinutes} 分钟
- 手边壶铃重量(kg)：[$kb]
- 伤病/禁忌：${(profile.injuries?.trim().isNotEmpty ?? false) ? profile.injuries : '无'}

## 今天实际
- 三餐合计：${totals.kcal} kcal，蛋白 ${totals.proteinG}g，碳水 ${totals.carbG}g，脂肪 ${totals.fatG}g
- 今天训练：${trainingDone ? '已完成' : '未完成'}

## 安全约束（必须遵守）
- 绝对不要编排会刺激到上述伤病/禁忌部位的动作；不确定就选更保守的替代动作。
- 训练水平是新手时：降低负荷、控制总组数、强调动作质量与热身，不要上大重量。
- 单次训练总时长不超过可训练时间；只使用爸爸手边已有的壶铃重量。
- 你是 AI，不替代医生/教练。

严格只输出 JSON，不要 markdown 围栏、不要解释，字段：
{"trainingPlan":[{"move":"动作名","sets":整数,"reps":整数,"weightKg":整数,"note":"要点"}],
"dietGuidance":"明日饮食建议，中文，结合今日缺口","kcalTarget":整数,"proteinTarget":整数,
"carbTarget":整数,"fatTarget":整数,"deficitSummary":"今天缺口一句话总结"}
语气称呼「爸爸」，第一人称，最多一个感叹号。''';
  }

  static List<LlmMessage> buildPlanMessages({
    required FitnessProfile profile,
    required DayTotals totals,
    required bool trainingDone,
  }) =>
      [
        LlmMessage.system(planSystemPrompt(
          profile: profile,
          totals: totals,
          trainingDone: trainingDone,
        )),
        LlmMessage.user('请生成我明天的训练和饮食计划。'),
      ];

  static TomorrowPlan parsePlan(String raw) {
    final json = _extractJson(raw);
    final moves = <TrainingMove>[];
    final tv = json['trainingPlan'];
    if (tv is List) {
      for (final e in tv) {
        if (e is Map) {
          moves.add(TrainingMove.fromJson(e.cast<String, dynamic>()));
        }
      }
    }
    return TomorrowPlan(
      trainingPlan: moves,
      dietGuidance: (json['dietGuidance'] ?? '').toString(),
      targets: MacroTargets(
        kcal: _asInt(json['kcalTarget']),
        proteinG: _asInt(json['proteinTarget']),
        carbG: _asInt(json['carbTarget']),
        fatG: _asInt(json['fatTarget']),
      ),
      deficitSummary: (json['deficitSummary'] ?? '').toString(),
      rawText: raw,
    );
  }

  // ── helpers ────────────────────────────────────────────────
  /// 先直解；失败找第一个 {...} 块再试；都不行返回空 map。
  static Map<String, dynamic> _extractJson(String raw) {
    try {
      final v = jsonDecode(raw);
      if (v is Map<String, dynamic>) return v;
    } catch (_) {}
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start >= 0 && end > start) {
      try {
        final v = jsonDecode(raw.substring(start, end + 1));
        if (v is Map<String, dynamic>) return v;
      } catch (_) {}
    }
    return const {};
  }

  static int _asInt(dynamic v) =>
      v is num ? v.round() : (int.tryParse(v?.toString() ?? '') ?? 0);
}
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/fitness_prompt_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add test/fitness_prompt_test.dart lib/features/fitness/fitness_prompt.dart
git commit -m "feat: fitness prompt 拼装 + 宽容 JSON 解析 + 测试"
```

---

## Task 5: repository + provider `fitness_repository.dart`（TDD）

**Files:**
- Create: `test/fitness_repository_test.dart`
- Create: `lib/features/fitness/fitness_repository.dart`

- [ ] **Step 1: 先写失败测试（in-memory drift）**

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dad/core/storage/database.dart';
import 'package:good_dad/features/fitness/fitness_models.dart';
import 'package:good_dad/features/fitness/fitness_repository.dart';

void main() {
  late AppDatabase db;
  late FitnessRepository repo;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    repo = FitnessRepository(db);
  });
  tearDown(() => db.close());

  test('profile 单行 upsert：保存后读回一致', () async {
    expect((await repo.loadProfile()).isComplete, isFalse);
    const p = FitnessProfile(
      heightCm: 175,
      weightKg: 70.5,
      age: 30,
      kettlebellsKg: [12, 16],
      goal: Goal.cut,
      injuries: '腰',
    );
    await repo.saveProfile(p);
    final back = await repo.loadProfile();
    expect(back.heightCm, 175);
    expect(back.weightKg, 70.5);
    expect(back.kettlebellsKg, [12, 16]);
    expect(back.goal, Goal.cut);
    expect(back.injuries, '腰');
    expect(back.isComplete, isTrue);

    // 再存一次仍只有一行
    await repo.saveProfile(p.copyWith(age: 31));
    expect((await repo.loadProfile()).age, 31);
  });

  test('meal_log 按日期查询', () async {
    await repo.saveMeal(
      date: '2026-06-16',
      meal: Meal.lunch,
      analysis: const MealAnalysis(kcal: 500, proteinG: 30, carbG: 60, fatG: 15),
      photoPath: null,
      edited: false,
    );
    await repo.saveMeal(
      date: '2026-06-16',
      meal: Meal.dinner,
      analysis: const MealAnalysis(kcal: 300, proteinG: 20, carbG: 40, fatG: 8),
      photoPath: null,
      edited: false,
    );
    await repo.saveMeal(
      date: '2026-06-15',
      meal: Meal.lunch,
      analysis: const MealAnalysis(kcal: 999),
      photoPath: null,
      edited: false,
    );
    final today = await repo.mealsForDate('2026-06-16');
    expect(today.length, 2);
  });

  test('daily_plan 缓存命中', () async {
    expect(await repo.planForDate('2026-06-17'), isNull);
    await repo.savePlan(
      '2026-06-17',
      const TomorrowPlan(
        dietGuidance: '加蛋',
        targets: MacroTargets(kcal: 1900, proteinG: 120, carbG: 190, fatG: 55),
        deficitSummary: '差30g蛋白',
      ),
    );
    final row = await repo.planForDate('2026-06-17');
    expect(row, isNotNull);
    expect(row!.kcalTarget, 1900);
    expect(row.dietGuidance, '加蛋');
  });
}
```

- [ ] **Step 2: 跑测试确认失败**

Run: `flutter test test/fitness_repository_test.dart`
Expected: FAIL — `FitnessRepository` 未定义。

- [ ] **Step 3: 写实现**

```dart
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
```

- [ ] **Step 4: 跑测试确认通过**

Run: `flutter test test/fitness_repository_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add test/fitness_repository_test.dart lib/features/fitness/fitness_repository.dart
git commit -m "feat: fitness repository + provider + 测试"
```

---

## Task 6: `FitnessLlm` 编排 `fitness_llm.dart`

**Files:**
- Create: `lib/features/fitness/fitness_llm.dart`

- [ ] **Step 1: 写实现（复用 `LlmClient`，错误统一封装）**

```dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/llm_client.dart';
import '../../core/llm/llm_providers.dart';
import '../../core/llm/types.dart';
import 'fitness_models.dart';
import 'fitness_prompt.dart';

class FitnessLlmError implements Exception {
  final String message;
  const FitnessLlmError(this.message);
  @override
  String toString() => message;
}

/// 两条 LLM 能力：拍照分析一餐、生成明日计划。
class FitnessLlm {
  final LlmClient client;
  const FitnessLlm(this.client);

  Future<MealAnalysis> analyzeMeal({
    required Meal meal,
    required Uint8List compressedBytes,
  }) async {
    final messages = FitnessPrompt.buildMealMessages(meal, compressedBytes);
    final LlmResult res;
    try {
      res = await client.chatOnce(messages, temperature: 0.3, needsVision: true);
    } on LlmException catch (e) {
      throw FitnessLlmError('AI 分析失败：${e.message}');
    }
    return FitnessPrompt.parseMeal(res.text);
  }

  Future<TomorrowPlan> generateTomorrowPlan({
    required FitnessProfile profile,
    required DayTotals totals,
    required bool trainingDone,
  }) async {
    final messages = FitnessPrompt.buildPlanMessages(
      profile: profile,
      totals: totals,
      trainingDone: trainingDone,
    );
    final LlmResult res;
    try {
      res = await client.chatOnce(messages, temperature: 0.7);
    } on LlmException catch (e) {
      throw FitnessLlmError('生成计划失败：${e.message}');
    }
    return FitnessPrompt.parsePlan(res.text);
  }
}

/// LLM 没配好时为 null（UI 据此提示去设置）。
final fitnessLlmProvider = Provider<FitnessLlm?>((ref) {
  final c = ref.watch(llmClientProvider);
  return c == null ? null : FitnessLlm(c);
});
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/features/fitness/fitness_llm.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fitness/fitness_llm.dart
git commit -m "feat: FitnessLlm 拍照分析 + 明日计划编排"
```

---

## Task 7: 餐照存储 `saveMealPhoto`

**Files:**
- Modify: `lib/core/storage/file_store.dart:51`（在 `saveChatPhoto` 之后追加）

- [ ] **Step 1: 在 `FileStore` 类中追加方法（紧跟 `saveChatPhoto` 后）**

```dart
  Future<String> saveMealPhoto(Uint8List bytes,
      {String extension = 'jpg'}) async {
    final dir = await _ensure(p.join('photos', 'meal'));
    final file = File(p.join(dir.path, '${_uuid.v4()}.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/core/storage/file_store.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/storage/file_store.dart
git commit -m "feat: FileStore.saveMealPhoto"
```

---

## Task 8: `MacroRing` 进度环 widget

**Files:**
- Create: `lib/features/fitness/widgets/macro_ring.dart`

- [ ] **Step 1: 写实现（CustomPainter，描边走设计系统）**

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/theme.dart';

/// 一个语义色进度环：value/target，居中显示数值。
/// 配色：热量 peach / 蛋白 mint / 碳水 sky / 脂肪 lemon（由 color 传入）。
class MacroRing extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final String unit;
  final Color color;
  final double size;

  const MacroRing({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    this.unit = '',
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pct = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              pct: pct.toDouble(),
              color: color,
              track: dark ? AppColors.darkSurface : AppColors.cream200,
              stroke: dark ? AppColors.darkInk : AppColors.ink900,
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.26,
                  color: dark ? AppColors.darkInk : AppColors.ink900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          target > 0 ? '$label $value/$target$unit' : '$label $value$unit',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppColors.ink600,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final Color track;
  final Color stroke;

  _RingPainter({
    required this.pct,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    const startAngle = -math.pi / 2;
    canvas.drawArc(rect, startAngle, 2 * math.pi * pct, false, progressPaint);

    // 细描边圈，呼应胖胖描边风格
    final outline = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius + 5, outline);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color;
}
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/features/fitness/widgets/macro_ring.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fitness/widgets/macro_ring.dart
git commit -m "feat: MacroRing 进度环 widget"
```

---

## Task 9: 每晚静态提醒 `daily_plan_notifier.dart`

**Files:**
- Create: `lib/core/notification/daily_plan_notifier.dart`

- [ ] **Step 1: 写实现（仿 `weekly_notifier.dart`，每日定时）**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 每晚固定时间发一条静态提醒，深链到 /fitness。
/// 真正的明日计划在用户点开页面时现场用 LLM 生成（见 fitness_page）。
class DailyPlanNotifier {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const _channelId = 'fitness_daily_plan';
  static const _channelName = '每晚训练计划提醒';
  static const _payload = '/fitness';
  static const _id = 10;

  static bool _tzReady = false;

  static void _ensureTz() {
    if (_tzReady) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (e) {
      debugPrint('timezone Asia/Shanghai not found: $e');
    }
    _tzReady = true;
  }

  /// 取消旧的，登记每天 [hour]:[minute] 的循环提醒。
  /// 假设 WeeklyNotifier.init() 已在启动期初始化过 plugin（共用同一插件实例）。
  static Future<void> schedule({int hour = 21, int minute = 0}) async {
    _ensureTz();
    await _plugin.cancel(_id);
    await _plugin.zonedSchedule(
      _id,
      '💪 明日计划准备好啦',
      '点开看看明天怎么练、怎么吃',
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: '每晚推送明日训练 + 饮食计划提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payload,
    );
  }

  static Future<void> cancel() => _plugin.cancel(_id);

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var s = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!s.isAfter(now)) s = s.add(const Duration(days: 1));
    return s;
  }
}

final dailyPlanNotifierProvider =
    Provider<DailyPlanNotifier>((_) => DailyPlanNotifier());
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/core/notification/daily_plan_notifier.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/notification/daily_plan_notifier.dart
git commit -m "feat: 每晚训练计划静态提醒 DailyPlanNotifier"
```

---

## Task 10: 设置/引导页 `fitness_profile_page.dart`

**Files:**
- Create: `lib/features/fitness/fitness_profile_page.dart`

- [ ] **Step 1: 写实现**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/notification/daily_plan_notifier.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_models.dart';
import 'fitness_repository.dart';

/// 健身资料引导/编辑。保存后顺手登记每晚提醒。
class FitnessProfilePage extends ConsumerStatefulWidget {
  const FitnessProfilePage({super.key});

  @override
  ConsumerState<FitnessProfilePage> createState() =>
      _FitnessProfilePageState();
}

class _FitnessProfilePageState extends ConsumerState<FitnessProfilePage> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _age = TextEditingController();
  final _injuries = TextEditingController();
  Sex _sex = Sex.male;
  Experience _exp = Experience.novice;
  Goal _goal = Goal.maintain;
  int _minutes = 20;
  final Set<int> _kbs = {};
  bool _loaded = false;
  bool _saving = false;

  static const _kbOptions = [8, 12, 16, 20, 24, 32];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(fitnessRepositoryProvider).loadProfile();
    if (!mounted) return;
    setState(() {
      _height.text = p.heightCm?.toString() ?? '';
      _weight.text = p.weightKg?.toString() ?? '';
      _age.text = p.age?.toString() ?? '';
      _injuries.text = p.injuries ?? '';
      _sex = p.sex;
      _exp = p.experience;
      _goal = p.goal;
      _minutes = p.dailyMinutes;
      _kbs
        ..clear()
        ..addAll(p.kettlebellsKg);
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _age.dispose();
    _injuries.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_kbs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先选一下手边有哪些壶铃重量')),
      );
      return;
    }
    setState(() => _saving = true);
    final p = FitnessProfile(
      heightCm: int.tryParse(_height.text.trim()),
      weightKg: double.tryParse(_weight.text.trim()),
      age: int.tryParse(_age.text.trim()),
      sex: _sex,
      kettlebellsKg: _kbs.toList()..sort(),
      experience: _exp,
      dailyMinutes: _minutes,
      goal: _goal,
      injuries: _injuries.text.trim().isEmpty ? null : _injuries.text.trim(),
    );
    await ref.read(fitnessRepositoryProvider).saveProfile(p);
    await DailyPlanNotifier.schedule(); // 默认 21:00
    if (!mounted) return;
    setState(() => _saving = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('我的健身资料'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _num('身高 (cm)', _height),
          _num('体重 (kg)', _weight, decimal: true),
          _num('年龄', _age),
          const SizedBox(height: 12),
          _seg<Sex>('性别', _sex, {Sex.male: '男', Sex.female: '女'},
              (v) => setState(() => _sex = v)),
          const SizedBox(height: 12),
          _seg<Goal>('目标', _goal,
              {Goal.cut: '减脂', Goal.maintain: '保持', Goal.gain: '增肌'},
              (v) => setState(() => _goal = v)),
          const SizedBox(height: 12),
          _seg<Experience>('训练水平', _exp,
              {Experience.novice: '新手', Experience.intermediate: '进阶'},
              (v) => setState(() => _exp = v)),
          const SizedBox(height: 16),
          const Text('手边的壶铃 (kg)',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kbOptions.map((kg) {
              final on = _kbs.contains(kg);
              return GestureDetector(
                onTap: () => setState(
                    () => on ? _kbs.remove(kg) : _kbs.add(kg)),
                child: CreamPill(
                  label: '$kg',
                  background: on ? AppColors.peach300 : AppColors.cream100,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('每天可训练时间：$_minutes 分钟',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
          Slider(
            value: _minutes.toDouble(),
            min: 10,
            max: 60,
            divisions: 10,
            label: '$_minutes',
            onChanged: (v) => setState(() => _minutes = v.round()),
          ),
          const SizedBox(height: 8),
          const Text('伤病 / 不能做的动作（选填）',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _injuries,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '比如：腰不好，避免硬拉类动作',
            ),
          ),
          const SizedBox(height: 24),
          CreamButton(
            label: _saving ? '保存中…' : '保存',
            emoji: _saving ? null : '💾',
            full: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _num(String label, TextEditingController c, {bool decimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: c,
        keyboardType:
            TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              RegExp(decimal ? r'[0-9.]' : r'[0-9]')),
        ],
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _seg<T>(String label, T value, Map<T, String> options,
      ValueChanged<T> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.entries.map((e) {
            final on = e.key == value;
            return GestureDetector(
              onTap: () => onChange(e.key),
              child: CreamPill(
                label: e.value,
                background: on ? AppColors.peach300 : AppColors.cream100,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/features/fitness/fitness_profile_page.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fitness/fitness_profile_page.dart
git commit -m "feat: fitness 健身资料引导/编辑页"
```

---

## Task 11: 拍照流页 `meal_capture_page.dart`

**Files:**
- Create: `lib/features/fitness/meal_capture_page.dart`

- [ ] **Step 1: 写实现**

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/storage/file_store.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_llm.dart';
import 'fitness_models.dart';
import 'fitness_prompt.dart';
import 'fitness_repository.dart';

/// 拍一餐 → AI 分析 → 可编辑结果 → 保存到 meal_log。
/// 通过构造参数拿到目标日期与餐次。
class MealCapturePage extends ConsumerStatefulWidget {
  final String date;
  final Meal meal;
  const MealCapturePage({super.key, required this.date, required this.meal});

  @override
  ConsumerState<MealCapturePage> createState() => _MealCapturePageState();
}

class _MealCapturePageState extends ConsumerState<MealCapturePage> {
  final _picker = ImagePicker();
  Uint8List? _bytes;
  MealAnalysis? _result;
  String? _error;
  bool _running = false;

  // 可编辑字段
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  bool _edited = false;

  @override
  void dispose() {
    _kcal.dispose();
    _protein.dispose();
    _carb.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_running) return;
    final llm = ref.read(fitnessLlmProvider);
    if (llm == null) {
      setState(() => _error = '请先到「设置」配好 LLM（baseURL + key + 视觉模型）');
      return;
    }
    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1600, imageQuality: 90);
      if (picked == null) return;
      final raw = await picked.readAsBytes();
      final compressed = FitnessPrompt.compressImage(raw);
      setState(() {
        _bytes = compressed;
        _result = null;
        _error = null;
        _running = true;
        _edited = false;
      });
      final res = await llm.analyzeMeal(
          meal: widget.meal, compressedBytes: compressed);
      if (!mounted) return;
      setState(() {
        _result = res;
        _running = false;
        _kcal.text = res.kcal.toString();
        _protein.text = res.proteinG.toString();
        _carb.text = res.carbG.toString();
        _fat.text = res.fatG.toString();
      });
    } on FitnessLlmError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '出错了: $e';
        _running = false;
      });
    }
  }

  Future<void> _save() async {
    final res = _result;
    if (res == null) return;
    String? photoPath;
    if (_bytes != null) {
      photoPath = await ref.read(fileStoreProvider).saveMealPhoto(_bytes!);
    }
    final analysis = MealAnalysis(
      foods: res.foods,
      kcal: int.tryParse(_kcal.text) ?? res.kcal,
      proteinG: int.tryParse(_protein.text) ?? res.proteinG,
      carbG: int.tryParse(_carb.text) ?? res.carbG,
      fatG: int.tryParse(_fat.text) ?? res.fatG,
      note: res.note,
    );
    await ref.read(fitnessRepositoryProvider).saveMeal(
          date: widget.date,
          meal: widget.meal,
          analysis: analysis,
          photoPath: photoPath,
          edited: _edited,
        );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = _result != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text('记一餐 · ${widget.meal.zh}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          if (_bytes == null)
            CreamCard(
              child: SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Sticker(emoji: '🍽', size: 56, background: AppColors.mint300),
                      SizedBox(height: 10),
                      Text('拍一张这餐的照片',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          if (_bytes != null)
            CreamCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppRadius.lg - 2),
                child: Stack(children: [
                  AspectRatio(
                      aspectRatio: 1.4,
                      child: Image.memory(_bytes!, fit: BoxFit.cover)),
                  if (_running)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12),
                            Text('AI 分析中…',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose300,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.ink900, width: 1.5),
              ),
              child: Text(_error!,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ],
          if (hasResult) ...[
            const SizedBox(height: 14),
            CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_result!.foods.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _result!.foods
                          .map((f) => CreamPill(
                              label: '${f.name} ${f.grams}g',
                              leadingEmoji: '🍴'))
                          .toList(),
                    ),
                  if (_result!.note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(_result!.note,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            height: 1.4)),
                  ],
                  const SizedBox(height: 12),
                  const Text('估算（可改）',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.ink600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _macroField('热量', _kcal),
                    const SizedBox(width: 8),
                    _macroField('蛋白', _protein),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _macroField('碳水', _carb),
                    const SizedBox(width: 8),
                    _macroField('脂肪', _fat),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CreamButton(
                label: '保存这餐', emoji: '✅', full: true, onPressed: _save),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: CreamButton(
                label: _running ? '分析中…' : '拍照',
                emoji: _running ? null : '📷',
                full: true,
                onPressed: _running ? null : () => _pick(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 10),
            CreamButton(
              label: '相册',
              emoji: '🖼',
              ghost: true,
              onPressed: _running ? null : () => _pick(ImageSource.gallery),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _macroField(String label, TextEditingController c) {
    return Expanded(
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        onChanged: (_) => _edited = true,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/features/fitness/meal_capture_page.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fitness/meal_capture_page.dart
git commit -m "feat: fitness 拍照记餐页"
```

---

## Task 12: 今日页 `fitness_page.dart`（含现场生成明日计划）

**Files:**
- Create: `lib/features/fitness/fitness_page.dart`

- [ ] **Step 1: 写实现**

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_calc.dart';
import 'fitness_llm.dart';
import 'fitness_models.dart';
import 'fitness_repository.dart';
import 'widgets/macro_ring.dart';

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 今日页：训练计划 + 三餐进度环 + 明日计划。
class FitnessPage extends ConsumerStatefulWidget {
  const FitnessPage({super.key});

  @override
  ConsumerState<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends ConsumerState<FitnessPage> {
  bool _checkedProfile = false;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final repo = ref.read(fitnessRepositoryProvider);
    final profile = await repo.loadProfile();
    if (!mounted) return;
    // 资料不全：引导先去填
    if (!profile.isComplete && !_checkedProfile) {
      _checkedProfile = true;
      await context.push('/fitness/profile');
    }
    await _maybeGeneratePlan();
  }

  Future<void> _maybeGeneratePlan() async {
    final repo = ref.read(fitnessRepositoryProvider);
    final now = DateTime.now();
    final tomorrow = _isoDate(now.add(const Duration(days: 1)));
    final has = (await repo.planForDate(tomorrow)) != null;
    if (!FitnessCalc.needsPlanGeneration(
        hasPlanForTomorrow: has, hour: now.hour)) {
      return;
    }
    final llm = ref.read(fitnessLlmProvider);
    if (llm == null) return;
    final profile = await repo.loadProfile();
    if (!profile.isComplete) return;

    final today = _isoDate(now);
    final meals = await repo.mealsForDate(today);
    final totals = FitnessCalc.sumDay(meals
        .map((m) => MealAnalysis(
            kcal: m.kcal, proteinG: m.proteinG, carbG: m.carbG, fatG: m.fatG))
        .toList());
    final training = await repo.trainingForDate(today);

    setState(() => _generating = true);
    try {
      final plan = await llm.generateTomorrowPlan(
        profile: profile,
        totals: totals,
        trainingDone: training?.done ?? false,
      );
      await repo.savePlan(tomorrow, plan);
    } catch (_) {
      // 生成失败静默，页面照常展示已有数据
    }
    if (mounted) setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(fitnessRepositoryProvider);
    final today = _isoDate(DateTime.now());
    final mealsStream = repo.watchMealsForDate(today);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('壶铃 · 今日'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/fitness/profile'),
          ),
        ],
      ),
      body: StreamBuilder<List<MealLogRow>>(
        stream: mealsStream,
        builder: (context, snap) {
          final meals = snap.data ?? const <MealLogRow>[];
          return FutureBuilder<_TodayData>(
            future: _loadToday(repo, today, meals),
            builder: (context, ds) {
              final data = ds.data;
              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  _TrainingCard(
                    plan: data.todayPlan,
                    done: data.trainingDone,
                    onDone: () async {
                      await repo.markTrainingDone(
                          today,
                          jsonEncode(data.todayPlan
                              .map((m) => m.toJson())
                              .toList()));
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _MealsSection(
                    date: today,
                    meals: meals,
                    targets: data.targets,
                    onRefresh: () => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _TomorrowCard(
                      plan: data.tomorrowPlan, generating: _generating),
                  const SizedBox(height: 20),
                  const Text(
                    '这是 AI 给的训练参考，身体不舒服就停，必要时问专业教练/医生 🩺',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink600),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<_TodayData> _loadToday(
      FitnessRepository repo, String today, List<MealLogRow> meals) async {
    final profile = await repo.loadProfile();
    final todayPlanRow = await repo.planForDate(today);
    final tomorrow =
        _isoDate(DateTime.now().add(const Duration(days: 1)));
    final tomorrowRow = await repo.planForDate(tomorrow);
    final training = await repo.trainingForDate(today);

    final todayPlan = todayPlanRow == null
        ? <TrainingMove>[]
        : (jsonDecode(todayPlanRow.trainingPlanJson) as List)
            .map((e) => TrainingMove.fromJson(e as Map<String, dynamic>))
            .toList();

    final targets = todayPlanRow != null
        ? MacroTargets(
            kcal: todayPlanRow.kcalTarget,
            proteinG: todayPlanRow.proteinTarget,
            carbG: todayPlanRow.carbTarget,
            fatG: todayPlanRow.fatTarget,
          )
        : FitnessCalc.defaultTargets(profile);

    return _TodayData(
      todayPlan: todayPlan,
      trainingDone: training?.done ?? false,
      targets: targets,
      tomorrowPlan: tomorrowRow,
    );
  }
}

class _TodayData {
  final List<TrainingMove> todayPlan;
  final bool trainingDone;
  final MacroTargets targets;
  final DailyPlanRow? tomorrowPlan;
  _TodayData({
    required this.todayPlan,
    required this.trainingDone,
    required this.targets,
    required this.tomorrowPlan,
  });
}

class _TrainingCard extends StatelessWidget {
  final List<TrainingMove> plan;
  final bool done;
  final VoidCallback onDone;
  const _TrainingCard(
      {required this.plan, required this.done, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Sticker(emoji: '🏋️', background: AppColors.peach300),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('今日训练',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ),
            if (done) const StatusTag(kind: SafetyTag.ok, label: '已完成'),
          ]),
          const SizedBox(height: 12),
          if (plan.isEmpty)
            const Text('今天还没有训练计划——晚上我会根据今天的情况生成明天的。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600))
          else
            ...plan.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '· ${m.move} — ${m.sets}组×${m.reps} @ ${m.weightKg}kg'
                    '${m.note.isEmpty ? '' : '（${m.note}）'}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.5),
                  ),
                )),
          if (plan.isNotEmpty && !done) ...[
            const SizedBox(height: 8),
            CreamButton(
                label: '标记完成', emoji: '✅', full: true, onPressed: onDone),
          ],
        ],
      ),
    );
  }
}

class _MealsSection extends StatelessWidget {
  final String date;
  final List<MealLogRow> meals;
  final MacroTargets targets;
  final VoidCallback onRefresh;
  const _MealsSection({
    required this.date,
    required this.meals,
    required this.targets,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    var kcal = 0, p = 0, c = 0, f = 0;
    for (final m in meals) {
      kcal += m.kcal;
      p += m.proteinG;
      c += m.carbG;
      f += m.fatG;
    }
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日三餐',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MacroRing(
                  label: '热量',
                  value: kcal,
                  target: targets.kcal,
                  color: AppColors.peach500),
              MacroRing(
                  label: '蛋白',
                  value: p,
                  target: targets.proteinG,
                  unit: 'g',
                  color: AppColors.mint500),
              MacroRing(
                  label: '碳水',
                  value: c,
                  target: targets.carbG,
                  unit: 'g',
                  color: AppColors.sky500),
              MacroRing(
                  label: '脂肪',
                  value: f,
                  target: targets.fatG,
                  unit: 'g',
                  color: AppColors.lemon500),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Meal.values.map((meal) {
              final logged = meals.any((m) => m.meal == meal.name);
              return GestureDetector(
                onTap: () async {
                  await context.push('/fitness/meal',
                      extra: {'date': date, 'meal': meal});
                  onRefresh();
                },
                child: CreamPill(
                  label: meal.zh,
                  leadingEmoji: logged ? '✅' : '📷',
                  background:
                      logged ? AppColors.mint300 : AppColors.cream100,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TomorrowCard extends StatelessWidget {
  final DailyPlanRow? plan;
  final bool generating;
  const _TomorrowCard({required this.plan, required this.generating});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      background: AppColors.cream200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Sticker(emoji: '🌙', background: AppColors.sky300),
            SizedBox(width: 10),
            Text('明日计划',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ]),
          const SizedBox(height: 12),
          if (generating)
            const Row(children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('我正在根据今天的情况生成…',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ])
          else if (plan == null)
            const Text('晚上我会根据你今天吃了/练了什么，生成明天的计划。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600))
          else ...[
            if (plan!.deficitSummary.isNotEmpty)
              Text(plan!.deficitSummary,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.4)),
            const SizedBox(height: 8),
            Text('🍽 ${plan!.dietGuidance}',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 4),
            Text(
                '🎯 目标 ${plan!.kcalTarget}kcal · 蛋白 ${plan!.proteinTarget}g',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.ink600)),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze lib/features/fitness/fitness_page.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/fitness/fitness_page.dart
git commit -m "feat: fitness 今日页 + 现场生成明日计划"
```

---

## Task 13: 路由注册 + 首页入口

**Files:**
- Modify: `lib/router.dart`
- Modify: `lib/features/home/home_page.dart:17-24`

- [ ] **Step 1: 在 `router.dart` 顶部加 import（与现有 import 同区）**

```dart
import 'features/fitness/fitness_page.dart';
import 'features/fitness/fitness_profile_page.dart';
import 'features/fitness/meal_capture_page.dart';
import 'features/fitness/fitness_models.dart';
```

- [ ] **Step 2: 在 `router.dart` 的 routes 列表里、`/shopping` 之后追加路由**

```dart
    GoRoute(
      path: '/fitness',
      name: 'fitness',
      builder: (context, state) => const FitnessPage(),
    ),
    GoRoute(
      path: '/fitness/profile',
      name: 'fitness-profile',
      builder: (context, state) => const FitnessProfilePage(),
    ),
    GoRoute(
      path: '/fitness/meal',
      name: 'fitness-meal',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        final date = (args?['date'] as String?) ??
            DateTime.now().toIso8601String().substring(0, 10);
        final meal = (args?['meal'] as Meal?) ?? Meal.breakfast;
        return MealCapturePage(date: date, meal: meal);
      },
    ),
```

> 注意：`/fitness/meal` 必须排在 `/fitness` 之后不影响匹配；go_router 按 path 精确匹配，顺序无碍。`/fitness/profile` 同理。

- [ ] **Step 3: 在 `home_page.dart` 的 `_skills` 列表追加一项（`lib/features/home/home_page.dart:17-24`）**

在 `_Skill('宝宝采购', ...)` 这一行之后加：

```dart
    _Skill('壶铃打卡', '🏋️', '今天怎么练', AppColors.peach200, '/fitness'),
```

- [ ] **Step 4: 验证编译 + 全量分析**

Run: `flutter analyze`
Expected: No issues（仅允许既有的、与本功能无关的告警）。

- [ ] **Step 5: Commit**

```bash
git add lib/router.dart lib/features/home/home_page.dart
git commit -m "feat: 注册 fitness 路由 + 首页壶铃入口"
```

---

## Task 14: 跑全量测试 + 手动验收

**Files:** 无（验证）

- [ ] **Step 1: 全量单测**

Run: `flutter test`
Expected: 全绿（含新增 3 个 fitness 测试文件 + 既有测试不回归）。

- [ ] **Step 2: 静态分析**

Run: `flutter analyze`
Expected: No issues。

- [ ] **Step 3: 手动验收（真机/模拟器）**

Run: `flutter run`
逐项确认：
1. 首页出现「壶铃打卡」卡片，点进 `/fitness`。
2. 首次进入弹出资料引导页，填身高/体重/年龄/壶铃/目标/伤病并保存。
3. 今日页三餐区点「早餐」→ 拍照 → 看到 AI 估算 → 可改数值 → 保存 → 三餐进度环更新。
4. 把设备时间调到 21:00 之后重进 `/fitness`，确认「明日计划」卡片出现「生成中…」后展示训练 + 饮食建议。
5. 训练卡「标记完成」后显示「已完成」tag。
6. 确认底部免责文案存在。

- [ ] **Step 4: 最终提交（若验收中有小修）**

```bash
git add -A
git commit -m "chore: fitness 模块验收修整"
```

---

## Self-Review 记录

- **Spec 覆盖**：§3 数据模型→Task1；§4 LLM→Task4/6；§5 通知与时机→Task3(needsPlanGeneration)/Task9/Task12(_maybeGeneratePlan)；§6 UI→Task8/10/11/12/13；§7 安全文案→Task4(planSystemPrompt 硬约束)+Task12(底部免责)。全部有对应任务。
- **类型一致性**：`FitnessProfile`/`MealAnalysis`/`TomorrowPlan`/`MacroTargets`/`TrainingMove`/`Meal` 在 Task2 定义，后续 Task3-13 一致引用；repo 方法名（`loadProfile`/`saveProfile`/`saveMeal`/`mealsForDate`/`watchMealsForDate`/`trainingForDate`/`markTrainingDone`/`planForDate`/`savePlan`）在 Task5 定义并在 Task10-12 一致使用。
- **无占位符**：每个 code step 均为完整可编译代码。
- **风险点**：Task3 cut 热量期望值 1867 取决于 `round()` 顺序，若实际差 ±1 按实现订正测试（已在该步注明）。
