import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/voice/agent/agent_orchestrator.dart';
import '../theme.dart';

/// 文字 + 图片 输入面板，作为 BottomSheet 弹出。
///
/// 用法：
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   useSafeArea: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const ComposerSheet(),
/// );
/// ```
class ComposerSheet extends ConsumerStatefulWidget {
  const ComposerSheet({super.key});

  @override
  ConsumerState<ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends ConsumerState<ComposerSheet> {
  final _picker = ImagePicker();
  final _textCtl = TextEditingController();
  final _focus = FocusNode();
  Uint8List? _attached;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _textCtl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _attached = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('取图失败：$e')),
      );
    }
  }

  Future<void> _send() async {
    final text = _textCtl.text.trim();
    if (text.isEmpty && _attached == null) return;
    if (_busy) return;
    setState(() => _busy = true);

    final navigator = Navigator.of(context);
    final orchestrator = ref.read(agentOrchestratorProvider.notifier);

    // sheet 关掉再异步跑——状态 overlay 会接管显示。
    navigator.pop();
    unawaited(orchestrator.submitText(
      text: text,
      imageBytes: _attached,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.cream100,
          border: Border.all(color: stroke, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.pop(dark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attached != null) ...[
              _AttachedImagePreview(
                bytes: _attached!,
                onRemove: () => setState(() => _attached = null),
              ),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                IconButton(
                  tooltip: '附图',
                  icon: const Icon(Icons.image_outlined),
                  onPressed: _busy ? null : _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _textCtl,
                    focusNode: _focus,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _busy ? null : _send(),
                    decoration: const InputDecoration(
                      hintText: '问问 / 加日程 / 拍菠萝 …',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 4, vertical: 10),
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: _busy ? null : _send,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_upward_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.peach500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: stroke, width: 2),
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachedImagePreview extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;
  const _AttachedImagePreview({
    required this.bytes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '已附图 · 发送时会用视觉模型一起判断',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.ink600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

