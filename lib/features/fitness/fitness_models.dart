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
