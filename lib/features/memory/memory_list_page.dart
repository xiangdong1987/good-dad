import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/memory/memory.dart';
import '../../core/memory/memory_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

class MemoryListPage extends ConsumerStatefulWidget {
  const MemoryListPage({super.key});

  @override
  ConsumerState<MemoryListPage> createState() => _MemoryListPageState();
}

class _MemoryListPageState extends ConsumerState<MemoryListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        ref.watch(pendingMemoryCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('记忆管理'),
        actions: [
          IconButton(
            tooltip: '手动添加',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openEditor(context),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: '待确认${pendingCount > 0 ? ' · $pendingCount' : ''}'),
            const Tab(text: '👨‍👩‍👧 家人'),
            const Tab(text: '🪶 偏好'),
            const Tab(text: '📅 阶段'),
            const Tab(text: '🔗 资源'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _MemoryList(status: MemoryStatus.pending),
          _MemoryList(status: MemoryStatus.active, type: MemoryType.user),
          _MemoryList(status: MemoryStatus.active, type: MemoryType.feedback),
          _MemoryList(status: MemoryStatus.active, type: MemoryType.project),
          _MemoryList(status: MemoryStatus.active, type: MemoryType.reference),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, [MemoryEntry? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _MemoryEditor(initial: existing),
      ),
    );
  }
}

class _MemoryList extends ConsumerWidget {
  final MemoryStatus status;
  final MemoryType? type;
  const _MemoryList({required this.status, this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(memoryRepositoryProvider);
    return StreamBuilder<List<MemoryEntry>>(
      stream: repo.watchAll(type: type, status: status),
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                status == MemoryStatus.pending
                    ? '没有待确认的记忆。\n聊天时我会自动捕捉长期事实。'
                    : '空。手动加几条试试 👆',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600,
                    height: 1.55),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          itemBuilder: (_, i) =>
              _MemoryCard(entry: items[i], pending: status == MemoryStatus.pending),
        );
      },
    );
  }
}

class _MemoryCard extends ConsumerWidget {
  final MemoryEntry entry;
  final bool pending;
  const _MemoryCard({required this.entry, required this.pending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(memoryRepositoryProvider);
    final fmt = DateFormat('M月d日 HH:mm');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CreamCard(
        flat: !pending,
        background: pending ? AppColors.lemon300 : null,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(entry.type.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.description.isEmpty
                      ? entry.name
                      : entry.description,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 14),
                ),
              ),
              Text(
                entry.updatedAt == null ? '' : fmt.format(entry.updatedAt!),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: AppColors.ink400),
              ),
            ]),
            const SizedBox(height: 4),
            Text(
              entry.name,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppColors.ink600),
            ),
            const SizedBox(height: 6),
            Text(
              entry.body,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.ink700),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (pending) ...[
                  TextButton.icon(
                    onPressed: () => repo.delete(entry.id!),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('忽略'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink600),
                  ),
                  const SizedBox(width: 4),
                  FilledButton.icon(
                    onPressed: () =>
                        repo.setStatus(entry.id!, MemoryStatus.active),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('收藏'),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, repo, entry),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.peach700),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, MemoryRepository repo, MemoryEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条记忆？'),
        content: Text(e.description.isEmpty ? e.name : e.description),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok == true) repo.delete(e.id!);
  }
}

class _MemoryEditor extends ConsumerStatefulWidget {
  final MemoryEntry? initial;
  const _MemoryEditor({this.initial});
  @override
  ConsumerState<_MemoryEditor> createState() => _MemoryEditorState();
}

class _MemoryEditorState extends ConsumerState<_MemoryEditor> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _body;
  MemoryType _type = MemoryType.user;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _desc = TextEditingController(text: widget.initial?.description ?? '');
    _body = TextEditingController(text: widget.initial?.body ?? '');
    _type = widget.initial?.type ?? MemoryType.user;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final body = _body.text.trim();
    if (name.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('name 和 body 都得填')),
      );
      return;
    }
    final repo = ref.read(memoryRepositoryProvider);
    await repo.upsert(MemoryEntry(
      id: widget.initial?.id,
      type: _type,
      name: name,
      description: _desc.text.trim(),
      body: body,
      status: MemoryStatus.active,
      createdAt: widget.initial?.createdAt,
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
          Text(widget.initial == null ? '加一条记忆' : '编辑',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<MemoryType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: '类型'),
            items: MemoryType.values
                .map((t) => DropdownMenuItem(
                    value: t, child: Text('${t.emoji} ${t.label}')))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? MemoryType.user),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: 'name (snake_case)',
                hintText: '例 partner.due_date'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(
                labelText: '一句话描述（可空）'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _body,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '内容'),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: CreamButton(
                  label: widget.initial == null ? '加进来' : '保存',
                  emoji: '💾',
                  onPressed: _save,
                  full: true),
            ),
          ]),
        ],
      ),
    );
  }
}
