import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';
import '../fitness_calc.dart';
import '../fitness_met.dart';
import '../fitness_models.dart';

/// 今日消耗卡：基础代谢 + 训练 + 日常活动。
///
/// 只展示，不参与热量目标计算——目标走 TDEE（含活动系数），
/// 把训练消耗再加进去会重复计算。
class BurnCard extends StatelessWidget {
  final DayBurn burn;
  final double trainingMinutes;
  final List<ActivityEntry> activities;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;

  const BurnCard({
    super.key,
    required this.burn,
    required this.trainingMinutes,
    required this.activities,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;

    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Sticker(
                  emoji: '🔥', background: AppColors.peach300, tilt: -6),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('今日消耗',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Text(
                '${FitnessMet.displayKcal(burn.total)}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 2),
              const Text('大卡',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.ink600)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _BurnRow(
            emoji: '😴',
            label: '基础代谢',
            hint: '躺着也在烧',
            kcal: burn.restingKcal,
            color: AppColors.sky500,
          ),
          _BurnRow(
            emoji: '🏋️',
            label: '壶铃训练',
            hint: trainingMinutes > 0
                ? '约 ${trainingMinutes.round()} 分钟'
                : '今天还没练',
            kcal: burn.trainingKcal,
            color: AppColors.peach500,
          ),
          _BurnRow(
            emoji: '🚶',
            label: '日常活动',
            hint: activities.isEmpty ? '走路、爬楼、抱娃都算' : '${activities.length} 笔',
            kcal: burn.activityKcal,
            color: AppColors.mint500,
          ),
          if (activities.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final a in activities)
                  GestureDetector(
                    onLongPress: () => onDelete(a.id),
                    child: CreamPill(
                      label: '${a.kind.zh} ${a.minutes}分 · ${a.kcal}大卡',
                      leadingEmoji: a.kind.emoji,
                      background: AppColors.mint300,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('长按一条可以删掉',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.ink400)),
          ],
          const SizedBox(height: AppSpacing.lg),
          CreamButton(
              label: '记一笔日常活动', emoji: '➕', full: true, onPressed: onAdd),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${FitnessCalc.burnCompareText(burn.activeKcal)}。真正决定体重的，还是那三张照片里的东西。',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.5,
                color: AppColors.ink600),
          ),
        ],
      ),
    );
  }
}

class _BurnRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String hint;
  final int kcal;
  final Color color;

  const _BurnRow({
    required this.emoji,
    required this.label,
    required this.hint,
    required this.kcal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Sticker(emoji: emoji, size: 32, background: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: ink)),
                Text(hint,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.ink600)),
              ],
            ),
          ),
          Text(
            kcal > 0 ? '+${FitnessMet.displayKcal(kcal)}' : '—',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: kcal > 0 ? ink : AppColors.ink400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
