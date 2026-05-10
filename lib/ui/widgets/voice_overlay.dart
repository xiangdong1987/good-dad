import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/voice/agent/agent_orchestrator.dart';
import '../../core/voice/voice_types.dart';
import '../theme.dart';

/// 麦克风按钮上方的状态条。会显示：
/// - 录音中：「我在听…」
/// - 思考中：「在想…」
/// - 播放中：assistant 回答（最多两行）
/// - 错误：红色提示
///
/// idle 时不渲染，把空间还给页面。
class VoiceOverlay extends ConsumerWidget {
  const VoiceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agentOrchestratorProvider);
    if (state.status == VoiceStatus.idle) {
      return const SizedBox.shrink();
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;
    final isError = state.status == VoiceStatus.error;
    final bg = isError
        ? AppColors.rose300
        : (dark ? AppColors.darkSurface : AppColors.cream100);

    final text = _textFor(state);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 88, 92),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: stroke, width: 2),
              boxShadow: AppShadows.pop(dark),
            ),
            child: Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.45,
                color: isError
                    ? AppColors.ink900
                    : (dark ? AppColors.darkInk : AppColors.ink900),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _textFor(VoiceState s) {
    switch (s.status) {
      case VoiceStatus.idle:
        return '';
      case VoiceStatus.requestingPermission:
        return '请求麦克风权限…';
      case VoiceStatus.recording:
        return '🎙 我在听，松手就发给 AI';
      case VoiceStatus.thinking:
        return '💭 在想…';
      case VoiceStatus.executing:
        return '⚙️ ${s.currentTool ?? '在执行'}…';
      case VoiceStatus.synthesizing:
        return '🔊 准备开口';
      case VoiceStatus.speaking:
        final t = s.speakText?.trim() ?? '';
        return t.isEmpty ? '🔊 ……' : '🔊 $t';
      case VoiceStatus.error:
        return '❗ ${s.errorMessage ?? '出错了'}';
    }
  }
}
