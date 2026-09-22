import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../fitness_calc.dart';
import '../fitness_models.dart';
import '../fitness_trends.dart';
import 'trend_shell.dart';

/// 体重曲线。手绘 painter 而不是引图表库：cream 系统的 2px 描边 + 落地阴影
/// 与第三方库的 Material 视觉不是一个语言（见设计文档 §5）。
class WeightTrendCard extends StatelessWidget {
  final Map<String, double> weights;
  final Goal goal;

  static const minPoints = 3;

  const WeightTrendCard({
    super.key,
    required this.weights,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final s = FitnessTrends.weightSummary(weights);
    if (s.points < minPoints) {
      return TrendShell(
        emoji: '⚖️',
        background: AppColors.sky500,
        title: '体重',
        child: TrendEmpty(
            text: '再记 ${minPoints - s.points} 天，这里就能画出曲线了'),
      );
    }

    final dates = weights.keys.toList()..sort();
    final rate = s.weeklyRateKg;
    final favorable = rate == null
        ? null
        : FitnessCalc.isFavorableWeightChange(deltaKg: rate, goal: goal);

    return TrendShell(
      emoji: '⚖️',
      background: AppColors.sky500,
      title: '体重',
      trailing: Text(
        '${FitnessCalc.weightText(s.currentKg!)} kg',
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 18,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _LinePainter(
                values: [for (final d in dates) weights[d]!],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (rate != null)
            Text(
              '每周 ${rate >= 0 ? '+' : '−'}'
              '${rate.abs().toStringAsFixed(1)} kg'
              ' · 这段时间共 ${s.deltaKg! >= 0 ? '+' : '−'}'
              '${s.deltaKg!.abs().toStringAsFixed(1)} kg',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: favorable == null
                    ? AppColors.ink600
                    : favorable
                        ? AppColors.mint700
                        : AppColors.lemon500,
              ),
            ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  _LinePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    // 全平时给个假区间，免得除零把所有点压到同一像素。
    final span = (hi - lo).abs() < 0.01 ? 1.0 : hi - lo;
    final pad = 8.0;

    Offset at(int i) {
      final x = values.length == 1
          ? size.width / 2
          : pad + (size.width - pad * 2) * i / (values.length - 1);
      final y = size.height -
          pad -
          (size.height - pad * 2) * (values[i] - lo) / span;
      return Offset(x, y);
    }

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.peach500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 端点画成描边圆点，和 Sticker 的胖胖描边呼应。
    for (final i in [0, values.length - 1]) {
      canvas.drawCircle(at(i), 5, Paint()..color = AppColors.cream50);
      canvas.drawCircle(
        at(i),
        5,
        Paint()
          ..color = AppColors.ink900
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.values != values;
}
