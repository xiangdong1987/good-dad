import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/calendar/daily_task.dart';
import '../../core/calendar/daily_task_repository.dart';
import '../../core/profile/profile.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 首页 hero 卡：当前孕周 + 今日 TODO 列表 + 加任务 + 打开日历入口。
class TodayCard extends ConsumerWidget {
  final FamilyProfile profile;
  const TodayCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider).valueOrNull ?? const [];
    final week = profile.currentWeek();
    final dayInWk = profile.currentDayInWeek();
    final weekText = week == null
        ? '设个孕周吧'
        : '孕 $week 周${dayInWk == null || dayInWk == 0 ? '' : '$dayInWk 天'}';

    return CreamCard(
      background: AppColors.peach300,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CreamPill(
                label: '✨ 今日',
                background: Colors.white,
                foreground: AppColors.peach700,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/profile-edit'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppRadius.pill),
                    border:
                        Border.all(color: AppColors.ink900, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(weekText,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: AppColors.peach700)),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded,
                          size: 12, color: AppColors.ink600),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: '日历',
                onPressed: () => context.push('/calendar'),
                icon: const Icon(Icons.calendar_month_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                      color: AppColors.ink900, width: 1.5),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            _EmptyState(onAdd: () => _openAddSheet(context, ref))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in tasks.take(5))
                  _TaskRow(task: t, ref: ref),
                if (tasks.length > 5) ...[
                  const SizedBox(height: 4),
                  Text('还有 ${tasks.length - 5} 条 · 去日历查看',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.ink600)),
                ],
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CreamButton(
                  label: '加一项',
                  emoji: '➕',
                  ghost: true,
                  onPressed: () => _openAddSheet(context, ref),
                  full: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _QuickAddSheet(forDate: DailyTask.atMidnight(DateTime.now())),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.ink900, width: 1.5),
        ),
        child: Row(
          children: const [
            Text('🗓', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '今天还没安排啥 · 加一项试试',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.ink700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final DailyTask task;
  final WidgetRef ref;
  const _TaskRow({required this.task, required this.ref});

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dailyTaskRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => repo.setDone(task.id!, !task.done),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.done ? AppColors.mint500 : Colors.white,
                border: Border.all(color: AppColors.ink900, width: 1.5),
                borderRadius: BorderRadius.circular(7),
              ),
              child: task.done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(task.kind.emoji,
              style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                decoration:
                    task.done ? TextDecoration.lineThrough : null,
                color:
                    task.done ? AppColors.ink400 : AppColors.ink900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  final DateTime forDate;
  const _QuickAddSheet({required this.forDate});
  @override
  ConsumerState<_QuickAddSheet> createState() =>
      _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _ctl = TextEditingController();
  TaskKind _kind = TaskKind.todo;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    await ref.read(dailyTaskRepositoryProvider).add(DailyTask(
          title: t,
          forDate: widget.forDate,
          kind: _kind,
        ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('给今天加一项',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _ctl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '比如「带老婆产检 9:30」',
            ),
            onSubmitted: (_) => _add(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: TaskKind.values
                .map((k) => ChoiceChip(
                      label: Text('${k.emoji} ${k.label}'),
                      selected: _kind == k,
                      onSelected: (_) => setState(() => _kind = k),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          CreamButton(label: '加进来', emoji: '➕', onPressed: _add, full: true),
        ],
      ),
    );
  }
}
