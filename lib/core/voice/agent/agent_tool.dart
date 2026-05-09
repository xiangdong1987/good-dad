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
/// - [name]：与模型 JSON 中 `action` 字段对齐。
/// - [descriptionZh] + [argsHint]：拼到 system prompt，告诉模型何时调用。
/// - [invoke]：被 orchestrator 调度，返回 [ToolResult]（决定是否覆盖口播 / 弹撤销）。
abstract class AgentTool {
  String get name;
  String get descriptionZh;

  /// 描述参数 schema 的简短人类可读字符串。
  /// 例：'title:string, date:YYYY-MM-DD|今天|明天, kind?:todo|checkup|milestone|note'
  String get argsHint;

  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  );
}
