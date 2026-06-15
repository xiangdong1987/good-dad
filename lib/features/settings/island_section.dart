import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../license_island/island_controller.dart';

/// 设置页里的「驾照灵动岛」开关区。
class IslandSection extends ConsumerWidget {
  const IslandSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(islandControllerProvider);
    final notifier = ref.read(islandControllerProvider.notifier);
    final busy = state.status == IslandStatus.capturing ||
        state.status == IslandStatus.thinking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            '学车刷题时点一下悬浮小岛，我帮你截屏看题：给答案、翻译、讲意大利语词汇和语法。'
            '小岛浮在别的 App 上，只截这一张，看完一眼就走。仅 Android。',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.car_crash_outlined),
          title: const Text('开启驾照灵动岛'),
          subtitle: Text(_subtitle(state)),
          value: state.enabled,
          onChanged: busy
              ? null
              : (v) async {
                  if (v) {
                    await notifier.enable();
                  } else {
                    await notifier.disable();
                  }
                },
        ),
        if (state.status == IslandStatus.error && state.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(state.error!),
            ),
          ),
      ],
    );
  }

  String _subtitle(IslandState s) {
    switch (s.status) {
      case IslandStatus.disabled:
        return '需要悬浮窗 + 录屏授权，各一次';
      case IslandStatus.active:
        return '✅ 小岛已就位，去驾考 App 点它';
      case IslandStatus.capturing:
        return '看题中…';
      case IslandStatus.thinking:
        return 'AI 正在讲解…';
      case IslandStatus.error:
        return '出了点问题，看下方提示';
    }
  }
}
