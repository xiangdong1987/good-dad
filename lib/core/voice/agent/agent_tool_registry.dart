import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tools/add_calendar_task_tool.dart';
import '../tools/chat_fallback_tool.dart';
import '../tools/explain_italian_question_tool.dart';
import '../tools/forget_fact_tool.dart';
import '../tools/get_weather_tool.dart';
import '../tools/list_facts_tool.dart';
import '../tools/navigate_to_tool.dart';
import '../tools/query_food_safety_tool.dart';
import '../tools/read_italian_question_tool.dart';
import '../tools/remember_fact_tool.dart';
import '../tools/update_persona_tool.dart';
import '../voice_types.dart';
import 'agent_tool.dart';

/// 工具注册表。orchestrator 用这个查找 + 用来生成 system prompt 中的工具描述。
///
/// 扩展方式：
/// 1. 新建一个 `class FooTool extends AgentTool { ... }`
/// 2. 在 [agentToolRegistryProvider] 的 list 里加一行
/// 3. 给 [AgentTool.examples] 写 1-3 个示例 — 模型自动知道何时用
///
/// system prompt 不用改，框架自动把工具描述塞进 `## 工具` 段。
class AgentToolRegistry {
  final List<AgentTool> tools;

  AgentToolRegistry(this.tools);

  AgentTool? find(String name) {
    for (final t in tools) {
      if (t.name == name) return t;
    }
    return null;
  }

  /// 给 system prompt 拼工具描述。带 page-context 过滤：
  /// 如果传了 [pageContext]，只列出能用的工具；其余加 `(unavailable)` 标记。
  String describeForPrompt({PageContext? pageContext}) {
    final pageKind = pageContext?.kind;
    final buf = StringBuffer();
    for (final t in tools) {
      final blocked =
          t.requiresPageKind != null && t.requiresPageKind != pageKind;
      buf.write('- ${t.name}');
      if (t.writes) buf.write(' [写库 · 用户可撤销]');
      if (blocked) {
        buf.write(' [当前页不可用，仅在 ${t.requiresPageKind} 页可用]');
      }
      buf.writeln('：${t.descriptionZh}');
      if (t.argsHint.trim().isNotEmpty) {
        buf.writeln('  args: ${t.argsHint}');
      }
      for (final e in t.examples) {
        buf.writeln('  例: "${e.utterance}" → ${jsonEncode(e.args)}');
      }
    }
    return buf.toString().trimRight();
  }
}

final agentToolRegistryProvider = Provider<AgentToolRegistry>(
  (ref) => AgentToolRegistry([
    AddCalendarTaskTool(),
    NavigateToTool(),
    GetWeatherTool(),
    QueryFoodSafetyTool(),
    RememberFactTool(),
    ForgetFactTool(),
    ListFactsTool(),
    UpdatePersonaTool(),
    ReadItalianQuestionTool(),
    ExplainItalianQuestionTool(),
    ChatFallbackTool(),
  ]),
);
