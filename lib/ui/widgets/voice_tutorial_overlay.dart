import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/llm_providers.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/voice/voice_onboarding.dart';
import '../../router.dart';
import '../theme.dart';

/// 首次教学浮层：右下两个按钮上方各浮一个箭头气泡，介绍语音 + 文字入口。
///
/// 显示条件全部为真：
/// - profile 完整（onboarding 走完）
/// - LLM 已配（不会跳设置 gate）
/// - 教学未看过
/// 点任意位置或按任一按钮 → markSeen 永久消失。
class VoiceTutorialOverlay extends ConsumerWidget {
  const VoiceTutorialOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seenAsync = ref.watch(voiceOnboardingProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final llmReady = ref.watch(llmClientProvider) != null;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // 只在首页显示 — 否则会全屏拦截路由内页面的所有点击。
    // VoiceTutorialOverlay 在 MaterialApp.router 的 builder 里，比 Router 高，
    // 拿不到 GoRouterState；走 appRouter 的当前 configuration。
    final routeUri =
        appRouter.routerDelegate.currentConfiguration.uri.toString();
    final isHome = routeUri == '/' || routeUri.isEmpty;

    final shouldShow = isHome &&
        seenAsync.valueOrNull == false &&
        profile != null &&
        profile.isComplete &&
        llmReady &&
        !keyboardOpen;

    if (!shouldShow) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            ref.read(voiceOnboardingProvider.notifier).markSeen(),
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          child: Stack(
            children: [
              // 麦克风右下气泡
              Positioned(
                right: 16,
                bottom: 96, // 麦克风按钮 24+56=80，再 +16 留空
                child: _Bubble(
                  emoji: '🎙',
                  title: '长按这里跟我说话',
                  subtitle: '问问题、加日程、查天气都行',
                  arrowOnRight: true,
                ),
              ),
              // 文字按钮上面的气泡
              Positioned(
                right: 80,
                bottom: 96,
                child: _Bubble(
                  emoji: '📝',
                  title: '点这里打字 + 拍照',
                  subtitle: '附图片让我看',
                  arrowOnRight: false,
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 80,
                child: Center(
                  child: _DismissHint(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool arrowOnRight;

  const _Bubble({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.arrowOnRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          arrowOnRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.cream100,
            border:
                Border.all(color: AppColors.ink900, width: 2),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.popLight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.ink900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.ink600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        // 箭头朝下指向按钮
        Padding(
          padding: arrowOnRight
              ? const EdgeInsets.only(right: 18)
              : const EdgeInsets.only(left: 18),
          child: const Icon(
            Icons.arrow_drop_down_rounded,
            color: AppColors.ink900,
            size: 32,
          ),
        ),
      ],
    );
  }
}

class _DismissHint extends StatelessWidget {
  const _DismissHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.ink900, width: 1.5),
      ),
      child: const Text(
        '点任意位置关闭',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: AppColors.ink900,
        ),
      ),
    );
  }
}
