import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/skill/skill_runner.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 孕期食谱 · Recipe（接 SkillRunner('pregnancy-recipe')）
class RecipePage extends ConsumerStatefulWidget {
  const RecipePage({super.key});
  @override
  ConsumerState<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends ConsumerState<RecipePage> {
  final _ingredientsCtl = TextEditingController();
  String? _result;
  bool _running = false;
  String? _error;
  int _generatedCount = 0;

  @override
  void dispose() {
    _ingredientsCtl.dispose();
    super.dispose();
  }

  Future<void> _generate({bool another = false}) async {
    final runner = ref.read(skillRunnerProvider);
    if (runner == null) {
      setState(() => _error = '请先到「设置」配好 LLM');
      return;
    }
    final profile =
        ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;

    final ingredients = _ingredientsCtl.text.trim();
    final hint = another ? '\n（请换一道，**别和上次重复**）' : '';
    final text = ingredients.isEmpty
        ? '请按当前孕周给我推荐一两道家常菜$hint'
        : '家里有：$ingredients。$hint';

    setState(() {
      _running = true;
      _error = null;
      if (another) _result = null; // 清空让用户感觉到「真的换了」
    });

    final buf = StringBuffer();
    try {
      await runner.runStream(
        'pregnancy-recipe',
        text: text,
        profile: profile,
        onChunk: (delta) {
          buf.write(delta);
          if (mounted) setState(() => _result = buf.toString());
        },
      );
      if (!mounted) return;
      setState(() {
        _running = false;
        _generatedCount += 1;
      });
    } on SkillRunError catch (e) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _running = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty;
    final week = profile.currentWeek();
    final hasResult = _result != null && _result!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('今晚吃啥？',
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text(
            week == null ? '设个孕周再来' : '孕 $week 周 · 营养自动按孕周适配',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.ink600),
          ),
          const SizedBox(height: 16),

          CreamCard(
            flat: true,
            background: AppColors.cream100,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('家里有什么？（可空）',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _ingredientsCtl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: '比如：鸡蛋、菠菜、虾、番茄、土豆',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (!hasResult && !_running)
            CreamCard(
              padding: EdgeInsets.zero,
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  color: AppColors.lemon300,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg - 2),
                      bottom: Radius.circular(AppRadius.lg - 2)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🍲', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 8),
                      Text('点下面按钮 让 AI 给点建议',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.ink700)),
                    ],
                  ),
                ),
              ),
            ),

          if (_running && !hasResult)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (hasResult)
            CreamCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: MarkdownBody(
                data: _result!,
                styleSheet: MarkdownStyleSheet(
                  h2: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.ink900),
                  p: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.ink900),
                  strong: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      color: AppColors.peach700),
                  blockquote: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.ink600),
                  listBullet: const TextStyle(
                      fontFamily: 'Nunito', color: AppColors.ink900),
                ),
              ),
            ),

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

          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: CreamButton(
                label: _running
                    ? '生成中…'
                    : (hasResult ? '换一道' : '让 AI 推荐'),
                emoji: _running ? null : (hasResult ? '🔁' : '✨'),
                onPressed: _running
                    ? null
                    : () => _generate(another: hasResult),
                full: true,
              ),
            ),
          ]),
          if (_generatedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '已生成 $_generatedCount 道 · 点上面输入框换食材试试',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.ink400),
              ),
            ),
        ],
      ),
    );
  }
}
