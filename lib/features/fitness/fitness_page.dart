import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'fitness_calc.dart';
import 'fitness_llm.dart';
import 'fitness_met.dart';
import 'fitness_models.dart';
import 'fitness_repository.dart';
import 'widgets/activity_sheet.dart';
import 'widgets/burn_card.dart';
import 'widgets/macro_ring.dart';

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 今日页：训练计划 + 三餐进度环 + 明日计划。
class FitnessPage extends ConsumerStatefulWidget {
  const FitnessPage({super.key});

  @override
  ConsumerState<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends ConsumerState<FitnessPage> {
  bool _checkedProfile = false;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final repo = ref.read(fitnessRepositoryProvider);
    final profile = await repo.loadProfile();
    if (!mounted) return;
    // 资料不全：引导先去填
    if (!profile.isComplete && !_checkedProfile) {
      _checkedProfile = true;
      await context.push('/fitness/profile');
    }
    await _maybeGeneratePlan();
  }

  Future<void> _maybeGeneratePlan() async {
    final repo = ref.read(fitnessRepositoryProvider);
    final now = DateTime.now();
    final tomorrow = _isoDate(now.add(const Duration(days: 1)));
    final has = (await repo.planForDate(tomorrow)) != null;
    if (!FitnessCalc.needsPlanGeneration(
        hasPlanForTomorrow: has, hour: now.hour)) {
      return;
    }
    final llm = ref.read(fitnessLlmProvider);
    if (llm == null) return;
    final profile = await repo.loadProfile();
    if (!profile.isComplete) return;

    final today = _isoDate(now);
    final meals = await repo.mealsForDate(today);
    final totals = FitnessCalc.sumDay(meals
        .map((m) => MealAnalysis(
            kcal: m.kcal, proteinG: m.proteinG, carbG: m.carbG, fatG: m.fatG))
        .toList());
    final training = await repo.trainingForDate(today);

    if (!mounted) return;
    setState(() => _generating = true);
    try {
      final plan = await llm.generateTomorrowPlan(
        profile: profile,
        totals: totals,
        trainingDone: training?.done ?? false,
      );
      await repo.savePlan(tomorrow, plan);
    } catch (_) {
      // 生成失败静默，页面照常展示已有数据
    }
    if (mounted) setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(fitnessRepositoryProvider);
    final today = _isoDate(DateTime.now());
    final mealsStream = repo.watchMealsForDate(today);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('壶铃 · 今日'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/fitness/profile'),
          ),
        ],
      ),
      body: StreamBuilder<List<MealLogRow>>(
        stream: mealsStream,
        builder: (context, snap) {
          final meals = snap.data ?? const <MealLogRow>[];
          return FutureBuilder<_TodayData>(
            future: _loadToday(repo, today, meals),
            builder: (context, ds) {
              final data = ds.data;
              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  _TrainingCard(
                    plan: data.todayPlan,
                    done: data.trainingDone,
                    onDone: () async {
                      await repo.markTrainingDone(
                          today,
                          jsonEncode(data.todayPlan
                              .map((m) => m.toJson())
                              .toList()));
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _MealsSection(
                    date: today,
                    meals: meals,
                    targets: data.targets,
                    onRefresh: () => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  BurnCard(
                    burn: data.burn,
                    trainingMinutes: data.trainingMinutes,
                    activities: data.activities,
                    onAdd: () => _addActivity(repo, today, data.profile),
                    onDelete: (id) async {
                      await repo.deleteActivity(id);
                      if (mounted) setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _TomorrowCard(
                      plan: data.tomorrowPlan, generating: _generating),
                  const SizedBox(height: 20),
                  const Text(
                    '这是 AI 给的训练参考，身体不舒服就停，必要时问专业教练/医生 🩺',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink600),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addActivity(
      FitnessRepository repo, String date, FitnessProfile profile) async {
    final picked = await showActivitySheet(context,
        weightKg: profile.weightKg ?? FitnessCalc.fallbackWeightKg);
    if (picked == null) return;
    final (kind, minutes) = picked;
    await repo.addActivity(
      date: date,
      kind: kind,
      minutes: minutes,
      kcal: FitnessMet.netKcal(
        kind: kind,
        weightKg: profile.weightKg ?? FitnessCalc.fallbackWeightKg,
        minutes: minutes.toDouble(),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<_TodayData> _loadToday(
      FitnessRepository repo, String today, List<MealLogRow> meals) async {
    final profile = await repo.loadProfile();
    final todayPlanRow = await repo.planForDate(today);
    final tomorrow =
        _isoDate(DateTime.now().add(const Duration(days: 1)));
    final tomorrowRow = await repo.planForDate(tomorrow);
    final training = await repo.trainingForDate(today);

    final todayPlan = todayPlanRow == null
        ? <TrainingMove>[]
        : (jsonDecode(todayPlanRow.trainingPlanJson) as List)
            .map((e) => TrainingMove.fromJson(e as Map<String, dynamic>))
            .toList();

    final targets = todayPlanRow != null
        ? MacroTargets(
            kcal: todayPlanRow.kcalTarget,
            proteinG: todayPlanRow.proteinTarget,
            carbG: todayPlanRow.carbTarget,
            fatG: todayPlanRow.fatTarget,
          )
        : FitnessCalc.defaultTargets(profile);

    final done = training?.done ?? false;
    final weight = profile.weightKg ?? FitnessCalc.fallbackWeightKg;
    // 只有标记完成的训练才算进消耗，计划摆在那不等于练了。
    final session = done
        ? FitnessMet.sessionBurn(plan: todayPlan, weightKg: weight)
        : BurnEstimate.zero;
    final activities = await repo.activitiesOn(today);
    final activityKcal =
        activities.fold<int>(0, (sum, a) => sum + a.kcal);

    return _TodayData(
      todayPlan: todayPlan,
      trainingDone: done,
      targets: targets,
      tomorrowPlan: tomorrowRow,
      profile: profile,
      trainingMinutes: session.minutes,
      activities: activities,
      burn: FitnessCalc.dayBurn(
        profile: profile,
        trainingKcal: session.kcal,
        activityKcal: activityKcal,
      ),
    );
  }
}

class _TodayData {
  final List<TrainingMove> todayPlan;
  final bool trainingDone;
  final MacroTargets targets;
  final DailyPlanRow? tomorrowPlan;
  final FitnessProfile profile;
  final double trainingMinutes;
  final List<ActivityEntry> activities;
  final DayBurn burn;
  _TodayData({
    required this.todayPlan,
    required this.trainingDone,
    required this.targets,
    required this.tomorrowPlan,
    required this.profile,
    required this.trainingMinutes,
    required this.activities,
    required this.burn,
  });
}

class _TrainingCard extends StatelessWidget {
  final List<TrainingMove> plan;
  final bool done;
  final VoidCallback onDone;
  const _TrainingCard(
      {required this.plan, required this.done, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Sticker(emoji: '🏋️', background: AppColors.peach300),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('今日训练',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ),
            if (done) const StatusTag(kind: SafetyTag.ok, label: '已完成'),
          ]),
          const SizedBox(height: 12),
          if (plan.isEmpty)
            const Text('今天还没有训练计划——晚上我会根据今天的情况生成明天的。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600))
          else
            ...plan.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '· ${m.move} — ${m.sets}组×${m.reps} @ ${m.weightKg}kg'
                    '${m.note.isEmpty ? '' : '（${m.note}）'}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.5),
                  ),
                )),
          if (plan.isNotEmpty && !done) ...[
            const SizedBox(height: 8),
            CreamButton(
                label: '标记完成', emoji: '✅', full: true, onPressed: onDone),
          ],
        ],
      ),
    );
  }
}

class _MealsSection extends StatelessWidget {
  final String date;
  final List<MealLogRow> meals;
  final MacroTargets targets;
  final VoidCallback onRefresh;
  const _MealsSection({
    required this.date,
    required this.meals,
    required this.targets,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    var kcal = 0, p = 0, c = 0, f = 0;
    for (final m in meals) {
      kcal += m.kcal;
      p += m.proteinG;
      c += m.carbG;
      f += m.fatG;
    }
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('今日三餐',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MacroRing(
                  label: '热量',
                  value: kcal,
                  target: targets.kcal,
                  color: AppColors.peach500),
              MacroRing(
                  label: '蛋白',
                  value: p,
                  target: targets.proteinG,
                  unit: 'g',
                  color: AppColors.mint500),
              MacroRing(
                  label: '碳水',
                  value: c,
                  target: targets.carbG,
                  unit: 'g',
                  color: AppColors.sky500),
              MacroRing(
                  label: '脂肪',
                  value: f,
                  target: targets.fatG,
                  unit: 'g',
                  color: AppColors.lemon500),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Meal.values.map((meal) {
              final logged = meals.any((m) => m.meal == meal.name);
              return GestureDetector(
                onTap: () async {
                  await context.push('/fitness/meal',
                      extra: {'date': date, 'meal': meal});
                  onRefresh();
                },
                child: CreamPill(
                  label: meal.zh,
                  leadingEmoji: logged ? '✅' : '📷',
                  background:
                      logged ? AppColors.mint300 : AppColors.cream100,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TomorrowCard extends StatelessWidget {
  final DailyPlanRow? plan;
  final bool generating;
  const _TomorrowCard({required this.plan, required this.generating});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      background: AppColors.cream200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Sticker(emoji: '🌙', background: AppColors.sky300),
            SizedBox(width: 10),
            Text('明日计划',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ]),
          const SizedBox(height: 12),
          if (generating)
            const Row(children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('我正在根据今天的情况生成…',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ])
          else if (plan == null)
            const Text('晚上我会根据你今天吃了/练了什么，生成明天的计划。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600))
          else ...[
            if (plan!.deficitSummary.isNotEmpty)
              Text(plan!.deficitSummary,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.4)),
            const SizedBox(height: 8),
            Text('🍽 ${plan!.dietGuidance}',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 4),
            Text(
                '🎯 目标 ${plan!.kcalTarget}kcal · 蛋白 ${plan!.proteinTarget}g',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.ink600)),
          ],
        ],
      ),
    );
  }
}
