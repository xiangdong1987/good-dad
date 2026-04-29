import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/llm/openai_compatible_client.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 首页 · 圆润奶油可爱风
/// 翻译自 good-dad-cute.html 的 HomeScreen
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static final _skills = <_Skill>[
    _Skill('能不能吃', '🍱', '拍一张，问我', AppColors.mint300, '/food'),
    _Skill('本周孕期', '👶', '宝宝在做啥', AppColors.sky300, '/week'),
    _Skill('孕期食谱', '🍲', '今天做点啥', AppColors.lemon300, '/recipe'),
    _Skill('肚肚照', '🤰', '本月该拍了', AppColors.peach200, '/belly'),
    _Skill('产前准备', '📋', '待产包', AppColors.cream200, '/checklist'),
    _Skill('宝宝采购', '🛒', '分阶段不囤', AppColors.rose300, '/shopping'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llmReady = ref.watch(llmClientProvider) != null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // 顶部问候
            Row(
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
                      Text('嘿，老周',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.ink600)),
                      Text('今天孕 24 周第 3 天',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 今日重点 hero card
            CreamCard(
              background: AppColors.peach300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CreamPill(
                    label: '✨ 今天重点',
                    background: Colors.white,
                    foreground: AppColors.peach700,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '妈妈说昨晚有点反胃\n下班顺路买点橘子？🍊',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.4,
                      color: AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    CreamButton(label: '已记下 ✓', onPressed: () {}),
                    const SizedBox(width: 8),
                    CreamButton(
                        label: '晚点说', ghost: true, onPressed: () {}),
                  ]),
                ],
              ),
            ),
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
              children: _skills
                  .map((s) => SkillCard(
                        emoji: s.emoji,
                        title: s.title,
                        subtitle: s.sub,
                        background: s.bg,
                        onTap: () => context.push(s.route),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 14),

            // 聊聊横条
            CreamCard(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('聊聊 · M2 阶段联通')),
                );
              },
              padding: const EdgeInsets.all(14),
              child: Row(children: const [
                Sticker(emoji: '💬', size: 44),
                SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('聊聊',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 14)),
                    SizedBox(height: 2),
                    Text('什么都能问，不用客气',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.ink600)),
                  ],
                )),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.peach700),
              ]),
            ),
          ],
        ),
      ),
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
