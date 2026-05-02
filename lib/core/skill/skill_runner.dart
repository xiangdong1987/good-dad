import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/app_locale.dart';
import '../i18n/locale_provider.dart';
import '../llm/llm_client.dart';
import '../llm/llm_providers.dart';
import '../llm/openai_compatible_client.dart';
import '../llm/types.dart';
import '../memory/memory_injector.dart';
import '../profile/profile.dart';
import '../storage/database.dart';
import 'skill.dart';
import 'skill_loader.dart';
import 'skill_output.dart';

/// SkillRunner 抛出的统一错误。
class SkillRunError implements Exception {
  final String message;
  final int? statusCode;
  const SkillRunError(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// 通用 skill 执行器：load → 注入 memory → 拼 prompt → 调 LLM → 解析 → 落 DB。
///
/// 三种模式：
/// - 非流式：[run] —— 适合 structured / checklist 输出，直接返回完整结果
/// - 流式：[runStream] —— 每个 token 一个回调，结束时仍返回完整结果（含落库）
class SkillRunner {
  final LlmClient client;
  final SkillLoader skillLoader;
  final AppDatabase db;
  final MemoryInjector memoryInjector;
  final AppLocale locale;

  SkillRunner({
    required this.client,
    required this.skillLoader,
    required this.db,
    required this.memoryInjector,
    this.locale = AppLocale.zhCN,
  });

  Future<SkillRunResult> run(
    String skillName, {
    String? text,
    Uint8List? imageBytes,
    FamilyProfile? profile,
    double? temperatureOverride,
  }) async {
    final ctx = await _prepare(
      skillName: skillName,
      text: text,
      imageBytes: imageBytes,
      profile: profile,
    );

    final c = _ensureOpenAI();
    final t0 = DateTime.now();
    String raw;
    try {
      raw = await c.chatOnceJson(
        ctx.messages,
        temperature: temperatureOverride ?? ctx.skill.temperature,
        // 自动升级：用户上图时一律走 vision，无论 skill frontmatter 怎么标。
        needsVision: ctx.skill.needsVision || ctx.hasImage,
      );
    } on LlmException catch (e) {
      throw SkillRunError('LLM 调用失败: ${e.message}',
          statusCode: e.statusCode);
    }
    final ms = DateTime.now().difference(t0).inMilliseconds;

    return _finalize(ctx, raw, ms);
  }

  /// 流式执行——每个 token 触发 [onChunk]，最终返回完整结果。
  Future<SkillRunResult> runStream(
    String skillName, {
    String? text,
    Uint8List? imageBytes,
    FamilyProfile? profile,
    double? temperatureOverride,
    void Function(String delta)? onChunk,
  }) async {
    final ctx = await _prepare(
      skillName: skillName,
      text: text,
      imageBytes: imageBytes,
      profile: profile,
    );

    final t0 = DateTime.now();
    final buf = StringBuffer();
    try {
      await for (final chunk in client.chat(
        ctx.messages,
        temperature: temperatureOverride ?? ctx.skill.temperature,
        // 自动升级：用户上图时一律走 vision，无论 skill frontmatter 怎么标。
        needsVision: ctx.skill.needsVision || ctx.hasImage,
      )) {
        if (chunk.deltaText.isNotEmpty) {
          buf.write(chunk.deltaText);
          onChunk?.call(chunk.deltaText);
        }
      }
    } on LlmException catch (e) {
      throw SkillRunError('LLM 调用失败: ${e.message}',
          statusCode: e.statusCode);
    }
    final ms = DateTime.now().difference(t0).inMilliseconds;
    return _finalize(ctx, buf.toString(), ms);
  }

  // ── helpers ────────────────────────────────────────────────────────

  Future<_RunContext> _prepare({
    required String skillName,
    String? text,
    Uint8List? imageBytes,
    FamilyProfile? profile,
  }) async {
    final skill = await skillLoader.load(skillName);
    final injectedMemoryBlock = await memoryInjector.buildBlock(skill);
    final messages =
        _buildMessages(skill, profile, text, imageBytes, injectedMemoryBlock);
    return _RunContext(
      skill: skill,
      messages: messages,
      inputText: text,
      imageBytes: imageBytes,
    );
  }

  Future<SkillRunResult> _finalize(
    _RunContext ctx,
    String raw,
    int latencyMs,
  ) async {
    Map<String, dynamic>? structured;
    List<ChecklistSection>? checklist;
    switch (ctx.skill.outputFormat) {
      case 'structured':
        structured = SkillOutputParser.parseJson(raw);
      case 'checklist':
        checklist = SkillOutputParser.parseChecklist(raw);
    }

    final outputJson = <String, dynamic>{'raw': raw};
    if (structured != null) outputJson['structured'] = structured;
    if (checklist != null) {
      outputJson['checklist'] = checklist
          .map((s) => {
                'title': s.title,
                'items': s.items
                    .map((i) => {'text': i.text, 'checked': i.checked})
                    .toList(),
              })
          .toList();
    }

    final skillRunId = await db.into(db.skillRuns).insert(
          SkillRunsCompanion.insert(
            skillName: ctx.skill.name,
            inputJson: jsonEncode({
              'text': ctx.inputText ?? '',
              'has_image': ctx.imageBytes != null,
            }),
            outputJson: Value(jsonEncode(outputJson)),
            latencyMs: Value(latencyMs),
          ),
        );

    return SkillRunResult(
      skill: ctx.skill,
      rawText: raw,
      structuredJson: structured,
      checklistSections: checklist,
      latencyMs: latencyMs,
      skillRunId: skillRunId,
    );
  }

  OpenAICompatibleClient _ensureOpenAI() {
    final c = client;
    if (c is! OpenAICompatibleClient) {
      throw const SkillRunError('LLM 客户端不可用');
    }
    return c;
  }

  List<LlmMessage> _buildMessages(
    Skill skill,
    FamilyProfile? profile,
    String? userText,
    Uint8List? imageBytes,
    String? memoryBlock,
  ) {
    final now = DateTime.now();
    final ctxLines = <String>[
      '## 家庭信息（请基于此回答）',
      '- 今天：${_isoDate(now)}（${_zhWeekday(now.weekday)}）',
    ];
    if (profile != null) {
      if (profile.dadName != null) {
        ctxLines.add('- 爸爸（用户）希望被叫：${profile.dadName}');
      }
      if (profile.momName != null) {
        ctxLines.add('- 妈妈希望被叫：${profile.momName}');
      }
      if (profile.currentWeek() != null) {
        final w = profile.currentWeek();
        final d = profile.currentDayInWeek() ?? 0;
        ctxLines.add(
            '- 当前孕周：$w 周 $d 天（共 40 周）');
        if (profile.dueDate != null) {
          ctxLines.add('- 预产期：${_isoDate(profile.dueDate!)}');
        }
      }
    }

    final parts = <String>[skill.body.trim(), '', ctxLines.join('\n')];
    if (memoryBlock != null && memoryBlock.isNotEmpty) {
      parts
        ..add('')
        ..add(memoryBlock);
    }

    // 语言：让 AI 用用户选定的语言回复（结构化字段值除外，比如 verdict=safe 仍是英文枚举）
    if (locale != AppLocale.zhCN) {
      parts
        ..add('')
        ..add('## 语言\n请用 ${locale.aiLanguageHint} 回复用户。'
            '保留 JSON 字段名 / 枚举值（safe/avoid/caution/todo/checkup 等）不翻译。');
    }

    if (skill.outputFormat == 'structured') {
      parts
        ..add('')
        ..add('严格只输出 JSON，不要 markdown 围栏，不要解释。');
    } else if (skill.outputFormat == 'checklist') {
      parts
        ..add('')
        ..add('严格按上方 markdown checklist 格式输出，不要别的话。');
    }

    final systemPrompt = parts.join('\n');

    final defaultUserText =
        userText?.trim().isNotEmpty == true ? userText!.trim() : null;

    final List<LlmMessage> messages = [LlmMessage.system(systemPrompt)];

    if (imageBytes != null) {
      messages.add(
        LlmMessage(
          LlmRole.user,
          [
            ImagePart(imageBytes),
            TextPart(defaultUserText ?? _defaultUserPrompt(skill)),
          ],
        ),
      );
    } else {
      messages.add(LlmMessage.user(
          defaultUserText ?? _defaultUserPrompt(skill)));
    }

    return messages;
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _zhWeekday(int w) {
    const map = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return map[(w - 1).clamp(0, 6)];
  }

  String _defaultUserPrompt(Skill skill) {
    switch (skill.name) {
      case 'food-safety':
        return '这个能吃吗？';
      case 'pregnancy-week':
        return '本周要点';
      case 'belly-photo':
        return '给这张孕肚照片配一段记录文字';
      case 'prenatal-prep':
        return '请生成一份完整的待产准备清单';
      case 'baby-shopping':
        return '请生成一份分阶段的宝宝采购清单';
      case 'italian-license':
        return '请讲解这道意大利驾照题：翻译题目、给出答案、教关键词汇和语法';
      default:
        return '请按你的角色给出建议';
    }
  }
}

class _RunContext {
  final Skill skill;
  final List<LlmMessage> messages;
  final String? inputText;
  final Uint8List? imageBytes;
  const _RunContext({
    required this.skill,
    required this.messages,
    this.inputText,
    this.imageBytes,
  });

  bool get hasImage => imageBytes != null;
}

final skillRunnerProvider = Provider<SkillRunner?>((ref) {
  final llm = ref.watch(llmClientProvider);
  if (llm == null) return null;
  return SkillRunner(
    client: llm,
    skillLoader: ref.watch(skillLoaderProvider),
    db: ref.watch(appDatabaseProvider),
    memoryInjector: ref.watch(memoryInjectorProvider),
    locale: ref.watch(localeProvider).valueOrNull ?? AppLocale.zhCN,
  );
});
