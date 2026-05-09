import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/voice/agent/agent_orchestrator.dart';
import '../../core/voice/voice_types.dart';
import '../theme.dart';

/// 全局浮动麦克风按钮。在 [GoodDadApp] 的 router builder 里叠到所有路由之上。
///
/// 交互：
/// - 长按开始录音；松手提交。
/// - 录音中点一下 = 取消（双保险）。
/// - 思考/合成/播放期间点一下 = 打断回到 idle。
class VoiceButton extends ConsumerWidget {
  const VoiceButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agentOrchestratorProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;

    final (bg, icon, pulse) = _stylesFor(state.status);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) =>
          ref.read(agentOrchestratorProvider.notifier).startRecording(),
      onLongPressEnd: (_) =>
          ref.read(agentOrchestratorProvider.notifier).stopAndSubmit(),
      onLongPressCancel: () =>
          ref.read(agentOrchestratorProvider.notifier).cancel(),
      onTap: () {
        // 录音/思考/播放中点一下 = 打断
        if (state.status != VoiceStatus.idle) {
          ref.read(agentOrchestratorProvider.notifier).cancel();
        }
      },
      child: _PulseRing(
        active: pulse,
        color: bg,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: stroke, width: 2),
            boxShadow: AppShadows.pop(dark),
          ),
          alignment: Alignment.center,
          child: _IconForStatus(status: state.status, icon: icon),
        ),
      ),
    );
  }

  (Color, IconData, bool) _stylesFor(VoiceStatus s) {
    switch (s) {
      case VoiceStatus.idle:
        return (AppColors.peach500, Icons.mic_rounded, false);
      case VoiceStatus.requestingPermission:
        return (AppColors.lemon500, Icons.lock_outline, false);
      case VoiceStatus.recording:
        return (AppColors.mint500, Icons.mic_rounded, true);
      case VoiceStatus.thinking:
      case VoiceStatus.executing:
        return (AppColors.sky500, Icons.psychology_alt_rounded, false);
      case VoiceStatus.synthesizing:
      case VoiceStatus.speaking:
        return (AppColors.lemon500, Icons.graphic_eq_rounded, true);
      case VoiceStatus.error:
        return (AppColors.rose500, Icons.error_outline, false);
    }
  }
}

class _IconForStatus extends StatelessWidget {
  final VoiceStatus status;
  final IconData icon;

  const _IconForStatus({required this.status, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (status == VoiceStatus.thinking ||
        status == VoiceStatus.executing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(AppColors.ink900),
        ),
      );
    }
    return Icon(icon, color: AppColors.ink900, size: 26);
  }
}

class _PulseRing extends StatefulWidget {
  final bool active;
  final Color color;
  final Widget child;

  const _PulseRing({
    required this.active,
    required this.color,
    required this.child,
  });

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.active) _ctl.repeat();
  }

  @override
  void didUpdateWidget(covariant _PulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctl.isAnimating) {
      _ctl.repeat();
    } else if (!widget.active && _ctl.isAnimating) {
      _ctl.stop();
      _ctl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _ctl,
      child: widget.child,
      builder: (context, child) {
        final t = _ctl.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56 + 28 * t,
              height: 56 + 28 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.4 * (1 - t)),
              ),
            ),
            child!,
          ],
        );
      },
    );
  }
}
