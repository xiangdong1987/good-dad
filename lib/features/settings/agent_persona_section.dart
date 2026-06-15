import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agent_config/agent_loader.dart';
import '../../core/agent_config/agent_profile_repository.dart';

/// 设置页里的「Agent 个性」段：让用户用 markdown 写个人偏好，
/// 拼到 system prompt 的第二层。
///
/// 类比 Claude Code 的 `~/.claude/CLAUDE.md`：放在 app 文档目录下的 profile.md，
/// 启动时读，编辑保存后立即生效（下一次对话用新 prompt）。
class AgentPersonaSection extends ConsumerStatefulWidget {
  const AgentPersonaSection({super.key});

  @override
  ConsumerState<AgentPersonaSection> createState() =>
      _AgentPersonaSectionState();
}

class _AgentPersonaSectionState extends ConsumerState<AgentPersonaSection> {
  final _ctl = TextEditingController();
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(agentProfileProvider.notifier).save(_ctl.text);
      // 让下一次对话重读 AGENT.md（虽然 AGENT.md 没改，invalidate 是为了将来支持热改）
      ref.read(agentLoaderProvider).invalidate();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存 · 下一句对话生效')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空个性'),
        content: const Text('确定要清空个性配置吗？助手会回到默认行为。'),
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
    await ref.read(agentProfileProvider.notifier).clear();
    _ctl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(agentProfileProvider);
    return profileAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('读取个性失败: $e'),
      data: (text) {
        if (!_hydrated) {
          _ctl.text = text;
          _hydrated = true;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '用 markdown 写你的偏好（最多约 2000 字），会拼到助手的 system prompt 里。例：',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '''# 我

- 我夜班，回答尽量短
- 妈妈对花生过敏，建议食物时主动避开
- 不要主动推荐买东西的链接''',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctl,
              maxLines: 10,
              minLines: 4,
              decoration: const InputDecoration(
                hintText: '# 我\n\n- ……',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _saving ? null : _clear,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('清空'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
