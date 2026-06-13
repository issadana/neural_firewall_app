import 'package:flutter/material.dart';

class ColorManager {
  ColorManager._();

  // ── Transparency ──────────────────────────────────────────────────────────
  static const Color transparent = Color(0x00000000);

  // ── Sentri Brand ─────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF167740); // Sentri green
  static const Color red       = Color(0xFFCC1D2A); // Sentri red
  static const Color white     = Color(0xFFFFFFFF);
  static const Color offWhite  = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFD4D5D5);
  static const Color black     = Color(0xFF292C2B);
  static const Color pureBlack = Color(0xFF000000);
  static const Color grey      = Color(0xFF747675);

  // ── Brand semantic aliases ────────────────────────────────────────────────
  static const Color textPrimary   = black;
  static const Color textSecondary = grey;
  static const Color border        = lightGrey;
  static const Color surface       = white;

  // ── Toast / in-app banners ────────────────────────────────────────────────
  static const Color toastInfo    = Color(0xFF1A6FBF);
  static const Color toastSuccess = primary;
  static const Color toastWarning = Color(0xFFB26B00);
  static const Color toastError   = red;

  // ── UI Theme — navy / dark palette ───────────────────────────────────────
  static const Color navy       = Color(0xFF0D173D);
  static const Color navyLight  = Color(0xFF162767);
  static const Color accentBlue  = Color(0xFF4175F5); // interactive primary
  static const Color accentGreen = Color(0xFF10B981); // accent / success

  // ── Dark-theme surfaces ───────────────────────────────────────────────────
  static const Color darkBackground    = Color(0xFF040713);
  static const Color darkAuthGradStart = Color(0xFF080F1F);
  static const Color darkSurface       = Color(0xFF0C1530);
  static const Color darkSurfaceDark   = Color(0xFF0A1224);
  static const Color darkSurfaceElev   = Color(0xFF111E3D);
  static const Color darkBorder        = Color(0xFF1B2D52);

  // ── Dark-theme text ───────────────────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCCCCCC);
  static const Color darkTextMuted     = Color(0xFF8B9EC7);
  static const Color darkTextDisabled  = Color(0xFF4A5C80);

  // ── Light-theme surfaces ──────────────────────────────────────────────────
  static const Color lightBackground    = Color(0xFFF8FAFF);
  static const Color lightAuthGradStart = Color(0xFFEEF3FF);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightSurfaceDark   = Color(0xFFEEF2FC);
  static const Color lightBorder        = Color(0xFFD0DCF0);

  // ── Light-theme text ──────────────────────────────────────────────────────
  static const Color lightTextPrimary   = Color(0xFF0D173D);
  static const Color lightTextSecondary = Color(0xFF2D4080);
  static const Color lightTextMuted     = Color(0xFF5B6F9E);
  static const Color lightTextDisabled  = Color(0xFF8FA3CC);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color statusNormal   = Color(0xFF10B981);
  static const Color statusWarning  = Color(0xFFF59E0B);
  static const Color statusDanger   = Color(0xFFEF4444);
  static const Color statusCritical = Color(0xFF881337);

  // ── VPN status ────────────────────────────────────────────────────────────
  static const Color vpnConnected    = statusNormal;
  static const Color vpnDisconnected = darkTextDisabled;
  static const Color vpnConnecting   = statusWarning;

  // ── Protocol / service labels ─────────────────────────────────────────────
  static const Color quicPurple  = Color(0xFFAA77FF);
  static const Color serviceCyan = Color(0xFF00BCD4);

  // ── Gradient colours ──────────────────────────────────────────────────────
  static const Color gradientBlue = Color(0xFF5A8BFF); // primaryGradient start

  // ── Shadow overlays (semi-transparent) ───────────────────────────────────
  static const Color shadowDark    = Color(0x50000000); // black @ 31%
  static const Color shadowNavy    = Color(0x200D173D); // navy  @ 12%
  static const Color shadowMedium  = Color(0x26000000); // black @ 15%
  static const Color shadowLight   = Color(0x1A000000); // black @ 10%
  static const Color shadowGlass   = Color(0x1F000000); // black @ 12%
  static const Color shadowSoft    = Color(0x14000000); // black @  8%
  static const Color shadowSubtle  = Color(0x0D000000); // black @  5%
  static const Color shadowFaint   = Color(0x0A000000); // black @  4%
  static const Color shadowBlue    = Color(0x0A4175F5); // blue shadow (light card)
  static const Color overlayHeavy  = Color(0x99000000); // black @ 60%
}
