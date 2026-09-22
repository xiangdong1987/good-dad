import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../fitness_trends.dart';
import 'trend_shell.dart';

/// 训练坚持度。二元数据（练没练）画折线没意义，用方格阵。
class TrainingStreakCard extends StatelessWidget {
  final Map<String, bool> trainings;
  final String today;
  final int days;

  const TrainingStreakCard({
    super.key,
    required this.trainings,
    required this.today,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final s = FitnessTrends.trainingStreak(trainings, today: today);
    if (s.monthCount == 0 && s.longest == 0) {
      return const TrendShell(
        emoji: '🏋️',
        background: AppColors.mint500,
        title: '训练坚持度',
        child: TrendEmpty(text: '练一次，这里就开始记了'),
      );
    }

    final end = DateTime.parse(today);
    final cells = [
      for (var i = days - 1; i >= 0; i--)
        trainings[FitnessTrends.isoDate(end.subtract(Duration(days: i)))] ==
            true,
    ];

    return TrendShell(
      emoji: '🏋️',
      background: AppColors.mint500,
      title: '训练坚持度',
      trailing: Text(
        '连续 ${s.current} 天',
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 13,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            key: const ValueKey('streak-cells'),
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final done in cells)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: done ? AppColors.mint500 : AppColors.cream200,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.ink900, width: 1.2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '最长连续 ${s.longest} 天 · 本月练了 ${s.monthCount} 次',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.ink600),
          ),
        ],
      ),
    );
  }
}
