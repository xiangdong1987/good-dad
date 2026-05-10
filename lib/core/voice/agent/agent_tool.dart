import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice_types.dart';

/// 工具上下文：执行时拿得到 Riverpod ref + 一个能拿到 BuildContext 的 hook。
///
/// BuildContext 是可选的——orchestrator 在按麦克风时把 navigatorKey 拿到的
/// context 注入进来，工具用它做导航 / 弹 SnackBar。
class AgentContext {
  final Ref ref;
  final BuildContext? Function() contextResolver;

  const AgentContext({
    required this.ref,
    required this.contextResolver,
  });

  BuildContext? get context => contextResolver();
}

/// 工具协议。
///
/// 设计目标：每个工具自带「什么时候用」+「示例」，agent system prompt 不需要
/// 列举所有触发场景；想加新工具只要实现这个 interface 注册到 registry，
/// prompt 自动包含进去。
///
/// 字段说明：
/// - [name]：与模型 JSON 中 `action` 字段对齐
/// - [descriptionZh]：一句话讲这个工具是干嘛的
/// - [argsHint]：参数 schema 简短人类可读字符串
///   例：`title:string, date:YYYY-MM-DD|今天|明天, kind?:todo|checkup|milestone|note`
/// - [examples]：触发例 + 应该怎么调（few-shot）；列 1-3 个就够
/// - [requiresPageKind]：仅当 page context kind 命中时才可用（如 italian_license）；
///   null 表示任何页面都能用
/// - [writes]：是否会写库（true 时 orchestrator 会自动鼓励"先调，撤销由用户决定"）
abstract class AgentTool {
  String get name;
  String get descriptionZh;
  String get argsHint;

  /// few-shot 例子，每条形如：
  /// `('帮我加个明天去体检的日程', {"title":"去体检","date":"明天","kind":"checkup"})`
  List<ToolExample> get examples => const [];

  /// 仅当 PageContext.kind 等于这里给的值时才可用；null = 任何页都行。
  String? get requiresPageKind => null;

  /// 是否会写本地库（决定 system prompt 里要不要鼓励"宁可调一次让用户撤销"）。
  bool get writes => false;

  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  );
}

/// 一条 few-shot 例子：用户原话 + 期望调用参数。
class ToolExample {
  final String utterance;
  final Map<String, dynamic> args;
  const ToolExample(this.utterance, this.args);
}
