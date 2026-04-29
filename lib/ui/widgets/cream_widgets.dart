import 'package:flutter/material.dart';

import '../theme.dart';

/// good-dad 通用 widget 库 — 翻译自 good-dad-cute.html 的 atoms.jsx

// ─────────────────────────────────────────────────────────────
// CreamCard · 默认卡片（2px 描边 + 3px 落地阴影）
// ─────────────────────────────────────────────────────────────
class CreamCard extends StatelessWidget {
  final Widget child;
  final Color? background;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool flat; // flat = 没有落地阴影
  final VoidCallback? onTap;

  const CreamCard({
    super.key,
    required this.child,
    this.background,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.flat = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;
    final bg =
        background ?? (dark ? AppColors.darkSurface : AppColors.cream100);

    final card = Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: stroke, width: 2),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: flat ? null : AppShadows.pop(dark),
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sticker · emoji 贴纸（彩色圆盘 + 描边 + 微旋转）
// ─────────────────────────────────────────────────────────────
class Sticker extends StatelessWidget {
  final String emoji;
  final double size;
  final Color background;
  final double tilt; // degrees

  const Sticker({
    super.key,
    required this.emoji,
    this.size = 40,
    this.background = AppColors.peach300,
    this.tilt = 0,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;

    return Transform.rotate(
      angle: tilt * 3.1415926 / 180,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: stroke, width: 2),
          boxShadow: AppShadows.pop(dark),
        ),
        alignment: Alignment.center,
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5, height: 1),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CreamPill · chip
// ─────────────────────────────────────────────────────────────
class CreamPill extends StatelessWidget {
  final String label;
  final String? leadingEmoji;
  final Color? background;
  final Color? foreground;

  const CreamPill({
    super.key,
    required this.label,
    this.leadingEmoji,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stroke = dark ? AppColors.darkInk : AppColors.ink900;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background ??
            (dark ? AppColors.darkSurface : AppColors.cream100),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: stroke, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingEmoji != null) ...[
            Text(leadingEmoji!, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color:
                  foreground ?? (dark ? AppColors.darkInk : AppColors.ink900),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CreamButton — 带 emoji 的便捷按钮
// ─────────────────────────────────────────────────────────────
class CreamButton extends StatelessWidget {
  final String label;
  final String? emoji;
  final VoidCallback? onPressed;
  final bool ghost;
  final bool full;

  const CreamButton({
    super.key,
    required this.label,
    this.emoji,
    this.onPressed,
    this.ghost = false,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (emoji != null) ...[
          const SizedBox(width: 6),
          Text(emoji!),
        ],
      ],
    );
    final btn = ghost
        ? OutlinedButton(onPressed: onPressed, child: child)
        : FilledButton(onPressed: onPressed, child: child);

    return full ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ─────────────────────────────────────────────────────────────
// SkillCard · 首页 7 个 skill 入口卡
// ─────────────────────────────────────────────────────────────
class SkillCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color background;
  final VoidCallback? onTap;

  const SkillCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CreamCard(
      background: background,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sticker(
            emoji: emoji,
            size: 42,
            background: dark ? AppColors.darkBg : AppColors.cream50,
          ),
          const Spacer(),
          Text(title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 15,
              )),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: dark ? AppColors.ink400 : AppColors.ink600,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 状态 tag · 可吃 / 避免 / 提醒
// ─────────────────────────────────────────────────────────────
enum SafetyTag { ok, avoid, caution, info }

class StatusTag extends StatelessWidget {
  final SafetyTag kind;
  final String label;

  const StatusTag({super.key, required this.kind, required this.label});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, stroke) = switch (kind) {
      SafetyTag.ok =>
        (AppColors.mint300, const Color(0xFF4F9D7F), const Color(0xFF4F9D7F)),
      SafetyTag.avoid =>
        (AppColors.rose300, const Color(0xFF8B3344), const Color(0xFF8B3344)),
      SafetyTag.caution =>
        (AppColors.lemon300, const Color(0xFF8A6B14), const Color(0xFF8A6B14)),
      SafetyTag.info =>
        (AppColors.sky300, const Color(0xFF305A82), const Color(0xFF305A82)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: stroke, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
