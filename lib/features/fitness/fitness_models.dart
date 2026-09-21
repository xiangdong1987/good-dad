import 'dart:convert';

import 'fitness_met.dart';

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

  /// 这一样食物自己的热量与宏量。
  ///
  /// 整餐层面的数字删不掉也缩放不了——要支持编辑清单，明细必须带数值。
  /// LLM 没给时为 0，此时整餐退回用 LLM 给的整餐值。
  final int kcal;
  final int proteinG;
  final int carbG;
  final int fatG;

  const FoodItem(
    this.name,
    this.grams, {
    this.kcal = 0,
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
  });

  /// 改分量：按克数线性缩放。
  ///
  /// 对「一整只鸡 vs 半只鸡」这类非线性情况不精确，但日常分量够用。
  /// 原克数为 0 时无从推算，数值原样保留。
  FoodItem scaledTo(int newGrams) {
    if (grams <= 0) {
      return FoodItem(name, newGrams,
          kcal: kcal, proteinG: proteinG, carbG: carbG, fatG: fatG);
    }
    final r = newGrams / grams;
    return FoodItem(
      name,
      newGrams,
      kcal: (kcal * r).round(),
      proteinG: (proteinG * r).round(),
      carbG: (carbG * r).round(),
      fatG: (fatG * r).round(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'grams': grams,
        'kcal': kcal,
        'proteinG': proteinG,
        'carbG': carbG,
        'fatG': fatG,
      };
  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        (j['name'] ?? '').toString(),
        (j['grams'] as num?)?.round() ?? 0,
        kcal: (j['kcal'] as num?)?.round() ?? 0,
        proteinG: (j['proteinG'] as num?)?.round() ?? 0,
        carbG: (j['carbG'] as num?)?.round() ?? 0,
        fatG: (j['fatG'] as num?)?.round() ?? 0,
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

  /// 明细是否齐全到可以逐项编辑：每一样都带了热量。
  ///
  /// 只要有一样缺，就整体退回 LLM 给的整餐值——半信半疑地混用两套
  /// 数字，编辑时会算出明显错的总和。
  bool get hasItemDetail =>
      foods.isNotEmpty && foods.every((f) => f.kcal > 0);

  int _sum(int Function(FoodItem) pick, int fallback) =>
      hasItemDetail ? foods.fold(0, (a, f) => a + pick(f)) : fallback;

  int get totalKcal => _sum((f) => f.kcal, kcal);
  int get totalProteinG => _sum((f) => f.proteinG, proteinG);
  int get totalCarbG => _sum((f) => f.carbG, carbG);
  int get totalFatG => _sum((f) => f.fatG, fatG);

  /// 编辑清单后重建：整餐数字由新的明细之和决定。
  MealAnalysis withFoods(List<FoodItem> next) {
    final t = MealAnalysis(foods: next, note: note, rawText: rawText);
    return MealAnalysis(
      foods: next,
      kcal: t._sum((f) => f.kcal, 0),
      proteinG: t._sum((f) => f.proteinG, 0),
      carbG: t._sum((f) => f.carbG, 0),
      fatG: t._sum((f) => f.fatG, 0),
      note: note,
      rawText: rawText,
    );
  }
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

  /// LLM 标注的动作类型；null 时由关键词兜底判定。
  final ActivityKind? kind;

  const TrainingMove({
    required this.move,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.note = '',
    this.kind,
  });

  Map<String, dynamic> toJson() => {
        'move': move,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'note': note,
        if (kind != null) 'kind': kind!.name,
      };
  factory TrainingMove.fromJson(Map<String, dynamic> j) => TrainingMove(
        move: (j['move'] ?? '').toString(),
        sets: (j['sets'] as num?)?.round() ?? 0,
        reps: (j['reps'] as num?)?.round() ?? 0,
        weightKg: (j['weightKg'] as num?)?.round() ?? 0,
        note: (j['note'] ?? '').toString(),
        kind: ActivityKind.parse(j['kind']?.toString()),
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

/// 一条日常活动记录。
class ActivityEntry {
  final int id;
  final ActivityKind kind;
  final int minutes;

  /// 净消耗千卡（记录时按 MET 算好后存下，改体重不会追溯改写历史）。
  final int kcal;

  const ActivityEntry({
    required this.id,
    required this.kind,
    required this.minutes,
    required this.kcal,
  });
}

/// 一次称重记录。
class WeightEntry {
  final String date;
  final double weightKg;
  const WeightEntry({required this.date, required this.weightKg});
}
