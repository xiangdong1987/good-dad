import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/theme.dart';

/// 一个语义色进度环：value/target，居中显示数值。
/// 配色：热量 peach / 蛋白 mint / 碳水 sky / 脂肪 lemon（由 color 传入）。
class MacroRing extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final String unit;
  final Color color;
  final double size;

  const MacroRing({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    this.unit = '',
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pct = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              pct: pct.toDouble(),
              color: color,
              track: dark ? AppColors.darkSurface : AppColors.cream200,
              stroke: dark ? AppColors.darkInk : AppColors.ink900,
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.26,
                  color: dark ? AppColors.darkInk : AppColors.ink900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          target > 0 ? '$label $value/$target$unit' : '$label $value$unit',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppColors.ink600,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final Color track;
  final Color stroke;

  _RingPainter({
    required this.pct,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    const startAngle = -math.pi / 2;
    canvas.drawArc(rect, startAngle, 2 * math.pi * pct, false, progressPaint);

    // 细描边圈，呼应胖胖描边风格
    final outline = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius + 5, outline);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color;
}
