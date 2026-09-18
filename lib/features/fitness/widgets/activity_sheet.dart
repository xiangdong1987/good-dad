import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';
import '../fitness_met.dart';

/// 记一笔日常活动：选项目 + 填分钟，现场按 MET 估净消耗。
///
/// 返回 (项目, 分钟)，取消则返回 null。
Future<(ActivityKind, int)?> showActivitySheet(
  BuildContext context, {
  required double weightKg,
}) =>
    showModalBottomSheet<(ActivityKind, int)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivitySheet(weightKg: weightKg),
    );

class _ActivitySheet extends StatefulWidget {
  final double weightKg;
  const _ActivitySheet({required this.weightKg});

  @override
  State<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends State<_ActivitySheet> {
  ActivityKind _kind = ActivityKind.walk;
  int _minutes = 30;

  static const _presets = [10, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;
    final kcal = FitnessMet.netKcal(
      kind: _kind,
      weightKg: widget.weightKg,
      minutes: _minutes.toDouble(),
    );

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.cream50,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
        border: Border.all(color: dark ? AppColors.darkInk : AppColors.ink900,
            width: 2),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20,
          20 + MediaQuery.of(context).viewInsets.bottom),
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
          Text('记一笔日常活动',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final k in ActivityKind.manual)
                GestureDetector(
                  onTap: () => setState(() => _kind = k),
                  child: CreamPill(
                    label: k.zh,
                    leadingEmoji: k.emoji,
                    background: k == _kind
                        ? AppColors.peach300
                        : AppColors.cream200,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text('练了多久',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: ink)),
              const Spacer(),
              Text('$_minutes 分钟',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final m in _presets)
                GestureDetector(
                  onTap: () => setState(() => _minutes = m),
                  child: CreamPill(
                    label: '$m 分',
                    background: m == _minutes
                        ? AppColors.mint300
                        : AppColors.cream200,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cream200,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Text('约 ${FitnessMet.displayKcal(kcal)} 大卡',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    )),
                const SizedBox(height: AppSpacing.xs),
                const Text('按 MET 估的净消耗，误差在两成左右',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.ink600)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CreamButton(
            label: '记下来',
            emoji: '✅',
            full: true,
            onPressed: () => Navigator.of(context).pop((_kind, _minutes)),
          ),
        ],
      ),
    );
  }
}
