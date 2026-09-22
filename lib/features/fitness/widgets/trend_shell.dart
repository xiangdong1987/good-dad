import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';

/// 三张趋势卡共用的外壳：贴纸 + 标题 + 右上角数字。
class TrendShell extends StatelessWidget {
  final String emoji;
  final Color background;
  final String title;
  final Widget? trailing;
  final Widget child;

  const TrendShell({
    super.key,
    required this.emoji,
    required this.background,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: CreamCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Sticker(emoji: emoji, size: 32, background: background),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
              ),
              ?trailing,
            ]),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

/// 数据不够时的占位。空着不画比画一条假曲线诚实。
class TrendEmpty extends StatelessWidget {
  final String text;
  const TrendEmpty({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cream200,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.ink600)),
      );
}
