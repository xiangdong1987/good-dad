import 'package:flutter/material.dart';

/// good-dad · 圆润奶油可爱风
/// 与 docs/design-system/styles.css 对齐
class AppColors {
  // Cream
  static const cream50 = Color(0xFFFFFBF5);
  static const cream100 = Color(0xFFFFF4E6);
  static const cream200 = Color(0xFFFCEBD3);
  static const cream300 = Color(0xFFF8DDB8);

  // Peach (主品牌色)
  static const peach200 = Color(0xFFFFD9C7);
  static const peach300 = Color(0xFFFFC9B5);
  static const peach500 = Color(0xFFFF8F6B);
  static const peach700 = Color(0xFFD9684A);
  static const caramel500 = Color(0xFFC98A4B);

  // Functional
  static const mint300 = Color(0xFFB6E2CC);
  static const mint500 = Color(0xFF7FC8A9);
  static const mint700 = Color(0xFF4F9D7F);
  static const sky300 = Color(0xFFC2D8EE);
  static const sky500 = Color(0xFF8FB8DE);
  static const lemon300 = Color(0xFFFBE39A);
  static const lemon500 = Color(0xFFF5C95A);
  static const rose300 = Color(0xFFF2BAC2);
  static const rose500 = Color(0xFFE07A8B);

  // Ink
  static const ink900 = Color(0xFF3D2E22);
  static const ink700 = Color(0xFF5C463A);
  static const ink600 = Color(0xFF7A6A5A);
  static const ink400 = Color(0xFFB5A89A);
  static const ink200 = Color(0xFFE2D5C5);
  static const line = Color(0xFFF0E5D6);

  // Dark
  static const darkBg = Color(0xFF1F1A14);
  static const darkSurface = Color(0xFF2A2218);
  static const darkInk = Color(0xFFF8E8D0);
}

class AppRadius {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const pill = 999.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Duolingo 式 3px 落地阴影 — 不偏移、不模糊，只是底部黑色实心条
class AppShadows {
  static const popLight = [
    BoxShadow(color: AppColors.ink900, offset: Offset(0, 3), blurRadius: 0),
  ];
  static const popDark = [
    BoxShadow(color: Color(0xFF100C08), offset: Offset(0, 3), blurRadius: 0),
  ];

  static List<BoxShadow> pop(bool dark) => dark ? popDark : popLight;
}

class AppTheme {
  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.cream50;
    final surface = isDark ? AppColors.darkSurface : AppColors.cream100;
    final onSurface = isDark ? AppColors.darkInk : AppColors.ink900;
    final stroke = isDark ? AppColors.darkInk : AppColors.ink900;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.peach500,
      onPrimary: Colors.white,
      secondary: AppColors.mint500,
      onSecondary: Colors.white,
      tertiary: AppColors.lemon500,
      onTertiary: AppColors.ink900,
      error: AppColors.rose500,
      onError: Colors.white,
      surface: bg,
      onSurface: onSurface,
      surfaceContainerHighest: surface,
      onSurfaceVariant: isDark ? AppColors.ink400 : AppColors.ink600,
      outline: stroke,
    );

    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      // 字体：Nunito 是 Google Font；中文走系统 fallback
      textTheme: _textTheme(onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 22,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: stroke, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.peach500,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
          side: BorderSide(color: stroke, width: 2),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          backgroundColor: surface,
          minimumSize: const Size(0, 56),
          side: BorderSide(color: stroke, width: 2),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: stroke, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: stroke, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.peach500, width: 2.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1.5,
      ),
    );
  }

  static TextTheme _textTheme(Color ink) {
    const family = 'Nunito';
    return TextTheme(
      displayLarge: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          color: ink,
          height: 1.25),
      titleLarge: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          color: ink),
      titleMedium: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: ink),
      bodyLarge: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: ink,
          height: 1.5),
      bodyMedium: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: ink,
          height: 1.55),
      labelLarge: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: ink),
      labelSmall: TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: ink),
    );
  }
}
