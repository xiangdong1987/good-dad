import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/profile/profile.dart';
import '../../core/profile/profile_repository.dart';
import '../../core/storage/database.dart';
import '../../core/storage/file_store.dart';
import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';

/// 肚肚照 · Belly Photo
///
/// 「重拍」按钮：拍照/相册选 → 保存到 FileStore → 写入 BellyPhotos 表。
/// 当前周显示最近一张为预览。
class BellyPhotoPage extends ConsumerStatefulWidget {
  const BellyPhotoPage({super.key});

  static const _milestones = [
    (12, '🌱', AppColors.mint300),
    (16, '🌿', AppColors.mint300),
    (20, '🌷', AppColors.peach300),
    (24, '🌽', AppColors.lemon300),
    (28, '🍐', AppColors.cream200),
    (32, '🍉', AppColors.cream200),
    (36, '🎃', AppColors.cream200),
    (40, '🎉', AppColors.cream200),
  ];

  @override
  ConsumerState<BellyPhotoPage> createState() => _BellyPhotoPageState();
}

class _BellyPhotoPageState extends ConsumerState<BellyPhotoPage> {
  final _picker = ImagePicker();
  bool _busy = false;
  String? _latestImagePath;
  DateTime? _latestTakenAt;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    final db = ref.read(appDatabaseProvider);
    try {
      final q = db.select(db.bellyPhotos)
        ..orderBy([(t) => drift.OrderingTerm.desc(t.takenAt)])
        ..limit(1);
      final row = await q.getSingleOrNull();
      if (!mounted || row == null) return;
      setState(() {
        _latestImagePath = row.imagePath;
        _latestTakenAt = row.takenAt;
      });
    } catch (_) {}
  }

  Future<void> _capture() async {
    if (_busy) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('拍照'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final Uint8List bytes = await picked.readAsBytes();
      final path = await ref.read(fileStoreProvider).saveBellyPhoto(bytes);
      final profile =
          ref.read(profileProvider).valueOrNull ?? FamilyProfile.empty;
      final week = profile.currentWeek();
      final now = DateTime.now();

      final db = ref.read(appDatabaseProvider);
      await db.into(db.bellyPhotos).insert(
            BellyPhotosCompanion.insert(
              takenAt: now,
              imagePath: path,
              pregnancyWeek:
                  week == null ? const drift.Value.absent() : drift.Value(week),
            ),
          );
      if (!mounted) return;
      setState(() {
        _latestImagePath = path;
        _latestTakenAt = now;
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(week == null
                ? '已存到肚肚相册'
                : '已存第 $week 周 · 已写入相册')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ref.watch(profileProvider).valueOrNull ?? FamilyProfile.empty;
    final currentWeek = profile.currentWeek() ?? 0;

    int currentIdx = 0;
    for (var i = 0; i < BellyPhotoPage._milestones.length; i++) {
      if (BellyPhotoPage._milestones[i].$1 <= currentWeek) currentIdx = i;
    }
    final doneCount = BellyPhotoPage._milestones
        .where((m) => m.$1 <= currentWeek)
        .length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.ios_share_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('肚肚相册', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          const Text('一个月一张，最后会做成成长动画',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.ink600)),
          const SizedBox(height: 16),

          CreamCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    color: AppColors.peach200,
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.ink900, width: 2)),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 2)),
                  ),
                  child: _latestImagePath == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🤰',
                                  style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 8),
                              Text(
                                currentWeek > 0
                                    ? '第 $currentWeek 周 · 还没拍'
                                    : '先去设个孕周',
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: AppColors.peach700,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.lg - 2)),
                          child: Image.file(
                            File(_latestImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _latestTakenAt == null
                                ? '本月还没拍'
                                : _formatYearMonth(_latestTakenAt!),
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.ink600),
                          ),
                          Text(
                            _latestTakenAt == null
                                ? '点拍照存第一张'
                                : '已存最近一张 ✓',
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    CreamButton(
                      label: _busy ? '保存中…' : (_latestImagePath == null ? '拍照' : '重拍'),
                      emoji: _busy ? null : '📷',
                      onPressed: _busy ? null : _capture,
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text('一路走过来 · $doneCount / ${BellyPhotoPage._milestones.length} 个里程碑',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: AppColors.ink700)),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: List.generate(BellyPhotoPage._milestones.length, (i) {
              final m = BellyPhotoPage._milestones[i];
              final isCurrent = i == currentIdx;
              final isPast = m.$1 <= currentWeek;
              return Container(
                decoration: BoxDecoration(
                  color: m.$3,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isCurrent ? AppColors.peach500 : AppColors.ink900,
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                  boxShadow: isCurrent ? AppShadows.popLight : null,
                ),
                child: Stack(children: [
                  Center(
                    child: Opacity(
                      opacity: isPast ? 1 : 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(m.$2, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 2),
                          Text('${m.$1}w',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  color: AppColors.ink700)),
                        ],
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.peach500,
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: AppColors.ink900, width: 1.5),
                        ),
                        child: const Text('NOW',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                color: Colors.white)),
                      ),
                    ),
                ]),
              );
            }),
          ),
          const SizedBox(height: 16),

          const Center(
            child: Text(
              '一个月拍一张 · 最后会做成成长动画 🎞',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatYearMonth(DateTime d) =>
      '${d.year} · ${d.month} 月';
}
