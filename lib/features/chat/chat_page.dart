import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../ui/theme.dart';
import '../../ui/widgets/cream_widgets.dart';
import 'chat_session_controller.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  Uint8List? _attachedImage;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    final image = _attachedImage;
    if (text.trim().isEmpty && image == null) return;
    _input.clear();
    setState(() => _attachedImage = null);
    await ref.read(chatSessionControllerProvider.notifier).send(
          text: text,
          imageBytes: image,
        );
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _attachedImage = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('取图失败: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatSessionControllerProvider);
    ref.listen(chatSessionControllerProvider, (_, _) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('聊聊'),
        actions: [
          IconButton(
            tooltip: '新对话',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: state.busy
                ? null
                : () => ref
                    .read(chatSessionControllerProvider.notifier)
                    .newSession(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.bubbles.isEmpty
                  ? const _EmptyHint()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      itemCount: state.bubbles.length,
                      itemBuilder: (ctx, i) =>
                          _Bubble(b: state.bubbles[i]),
                    ),
            ),
            if (_attachedImage != null) _AttachedImagePreview(
              bytes: _attachedImage!,
              onRemove: () => setState(() => _attachedImage = null),
            ),
            _Composer(
              controller: _input,
              busy: state.busy,
              onSend: _send,
              onAttach: _pickImage,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Sticker(
                emoji: '💬',
                background: AppColors.peach200,
                size: 64,
                tilt: -4),
            SizedBox(height: 14),
            Text('问点什么？',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
            SizedBox(height: 4),
            Text(
              '我会记得你告诉过我的事——\n比如老婆的预产期、过敏、口味偏好。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.ink600,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatBubble b;
  const _Bubble({required this.b});

  @override
  Widget build(BuildContext context) {
    final isUser = b.role == ChatBubbleRole.user;
    final align =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser ? AppColors.peach300 : AppColors.cream100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: AppColors.ink900, width: 2),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.popLight,
              ),
              child: Column(
                crossAxisAlignment: align,
                children: [
                  if (b.text.isEmpty && b.streaming)
                    const _TypingDots()
                  else
                    Text(
                      b.text,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.ink900,
                      ),
                    ),
                  if (b.streaming && b.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    const _TypingDots(small: true),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  final bool small;
  const _TypingDots({this.small = false});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.small ? 5.0 : 7.0;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (t + i / 3) % 1;
            final scale = 0.6 + 0.4 * (1 - (phase * 2 - 1).abs());
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: AppColors.ink600,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  const _Composer({
    required this.controller,
    required this.busy,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppColors.cream100,
          border: Border.all(color: AppColors.ink900, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.popLight,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: '附图',
              icon: const Icon(Icons.image_outlined),
              onPressed: busy ? null : onAttach,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => busy ? null : onSend(),
                decoration: const InputDecoration(
                  hintText: '问问我吧…',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                ),
              ),
            ),
            IconButton.filled(
              onPressed: busy ? null : onSend,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_upward_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.peach500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: AppColors.ink900, width: 2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
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
  const _AttachedImagePreview(
      {required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              '已附图（发送后随消息一起发）',
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
