import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';
import '../fitness_trends.dart';

/// 历史列表里的一天。
///
/// 没记的项显示「—」而不是 0——「那天没记」和「那天吃了 0 卡」是两回事。
class DaySummaryTile extends StatelessWidget {
  final DaySummary summary;
  final VoidCallback onTap;

  const DaySummaryTile({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;
    final s = summary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CreamCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    FitnessTrends.dayLabel(s.date),
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: ink),
                  ),
                ),
                if (s.weightKg != null)
                  CreamPill(
                    label: '${_trim(s.weightKg!)} kg',
                    leadingEmoji: '⚖️',
                    background: AppColors.sky300,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Text('🍽 ',
                    style: TextStyle(fontSize: 13)),
                _value(
                  ink,
                  s.intakeKcal == null ? '—' : '${s.intakeKcal} 大卡',
                  muted: s.intakeKcal == null,
                ),
                if (s.mealCount > 0)
                  Text('  ${s.mealCount} 餐',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.ink600)),
                const Spacer(),
                const Text('🏋️ ', style: TextStyle(fontSize: 13)),
                if (s.trainingDone == null)
                  _value(ink, '—', muted: true)
                else if (s.trainingDone!)
                  const StatusTag(kind: SafetyTag.ok, label: '已完成')
                else
                  const StatusTag(kind: SafetyTag.caution, label: '没练'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _value(Color ink, String text, {bool muted = false}) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: muted ? AppColors.ink400 : ink,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}
