import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../fitness_trends.dart';
import 'trend_shell.dart';

/// 每日摄入 vs 目标。柱状而非折线：每天是离散的一次结果，
/// 超没超一眼看出来比看斜率有用。
class IntakeTrendCard extends StatelessWidget {
  final Map<String, int> intake;
  final Map<String, int> targets;

  static const minDays = 3;

  const IntakeTrendCard({
    super.key,
    required this.intake,
    required this.targets,
  });

  @override
  Widget build(BuildContext context) {
    final list =
        FitnessTrends.intakeVsTarget(intake: intake, targets: targets);
    if (list.length < minDays) {
      return TrendShell(
        emoji: '🍽',
        background: AppColors.peach500,
        title: '热量摄入',
        child: TrendEmpty(
            text: '再记 ${minDays - list.length} 天，这里就能比出趋势了'),
      );
    }

    final onTarget = FitnessTrends.onTargetDays(list);
    return TrendShell(
      emoji: '🍽',
      background: AppColors.peach500,
      title: '热量摄入',
      trailing: Text(
        '$onTarget/${list.length} 天达标',
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 13,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: CustomPaint(painter: _BarPainter(list: list)),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<IntakeCompare> list;
  _BarPainter({required this.list});

  @override
  void paint(Canvas canvas, Size size) {
    if (list.isEmpty) return;
    final maxVal = [
      ...list.map((e) => e.kcal),
      ...list.map((e) => e.target ?? 0),
    ].reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return;

    const pad = 8.0;
    final usable = size.height - pad * 2;
    final slot = (size.width - pad * 2) / list.length;
    final barW = (slot * 0.6).clamp(3.0, 28.0);

    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      final h = usable * e.kcal / maxVal;
      final x = pad + slot * i + (slot - barW) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - pad - h, barW, h),
        const Radius.circular(4),
      );
      // 超标走 lemon（提醒）而不是 rose（警示）：多吃两百大卡不是错误。
      canvas.drawRRect(
        rect,
        Paint()
          ..color = e.onTarget == false
              ? AppColors.lemon500
              : AppColors.mint500,
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = AppColors.ink900
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // 目标线取区间内目标的中位数，虚线画在柱子上方。
    final targets = list.map((e) => e.target).whereType<int>().toList()..sort();
    if (targets.isNotEmpty) {
      final mid = targets[targets.length ~/ 2];
      final y = size.height - pad - usable * mid / maxVal;
      final paint = Paint()
        ..color = AppColors.ink400
        ..strokeWidth = 2;
      for (var x = pad; x < size.width - pad; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 5, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.list != list;
}
