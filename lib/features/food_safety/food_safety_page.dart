import 'package:flutter/material.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 能不能吃 · Food Safety
class FoodSafetyPage extends StatelessWidget {
  const FoodSafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('能不能吃？', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('拍一张照片，或者直接问我',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 16),

          // 结果卡 — 螃蟹
          CreamCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.rose300,
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.ink900, width: 2)),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 2)),
                  ),
                  child: Stack(children: const [
                    Center(child: Text('🦀', style: TextStyle(fontSize: 70))),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Sticker(
                          emoji: '❌', background: Colors.white, size: 44),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        StatusTag(kind: SafetyTag.avoid, label: '避免'),
                        SizedBox(width: 8),
                        Text('螃蟹',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.ink600)),
                      ]),
                      const SizedBox(height: 6),
                      const Text('这个先放下吧，孕期不太合适。',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              height: 1.4)),
                      const SizedBox(height: 6),
                      const Text(
                        '性偏寒，可能引起宫缩；蟹黄重金属也偏高。\n想吃海鲜可以选三文鱼或鳕鱼，铁和 DHA 都比螃蟹高。',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.ink700),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      const Text(
                        '这是参考，特殊情况问产检医生 🩺',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.ink600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text('最近问过 ↓',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 8),
          const Wrap(spacing: 8, runSpacing: 8, children: [
            CreamPill(label: '虾', leadingEmoji: '🦐'),
            CreamPill(
                label: '牛油果',
                leadingEmoji: '🥑',
                background: AppColors.mint300),
            CreamPill(label: '咖啡', leadingEmoji: '☕'),
            CreamPill(
                label: '生鱼片',
                leadingEmoji: '🍣',
                background: AppColors.rose300),
          ]),
          const SizedBox(height: 20),

          // 输入坞
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cream100,
              border: Border.all(color: AppColors.ink900, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.popLight,
            ),
            child: Row(children: const [
              Sticker(
                  emoji: '📷', background: AppColors.peach300, size: 42),
              SizedBox(width: 10),
              Expanded(
                child: Text('「这个能吃吗？」',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.ink400)),
              ),
              Sticker(
                  emoji: '🎤', background: AppColors.cream200, size: 42),
            ]),
          ),
        ],
      ),
    );
  }
}
