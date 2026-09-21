import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../core/llm/types.dart';
import 'fitness_met.dart';
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
{"trainingPlan":[{"move":"动作名","kind":"动作类型","sets":整数,"reps":整数,"weightKg":整数,"note":"要点"}],
"dietGuidance":"明日饮食建议，中文，结合今日缺口","kcalTarget":整数,"proteinTarget":整数,
"carbTarget":整数,"fatTarget":整数,"deficitSummary":"今天缺口一句话总结"}
kind 必须从这些里选一个（照抄英文标识，别自创）：
${ActivityKind.training.map((k) => '${k.name}（${k.zh}）').join('、')}
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
