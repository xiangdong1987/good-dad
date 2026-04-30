import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 孕期食谱 · Recipe（M2 阶段为视觉占位 mock，文字孕周已联通）
class RecipePage extends ConsumerWidget {
  const RecipePage({super.key});

  static const _ingredients = [
    ('🥩', '牛肉 300g'),
    ('🍅', '番茄 2 个'),
    ('🥔', '土豆 1 个'),
    ('🧅', '洋葱 半个'),
    ('🧄', '蒜 3 瓣'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile =
        ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty;
    final week = profile.currentWeek();
    final subtitle = week == null ? '记得设孕周' : '孕 $week 周 · 该补钙 + 铁';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.favorite_outline_rounded),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('今晚吃啥？', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 16),

          // hero 食谱
          CreamCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    color: AppColors.lemon300,
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.ink900, width: 2)),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 2)),
                  ),
                  child: Stack(children: const [
                    Center(child: Text('🍲', style: TextStyle(fontSize: 78))),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: StatusTag(
                          kind: SafetyTag.ok, label: '补钙 · 补铁'),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Sticker(
                          emoji: '⏱', background: Colors.white, size: 36),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('番茄牛肉炖土豆',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 18)),
                      const SizedBox(height: 4),
                      const Text('35 分钟 · 简单 · 一口锅搞定',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.ink600)),
                      const SizedBox(height: 12),
                      Row(children: const [
                        _Stat(label: '热量', value: '420kcal'),
                        SizedBox(width: 8),
                        _Stat(label: '蛋白质', value: '32g'),
                        SizedBox(width: 8),
                        _Stat(label: '铁', value: '18%', highlight: true),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text('要准备 ↓',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ingredients
                .map((it) => CreamPill(label: it.$2, leadingEmoji: it.$1))
                .toList(),
          ),
          const SizedBox(height: 14),

          CreamCard(
            background: AppColors.peach200,
            padding: const EdgeInsets.all(12),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('🌟', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '番茄里的维生素 C 帮牛肉里的铁吸收，搭配刚刚好——孕中期妈妈最容易缺铁。',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                ]),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(
                child: CreamButton(
                    label: '开始做',
                    emoji: '👨‍🍳',
                    onPressed: () {},
                    full: true)),
            const SizedBox(width: 10),
            CreamButton(label: '换一道', ghost: true, onPressed: () {}),
          ]),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _Stat(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlight ? AppColors.mint300 : AppColors.cream100,
          border: Border.all(color: AppColors.ink900, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: AppColors.ink600)),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.ink900,
                    letterSpacing: -0.3)),
          ],
        ),
      ),
    );
  }
}
