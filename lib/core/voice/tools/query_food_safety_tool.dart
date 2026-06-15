import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/food_safety/food_safety_models.dart';
import '../../../features/food_safety/food_safety_runner.dart';
import '../../../router.dart';
import '../../profile/profile.dart';
import '../../profile/profile_repository.dart';
import '../agent/agent_tool.dart';
import '../voice_types.dart';

/// 「孕期能吃 X 吗」类语音问题。
///
/// 走完整的 `food-safety` skill（比 chat_fallback 严谨：返回 safe / caution / avoid
/// 加理由 + 注意事项）；同时 navigate_to `/food` 让爸爸能看到详细卡片。
class QueryFoodSafetyTool extends AgentTool {
  @override
  String get name => 'query_food_safety';

  @override
  String get descriptionZh =>
      '查孕期某个食物能不能吃（用 food-safety skill，比闲聊更严谨）';

  @override
  String get argsHint => 'food_name:string(食物名，必填)';

  @override
  List<ToolExample> get examples => const [
        ToolExample('生鱼片能吃吗', {'food_name': '生鱼片'}),
        ToolExample('牛奶可以喝吗', {'food_name': '牛奶'}),
        ToolExample('那个咖啡呢', {'food_name': '咖啡'}),
        ToolExample('孕妇方便面可不可以', {'food_name': '方便面'}),
      ];

  @override
  Future<ToolResult> invoke(
    Map<String, dynamic> args,
    AgentContext ctx,
  ) async {
    final foodName = (args['food_name'] ?? '').toString().trim();
    if (foodName.isEmpty) {
      return const ToolResult(speakText: '没听清要查哪个食物');
    }

    final runner = ctx.ref.read(foodSafetyRunnerProvider);
    if (runner == null) {
      return const ToolResult(
        speakText: '食物识别要先去设置里把 LLM 配好',
      );
    }

    final profile =
        ctx.ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;

    FoodSafetyResult result;
    try {
      result = await runner.runText(
        foodName: foodName,
        profile: profile,
      );
    } on FoodSafetyError catch (e) {
      return ToolResult(speakText: '查不出来：${e.message}');
    }

    // 跳到 /food 页让爸爸能看到详情卡（虽然 v1 这页没用 result，至少导航过去）
    appRouter.push('/food');

    final v = result.verdict;
    final name = result.name.isEmpty ? foodName : result.name;
    final reason = result.reason.isEmpty ? '' : '。${result.reason}';

    final speak = switch (v) {
      FoodVerdict.safe => '$name 可以吃$reason',
      FoodVerdict.caution => '$name 要谨慎$reason',
      FoodVerdict.avoid => '$name 不建议$reason',
      FoodVerdict.unknown => '$name 这个我不太敢替医生说，建议问下产检医生',
    };

    return ToolResult(speakText: speak);
  }
}
