import 'package:flutter/services.dart';

/// Centralized haptic feedback for consistent iOS-style interactions.
class HapticsHelper {
  HapticsHelper._();

  static void lightImpact() => HapticFeedback.lightImpact();

  static void selectionClick() => HapticFeedback.selectionClick();

  static void mediumImpact() => HapticFeedback.mediumImpact();
}
