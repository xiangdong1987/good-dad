import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../agent_config/agent_doc.dart';
import '../../memory/memory_injector.dart';
import '../../profile/profile.dart';
import '../../skill/skill.dart';
import '../agent/agent_tool_registry.dart';
import '../voice_types.dart';

void _slog(String msg) => debugPrint('[PromptBuilder] $msg');

/// 六层插槽拼装最终 system prompt（slot 顺序与 AGENT.md 「## 你工作的方式」对齐）：
///
/// 1. AGENT.md body —— meta-instruction（agent 怎么思考），永远在
/// 2. `## 家庭信息` —— FamilyProfile，永远在（哪怕没填，也告诉模型今天日期）
/// 3. `## 用户偏好` —— profile.md，可选
/// 4. `## 记忆` —— MemoryInjector，可选
/// 5. `## 当前页` —— PageContext，可选；page-aware 工具列表也据此过滤
/// 6. `## 工具` —— AgentToolRegistry.describeForPrompt(pageContext)，永远在
///
/// 想加新能力 = 在 AgentToolRegistry 里 register 一个新 [AgentTool]，写好
/// `examples` + `requiresPageKind` + `writes` —— 不用动 AGENT.md 也不用动 builder。
/// 这就是 OpenClaw-style 「skill hot-load」：每个 tool 自描述何时该用。
///
/// 超长时按 5 → 4 → 3 → 2 优先级丢层（layer1 / layer6 / layer2 永远保留）。
class SystemPromptBuilder {
  /// 最终 prompt 的硬上限（字符数粗估 4 字符/token，~8k tokens）。
  static const int _maxChars = 32000;

  /// profile.md 单层硬截断。
  static const int _profileMax = 2000;

  final AgentDoc agentDoc;
  final String profileText;
  final FamilyProfile? familyProfile;
  final MemoryInjector memoryInjector;
  final AgentToolRegistry registry;

  SystemPromptBuilder({
    required this.agentDoc,
    required this.profileText,
    required this.familyProfile,
    required this.memoryInjector,
    required this.registry,
  });

  /// 拼出最终 prompt。
  Future<String> build({PageContext? pageContext}) async {
    final layer1 = agentDoc.body.trim(); // meta-instruction
    final layer2 = _buildFamilyBlock(); // ## 家庭信息
    final layer3 = _trimProfile(profileText); // ## 用户偏好
    final layer4 = await _buildMemoryBlock(); // ## 记忆
    final layer5 = pageContext == null // ## 当前页
        ? null
        : '## 当前页\n${pageContext.kind}\n```json\n${jsonEncode(pageContext.payload)}\n```';
    final layer6 = '## 工具\n${registry.describeForPrompt(pageContext: pageContext)}';

    // 优先级：layer1（meta）+ layer2（家庭）+ layer6（工具）必须保留；
    //  超长时按 5 → 4 → 3 顺序丢。
    final priorityKept = <String>[layer1, layer2, layer6];
    final droppable = <String?>[layer3, layer4, layer5];

    for (int keep = droppable.length; keep >= 0; keep--) {
      final keptDroppable = droppable.sublist(0, keep);
      final composed = _join([
        layer1,
        layer2,
        ...keptDroppable,
        layer6,
      ]);
      if (composed.length <= _maxChars) {
        final dropped = droppable.length - keep;
        if (dropped > 0) {
          _slog('prompt over budget; dropped $dropped optional layers; '
              'final=${composed.length}c');
        } else {
          _slog('prompt built ok ${composed.length}c');
        }
        return composed;
      }
    }

    // 极端情况：连 1+2+6 都超限，硬截断。
    final minimal = _join(priorityKept);
    final hard = minimal.length > _maxChars
        ? '${minimal.substring(0, _maxChars - 50)}…（系统截断）'
        : minimal;
    _slog('prompt still over after dropping all optional; hard=${hard.length}c');
    return hard;
  }

  String _join(List<String?> layers) {
    final filtered = layers
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return filtered.join('\n\n');
  }

  String _buildFamilyBlock() {
    final p = familyProfile;
    final now = DateTime.now();
    final today = '${_iso(now)} 周${_zhWeekday(now.weekday)}';
    if (p == null ||
        (p.dadName == null && p.momName == null && p.dueDate == null)) {
      return '## 家庭信息\n今天 $today。用户尚未填写家庭信息（建议提示去设置补上）';
    }
    final segs = <String>['今天 $today'];
    if (p.dadName != null && p.dadName!.trim().isNotEmpty) {
      segs.add('爸爸叫 ${p.dadName}');
    }
    if (p.momName != null && p.momName!.trim().isNotEmpty) {
      segs.add('妈妈叫 ${p.momName}');
    }
    final week = p.currentWeek();
    if (week != null) {
      final day = p.currentDayInWeek() ?? 0;
      final remain = p.weeksToDue();
      final dueStr = p.dueDate == null ? '' : '预产期 ${_iso(p.dueDate!)}';
      final remainStr = remain == null ? '' : '还剩 $remain 周';
      segs.add(
          '孕 $week 周 $day 天${dueStr.isEmpty ? "" : "（$dueStr，$remainStr）"}');
    } else if (p.dueDate != null) {
      segs.add('预产期 ${_iso(p.dueDate!)}');
    }
    return '## 家庭信息\n${segs.join('，')}';
  }

  String _iso(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  String _zhWeekday(int w) =>
      const ['一', '二', '三', '四', '五', '六', '日'][w - 1];

  String _trimProfile(String text) {
    final t = text.trim();
    if (t.isEmpty) return '';
    final body = t.length > _profileMax
        ? '${t.substring(0, _profileMax)}…（用户配置文件被截断）'
        : t;
    return '## 用户偏好（你在设置里告诉我的）\n$body';
  }

  Future<String?> _buildMemoryBlock() async {
    final synthesized = Skill(
      name: 'voice-agent',
      frontmatter: agentDoc.frontmatter,
      body: '',
    );
    try {
      final raw = await memoryInjector.buildBlock(synthesized);
      if (raw == null) return null;
      return _compactMemory(raw);
    } catch (e) {
      _slog('memory inject failed: $e');
      return null;
    }
  }

  /// 把 MemoryInjector 出的多行条目压缩成一行：
  /// - 去掉 `source:` / `note:` 前缀的换行，全部接成 ` · ` 分隔
  /// - 去除空行
  /// 节省 token 又不丢信息。
  String _compactMemory(String raw) {
    final out = <String>[];
    String? current;
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('## ')) {
        out.add(trimmed);
        current = null;
        continue;
      }
      if (trimmed.startsWith('- ')) {
        if (current != null) out.add(current);
        current = trimmed;
        continue;
      }
      if (current != null) {
        // 多行 body 续到上一条，用 ' · ' 分隔
        if (trimmed.startsWith('source:')) continue; // 跳掉调试用元数据
        current = '$current · $trimmed';
      } else {
        out.add(trimmed);
      }
    }
    if (current != null) out.add(current);
    return out.join('\n');
  }
}
