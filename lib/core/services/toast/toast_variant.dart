import 'package:Sentri/core/resources/color_manager.dart';
import 'package:flutter/material.dart';


/// The semantic states a global toast can represent. `info` is the neutral
/// default; the rest mirror the in-app banner set in Figma.
enum ToastVariant { info, success, warning, error }

/// Resolved visual tokens for a [ToastVariant] — the accent colour and the
/// status glyph drawn in the leading disc. Every colour flows through
/// [ColorManager]; widgets never inline a raw value.
extension ToastVariantStyle on ToastVariant {
  /// Accent colour — tints the leading disc and colours its glyph.
  Color get color => switch (this) {
    ToastVariant.info => ColorManager.toastInfo,
    ToastVariant.success => ColorManager.toastSuccess,
    ToastVariant.warning => ColorManager.toastWarning,
    ToastVariant.error => ColorManager.toastError,
  };

  /// Status glyph. Each state gets a visually distinct shape — an `i`, a
  /// check, a warning triangle, and an error circle — so the variant is
  /// readable at a glance, never by colour alone.
  IconData get icon => switch (this) {
    ToastVariant.info => Icons.info_outline_rounded,
    ToastVariant.success => Icons.check_rounded,
    ToastVariant.warning => Icons.warning_amber_rounded,
    ToastVariant.error => Icons.error_outline_rounded,
  };
}
