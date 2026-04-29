import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'food_safety_models.dart';
import 'food_safety_runner.dart';

/// 最近 10 条食物识别记录。
final _foodHistoryProvider =
    StreamProvider.autoDispose<List<SkillRunRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.skillRuns)
    ..where((t) => t.skillName.equals('food-safety'))
    ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
    ..limit(10);
  return query.watch();
});

class FoodSafetyPage extends ConsumerStatefulWidget {
  const FoodSafetyPage({super.key});

  @override
  ConsumerState<FoodSafetyPage> createState() => _FoodSafetyPageState();
}

class _FoodSafetyPageState extends ConsumerState<FoodSafetyPage> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  FoodSafetyRun? _result;
  String? _error;
  bool _running = false;

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
    final runner = ref.read(foodSafetyRunnerProvider);
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
    } on FoodSafetyError catch (e) {
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
    final history = ref.watch(_foodHistoryProvider);
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
          Text('能不能吃？',
              style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('拍一张，孕期友好度立等可取',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 16),

          if (!hasPreview && !hasResult) _IdlePlaceholder(),
          if (hasPreview && !hasResult)
            _PreviewCard(bytes: _previewBytes!, running: _running),
          if (hasResult)
            _VerdictCard(
              run: _result!,
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
                label: _running ? '识别中…' : '拍照',
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
              onPressed:
                  _running ? null : () => _pick(ImageSource.gallery),
            ),
          ]),
          const SizedBox(height: 24),

          const Text('最近问过 ↓',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 8),
          history.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('历史读取失败: $e',
                style: const TextStyle(fontSize: 11)),
            data: (rows) {
              if (rows.isEmpty) {
                return const Text('还没有记录。拍第一张试试 👆',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.ink400));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rows
                    .map((r) => _HistoryPill.fromRow(r))
                    .toList(),
              );
            },
          ),
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
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg - 2),
              bottom: Radius.circular(AppRadius.lg - 2)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🍱', style: TextStyle(fontSize: 60)),
              SizedBox(height: 8),
              Text('随手拍一张食物',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.ink700)),
              SizedBox(height: 2),
              Text('我会告诉你孕期能不能吃',
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
        borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.lg - 2)),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text('AI 识别中…',
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

class _VerdictCard extends StatelessWidget {
  final FoodSafetyRun run;
  final VoidCallback onAgain;
  const _VerdictCard({required this.run, required this.onAgain});

  @override
  Widget build(BuildContext context) {
    final r = run.result;
    final (bgColor, tag, emoji) = switch (r.verdict) {
      FoodVerdict.safe => (AppColors.mint300, SafetyTag.ok, '✅'),
      FoodVerdict.caution => (AppColors.lemon300, SafetyTag.caution, '⚠'),
      FoodVerdict.avoid => (AppColors.rose300, SafetyTag.avoid, '❌'),
      FoodVerdict.unknown => (AppColors.cream200, SafetyTag.info, '❓'),
    };
    final tagLabel = switch (r.verdict) {
      FoodVerdict.safe => '可以吃',
      FoodVerdict.caution => '注意',
      FoodVerdict.avoid => '避免',
      FoodVerdict.unknown => '看不太准',
    };

    return CreamCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: bgColor,
              border: const Border(
                  bottom: BorderSide(color: AppColors.ink900, width: 2)),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg - 2)),
            ),
            child: Stack(children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg - 2)),
                  child: Image.file(
                    File(run.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Sticker(
                    emoji: emoji, background: Colors.white, size: 44),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  StatusTag(kind: tag, label: tagLabel),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      r.name.isEmpty ? '食物' : r.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.ink600),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(
                  r.reason.isEmpty ? '没拿到具体原因' : r.reason,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      height: 1.4),
                ),
                if (r.dos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _BulletList(title: '怎么吃', emoji: '👍', items: r.dos),
                ],
                if (r.donts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _BulletList(title: '小心', emoji: '⚠', items: r.donts),
                ],
                if (r.alternatives.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _BulletList(
                      title: '想吃可以替换为', emoji: '🔁', items: r.alternatives),
                ],
                if (r.verdict == FoodVerdict.unknown) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '模型这次没给出标准 JSON。原文：',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.ink600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.rawText,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.ink700),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
                const Text(
                  '这是参考，特殊情况问产检医生 🩺',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.ink600),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: CreamButton(
                      label: '再来一张',
                      emoji: '📷',
                      onPressed: onAgain,
                      full: true,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final String title;
  final String emoji;
  final List<String> items;
  const _BulletList(
      {required this.title, required this.emoji, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.ink700)),
        ]),
        const SizedBox(height: 4),
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text('· $s',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.ink700)),
          ),
      ],
    );
  }
}

class _HistoryPill extends StatelessWidget {
  final String name;
  final FoodVerdict verdict;
  const _HistoryPill({required this.name, required this.verdict});

  factory _HistoryPill.fromRow(SkillRunRow row) {
    String name = '';
    FoodVerdict verdict = FoodVerdict.unknown;
    final out = row.outputJson;
    if (out != null && out.isNotEmpty) {
      try {
        final m = jsonDecode(out) as Map<String, dynamic>;
        final parsed = m['parsed'] as Map<String, dynamic>?;
        if (parsed != null) {
          name = (parsed['name'] ?? '').toString();
          verdict = FoodVerdict.parse(parsed['verdict']?.toString());
        }
      } catch (_) {}
    }
    return _HistoryPill(
      name: name.isEmpty ? '一张图' : name,
      verdict: verdict,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (bg, emoji) = switch (verdict) {
      FoodVerdict.safe => (AppColors.mint300, '✅'),
      FoodVerdict.caution => (AppColors.lemon300, '⚠'),
      FoodVerdict.avoid => (AppColors.rose300, '❌'),
      FoodVerdict.unknown => (AppColors.cream200, '❓'),
    };
    return CreamPill(label: name, leadingEmoji: emoji, background: bg);
  }
}
