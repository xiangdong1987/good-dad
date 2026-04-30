import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/skill/skill.dart';
import '../../core/skill/skill_loader.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

const _builtinSkillNames = [
  'chat',
  'food-safety',
  'pregnancy-recipe',
  'pregnancy-week',
  'belly-photo',
  'prenatal-prep',
  'baby-shopping',
];

final _allSkillsProvider = FutureProvider<List<Skill>>((ref) async {
  final loader = ref.watch(skillLoaderProvider);
  final out = <Skill>[];
  for (final n in _builtinSkillNames) {
    try {
      out.add(await loader.load(n));
    } catch (_) {
      // 忽略缺失
    }
  }
  return out;
});

class SkillListPage extends ConsumerWidget {
  const SkillListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(_allSkillsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('技能列表'),
      ),
      body: skillsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (skills) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: skills.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) return const _Header();
            return _SkillCard(skill: skills[i - 1]);
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CreamCard(
        flat: true,
        background: AppColors.cream200,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('💡', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '每个技能都是一份 SKILL.md（assets/skills/<name>/SKILL.md）。'
                '想改 prompt 直接编辑那份 md，重启 App 生效；'
                '本地用 dart run tool/skill_test.dart 可以快速验证。',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.55,
                    color: AppColors.ink600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;
  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CreamCard(
        flat: true,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(skill.title,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 15)),
              const SizedBox(width: 8),
              if (skill.needsVision)
                const StatusTag(kind: SafetyTag.info, label: '👁 vision'),
            ]),
            const SizedBox(height: 4),
            Text(
              skill.name,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppColors.ink600),
            ),
            const SizedBox(height: 6),
            Text(
              skill.description,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.ink700),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _MiniPill(text: 'output: ${skill.outputFormat}'),
              _MiniPill(text: 'temp: ${skill.temperature.toStringAsFixed(1)}'),
              _MiniPill(text: 'assets/skills/${skill.name}/SKILL.md'),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  const _MiniPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cream200,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink900, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: AppColors.ink700),
      ),
    );
  }
}
