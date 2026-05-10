import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/llm_log/llm_log_entry.dart';
import '../../core/llm_log/llm_log_repository.dart';
import '../../ui/theme.dart';

/// LLM 调用调试日志页：列表 + 清除 + 点击展开看完整请求/响应。
class LlmLogPage extends ConsumerWidget {
  const LlmLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(llmLogStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM 调试日志'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: '清空',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context, ref),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('读取失败: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '还没有 LLM 调用记录\n按麦克风、点 📝 输入 或 试听 后回来看看',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final sorted = entries.reversed.toList();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) => _LogTile(entry: sorted[i]),
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('清空后无法恢复。确定吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('清空')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(llmLogRepositoryProvider).clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清空')),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LlmLogEntry entry;
  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm:ss').format(entry.time);
    final channelColor = _channelColor(entry.channel);
    return InkWell(
      onTap: () => _showDetail(context, entry),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态点
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: BoxDecoration(
                color: entry.ok
                    ? channelColor
                    : Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶行：channel + 状态/时延 + 时间
                  Row(
                    children: [
                      Text(
                        entry.channel,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: channelColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.durationMs}ms',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink400,
                        ),
                      ),
                      if (entry.statusCode != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'HTTP ${entry.statusCode}',
                          style: TextStyle(
                            fontSize: 11,
                            color: entry.ok
                                ? AppColors.ink400
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 请求摘要
                  Text(
                    '↑ ${entry.requestSummary.isEmpty ? "<empty>" : entry.requestSummary}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.ink900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 响应摘要
                  Text(
                    '↓ ${entry.responseSummary}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      height: 1.45,
                      color: entry.ok
                          ? AppColors.ink600
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _channelColor(String c) {
    return switch (c) {
      'mimo-agent' => AppColors.peach500,
      'mimo-tts' => AppColors.lemon500,
      'openai' => AppColors.sky500,
      _ => AppColors.ink400,
    };
  }

  void _showDetail(BuildContext context, LlmLogEntry e) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollCtl) => _LogDetailSheet(
          entry: e,
          scrollController: scrollCtl,
        ),
      ),
    );
  }
}

class _LogDetailSheet extends StatelessWidget {
  final LlmLogEntry entry;
  final ScrollController scrollController;
  const _LogDetailSheet({required this.entry, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动手柄
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.ink400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.channel} · ${entry.model}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('MM-dd HH:mm:ss').format(entry.time)}'
                        ' · ${entry.durationMs}ms'
                        ' · ${entry.ok ? "OK" : "ERROR"}'
                        '${entry.statusCode == null ? "" : " · HTTP ${entry.statusCode}"}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _section(context, '请求摘要', entry.requestSummary),
                _section(context, '响应摘要', entry.responseSummary),
                if (entry.rawRequest != null)
                  _section(context, '完整请求', entry.rawRequest!,
                      mono: true),
                if (entry.rawResponse != null)
                  _section(context, '完整响应', entry.rawResponse!,
                      mono: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String label, String body,
      {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: AppColors.ink400,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${body.length} 字符',
                style: const TextStyle(
                    fontSize: 10, color: AppColors.ink400),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _copy(context, body),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 12, color: AppColors.ink600),
                      const SizedBox(width: 2),
                      Text('复制',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.ink600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              body,
              style: TextStyle(
                fontFamily: mono ? 'monospace' : null,
                fontSize: mono ? 10.5 : 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
