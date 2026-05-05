import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF10B981);

  // Legacy aliases kept for existing references
  static const Color primaryDark = Color(0xFFF1F5F9);
  static const Color primaryBlack = Color(0xFFF8FAFC);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF10B981);

  // Status colors
  static const Color statusNormal = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFF43F5E);
  static const Color statusCritical = Color(0xFF881337);

  // UI colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF1F5F9);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);

  // Chart colors
  static const Color chartLine1 = Color(0xFF2563EB);
  static const Color chartLine2 = Color(0xFF10B981);
  static const Color chartLine3 = Color(0xFFF43F5E);
  static const Color chartBackground = Color(0xFFFFFFFF);

  // VPN colors
  static const Color vpnConnected = Color(0xFF10B981);
  static const Color vpnDisconnected = Color(0xFF94A3B8);
  static const Color vpnConnecting = Color(0xFFF59E0B);

  // Shared card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 10)),
  ];
}
