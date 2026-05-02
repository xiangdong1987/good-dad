import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/memory/memory_repository.dart';
import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'italian_license_models.dart';
import 'italian_license_runner.dart';
import 'italian_license_vocab.dart';

class ItalianLicensePage extends ConsumerStatefulWidget {
  const ItalianLicensePage({super.key});

  @override
  ConsumerState<ItalianLicensePage> createState() =>
      _ItalianLicensePageState();
}

class _ItalianLicensePageState extends ConsumerState<ItalianLicensePage> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  ItalianLicenseRun? _result;
  String? _error;
  bool _running = false;

  /// 已经收藏到「单词表」的词条 name（形如 `vocab.it.foo`）。
  /// 进页面 + 每次出新结果时刷新一次；点收藏立即乐观更新。
  Set<String> _savedSlugs = const {};

  @override
  void initState() {
    super.initState();
    _refreshSavedSlugs();
  }

  Future<void> _refreshSavedSlugs() async {
    final repo = ref.read(memoryRepositoryProvider);
    final rows =
        await repo.findActiveLikeNames([ItalianLicenseVocab.namePattern]);
    if (!mounted) return;
    setState(() {
      _savedSlugs = rows.map((e) => e.name).toSet();
    });
  }

  Future<void> _saveVocab(LicenseVocab v) async {
    final entry = ItalianLicenseVocab.toEntry(v);
    if (_savedSlugs.contains(entry.name)) {
      _toast('已经在单词表里了');
      return;
    }
    setState(() => _savedSlugs = {..._savedSlugs, entry.name});
    try {
      await ref.read(memoryRepositoryProvider).upsert(entry);
      if (!mounted) return;
      _toast('已加入单词表 ✓');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _savedSlugs = _savedSlugs.where((s) => s != entry.name).toSet();
      });
      _toast('保存失败：$e');
    }
  }

  Future<void> _saveAllVocab(List<LicenseVocab> all) async {
    final repo = ref.read(memoryRepositoryProvider);
    final newOnes = all
        .where((v) => !_savedSlugs.contains(ItalianLicenseVocab.slugFor(v)))
        .toList();
    if (newOnes.isEmpty) {
      _toast('全部已经在单词表里了');
      return;
    }
    final newSlugs =
        newOnes.map(ItalianLicenseVocab.slugFor).toSet();
    setState(() => _savedSlugs = {..._savedSlugs, ...newSlugs});
    try {
      for (final v in newOnes) {
        await repo.upsert(ItalianLicenseVocab.toEntry(v));
      }
      if (!mounted) return;
      _toast('已加入 ${newOnes.length} 个新词 ✓');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _savedSlugs = _savedSlugs.difference(newSlugs);
      });
      _toast('保存失败：$e');
    }
  }

  void _toast(String msg) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    if (_running) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _previewBytes = bytes;
        _result = null;
        _error = null;
      });
      await _run(bytes);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '取图失败: $e');
    }
  }

  Future<void> _run(Uint8List bytes) async {
    final runner = ref.read(italianLicenseRunnerProvider);
    if (runner == null) {
      setState(() => _error = '请先到「设置」填好 baseURL + key + 视觉模型');
      return;
    }
    final profile =
        ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;

    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final run = await runner.run(
        rawImageBytes: bytes,
        profile: profile,
      );
      if (!mounted) return;
      setState(() {
        _result = run;
        _running = false;
      });
      _refreshSavedSlugs();
    } on ItalianLicenseError catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final hasResult = _result != null;
    final hasPreview = _previewBytes != null;

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
          Text('意大利驾照',
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          const Text('拍一张题，AI 翻译 + 讲答案 + 教语法',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 16),

          if (!hasPreview && !hasResult) const _IdlePlaceholder(),
          if (hasPreview && !hasResult)
            _PreviewCard(bytes: _previewBytes!, running: _running),
          if (hasResult)
            _ResultCard(
              run: _result!,
              previewBytes: _previewBytes,
              savedSlugs: _savedSlugs,
              onSaveVocab: _saveVocab,
              onSaveAllVocab: _saveAllVocab,
              onAgain: () {
                setState(() {
                  _result = null;
                  _previewBytes = null;
                });
              },
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
              child: Row(children: [
                const Text('⚠', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ]),
            ),
          ],

          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: CreamButton(
                label: _running ? '识别中…' : '拍题',
                emoji: _running ? null : '📷',
                onPressed:
                    _running ? null : () => _pick(ImageSource.camera),
                full: true,
              ),
            ),
            const SizedBox(width: 10),
            CreamButton(
              label: '相册',
              emoji: '🖼',
              ghost: true,
              onPressed: _running ? null : () => _pick(ImageSource.gallery),
            ),
          ]),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// 子组件
