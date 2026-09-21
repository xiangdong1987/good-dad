import 'package:flutter/material.dart';

import '../../../ui/theme.dart';
import '../../../ui/widgets/cream_widgets.dart';
import '../fitness_models.dart';

/// 可编辑的食物清单。
///
/// 增删改都只动明细，整餐数字由 [MealAnalysis.withFoods] 按明细之和重算，
/// 所以删一样、改分量都是本地即时的，不用再调一次 AI。
class FoodListEditor extends StatelessWidget {
  final List<FoodItem> foods;
  final ValueChanged<List<FoodItem>> onChanged;

  /// 新增一样：由页面去问 AI 要估值，返回 null 表示取消或失败。
  final Future<FoodItem?> Function() onAdd;

  /// 一次增减的克数。
  static const step = 25;

  const FoodListEditor({
    super.key,
    required this.foods,
    required this.onChanged,
    required this.onAdd,
  });

  void _replace(int i, FoodItem next) {
    final copy = [...foods];
    copy[i] = next;
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.darkInk : AppColors.ink900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (foods.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text('还没有食物，点下面加一样',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.ink600)),
          )
        else
          for (final (i, f) in foods.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: ink)),
                        Text('${f.grams}g · ${f.kcal} 大卡',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: AppColors.ink600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            )),
                      ],
                    ),
                  ),
                  _RoundButton(
                    key: ValueKey('minus-${f.name}'),
                    icon: Icons.remove_rounded,
                    onTap: () => _replace(
                        i, f.scaledTo((f.grams - step).clamp(0, 99999))),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RoundButton(
                    key: ValueKey('plus-${f.name}'),
                    icon: Icons.add_rounded,
                    onTap: () => _replace(i, f.scaledTo(f.grams + step)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _RoundButton(
                    key: ValueKey('del-${f.name}'),
                    icon: Icons.close_rounded,
                    background: AppColors.rose300,
                    onTap: () =>
                        onChanged([...foods]..removeAt(i)),
                  ),
                ],
              ),
            ),
        CreamButton(
          label: '加一样',
          emoji: '➕',
          ghost: true,
          onPressed: () async {
            final added = await onAdd();
            if (added != null) onChanged([...foods, added]);
          },
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? background;

  const _RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: background ?? AppColors.cream200,
          shape: BoxShape.circle,
          border: Border.all(color: stroke, width: 2),
        ),
        child: Icon(icon, size: 18, color: stroke),
      ),
    );
  }
}
