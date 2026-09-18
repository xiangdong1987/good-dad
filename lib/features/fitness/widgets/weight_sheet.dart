import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';
import '../fitness_calc.dart';

/// 称重弹窗。返回确认的体重（kg），取消返回 null。
Future<double?> showWeightSheet(
  BuildContext context, {
  required double? initialKg,
  required double? lastKg,
}) =>
    showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightSheet(initialKg: initialKg, lastKg: lastKg),
    );

class _WeightSheet extends StatefulWidget {
  final double? initialKg;
  final double? lastKg;
  const _WeightSheet({required this.initialKg, required this.lastKg});

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  late double _kg = widget.initialKg ?? 70.0;

  void _bump(double d) => setState(() {
        // 浮点累加会飘出 92.30000000000001，固定一位小数。
        _kg = double.parse((_kg + d).toStringAsFixed(1));
      });

  Future<void> _confirm() async {
    final err = FitnessCalc.weightInputError(_kg);
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final warn =
        FitnessCalc.weightSwingWarning(newKg: _kg, lastKg: widget.lastKg);
    if (warn != null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(warn),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text('再改改')),
            TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: const Text('确定')),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (mounted) Navigator.of(context).pop(_kg);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.cream50,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border.all(
            color: dark ? AppColors.darkInk : AppColors.ink900, width: 2),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink400,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('今天多重', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              '${FitnessCalc.weightText(_kg)} kg',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 40,
                color: ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final d in const [-0.5, -0.1, 0.1, 0.5])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () => _bump(d),
                    child: CreamPill(
                      label: d < 0
                          ? '−${d.abs().toStringAsFixed(1)}'
                          : '+${d.toStringAsFixed(1)}',
                      background:
                          d < 0 ? AppColors.cream200 : AppColors.peach200,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('空腹、同一时间称，曲线才看得出趋势',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.ink600)),
          const SizedBox(height: AppSpacing.lg),
          CreamButton(
              label: '记下来', emoji: '✅', full: true, onPressed: _confirm),
        ],
      ),
    );
  }
}
