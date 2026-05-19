import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Palette ──────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF0d173d);     // Deep navy (primary brand)
  static const Color navyLight = Color(0xFF162767); // Medium navy (secondary brand)

  // ── Interactive Accent ─────────────────────────────────────────────────────
  // Vibrant blue that reads clearly on dark backgrounds
  static const Color primary = Color(0xFF4175F5);
  static const Color accent  = Color(0xFF10B981);  // Green — safe / active states

  // ── Legacy aliases (all existing widget references preserved) ─────────────
  static const Color primaryDark  = navy;
  static const Color primaryBlack = Color(0xFF040713); // Near-black background
  static const Color accentBlue   = primary;
  static const Color accentGreen  = accent;

  // ── Dark Surface System (layered) ──────────────────────────────────────────
  // background  < surface  < card  < elevated  (progressively lighter)
  static const Color background      = Color(0xFF040713); // Deepest — scaffold bg
  static const Color surfaceLight    = Color(0xFF0C1530); // Cards / bottom-sheets
  static const Color surfaceDark     = Color(0xFF0A1224); // Input fills
  static const Color surfaceElevated = Color(0xFF111E3D); // Popovers / dialogs

  // ── Border / Divider ───────────────────────────────────────────────────────
  static const Color borderColor = Color(0xFF1B2D52);

  // ── Text Hierarchy ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // Main labels
  static const Color textSecondary = Color(0xFFCCCCCC); // Supporting text
  static const Color textMuted     = Color(0xFF8B9EC7); // Placeholders / hints
  static const Color textDisabled  = Color(0xFF4A5C80); // Disabled / very dim

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color statusNormal   = Color(0xFF10B981);
  static const Color statusWarning  = Color(0xFFF59E0B);
  static const Color statusDanger   = Color(0xFFEF4444);
  static const Color statusCritical = Color(0xFF881337);

  // ── Chart ──────────────────────────────────────────────────────────────────
  static const Color chartLine1      = primary;
  static const Color chartLine2      = accent;
  static const Color chartLine3      = statusDanger;
  static const Color chartBackground = surfaceLight;

  // ── VPN Status ─────────────────────────────────────────────────────────────
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
