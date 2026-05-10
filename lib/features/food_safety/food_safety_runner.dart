import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/profile/profile.dart';
import '../../core/skill/skill_output.dart';
import '../../core/skill/skill_runner.dart';
import '../../core/storage/file_store.dart';
import 'food_safety_models.dart';
import 'food_safety_prompt.dart';

class FoodSafetyError implements Exception {
  final String message;
  const FoodSafetyError(this.message);
  @override
  String toString() => message;
}

class FoodSafetyRun {
  final FoodSafetyResult result;
  final String imagePath;
  final int? skillRunId;
  const FoodSafetyRun({
    required this.result,
    required this.imagePath,
    required this.skillRunId,
  });
}

/// 食物识别 = SkillRunner('food-safety') + 把结构化 JSON 映射回 FoodSafetyResult。
class FoodSafetyRunner {
  final SkillRunner runner;
  final FileStore fileStore;

  FoodSafetyRunner({required this.runner, required this.fileStore});

  Future<FoodSafetyRun> run({
    required Uint8List rawImageBytes,
    required FamilyProfile profile,
    String? userText,
  }) async {
    final compressed = FoodSafetyPrompt.compressImage(rawImageBytes);
    final imagePath = await fileStore.saveFoodPhoto(compressed);

    SkillRunResult res;
    try {
      res = await runner.run(
        'food-safety',
        text: userText,
        imageBytes: compressed,
        profile: profile,
      );
    } on SkillRunError catch (e) {
      throw FoodSafetyError(e.message);
    }

    final parsed = _mapResult(res);
    return FoodSafetyRun(
      result: parsed,
      imagePath: imagePath,
      skillRunId: res.skillRunId,
    );
  }

  static FoodSafetyResult _mapResult(SkillRunResult res) {
    final json = res.structuredJson;
    if (json == null) {
      // 解析失败：回退到原文兜底解析（兼容旧逻辑里的容错）
      return FoodSafetyPrompt.parseModelOutput(res.rawText);
    }

    List<String> asList(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
      return const [];
    }

    return FoodSafetyResult(
      verdict: FoodVerdict.parse(json['verdict']?.toString()),
      name: (json['name'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      dos: asList(json['dos']),
      donts: asList(json['donts']),
      alternatives: asList(json['alternatives']),
      rawText: res.rawText,
    );
  }

  /// 纯文本版（语音/文字 agent 用，没图片只有食物名）。
  ///
  /// 不存图片到 disk，imagePath 留空；其余字段用同一个 prompt 出。
  Future<FoodSafetyResult> runText({
    required String foodName,
    required FamilyProfile profile,
  }) async {
    SkillRunResult res;
    try {
      res = await runner.run(
        'food-safety',
        text: '请判断「$foodName」孕期能不能吃。如果信息不够也请基于食物名做最佳判断。',
        profile: profile,
      );
    } on SkillRunError catch (e) {
      throw FoodSafetyError(e.message);
    }
    return _mapResult(res);
  }

  /// 测试与 CLI 入口（沿用旧名）。
  static FoodSafetyResult parseModelOutput(String raw) =>
      FoodSafetyPrompt.parseModelOutput(raw);
  static Uint8List compressImage(Uint8List bytes) =>
      FoodSafetyPrompt.compressImage(bytes);
}

final foodSafetyRunnerProvider = Provider<FoodSafetyRunner?>((ref) {
  final runner = ref.watch(skillRunnerProvider);
  if (runner == null) return null;
  return FoodSafetyRunner(
    runner: runner,
    fileStore: ref.watch(fileStoreProvider),
  );
});
