import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/llm_client.dart';
import '../../core/llm/llm_providers.dart';
import '../../core/llm/openai_compatible_client.dart';
import '../../core/llm/types.dart';
import '../../core/profile/profile.dart';
import '../../core/skill/skill.dart';
import '../../core/skill/skill_loader.dart';
import '../../core/storage/database.dart';
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
  final int skillRunId;
  const FoodSafetyRun(
      {required this.result,
      required this.imagePath,
      required this.skillRunId});
}

class FoodSafetyRunner {
  final LlmClient client;
  final SkillLoader skillLoader;
  final FileStore fileStore;
  final AppDatabase db;

  FoodSafetyRunner({
    required this.client,
    required this.skillLoader,
    required this.fileStore,
    required this.db,
  });

  /// 完整流程：压缩 → 落盘 → 拼 prompt → 调 LLM → 解析 → 落库。
  Future<FoodSafetyRun> run({
    required Uint8List rawImageBytes,
    required FamilyProfile profile,
    String? userText,
  }) async {
    final compressed = FoodSafetyPrompt.compressImage(rawImageBytes);
    final imagePath = await fileStore.saveFoodPhoto(compressed);
    final Skill skill = await skillLoader.load('food-safety');

    final messages = FoodSafetyPrompt.buildMessages(
        skill, profile, compressed, userText);

    final t0 = DateTime.now();
    final raw = await _callOnce(messages, skill);
    final ms = DateTime.now().difference(t0).inMilliseconds;

    final parsed = FoodSafetyPrompt.parseModelOutput(raw);

    final runId = await db.into(db.skillRuns).insert(
          SkillRunsCompanion.insert(
            skillName: 'food-safety',
            inputJson: jsonEncode({
              'image_path': imagePath,
              'text': userText ?? '',
            }),
            outputJson: Value(jsonEncode({
              'raw': raw,
              'parsed': parsed.toJson(),
            })),
            latencyMs: Value(ms),
          ),
        );

    return FoodSafetyRun(
        result: parsed, imagePath: imagePath, skillRunId: runId);
  }

  Future<String> _callOnce(List<LlmMessage> msgs, Skill skill) async {
    final c = client;
    if (c is! OpenAICompatibleClient) {
      throw const FoodSafetyError('LLM 客户端不可用');
    }
    try {
      return await c.chatOnceJson(
        msgs,
        temperature: skill.temperature,
        needsVision: true,
      );
    } on LlmException catch (e) {
      throw FoodSafetyError('LLM 调用失败: ${e.message}');
    }
  }

  /// 测试 / CLI 入口（保留旧名以兼容已有引用）。
  static FoodSafetyResult parseModelOutput(String raw) =>
      FoodSafetyPrompt.parseModelOutput(raw);
  static Uint8List compressImage(Uint8List bytes) =>
      FoodSafetyPrompt.compressImage(bytes);
  static List<LlmMessage> buildFoodSafetyMessages(
    Skill skill,
    FamilyProfile profile,
    Uint8List bytes,
    String? userText,
  ) =>
      FoodSafetyPrompt.buildMessages(skill, profile, bytes, userText);
}

final foodSafetyRunnerProvider = Provider<FoodSafetyRunner?>((ref) {
  final llm = ref.watch(llmClientProvider);
  if (llm == null) return null;
  return FoodSafetyRunner(
    client: llm,
    skillLoader: ref.watch(skillLoaderProvider),
    fileStore: ref.watch(fileStoreProvider),
    db: ref.watch(appDatabaseProvider),
  );
});
