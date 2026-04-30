import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/calendar/daily_task.dart';
import '../../core/calendar/daily_task_repository.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// (year, month) 的任务数 stream 给一个月视图用。
final _monthCountsProvider = StreamProvider.autoDispose
    .family<Map<DateTime, int>, ({int year, int month})>((ref, key) {
  final repo = ref.watch(dailyTaskRepositoryProvider);
  return repo.watchCountsForMonth(key.year, key.month);
});

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _displayedMonth; // 当前展示的月（first day）
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DailyTask.atMidnight(DateTime.now());
    _displayedMonth = DateTime(now.year, now.month);
    _selectedDate = now;
  }

  void _goPrevMonth() {
    setState(() => _displayedMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month - 1));
  }

  void _goNextMonth() {
    setState(() => _displayedMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1));
  }

  void _goToday() {
    final now = DailyTask.atMidnight(DateTime.now());
    setState(() {
      _displayedMonth = DateTime(now.year, now.month);
      _selectedDate = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty;
    final counts = ref.watch(_monthCountsProvider((
      year: _displayedMonth.year,
      month: _displayedMonth.month,
    ))).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('日历'),
        actions: [
          TextButton(onPressed: _goToday, child: const Text('今天')),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _MonthHeader(
              month: _displayedMonth,
              onPrev: _goPrevMonth,
              onNext: _goNextMonth,
            ),
            const SizedBox(height: 8),
            _WeekdayHeader(),
            const SizedBox(height: 4),
            _MonthGrid(
              displayedMonth: _displayedMonth,
              selected: _selectedDate,
              taskCounts: counts,
              profile: profile,
              onSelect: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: _DayPanel(
                date: _selectedDate,
                profile: profile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Month header (← Apr 2026 →)
// ─────────────────────────────────────────────────────────────
class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader(
      {required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy 年 M 月');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left_rounded)),
          Text(fmt.format(month),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
          IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  static const _names = ['一', '二', '三', '四', '五', '六', '日'];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _names
            .map((n) => Expanded(
                  child: Center(
                    child: Text(n,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: AppColors.ink600)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 6 行 × 7 列 grid
// ─────────────────────────────────────────────────────────────
class _MonthGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selected;
  final Map<DateTime, int> taskCounts;
  final FamilyProfile profile;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    required this.displayedMonth,
    required this.selected,
    required this.taskCounts,
    required this.profile,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month);
    // weekday 1=Mon..7=Sun，我们要让 Mon 对到第 0 列
    final leadingBlanks = (firstOfMonth.weekday - 1) % 7;
    final cells = <DateTime>[];
    for (var i = 0; i < 42; i++) {
      cells.add(firstOfMonth
          .subtract(Duration(days: leadingBlanks))
          .add(Duration(days: i)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 0.85,
        children: cells.map((d) {
          final inMonth = d.month == displayedMonth.month;
          final isSelected = DailyTask.isSameDay(d, selected);
          final isToday = DailyTask.isSameDay(d, DateTime.now());
          final week = profile.currentWeek(now: d);
          final count = taskCounts[d] ?? 0;
          return _DayCell(
            date: d,
            inMonth: inMonth,
            selected: isSelected,
            isToday: isToday,
            pregnancyWeek: week,
            taskCount: count,
            onTap: () => onSelect(d),
          );
        }).toList(),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool inMonth;
  final bool selected;
  final bool isToday;
  final int? pregnancyWeek;
  final int taskCount;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.isToday,
    required this.pregnancyWeek,
    required this.taskCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayColor = inMonth
        ? (selected ? Colors.white : AppColors.ink900)
        : AppColors.ink400;
    final bg = selected
        ? AppColors.peach500
        : (isToday ? AppColors.cream200 : Colors.transparent);
    final border = selected
        ? Border.all(color: AppColors.ink900, width: 2)
        : Border.all(color: Colors.transparent, width: 2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${date.day}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: isToday || selected
                      ? FontWeight.w900
                      : FontWeight.w700,
                  fontSize: 13,
                  color: dayColor,
                )),
            if (pregnancyWeek != null && pregnancyWeek! >= 1 && pregnancyWeek! <= 42)
              Text('${pregnancyWeek}w',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.ink600)),
            if (taskCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : AppColors.peach500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 选中天的任务面板
// ─────────────────────────────────────────────────────────────
class _DayPanel extends ConsumerWidget {
  final DateTime date;
  final FamilyProfile profile;
  const _DayPanel({required this.date, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dailyTaskRepositoryProvider);
    final fmt = DateFormat('M 月 d 日');
    final weekdayName = _zhWeekday(date.weekday);
    final week = profile.currentWeek(now: date);
    final dayInWk = profile.currentDayInWeek(now: date);
    final headerSuffix = (week != null && week >= 1 && week <= 42)
        ? '  ·  孕 $week 周${dayInWk == null || dayInWk == 0 ? '' : '$dayInWk 天'}'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${fmt.format(date)} · $weekdayName$headerSuffix',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14),
                ),
              ),
              IconButton(
                tooltip: '加任务',
                icon: const Icon(Icons.add_circle_rounded,
                    color: AppColors.peach500),
                onPressed: () => _openAddSheet(context, ref, date),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<DailyTask>>(
              stream: repo.watchForDate(date),
              builder: (ctx, snap) {
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Sticker(
                              emoji: '🗓',
                              background: AppColors.cream200,
                              tilt: -4,
                              size: 48),
                          SizedBox(height: 12),
                          Text('这天还没安排啥',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.ink700)),
                          SizedBox(height: 4),
                          Text('点右上角 + 加一项',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.ink600)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      _TaskTile(task: list[i], repo: repo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _zhWeekday(int wd) {
    const map = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${map[(wd - 1).clamp(0, 6)]}';
  }

  void _openAddSheet(BuildContext context, WidgetRef ref, DateTime forDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddTaskSheet(forDate: forDate),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final DailyTask task;
  final DailyTaskRepository repo;
  const _TaskTile({required this.task, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.rose500,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => repo.delete(task.id!),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: CreamCard(
          flat: true,
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          child: Row(children: [
            GestureDetector(
              onTap: () => repo.setDone(task.id!, !task.done),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.done ? AppColors.mint500 : Colors.white,
                  border: Border.all(color: AppColors.ink900, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: task.done
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(task.kind.emoji,
                style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  decoration: task.done
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.done
                      ? AppColors.ink400
                      : AppColors.ink900,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  final DateTime forDate;
  const _AddTaskSheet({required this.forDate});
  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _ctl = TextEditingController();
  TaskKind _kind = TaskKind.todo;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _ctl.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(dailyTaskRepositoryProvider);
    await repo.add(DailyTask(
      title: title,
      forDate: widget.forDate,
      kind: _kind,
    ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('M 月 d 日');
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('加一项 · ${fmt.format(widget.forDate)}',
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
