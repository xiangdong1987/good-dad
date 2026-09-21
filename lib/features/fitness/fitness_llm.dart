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

  /// 文字描述记一餐。走非 vision 通道——没有图片还按 vision 计费是白花钱。
  Future<MealAnalysis> analyzeMealText({
    required Meal meal,
    required String description,
  }) async {
    final messages = FitnessPrompt.buildMealTextMessages(meal, description);
    final LlmResult res;
    try {
      res = await client.chatOnce(messages, temperature: 0.3);
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
