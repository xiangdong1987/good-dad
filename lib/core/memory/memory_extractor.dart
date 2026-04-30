import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../llm/llm_client.dart';
import '../llm/llm_providers.dart';
import '../llm/openai_compatible_client.dart';
import '../llm/types.dart';
import 'memory.dart';
import 'memory_repository.dart';

/// 从一轮对话里抽取候选记忆。
///
/// 目标：把「老婆 8 月 15 号预产期」「我对花生过敏」之类的**长期事实**
/// 沉淀进 memories 表（先入 `pending`），用户在抽屉里一键确认转 `active`。
class MemoryExtractor {
  final LlmClient client;
  final MemoryRepository repo;

  MemoryExtractor({required this.client, required this.repo});

  /// 输入：用户最后一条消息 + （可选）assistant 的回答。
  /// 输出：写入 DB 的 pending 条目数量。
  Future<int> extractFromTurn({
    required String userMessage,
    String? assistantMessage,
  }) async {
    final c = client;
    if (c is! OpenAICompatibleClient) return 0;
    if (userMessage.trim().isEmpty) return 0;

    final messages = [
      LlmMessage.system(_systemPrompt),
      LlmMessage.user('用户说：「${userMessage.trim()}」\n'
          '${assistantMessage == null ? '' : '我回复了：「${assistantMessage.trim()}」\n'}'
          '请输出候选记忆 JSON 数组。'),
    ];

    String raw;
    try {
      raw = await c.chatOnceJson(messages, temperature: 0);
    } on LlmException {
      // 抽取失败不应阻塞主对话流程；静默放弃这一轮。
      return 0;
    }

    final list = _parseList(raw);
    if (list.isEmpty) return 0;

    var written = 0;
    for (final m in list) {
      try {
        await repo.upsert(m.copyWith(status: MemoryStatus.pending));
        written++;
      } catch (_) {
        // 单条入库失败不影响其它候选
      }
    }
    return written;
  }

  // ── helpers ───────────────────────────────────────────────────

  static const _systemPrompt = '''
你是一个家庭事实提取器。你只关心**长期适用**的事实——家人称呼/角色/偏好/过敏/关键日期/医院/产检医生等。

你必须**只输出一个 JSON 数组**，不要 markdown 围栏，不要解释。

每条候选格式：
{
  "type": "user" | "feedback" | "project" | "reference",
  "name": "snake_case 的稳定 key，例 partner.due_date / partner.allergies / baby.gender / dad.preferences.cuisine",
  "description": "≤20 字一行总结",
  "body": "详细内容，原文转述，保留数字/日期/单位"
}

类型语义：
- user：家人画像（爸爸/妈妈/宝宝的属性、偏好、过敏）
- project：当前阶段（孕周、产检日期、入院流程）
- feedback：用户对 AI 表达的喜好（语气、详简、避忌内容）
- reference：外部资源（医院名、医生、链接）

规则：
- 只提取明确说出的事实，不要脑补、不要推断
- 一次性问题（"今天能吃这个吗"）**不是**长期事实，不要提取
- 已经众所周知的常识不要提取
- 没有可提取内容时，输出空数组：[]
- 不要重复用户已经说过的同一事实

示例输入：「我老婆 8 月 15 号预产期，她对花生过敏。」
输出：
[
  {"type":"user","name":"partner.due_date","description":"老婆预产期","body":"2026-08-15"},
  {"type":"user","name":"partner.allergies","description":"老婆过敏","body":"花生"}
]

示例输入：「这个能吃吗？」
输出：[]
''';

  static List<MemoryEntry> _parseList(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return const [];

    dynamic decoded;
    try {
      decoded = jsonDecode(s);
    } catch (_) {
      // 抠 [...] 块再试
      final start = s.indexOf('[');
      final end = s.lastIndexOf(']');
      if (start >= 0 && end > start) {
        try {
          decoded = jsonDecode(s.substring(start, end + 1));
        } catch (_) {}
      }
    }
    if (decoded is! List) return const [];

    final out = <MemoryEntry>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final name = (item['name'] ?? '').toString().trim();
      final body = (item['body'] ?? '').toString().trim();
      if (name.isEmpty || body.isEmpty) continue;
      out.add(MemoryEntry(
        type: MemoryType.parse(item['type']?.toString()),
        name: name,
        description: (item['description'] ?? '').toString().trim(),
        body: body,
      ));
    }
    return out;
  }
}

final memoryExtractorProvider = Provider<MemoryExtractor?>((ref) {
  final llm = ref.watch(llmClientProvider);
  if (llm == null) return null;
  return MemoryExtractor(
    client: llm,
    repo: ref.watch(memoryRepositoryProvider),
  );
});
