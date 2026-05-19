import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Palette ──────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF0d173d);
  static const Color navyLight = Color(0xFF162767);

  // ── Interactive Accent (same in both themes) ───────────────────────────────
  static const Color primary = Color(0xFF4175F5);
  static const Color accent  = Color(0xFF10B981);

  // ── Legacy aliases ─────────────────────────────────────────────────────────
  static const Color primaryDark  = navy;
  static const Color primaryBlack = Color(0xFF040713);
  static const Color accentBlue   = primary;
  static const Color accentGreen  = accent;

  // ── Dark Surface System (kept as static for const contexts) ───────────────
  static const Color background      = Color(0xFF040713);
  static const Color surfaceLight    = Color(0xFF0C1530);
  static const Color surfaceDark     = Color(0xFF0A1224);
  static const Color surfaceElevated = Color(0xFF111E3D);
  static const Color borderColor     = Color(0xFF1B2D52);

  // ── Text (dark mode) ───────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textMuted     = Color(0xFF8B9EC7);
  static const Color textDisabled  = Color(0xFF4A5C80);

  // ── Status (unchanged across themes) ──────────────────────────────────────
  static const Color statusNormal   = Color(0xFF10B981);
  static const Color statusWarning  = Color(0xFFF59E0B);
  static const Color statusDanger   = Color(0xFFEF4444);
  static const Color statusCritical = Color(0xFF881337);

  // ── Chart ──────────────────────────────────────────────────────────────────
  static const Color chartLine1      = primary;
  static const Color chartLine2      = accent;
  static const Color chartLine3      = statusDanger;
  static const Color chartBackground = surfaceLight;

  // ── VPN Status (unchanged across themes) ──────────────────────────────────
  static const Color vpnConnected    = Color(0xFF10B981);
  static const Color vpnDisconnected = Color(0xFF4A5C80);
  static const Color vpnConnecting   = Color(0xFFF59E0B);

  // ── Shadows ────────────────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x50000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x200d173d), blurRadius: 12, offset: Offset(0, 2)),
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
    colors: [Color(0xFF080F1F), Color(0xFF040713)],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyLight, navy],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5A8BFF), primary],
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
        background: Color(0xFF040713),
        surfaceLight: Color(0xFF0C1530),
        surfaceDark: Color(0xFF0A1224),
        surfaceElevated: Color(0xFF111E3D),
        borderColor: Color(0xFF1B2D52),
        textPrimary: Color(0xFFFFFFFF),
        textSecondary: Color(0xFFCCCCCC),
        textMuted: Color(0xFF8B9EC7),
        textDisabled: Color(0xFF4A5C80),
        navyLight: Color(0xFF162767),
        authBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF080F1F), Color(0xFF040713)],
        ),
        cardShadow: [
          BoxShadow(color: Color(0x50000000), blurRadius: 24, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x200d173d), blurRadius: 12, offset: Offset(0, 2)),
        ],
      );

  factory AppThemeColors.light() => const AppThemeColors(
        background: Color(0xFFF8FAFF),
        surfaceLight: Color(0xFFFFFFFF),
        surfaceDark: Color(0xFFEEF2FC),
        surfaceElevated: Color(0xFFFFFFFF),
        borderColor: Color(0xFFD0DCF0),
        textPrimary: Color(0xFF0D173D),
        textSecondary: Color(0xFF2D4080),
        textMuted: Color(0xFF5B6F9E),
        textDisabled: Color(0xFF8FA3CC),
        navyLight: Color(0xFF162767),
        authBackground: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF3FF), Color(0xFFF8FAFF)],
        ),
        cardShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0A4175F5), blurRadius: 8, offset: Offset(0, 2)),
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
        background: background ?? this.background,
        surfaceLight: surfaceLight ?? this.surfaceLight,
        surfaceDark: surfaceDark ?? this.surfaceDark,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        borderColor: borderColor ?? this.borderColor,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        textDisabled: textDisabled ?? this.textDisabled,
        navyLight: navyLight ?? this.navyLight,
        authBackground: authBackground ?? this.authBackground,
        cardShadow: cardShadow ?? this.cardShadow,
      );

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      navyLight: Color.lerp(navyLight, other.navyLight, t)!,
      authBackground: t < 0.5 ? authBackground : other.authBackground,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}
