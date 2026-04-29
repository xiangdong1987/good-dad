import 'package:flutter/material.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 肚肚照 · Belly Photo
class BellyPhotoPage extends StatelessWidget {
  const BellyPhotoPage({super.key});

  static const _months = [
    (12, '🌱', true, AppColors.mint300, false),
    (16, '🌿', true, AppColors.mint300, false),
    (20, '🌷', true, AppColors.peach300, false),
    (24, '🌽', true, AppColors.lemon300, true),
    (28, '🍐', false, AppColors.cream200, false),
    (32, '🍉', false, AppColors.cream200, false),
    (36, '🎃', false, AppColors.cream200, false),
    (40, '🎉', false, AppColors.cream200, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.ios_share_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('肚肚相册', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          const Text('一个月一张，最后会做成成长动画',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 16),

          CreamCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    color: AppColors.peach200,
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.ink900, width: 2)),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 2)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('🤰', style: TextStyle(fontSize: 64)),
                        SizedBox(height: 8),
                        Text('第 24 周 · 侧面照 placeholder',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: AppColors.peach700,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('2026 · 4 月',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.ink600)),
                          Text('本月已记 ✓',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    CreamButton(
                        label: '重拍', emoji: '📷', onPressed: () {}),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text('一路走过来 · 4 / 8 个月',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.ink700)),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _months.map((m) {
              final isCurrent = m.$5;
              return Container(
                decoration: BoxDecoration(
                  color: m.$4,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isCurrent ? AppColors.peach500 : AppColors.ink900,
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                  boxShadow: isCurrent ? AppShadows.popLight : null,
                ),
                child: Stack(children: [
                  Center(
                    child: Opacity(
                      opacity: m.$3 ? 1 : 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(m.$2, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 2),
                          Text('${m.$1}w',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  color: AppColors.ink700)),
                        ],
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.peach500,
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: AppColors.ink900, width: 1.5),
                        ),
                        child: const Text('NOW',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                color: Colors.white)),
                      ),
                    ),
                ]),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Center(
            child: Text(
              '再过 4 周拍下一张 · 9 月会变成成长视频 🎞',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink600),
            ),
          ),
        ],
      ),
    );
  }
}
