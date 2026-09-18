import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';
import '../fitness_calc.dart';
import '../fitness_models.dart';

/// 今日页顶部的称重卡。
///
/// fitness_profile 是单行 upsert，改体重会覆盖旧值；这张卡把每天的体重
/// 留进 weight_log，减脂曲线才画得出来。
class WeightCard extends StatelessWidget {
  final WeightEntry? today;
  final WeightEntry? previous;
  final Goal goal;
  final VoidCallback onRecord;

  const WeightCard({
    super.key,
    required this.today,
    required this.previous,
    required this.goal,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;
    final w = today;

    return CreamCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Sticker(emoji: '⚖️', size: 36, background: AppColors.sky500),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: w == null
                ? Text('今天称了吗',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: ink))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${FitnessCalc.weightText(w.weightKg)} kg',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: ink,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (previous != null)
                        Text(
                          FitnessCalc.weightDeltaLabel(
                              w.weightKg - previous!.weightKg),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _deltaColor(w.weightKg - previous!.weightKg),
                          ),
                        ),
                    ],
                  ),
          ),
          if (w == null)
            CreamButton(label: '记一下', emoji: '⚖️', onPressed: onRecord)
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 22),
              onPressed: onRecord,
            ),
        ],
      ),
    );
  }

  /// 变化是不是朝着目标走的：减脂盼掉秤，增肌盼涨秤。
  Color _deltaColor(double delta) {
    final favorable = FitnessCalc.isFavorableWeightChange(
      deltaKg: delta,
      goal: goal,
    );
    if (favorable == null) return AppColors.ink600;
    return favorable ? AppColors.mint700 : AppColors.lemon500;
  }
}
