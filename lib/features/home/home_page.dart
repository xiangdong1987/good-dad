import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/llm/llm_providers.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import '../onboarding/onboarding_page.dart';
import 'today_card.dart';

/// 首页 · 圆润奶油可爱风
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static final _skills = <_Skill>[
    _Skill('能不能吃', '🍱', '拍一张，问我', AppColors.mint300, '/food'),
    _Skill('本周孕期', '👶', '宝宝在做啥', AppColors.sky300, '/week'),
    _Skill('孕期食谱', '🍲', '今天做点啥', AppColors.lemon300, '/recipe'),
    _Skill('肚肚照', '🤰', '本月该拍了', AppColors.peach200, '/belly'),
    _Skill('产前准备', '📋', '待产包', AppColors.cream200, '/checklist'),
    _Skill('宝宝采购', '🛒', '分阶段不囤', AppColors.rose300, '/shopping'),
    _Skill('意大利驾照', '🚗', '拍题学语法', AppColors.peach300, '/italian-license'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('读取家庭信息失败: $e')),
          data: (profile) {
            if (!profile.isComplete) return const OnboardingPage();
            return _HomeContent(profile: profile, skills: _skills);
          },
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final FamilyProfile profile;
  final List<_Skill> skills;

  const _HomeContent({required this.profile, required this.skills});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llmReady = ref.watch(llmClientProvider) != null;
    final week = profile.currentWeek();
    final dayInWeek = profile.currentDayInWeek();
    final weekText = week == null
        ? '已设置完成'
        : '今天孕 $week 周${dayInWeek == null || dayInWeek == 0 ? '' : '第 $dayInWeek 天'}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // 顶部问候 — 点 🐻 / 名字 / 孕周徽 都进设置
        InkWell(
          onTap: () => context.push('/settings'),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Sticker(
                    emoji: '🐻',
                    background: AppColors.lemon300,
                    tilt: -4,
                    size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('嘿，${profile.dadName ?? "爸爸"}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.ink600)),
                      Text(weekText,
                          style:
                              Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                Icon(Icons.settings_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 今日要点：当前孕周 + 今日 TODO + 加任务 + 打开日历
        TodayCard(profile: profile),
        const SizedBox(height: 18),

        // LLM 状态
        if (!llmReady)
          _StatusBanner(onTap: () => context.push('/settings')),
        if (!llmReady) const SizedBox(height: 14),

        Text('今天能帮上什么？',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: skills
              .map((s) => SkillCard(
                    emoji: s.emoji,
                    title: s.title,
                    subtitle: s.sub,
                    background: s.bg,
                    onTap: () => context.push(s.route),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _Skill {
  final String title, emoji, sub, route;
  final Color bg;
  _Skill(this.title, this.emoji, this.sub, this.bg, this.route);
}

class _StatusBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _StatusBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      background: AppColors.lemon300,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(children: const [
        Sticker(
            emoji: '⚙️',
            size: 36,
            background: Colors.white,
            tilt: -4),
        SizedBox(width: 10),
        Expanded(
            child: Text(
          '还没配 LLM——点这里去设置',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: Color(0xFF8A6B14),
          ),
        )),
      ]),
    );
  }
}
