import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_calc.dart';
import 'fitness_repository.dart';
import 'fitness_trends.dart';
import 'widgets/day_summary_tile.dart';

/// 历史：按日列表，点进某天看明细。
///
/// 趋势图（体重曲线 / 热量 vs 目标 / 训练坚持度）是下一步，
/// 这里先解决「翻到某天看当时到底吃了什么」。
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  static const _ranges = [7, 30, 90];
  int _days = 30;

  Future<List<DaySummary>> _load() async {
    final repo = ref.read(fitnessRepositoryProvider);
    final now = DateTime.now();
    final to = FitnessCalc.isoDate(now);
    final from = FitnessCalc.isoDate(now.subtract(Duration(days: _days - 1)));

    final meals = await repo.mealsBetween(from, to);
    final trainings = await repo.trainingBetween(from, to);
    final weights = await repo.weightsBetween(from, to);

    return FitnessTrends.daySummaries(
      meals: meals.map((m) => DayMeal(date: m.date, kcal: m.kcal)).toList(),
      trainings: {for (final t in trainings) t.date: t.done},
      weights: {for (final w in weights) w.date: w.weightKg},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('壶铃 · 历史'),
      ),
      body: FutureBuilder<List<DaySummary>>(
        future: _load(),
        builder: (context, snap) {
          final days = snap.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final d in _ranges)
                    GestureDetector(
                      onTap: () => setState(() => _days = d),
                      child: CreamPill(
                        label: '$d 天',
                        background: d == _days
                            ? AppColors.peach300
                            : AppColors.cream200,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (days == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (days.isEmpty)
                CreamCard(
                  background: AppColors.cream200,
                  child: Column(
                    children: const [
                      Sticker(
                          emoji: '📒', size: 48, background: AppColors.lemon300),
                      SizedBox(height: AppSpacing.md),
                      Text('这段时间还没有记录',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                      SizedBox(height: AppSpacing.xs),
                      Text('记几天三餐和体重，这里就能翻了',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.ink600)),
                    ],
                  ),
                )
              else
                for (final d in days)
                  DaySummaryTile(
                    summary: d,
                    onTap: () async {
                      await context.push('/fitness/day', extra: d.date);
                      if (mounted) setState(() {});
                    },
                  ),
            ],
          );
        },
      ),
    );
  }
}
