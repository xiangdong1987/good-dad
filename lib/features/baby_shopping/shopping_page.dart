import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/checklist/checklist_repository.dart';
import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 宝宝采购 · baby-shopping skill 落地页
class ShoppingPage extends ConsumerStatefulWidget {
  const ShoppingPage({super.key});
  @override
  ConsumerState<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends ConsumerState<ShoppingPage> {
  bool _busy = false;
  String? _error;
  int _activeStageIdx = 0;

  Future<void> _generate({bool augment = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(checklistRepositoryProvider);
    try {
      if (augment) {
        await repo.augment('baby-shopping');
      } else {
        await repo.generate('baby-shopping');
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
    final viewAsync = ref.watch(checklistViewProvider('baby-shopping'));

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
              Text('宝宝采购',
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              const Text('分阶段买，不囤货也不漏',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.ink600)),
              const SizedBox(height: 14),
              if (view == null)
                _EmptyState(busy: _busy, onGenerate: () => _generate()),
              if (view != null) ..._buildStaged(view, ref),
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
                  label: _busy ? '生成中…' : '让 AI 补几件',
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

  List<Widget> _buildStaged(ChecklistView view, WidgetRef ref) {
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
    final activeIdx = _activeStageIdx.clamp(0, groups.length - 1);
    final repo = ref.read(checklistRepositoryProvider);
    return [
      // stage tabs
      SizedBox(
        height: 70,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: groups.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final s = groups[i];
            final active = i == activeIdx;
            final done = s.items.where((x) => x.checked).length;
            return GestureDetector(
              onTap: () => setState(() => _activeStageIdx = i),
              child: Container(
                width: 140,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.peach500 : AppColors.cream100,
                  border:
                      Border.all(color: AppColors.ink900, width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: active ? AppShadows.popLight : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color:
                                active ? Colors.white : AppColors.ink900)),
                    const SizedBox(height: 2),
                    Text('$done / ${s.items.length}',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: active
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.ink600)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      _ItemsCard(items: groups[activeIdx].items, repo: repo),
    ];
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
              emoji: '🛒',
              background: Colors.white,
              size: 48,
              tilt: -4),
          const SizedBox(height: 12),
          const Text('采购清单还没生成',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'AI 会按月龄段（出生前 / 0–3 月 / 3–6 月 …）列出该买什么、不必着急买什么。可勾选 + 增量补充。',
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
