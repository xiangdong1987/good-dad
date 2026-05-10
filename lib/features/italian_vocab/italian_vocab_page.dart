import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/memory/memory.dart';
import '../../core/memory/memory_repository.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import '../italian_license/italian_license_vocab.dart';
import 'italian_vocab_models.dart';
import 'italian_vocab_runner.dart';

/// 实时监听 `vocab.it.*` 下的所有已收藏单词。
final savedItalianVocabProvider =
    StreamProvider.autoDispose<List<SavedVocab>>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  // memory_repository 没暴露按名称模糊的 stream；这里直接 watch 全表 + filter。
  return repo
      .watchAll(status: MemoryStatus.active, type: MemoryType.reference)
      .map((rows) => rows
          .where((e) => e.name.startsWith(ItalianLicenseVocab.namePrefix))
          .map(SavedVocab.fromMemory)
          .toList());
});

class ItalianVocabPage extends ConsumerStatefulWidget {
  const ItalianVocabPage({super.key});

  @override
  ConsumerState<ItalianVocabPage> createState() => _ItalianVocabPageState();
}

class _ItalianVocabPageState extends ConsumerState<ItalianVocabPage> {
  StudySession? _session;
  String? _error;
  bool _running = false;

  Future<void> _startStudy(List<SavedVocab> words) async {
    final runner = ref.read(italianVocabRunnerProvider);
    if (runner == null) {
      setState(() => _error = '请先到「设置」填好 baseURL + key + 模型');
      return;
    }
    final profile =
        ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;
    final shuffled = List<SavedVocab>.from(words)..shuffle();

    setState(() {
      _running = true;
      _error = null;
      _session = null;
    });
    try {
      final s = await runner.run(words: shuffled, profile: profile);
      if (!mounted) return;
      if (s.cards.isEmpty) {
        setState(() {
          _running = false;
          _error = 'AI 没返回有效卡片，可能输出格式异常。再试一次？';
        });
        return;
      }
      setState(() {
        _session = s;
        _running = false;
      });
    } on ItalianVocabError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '出错了: $e';
        _running = false;
      });
    }
  }

  Future<void> _delete(SavedVocab v) async {
    if (v.memoryId < 0) return;
    await ref.read(memoryRepositoryProvider).delete(v.memoryId);
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(savedItalianVocabProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('我的意大利单词'),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('读取失败: $e')),
        data: (words) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _Header(count: words.length),
              const SizedBox(height: 12),

              if (words.isEmpty)
                const _EmptyState()
              else
                _StudyCta(
                  count: words.length,
                  running: _running,
                  hasSession: _session != null,
                  onStart: () => _startStudy(words),
                ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(_error!),
              ],

              if (_session != null) ...[
                const SizedBox(height: 16),
                ..._session!.cards.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _StudyCardWidget(card: c),
                    )),
              ],

              if (words.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text('已收藏单词',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.ink600)),
                const SizedBox(height: 8),
                ...words.map((v) => _SavedVocabRow(
                      v: v,
                      onDelete: () => _delete(v),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的意大利单词',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 4),
        Text(
          count == 0 ? '还没收藏单词' : '已收藏 $count 个 · 开始 AI 测验',
          style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.ink600),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return CreamCard(
      child: Column(
        children: const [
          Text('📚', style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Text('单词表是空的',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.ink900)),
          SizedBox(height: 4),
          Text('回意大利驾照页拍道题，把里面的词加进来',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.ink600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StudyCta extends StatelessWidget {
  final int count;
  final bool running;
  final bool hasSession;
  final VoidCallback onStart;
  const _StudyCta({
    required this.count,
    required this.running,
    required this.hasSession,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final pickCount = count > 8 ? 8 : count;
    final label = running
        ? 'AI 出题中…'
        : hasSession
            ? '换一组 (随机 $pickCount)'
            : '开始学习 (随机 $pickCount)';
    return CreamButton(
      label: label,
      emoji: running ? null : '🎯',
      onPressed: running ? null : onStart,
      full: true,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner(this.msg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rose300,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.ink900, width: 1.5),
      ),
      child: Row(children: [
        const Text('⚠', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(msg,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.5)),
        ),
      ]),
    );
  }
}

class _SavedVocabRow extends StatelessWidget {
  final SavedVocab v;
  final VoidCallback onDelete;
  const _SavedVocabRow({required this.v, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.cream100,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cream300, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(v.it,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.peach700)),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (v.zh.isNotEmpty)
                  Text(v.zh,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.ink900,
                          height: 1.35)),
                if (v.note.isNotEmpty)
                  Text(v.note,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: AppColors.ink400,
                          height: 1.4)),
              ],
            ),
          ),
          IconButton(
            tooltip: '从单词表移除',
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.ink400),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('从单词表移除？'),
        content: Text('「${v.it}」将从记忆里删除，不影响驾照题历史。'),
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
    if (ok == true) onDelete();
  }
}

class _StudyCardWidget extends StatefulWidget {
  final StudyCard card;
  const _StudyCardWidget({required this.card});

  @override
  State<_StudyCardWidget> createState() => _StudyCardWidgetState();
}

class _StudyCardWidgetState extends State<_StudyCardWidget> {
  late List<String> _shuffled;
  String? _picked;

  @override
  void initState() {
    super.initState();
    _shuffled = List<String>.from(widget.card.quizOptions)..shuffle();
  }

  bool get _answered => _picked != null;

  bool _isCorrect(String opt) =>
      opt.trim().toLowerCase() ==
      widget.card.quizAnswer.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 词头
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(c.wordIt,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.peach700,
                        height: 1.2)),
              ),
              const SizedBox(width: 8),
              if (c.wordZh.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(c.wordZh,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.ink900)),
                ),
            ],
          ),
          if (c.exampleIt.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cream100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.cream300, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.exampleIt,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.4)),
                  if (c.exampleZh.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(c.exampleZh,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: AppColors.ink600,
                              height: 1.4)),
                    ),
                ],
              ),
            ),
          ],
          if (c.quizQuestionIt.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('填空',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: AppColors.ink400)),
            const SizedBox(height: 4),
            Text(c.quizQuestionIt,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.4)),
            const SizedBox(height: 8),
            ..._shuffled.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _OptionButton(
                    text: opt,
                    state: _stateFor(opt),
                    onTap: _answered
                        ? null
                        : () => setState(() => _picked = opt),
                  ),
                )),
          ],
          if (_answered && c.tip.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lemon500.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(c.tip,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  _OptionState _stateFor(String opt) {
    if (!_answered) return _OptionState.idle;
    if (_isCorrect(opt)) return _OptionState.correct;
    if (opt == _picked) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;
  const _OptionButton({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color fg = AppColors.ink900;
    String? badge;

    switch (state) {
      case _OptionState.idle:
        bg = AppColors.cream200;
        border = AppColors.cream300;
        break;
      case _OptionState.correct:
        bg = AppColors.mint500.withValues(alpha: 0.25);
        border = AppColors.mint500;
        badge = '✓';
        break;
      case _OptionState.wrong:
        bg = AppColors.rose500.withValues(alpha: 0.22);
        border = AppColors.rose500;
        badge = '×';
        break;
      case _OptionState.dimmed:
        bg = AppColors.cream100;
        border = AppColors.cream200;
        fg = AppColors.ink400;
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(text,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: fg)),
              ),
              if (badge != null)
                Text(badge,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: border)),
            ],
          ),
        ),
      ),
    );
  }
}
