import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tools/add_calendar_task_tool.dart';
import '../tools/chat_fallback_tool.dart';
import '../tools/explain_italian_question_tool.dart';
import '../tools/navigate_to_tool.dart';
import '../tools/read_italian_question_tool.dart';
import 'agent_tool.dart';

/// 工具注册表。orchestrator 用这个查找 + 用来生成 system prompt 中的工具描述。
class AgentToolRegistry {
  final List<AgentTool> tools;

  AgentToolRegistry(this.tools);

  AgentTool? find(String name) {
    for (final t in tools) {
      if (t.name == name) return t;
    }
    return null;
  }

  /// 给 system prompt 拼一段工具列表。简短不啰嗦，让模型知道每个工具叫啥 + 干啥用。
  String describeForPrompt() {
    final buf = StringBuffer();
    buf.writeln('可用工具：');
    for (final t in tools) {
      buf.writeln('- ${t.name}：${t.descriptionZh}');
      buf.writeln('  args: ${t.argsHint}');
    }
    return buf.toString();
  }
}

final agentToolRegistryProvider = Provider<AgentToolRegistry>(
  (ref) => AgentToolRegistry([
    AddCalendarTaskTool(),
    NavigateToTool(),
    ReadItalianQuestionTool(),
    ExplainItalianQuestionTool(),
    ChatFallbackTool(),
  ]),
);
