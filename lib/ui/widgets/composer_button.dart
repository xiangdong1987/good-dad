import 'package:flutter/material.dart';

import '../theme.dart';

/// 「📝」浮动按钮 —— 在麦克风左边，点击弹起 [ComposerSheet] 输入文字+图片。
///
/// 跟 [VoiceButton] 同尺寸 56×56，桃色描边、奶油底，emoji 不旋转。
class ComposerButton extends StatelessWidget {
  final VoidCallback onTap;

  const ComposerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          debugPrint('[Composer] button tapped');
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cream100,
            shape: BoxShape.circle,
            border: Border.all(color: stroke, width: 2),
            boxShadow: AppShadows.pop(dark),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.edit_rounded,
            color: AppColors.ink900,
            size: 26,
          ),
        ),
      ),
    );
  }
}
