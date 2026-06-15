import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/voice/agent/agent_orchestrator.dart';
import '../../core/voice/voice_onboarding.dart';
import '../../core/voice/voice_providers.dart';
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

    final isRecording = state.status == VoiceStatus.recording;
    final amplitude =
        isRecording ? ref.watch(voiceAmplitudeProvider).valueOrNull ?? 0.0 : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) {
        ref.read(voiceOnboardingProvider.notifier).markSeen();
        ref.read(agentOrchestratorProvider.notifier).startRecording();
      },
      onLongPressEnd: (_) =>
          ref.read(agentOrchestratorProvider.notifier).stopAndSubmit(),
      onLongPressCancel: () =>
          ref.read(agentOrchestratorProvider.notifier).cancel(),
      onTap: () {
        ref.read(voiceOnboardingProvider.notifier).markSeen();
        // 录音/思考/播放中点一下 = 打断
        if (state.status != VoiceStatus.idle) {
          ref.read(agentOrchestratorProvider.notifier).cancel();
        }
      },
      child: _PulseRing(
        active: pulse,
        color: bg,
        amplitude: amplitude,
        amplitudeDriven: isRecording,
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

  /// 录音时实时音量 0-1。仅在 [amplitudeDriven] true 时使用。
  final double amplitude;

  /// true = 用 amplitude 驱动 ring 大小（录音时）；false = 走时钟脉冲（合成/播放时）。
  final bool amplitudeDriven;

  const _PulseRing({
    required this.active,
    required this.color,
    required this.child,
    this.amplitude = 0,
    this.amplitudeDriven = false,
  });

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  /// 平滑后的 amplitude，避免 mic 抖动让 ring 跳。
  double _smoothed = 0;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.active && !widget.amplitudeDriven) _ctl.repeat();
  }

  @override
  void didUpdateWidget(covariant _PulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldClock = widget.active && !widget.amplitudeDriven;
    if (shouldClock && !_ctl.isAnimating) {
      _ctl.repeat();
    } else if (!shouldClock && _ctl.isAnimating) {
      _ctl.stop();
      _ctl.value = 0;
    }
    if (widget.amplitudeDriven) {
      // 单极指数平滑：靠近峰值快回落，靠近静音慢上升。
      final target = widget.amplitude;
      _smoothed = target > _smoothed
          ? _smoothed + (target - _smoothed) * 0.6
          : _smoothed + (target - _smoothed) * 0.2;
    } else {
      _smoothed = 0;
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

    if (widget.amplitudeDriven) {
      // 录音中：ring 半径跟着音量，三层叠加显得有"呼吸感"。
      final amp = _smoothed.clamp(0.0, 1.0);
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 56 + 60 * amp,
            height: 56 + 60 * amp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.18 * amp),
            ),
          ),
          Container(
            width: 56 + 36 * amp,
            height: 56 + 36 * amp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.32 * amp),
            ),
          ),
          widget.child,
        ],
      );
    }

    // 时钟脉冲（合成/播放时）：原有行为
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
