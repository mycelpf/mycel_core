import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Mycel theme — premium fintech aesthetic.
///
/// Light: warm cream scaffold, pure white cards.
/// Dark: deep black scaffold, dark elevated cards.
class MycelTheme {
  MycelTheme._();

  static const _fontFamily = 'Inter';

  // ── Palette ──────────────────────────────────────────────
  // Dark
  static const _darkScaffold = Color(0xFF0D0D0D);
  static const _darkCard = Color(0xFF1A1A1C);
  static const _darkCardHigh = Color(0xFF222224);
  static const _darkBorder = Color(0xFF2A2A2C);
  static const _darkTextPrimary = Color(0xFFF5F5F5);
  static const _darkTextSecondary = Color(0xFF8E8E93);

  // Light
  static const _lightScaffold = Color(0xFFF5F2EE); // warm cream
  static const _lightCard = Colors.white;
  static const _lightCardHigh = Color(0xFFF8F6F3);
  static const _lightBorder = Color(0xFFE8E4DF);
  static const _lightTextPrimary = Color(0xFF1A1A1A);
  static const _lightTextSecondary = Color(0xFF8A857E);

  // Brand
  static const _brand = Color(0xFF0D9488); // teal
  static const _brandOnDark = Color(0xFF2DD4BF);

  /// Light theme.
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: _brand,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFCCFBF1),
      onPrimaryContainer: Color(0xFF0F766E),

      secondary: Color(0xFF6B6560),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEDE8E3),
      onSecondaryContainer: Color(0xFF4A4540),

      tertiary: Color(0xFF3B82F6),
      onTertiary: Colors.white,

      error: Color(0xFFDC2626),
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),

      surface: _lightScaffold,
      onSurface: _lightTextPrimary,
      onSurfaceVariant: _lightTextSecondary,

      surfaceContainerLowest: _lightCard,
      surfaceContainerLow: _lightCardHigh,
      surfaceContainer: Color(0xFFF0EDE9),
      surfaceContainerHigh: Color(0xFFE8E4DF),
      surfaceContainerHighest: Color(0xFFDDD8D2),

      outline: Color(0xFFCCC7C1),
      outlineVariant: _lightBorder,

      inverseSurface: _darkCard,
      onInverseSurface: _darkTextPrimary,
      inversePrimary: _brandOnDark,
    );

    return _build(colorScheme, Brightness.light);
  }

  /// Dark theme.
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: _brandOnDark,
      onPrimary: Color(0xFF003733),
      primaryContainer: Color(0xFF0F766E),
      onPrimaryContainer: Color(0xFF99F6E4),

      secondary: Color(0xFF9E9A96),
      onSecondary: Color(0xFF1A1A1A),
      secondaryContainer: Color(0xFF2A2A2C),
      onSecondaryContainer: Color(0xFFCCC8C4),

      tertiary: Color(0xFF60A5FA),
      onTertiary: Color(0xFF1E3A5F),

      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFECACA),

      surface: _darkScaffold,
      onSurface: _darkTextPrimary,
      onSurfaceVariant: _darkTextSecondary,

      surfaceContainerLowest: Color(0xFF111112),
      surfaceContainerLow: _darkCard,
      surfaceContainer: _darkCardHigh,
      surfaceContainerHigh: Color(0xFF2A2A2C),
      surfaceContainerHighest: Color(0xFF333335),

      outline: Color(0xFF3A3A3C),
      outlineVariant: _darkBorder,

      inverseSurface: _lightCard,
      onInverseSurface: _lightTextPrimary,
      inversePrimary: _brand,
    );

    return _build(colorScheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme cs, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    const textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSize3xl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSize2xl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeXl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeLg,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeMd,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeSm,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeMd,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeSm,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeXs,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeSm,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: MycelTokens.fontSizeXs,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        height: 1.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: cs,
      brightness: brightness,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDark ? _darkCard : _lightCard,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MycelTokens.spacingMd,
          vertical: MycelTokens.spacingXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MycelTokens.radiusMd),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MycelTokens.spacingMd,
          vertical: MycelTokens.spacingSm + 4,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? _darkCard : _lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isDark ? 8 : 4,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
      ),
    );
  }
}
