import 'package:flutter/material.dart';
import 'package:Sentri/core/resources/color_manager.dart';

class AppColors {
  // ── Brand Palette ──────────────────────────────────────────────────────────
  static const Color navy      = ColorManager.navy;
  static const Color navyLight = ColorManager.navyLight;

  // ── Interactive Accent (same in both themes) ───────────────────────────────
  static const Color primary = ColorManager.accentBlue;
  static const Color accent  = ColorManager.accentGreen;

  // ── Legacy aliases ─────────────────────────────────────────────────────────
  static const Color primaryDark  = navy;
  static const Color primaryBlack = ColorManager.darkBackground;
  static const Color accentBlue   = primary;
  static const Color accentGreen  = accent;

  // ── Dark Surface System ────────────────────────────────────────────────────
  static const Color background      = ColorManager.darkBackground;
  static const Color surfaceLight    = ColorManager.darkSurface;
  static const Color surfaceDark     = ColorManager.darkSurfaceDark;
  static const Color surfaceElevated = ColorManager.darkSurfaceElev;
  static const Color borderColor     = ColorManager.darkBorder;

  // ── Text (dark mode) ───────────────────────────────────────────────────────
  static const Color textPrimary   = ColorManager.darkTextPrimary;
  static const Color textSecondary = ColorManager.darkTextSecondary;
  static const Color textMuted     = ColorManager.darkTextMuted;
  static const Color textDisabled  = ColorManager.darkTextDisabled;

  // ── Status (unchanged across themes) ──────────────────────────────────────
  static const Color statusNormal   = ColorManager.statusNormal;
  static const Color statusWarning  = ColorManager.statusWarning;
  static const Color statusDanger   = ColorManager.statusDanger;
  static const Color statusCritical = ColorManager.statusCritical;

  // ── Chart ──────────────────────────────────────────────────────────────────
  static const Color chartLine1      = primary;
  static const Color chartLine2      = accent;
  static const Color chartLine3      = statusDanger;
  static const Color chartBackground = surfaceLight;

  // ── VPN Status (unchanged across themes) ──────────────────────────────────
  static const Color vpnConnected    = ColorManager.vpnConnected;
  static const Color vpnDisconnected = ColorManager.vpnDisconnected;
  static const Color vpnConnecting   = ColorManager.vpnConnecting;

  // ── Shadows ────────────────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: ColorManager.shadowDark, blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: ColorManager.shadowNavy, blurRadius: 12, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 18,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient authBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ColorManager.darkAuthGradStart, ColorManager.darkBackground],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyLight, navy],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ColorManager.gradientBlue, primary],
  );
}

// ── Theme-aware color extension ────────────────────────────────────────────────

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surfaceLight;
  final Color surfaceDark;
  final Color surfaceElevated;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color navyLight;
  final LinearGradient authBackground;
  final List<BoxShadow> cardShadow;

  const AppThemeColors({
    required this.background,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.surfaceElevated,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.navyLight,
    required this.authBackground,
    required this.cardShadow,
  });

  factory AppThemeColors.dark() => const AppThemeColors(
        background:      ColorManager.darkBackground,
        surfaceLight:    ColorManager.darkSurface,
        surfaceDark:     ColorManager.darkSurfaceDark,
        surfaceElevated: ColorManager.darkSurfaceElev,
        borderColor:     ColorManager.darkBorder,
        textPrimary:     ColorManager.darkTextPrimary,
        textSecondary:   ColorManager.darkTextSecondary,
        textMuted:       ColorManager.darkTextMuted,
        textDisabled:    ColorManager.darkTextDisabled,
        navyLight:       ColorManager.navyLight,
        authBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorManager.darkAuthGradStart, ColorManager.darkBackground],
        ),
        cardShadow: [
          BoxShadow(color: ColorManager.shadowDark, blurRadius: 24, offset: Offset(0, 8)),
          BoxShadow(color: ColorManager.shadowNavy, blurRadius: 12, offset: Offset(0, 2)),
        ],
      );

  factory AppThemeColors.light() => const AppThemeColors(
        background:      ColorManager.lightBackground,
        surfaceLight:    ColorManager.lightSurface,
        surfaceDark:     ColorManager.lightSurfaceDark,
        surfaceElevated: ColorManager.lightSurface,
        borderColor:     ColorManager.lightBorder,
        textPrimary:     ColorManager.lightTextPrimary,
        textSecondary:   ColorManager.lightTextSecondary,
        textMuted:       ColorManager.lightTextMuted,
        textDisabled:    ColorManager.lightTextDisabled,
        navyLight:       ColorManager.navyLight,
        authBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorManager.lightAuthGradStart, ColorManager.lightBackground],
        ),
        cardShadow: [
          BoxShadow(color: ColorManager.shadowSoft, blurRadius: 12, offset: Offset(0, 4)),
          BoxShadow(color: ColorManager.shadowBlue, blurRadius: 8,  offset: Offset(0, 2)),
        ],
      );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surfaceLight,
    Color? surfaceDark,
    Color? surfaceElevated,
    Color? borderColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? navyLight,
    LinearGradient? authBackground,
    List<BoxShadow>? cardShadow,
  }) =>
      AppThemeColors(
        background:      background      ?? this.background,
        surfaceLight:    surfaceLight    ?? this.surfaceLight,
        surfaceDark:     surfaceDark     ?? this.surfaceDark,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        borderColor:     borderColor     ?? this.borderColor,
        textPrimary:     textPrimary     ?? this.textPrimary,
        textSecondary:   textSecondary   ?? this.textSecondary,
        textMuted:       textMuted       ?? this.textMuted,
        textDisabled:    textDisabled    ?? this.textDisabled,
        navyLight:       navyLight       ?? this.navyLight,
        authBackground:  authBackground  ?? this.authBackground,
        cardShadow:      cardShadow      ?? this.cardShadow,
      );

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      background:      Color.lerp(background,      other.background,      t)!,
      surfaceLight:    Color.lerp(surfaceLight,    other.surfaceLight,    t)!,
      surfaceDark:     Color.lerp(surfaceDark,     other.surfaceDark,     t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      borderColor:     Color.lerp(borderColor,     other.borderColor,     t)!,
      textPrimary:     Color.lerp(textPrimary,     other.textPrimary,     t)!,
      textSecondary:   Color.lerp(textSecondary,   other.textSecondary,   t)!,
      textMuted:       Color.lerp(textMuted,       other.textMuted,       t)!,
      textDisabled:    Color.lerp(textDisabled,     other.textDisabled,    t)!,
      navyLight:       Color.lerp(navyLight,        other.navyLight,       t)!,
      authBackground:  t < 0.5 ? authBackground  : other.authBackground,
      cardShadow:      t < 0.5 ? cardShadow      : other.cardShadow,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}
