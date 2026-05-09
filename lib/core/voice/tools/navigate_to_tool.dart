import '../../../router.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';

class NavigateToTool extends AgentTool {
  /// 路由名 → 给用户念的短名。和 [routes] 同源；后续加路由要两边一起加。
  static const Map<String, String> routes = {
    '/': '首页',
    '/chat': '聊聊',
    '/calendar': '日历',
    '/checklist': '待产清单',
    '/food': '能不能吃',
    '/recipe': '食谱',
    '/week': '孕周',
    '/belly': '肚肚照',
    '/shopping': '采购清单',
    '/italian-license': '意大利驾照',
    '/italian-vocab': '意大利语词汇',
    '/memory': '记忆管理',
    '/skills': '技能列表',
    '/settings': '设置',
    '/profile-edit': '家庭信息',
  };

  @override
  String get name => 'navigate_to';

  @override
  String get descriptionZh =>
      '跳到 app 内某个页面。用户说"打开 X"、"去 Y 页面"时调用。';

  @override
  String get argsHint =>
      'route:string(必填)，可选值：${routes.keys.join(' | ')}';

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final route = (args['route'] ?? '').toString().trim();
    if (!routes.containsKey(route)) {
      return ToolResult(
        speakText: '没找到这个页面：$route',
      );
    }
    // 直接用全局 GoRouter 实例：voice button 装在 ScaffoldMessenger 层，
    // 它比 GoRouter 高，GoRouter.of(context) 会拿不到 inherited widget。
    //
    // 用 push 而不是 go，让目标页面能正常 pop 回原页面。
    if (route == '/') {
      // 回首页用 go 把栈清干净；否则会越堆越深。
      appRouter.go('/');
    } else {
      appRouter.push(route);
    }
    final label = routes[route] ?? route;
    return ToolResult(speakText: '好的，去$label');
  }
}