// ───────────────────────────────────────────────────────────

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder();
  @override
  Widget build(BuildContext context) {
    return CreamCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          color: AppColors.cream200,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg - 2)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🚗', style: TextStyle(fontSize: 60)),
              SizedBox(height: 8),
              Text('拍一道意大利驾照题',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.ink900)),
              SizedBox(height: 2),
              Text('Vero/Falso 或 A/B/C 都行',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.ink600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Uint8List bytes;
  final bool running;
  const _PreviewCard({required this.bytes, required this.running});

  @override
  Widget build(BuildContext context) {
    return CreamCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadius.lg - 2)),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: Image.memory(bytes, fit: BoxFit.cover),
            ),
            if (running)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text('AI 讲解中…',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ItalianLicenseRun run;
  final Uint8List? previewBytes;
  final Set<String> savedSlugs;
  final Future<void> Function(LicenseVocab) onSaveVocab;
  final Future<void> Function(List<LicenseVocab>) onSaveAllVocab;
  final VoidCallback onAgain;
  const _ResultCard({
    required this.run,
    required this.previewBytes,
    required this.savedSlugs,
    required this.onSaveVocab,
    required this.onSaveAllVocab,
    required this.onAgain,
  });

  @override
  Widget build(BuildContext context) {
    final r = run.result;
    return CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (previewBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.memory(previewBytes!,
                  height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          if (previewBytes != null) const SizedBox(height: 12),

          // 题目（意大利语）
          _SectionLabel('题目（IT）'),
          const SizedBox(height: 4),
          Text(
            r.questionIt.isEmpty ? '(未识别到题目)' : r.questionIt,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.45,
                color: AppColors.ink900),
          ),
          const SizedBox(height: 10),

          _SectionLabel('翻译'),
          const SizedBox(height: 4),
          Text(
            r.questionZh.isEmpty ? '—' : r.questionZh,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.45,
                color: AppColors.ink600),
          ),

          if (r.options.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SectionLabel('选项'),
            const SizedBox(height: 4),
            ...r.options.map((o) => _OptionRow(
                  option: o,
                  isAnswer: o.letter.toUpperCase() ==
                      r.answer.trim().toUpperCase(),
                )),
          ],

          const SizedBox(height: 12),
          _AnswerBadge(answer: r.answer, format: r.format),
          const SizedBox(height: 8),

          if (r.explanationZh.isNotEmpty)
            Text(
              r.explanationZh,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.ink900),
            ),

          if (r.vocabulary.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _SectionLabel('关键词汇 · 点 🔖 加单词表')),
                _SaveAllChip(
                  vocab: r.vocabulary,
                  savedSlugs: savedSlugs,
                  onTap: () => onSaveAllVocab(r.vocabulary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...r.vocabulary.map((v) => _VocabRow(
                  v: v,
                  saved: savedSlugs.contains(ItalianLicenseVocab.slugFor(v)),
                  onSave: () => onSaveVocab(v),
                )),
          ],

          if (r.grammarNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionLabel('语法'),
            const SizedBox(height: 4),
            ...r.grammarNotes.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $g',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.5)),
                )),
          ],

          if (r.mnemonic.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lemon500.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r.mnemonic,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.45)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: CreamButton(
              label: '再来一题',
              emoji: '↻',
              ghost: true,
              onPressed: onAgain,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 0.5,
        color: AppColors.ink400,
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final LicenseOption option;
  final bool isAnswer;
  const _OptionRow({required this.option, required this.isAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isAnswer
            ? AppColors.mint500.withValues(alpha: 0.20)
            : AppColors.cream200,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isAnswer ? AppColors.mint500 : AppColors.cream300,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAnswer ? AppColors.mint500 : AppColors.ink400,
              shape: BoxShape.circle,
            ),
            child: Text(
              option.letter,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.it,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.4)),
                if (option.zh.isNotEmpty)
                  Text(option.zh,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.ink600,
                          height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  final String answer;
  final LicenseFormat format;
  const _AnswerBadge({required this.answer, required this.format});

  @override
  Widget build(BuildContext context) {
    final a = answer.trim().toUpperCase();
    if (a.isEmpty) {
      return const Text('未给出答案',
          style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.ink400));
    }

    String label;
    Color bg;
    if (format == LicenseFormat.trueFalse) {
      if (a == 'V' || a == 'TRUE' || a == 'VERO') {
        label = 'Vero · 正确';
        bg = AppColors.mint500;
      } else if (a == 'F' || a == 'FALSE' || a == 'FALSO') {
        label = 'Falso · 错误';
        bg = AppColors.rose500;
      } else {
        label = a;
        bg = AppColors.ink400;
      }
    } else {
      label = '正确答案：$a';
      bg = AppColors.peach500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.ink900, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: Colors.white),
      ),
    );
  }
}

class _VocabRow extends StatelessWidget {
  final LicenseVocab v;
  final bool saved;
  final VoidCallback onSave;
  const _VocabRow({
    required this.v,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: saved ? null : onSave,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
            const SizedBox(width: 6),
            _BookmarkButton(saved: saved, onPressed: onSave),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onPressed;
  const _BookmarkButton({required this.saved, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: saved ? null : onPressed,
      radius: 18,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: saved ? AppColors.mint500 : AppColors.cream200,
          shape: BoxShape.circle,
          border: Border.all(
            color: saved ? AppColors.mint700 : AppColors.cream300,
            width: 1.5,
          ),
        ),
        child: Text(
          saved ? '✓' : '🔖',
          style: TextStyle(
              fontSize: saved ? 14 : 13,
              fontWeight: FontWeight.w900,
              color: saved ? Colors.white : null),
        ),
      ),
    );
  }
}

class _SaveAllChip extends StatelessWidget {
  final List<LicenseVocab> vocab;
  final Set<String> savedSlugs;
  final VoidCallback onTap;
  const _SaveAllChip({
    required this.vocab,
    required this.savedSlugs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unsavedCount = vocab
        .where((v) =>
            !savedSlugs.contains(ItalianLicenseVocab.slugFor(v)))
        .length;
    final allSaved = unsavedCount == 0;
    return InkWell(
      onTap: allSaved ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: allSaved
              ? AppColors.cream200
              : AppColors.peach500.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: allSaved ? AppColors.cream300 : AppColors.peach500,
            width: 1.2,
          ),
        ),
        child: Text(
          allSaved ? '已全部收藏' : '全部加 ($unsavedCount)',
          style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: allSaved ? AppColors.ink400 : AppColors.peach700),
        ),
      ),
    );
  }
}
