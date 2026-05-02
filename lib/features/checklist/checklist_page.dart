import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/checklist/checklist_repository.dart';
import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 待产包 · prenatal-prep skill 落地页
class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({super.key});
  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  bool _busy = false;
  String? _error;

  Future<void> _generate({bool augment = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(checklistRepositoryProvider);
    try {
      if (augment) {
        await repo.augment('prenatal-prep');
      } else {
        await repo.generate('prenatal-prep');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewAsync = ref.watch(checklistViewProvider('prenatal-prep'));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: '让 AI 补充',
            icon: const Icon(Icons.add_rounded),
            onPressed: _busy ? null : () => _generate(augment: true),
          ),
        ],
      ),
      body: viewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (view) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text('待产包', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 12),
              if (view == null)
                _EmptyState(busy: _busy, onGenerate: () => _generate()),
              if (view != null) _Progress(view: view),
              if (view != null) const SizedBox(height: 14),
              if (view != null)
                ..._buildGroups(view, ref),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.rose300,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.ink900, width: 1.5),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
              if (view != null) ...[
                const SizedBox(height: 16),
                CreamButton(
                  label: _busy ? '生成中…' : '让 AI 补充几项',
                  emoji: _busy ? null : '✨',
                  onPressed:
                      _busy ? null : () => _generate(augment: true),
                  full: true,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildGroups(ChecklistView view, WidgetRef ref) {
    final repo = ref.read(checklistRepositoryProvider);
    final groups = view.groups;
    if (groups.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text('解析失败 · 试试重新生成',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.ink600)),
          ),
        ),
      ];
    }
    final sectionEmojis = ['🤱', '👶', '📑', '🎒', '🛁', '🍼'];
    final widgets = <Widget>[];
    for (var gi = 0; gi < groups.length; gi++) {
      final g = groups[gi];
      final emoji = sectionEmojis[gi % sectionEmojis.length];
      widgets.add(_GroupHeader(
        title: g.title,
        emoji: emoji,
        done: g.items.where((i) => i.checked).length,
        total: g.items.length,
      ));
      widgets.add(const SizedBox(height: 8));
      widgets.add(_ItemsCard(items: g.items, repo: repo));
      widgets.add(const SizedBox(height: 14));
    }
    return widgets;
  }
}

class _EmptyState extends StatelessWidget {
  final bool busy;
  final VoidCallback onGenerate;
  const _EmptyState({required this.busy, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      background: AppColors.cream200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Sticker(
              emoji: '🎒',
              background: Colors.white,
              size: 48,
              tilt: -4),
          const SizedBox(height: 12),
          const Text('待产包还没生成',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'AI 会按你的孕周和情况列一份完整待产包，包含妈妈用品 / 宝宝用品 / 证件 / 入院流程 / 家中布置。可勾选 + 增量补充。',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.55,
                color: AppColors.ink700),
          ),
          const SizedBox(height: 14),
          CreamButton(
            label: busy ? '生成中…' : '让 AI 给我列一份',
            emoji: busy ? null : '✨',
            onPressed: busy ? null : onGenerate,
            full: true,
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final ChecklistView view;
  const _Progress({required this.view});
  @override
  Widget build(BuildContext context) {
    final total = view.totalItems;
    final done = view.doneItems;
    return CreamCard(
      background: AppColors.mint300,
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        const Sticker(
            emoji: '🎒',
            background: Colors.white,
            size: 56,
            tilt: -6),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('已收拾',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.mint700)),
              Text('$done / $total 件',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: AppColors.ink900, width: 1.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: total == 0 ? 0 : done / total,
                    child: Container(color: AppColors.mint500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  final String emoji;
  final int done;
  final int total;
  const _GroupHeader(
      {required this.title,
      required this.emoji,
      required this.done,
      required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Sticker(emoji: emoji, background: AppColors.peach200, size: 28),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: 14)),
      const SizedBox(width: 8),
      Text('$done / $total',
          style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: AppColors.ink600)),
    ]);
  }
}

class _ItemsCard extends StatelessWidget {
  final List<ChecklistItemRow> items;
  final ChecklistRepository repo;
  const _ItemsCard({required this.items, required this.repo});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      flat: true,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Dismissible(
              key: ValueKey(items[i].id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: AppColors.rose500,
                child: const Icon(Icons.delete_rounded,
                    color: Colors.white),
              ),
              onDismissed: (_) => repo.deleteItem(items[i].id),
              child: InkWell(
                onTap: () =>
                    repo.setItemDone(items[i].id, !items[i].checked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: items[i].checked
                            ? AppColors.mint500
                            : Colors.white,
                        border: Border.all(
                            color: AppColors.ink900, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: items[i].checked
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        items[i].title,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: items[i].checked
                              ? TextDecoration.lineThrough
                              : null,
                          color: items[i].checked
                              ? AppColors.ink400
                              : AppColors.ink900,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }
}
