import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_models.dart';
import 'fitness_repository.dart';
import 'fitness_trends.dart';

/// 某一天的明细：三餐（含当时的照片）、训练、日常活动、体重。
///
/// 点某一餐直接进记餐页编辑——翻到三天前发现记错了，当场能改。
class DayDetailPage extends ConsumerStatefulWidget {
  final String date;
  const DayDetailPage({super.key, required this.date});

  @override
  ConsumerState<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends ConsumerState<DayDetailPage> {
  Future<_DayData> _load() async {
    final repo = ref.read(fitnessRepositoryProvider);
    return _DayData(
      meals: await repo.mealsForDate(widget.date),
      training: await repo.trainingForDate(widget.date),
      activities: await repo.activitiesOn(widget.date),
      weight: await repo.weightOn(widget.date),
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
        title: Text(FitnessTrends.dayLabel(widget.date)),
      ),
      body: FutureBuilder<_DayData>(
        future: _load(),
        builder: (context, snap) {
          final d = snap.data;
          if (d == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              if (d.weight != null) ...[
                CreamCard(
                  child: Row(children: [
                    const Sticker(
                        emoji: '⚖️', size: 32, background: AppColors.sky500),
                    const SizedBox(width: AppSpacing.md),
                    Text('${d.weight!.weightKg} kg',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              for (final meal in Meal.values)
                _MealBlock(
                  meal: meal,
                  row: d.meals.where((m) => m.meal == meal.name).firstOrNull,
                  onEdit: () async {
                    await context.push('/fitness/meal',
                        extra: {'date': widget.date, 'meal': meal});
                    if (mounted) setState(() {});
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
              _TrainingBlock(row: d.training),
              if (d.activities.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                CreamCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('日常活动',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 15)),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final a in d.activities)
                            CreamPill(
                              label: '${a.kind.zh} ${a.minutes}分 · ${a.kcal}大卡',
                              leadingEmoji: a.kind.emoji,
                              background: AppColors.mint300,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DayData {
  final List<MealLogRow> meals;
  final TrainingLogRow? training;
  final List<ActivityEntry> activities;
  final WeightEntry? weight;
  _DayData({
    required this.meals,
    required this.training,
    required this.activities,
    required this.weight,
  });
}

class _MealBlock extends StatelessWidget {
  final Meal meal;
  final MealLogRow? row;
  final VoidCallback onEdit;
  const _MealBlock({required this.meal, required this.row, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final r = row;
    final foods = r == null
        ? const <FoodItem>[]
        : (jsonDecode(r.foodsJson) as List)
            .map((e) => FoodItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CreamCard(
        onTap: onEdit,
        background: r == null ? AppColors.cream200 : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(meal.zh,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
              ),
              if (r == null)
                const Text('没记',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.ink400))
              else
                Text('${r.kcal} 大卡',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      fontFeatures: [FontFeature.tabularFigures()],
                    )),
            ]),
            if (r?.photoPath != null) ...[
              const SizedBox(height: AppSpacing.md),
              _MealPhoto(path: r!.photoPath!),
            ],
            if (foods.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final f in foods)
                    CreamPill(
                        label: '${f.name} ${f.grams}g', leadingEmoji: '🍴'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 老记录的照片文件可能已被系统清理，文件不在就直接不显示，不摆破图。
class _MealPhoto extends StatelessWidget {
  final String path;
  const _MealPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }
}

class _TrainingBlock extends StatelessWidget {
  final TrainingLogRow? row;
  const _TrainingBlock({required this.row});

  @override
  Widget build(BuildContext context) {
    final r = row;
    final moves = r == null
        ? const <TrainingMove>[]
        : (jsonDecode(r.planJson) as List)
            .map((e) => TrainingMove.fromJson((e as Map).cast<String, dynamic>()))
            .toList();

    return CreamCard(
      background: r == null ? AppColors.cream200 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Sticker(
                emoji: '🏋️', size: 32, background: AppColors.peach300),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text('训练',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 15)),
            ),
            if (r == null)
              const Text('没记',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.ink400))
            else if (r.done)
              const StatusTag(kind: SafetyTag.ok, label: '已完成')
            else
              const StatusTag(kind: SafetyTag.caution, label: '没练'),
          ]),
          for (final m in moves) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('· ${m.move} ${m.sets}组×${m.reps} @ ${m.weightKg}kg',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.4)),
          ],
        ],
      ),
    );
  }
}
