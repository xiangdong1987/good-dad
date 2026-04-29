import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/llm/openai_compatible_client.dart';

/// M1 占位首页：grid 内卡片在 M2 之后由 SkillRegistry 动态生成。
/// 现在先列出 7 个未来 skill 的入口（点击后提示 "M2 起可用"），并提供
/// 「设置」入口以及 LLM 配置状态徽章。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _stub = [
    _Skill('能不能吃', Icons.restaurant_outlined, '拍一张食物照，问我'),
    _Skill('孕期食谱', Icons.menu_book_outlined, '今天给老婆做什么'),
    _Skill('本周孕期', Icons.calendar_month_outlined, '宝宝在做什么'),
    _Skill('肚肚照', Icons.photo_camera_outlined, '每月记录'),
    _Skill('产前准备', Icons.checklist_outlined, '待产包 / 入院流程'),
    _Skill('宝宝采购', Icons.shopping_bag_outlined, '分阶段不囤积'),
    _Skill('聊聊', Icons.chat_bubble_outline, '什么都能问'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llmReady = ref.watch(llmClientProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('good-dad'),
        actions: [
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _StatusBanner(ready: llmReady),
            const SizedBox(height: 16),
            const Text(
              '今天怎么帮上忙？',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: _stub
                  .map((s) => _SkillCard(
                        skill: s,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('该功能将在 M2 阶段联通 SKILL.md 后可用'),
                            ),
                          );
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skill {
  final String title;
  final IconData icon;
  final String subtitle;
  const _Skill(this.title, this.icon, this.subtitle);
}

class _SkillCard extends StatelessWidget {
  final _Skill skill;
  final VoidCallback onTap;
  const _SkillCard({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(skill.icon, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    skill.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool ready;
  const _StatusBanner({required this.ready});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ready ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: ready
                ? scheme.onPrimaryContainer
                : scheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ready
                  ? 'AI 已配置好，可以开聊'
                  : '还没配置 LLM——去「设置」填上 baseURL 与 key',
              style: TextStyle(
                color: ready
                    ? scheme.onPrimaryContainer
                    : scheme.onErrorContainer,
              ),
            ),
          ),
          if (!ready)
            TextButton(
              onPressed: () => context.go('/settings'),
              child: const Text('去设置'),
            ),
        ],
      ),
    );
  }
}
