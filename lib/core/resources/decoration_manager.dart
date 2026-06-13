import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DecorationManager {
  DecorationManager._();

  // ─── LEGACY STATIC ─────────────────────────────────────────────────────────

  static BoxDecoration card = BoxDecoration(
    color: ColorManager.surface,
    borderRadius: BorderRadiusManager.card,
  );

  static BoxDecoration pillOutlined = BoxDecoration(
    color: ColorManager.surface,
    border: Border.all(color: ColorManager.border),
    borderRadius: BorderRadiusManager.pill,
  );

  static const LinearGradient heroOverlayTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [ColorManager.overlayHeavy, ColorManager.transparent],
  );

  static const LinearGradient heroOverlayBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [ColorManager.overlayHeavy, ColorManager.transparent],
  );

  static const List<BoxShadow> glassShadow = [
    BoxShadow(color: ColorManager.shadowLight, blurRadius: 2),
    BoxShadow(color: ColorManager.shadowGlass, offset: Offset(0, 1), blurRadius: 8),
  ];

  static const List<BoxShadow> softCardShadow = [
    BoxShadow(color: ColorManager.shadowSubtle, blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: ColorManager.shadowFaint, blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> toastShadow = [
    BoxShadow(color: ColorManager.shadowMedium, blurRadius: 28, offset: Offset(0, 10)),
    BoxShadow(color: ColorManager.shadowSoft, blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> frostedPillHalo = [
    BoxShadow(color: ColorManager.shadowSoft, blurRadius: 24, spreadRadius: -2, offset: Offset(0, 6)),
    BoxShadow(color: ColorManager.shadowFaint, blurRadius: 12, spreadRadius: -4),
  ];

  // ─── GRADIENTS ─────────────────────────────────────────────────────────────

  /// Horizontal gradient for primary action buttons (auth, dialog confirm).
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ColorManager.gradientBlue, AppColors.primary],
  );

  /// Vertical gradient for section-header accent bars.
  static const LinearGradient sectionAccent = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [ColorManager.gradientBlue, AppColors.primary],
  );

  /// Below-bar area gradient for the threat sparkline chart.
  static LinearGradient get threatSparkline => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.statusDanger.withValues(alpha: 0.25),
          AppColors.statusDanger.withValues(alpha: 0.02),
        ],
      );

  // ─── SHADOWS ───────────────────────────────────────────────────────────────

  /// Deep shadow under the floating navigation bar.
  static final List<BoxShadow> navBarShadow = [
    BoxShadow(
      color: ColorManager.pureBlack.withValues(alpha: 0.35),
      blurRadius: 32,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── STATIC DECORATIONS (constant / brand colours) ─────────────────────────

  /// Circular send button with primary colour fill.
  static const BoxDecoration sendButton = BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
  );

  /// Circular Nova AI launcher beside the nav bar — gradient fill with brand glow.
  static BoxDecoration get novaFab => BoxDecoration(
        gradient: primaryButton,
        shape: BoxShape.circle,
        boxShadow: AppColors.glowShadow(AppColors.primary),
      );

  /// Gradient avatar disc for Nova (chat header / empty state).
  static BoxDecoration get novaAvatar => const BoxDecoration(
        gradient: primaryButton,
        shape: BoxShape.circle,
      );

  /// Thin vertical bar decoration used in gradient section headers.
  static BoxDecoration get sectionAccentBar => BoxDecoration(
        gradient: sectionAccent,
        borderRadius: BorderRadiusManager.radiusAll2,
      );

  /// Suggestion chip in the chat screen.
  static BoxDecoration get suggestionChip => BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadiusManager.radiusAll18,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 0.5),
      );

  /// User-side chat bubble with primary tint.
  static BoxDecoration get userChatBubble => BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadiusManager.chatBubbleUser,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
      );

  /// Protocol label chip (TCP, UDP…) in traffic rows.
  static BoxDecoration get protoChip => BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadiusManager.radiusAll4,
      );

  /// Service-name chip in traffic rows (cyan accent).
  static BoxDecoration get serviceChip => BoxDecoration(
        color: ColorManager.serviceCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadiusManager.radiusAll4,
        border: Border.all(color: ColorManager.serviceCyan.withValues(alpha: 0.3), width: 0.5),
      );

  // ─── COLOR-PARAMETERISED DECORATIONS ───────────────────────────────────────

  /// Filled circle with a matching glow — VPN status dot.
  static BoxDecoration colorDot(Color color) => BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: AppColors.glowShadow(color),
      );

  /// Rounded pill with glow — Start / Stop VPN button.
  static BoxDecoration colorButton(Color color, {BorderRadius? radius}) => BoxDecoration(
        color: color,
        borderRadius: radius ?? BorderRadiusManager.radiusAll20,
        boxShadow: AppColors.glowShadow(color),
      );

  /// Thin solid-colour bar — action/status accent bars and left-edge indicators.
  static BoxDecoration colorBar(Color color, {BorderRadius? radius}) => BoxDecoration(
        color: color,
        borderRadius: radius ?? BorderRadiusManager.radiusAll3,
      );

  /// Thinking-dot circle with variable opacity — streaming AI bubble loader.
  static BoxDecoration thinkingDot(double alpha) => BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: alpha),
      );

  /// Status badge pill — tinted fill + matching border (BLOCK, WARN, SAFE…).
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadiusManager.radiusAll6,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      );

  /// Simple tinted container without border — icon backgrounds, loaders, dots.
  static BoxDecoration tinted(Color color, BorderRadius radius, {double alpha = 0.12}) =>
      BoxDecoration(
        color: color.withValues(alpha: alpha),
        borderRadius: radius,
      );

  /// Tinted container with a soft matching border — chips, badges, count pills.
  static BoxDecoration coloredChip(
    Color color,
    BorderRadius radius, {
    double fillAlpha = 0.12,
    double borderAlpha = 0.3,
    double borderWidth = 0.5,
  }) =>
      BoxDecoration(
        color: color.withValues(alpha: fillAlpha),
        borderRadius: radius,
        border: Border.all(color: color.withValues(alpha: borderAlpha), width: borderWidth),
      );

  /// Tinted circle icon disc — toast leading icon.
  static BoxDecoration circleIcon(Color color, {double alpha = 0.12}) => BoxDecoration(
        color: color.withValues(alpha: alpha),
        shape: BoxShape.circle,
      );

  /// Nav-item pill — active gets primary tint, inactive is transparent.
  static BoxDecoration navItem(bool isActive) => BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.12) : ColorManager.transparent,
        borderRadius: BorderRadiusManager.radiusAll32,
      );

  /// Gradient button box for primary CTA (auth button, dialog confirm).
  static BoxDecoration primaryButtonBox({BorderRadius? radius, bool glow = false}) => BoxDecoration(
        gradient: primaryButton,
        borderRadius: radius ?? BorderRadiusManager.radiusAll28,
        boxShadow: glow ? AppColors.glowShadow(AppColors.primary) : null,
      );

  /// Solid-colour button box with optional border — AppPrimaryButton.
  static BoxDecoration solidButton({
    Color? color,
    Color? borderColor,
    BorderRadius? radius,
  }) =>
      BoxDecoration(
        color: color ?? ColorManager.primary,
        borderRadius: radius ?? BorderRadiusManager.radiusAll24,
        border: Border.all(color: borderColor ?? ColorManager.transparent, width: 1),
      );

  // ─── THEME-DEPENDENT DECORATIONS ───────────────────────────────────────────

  /// The most-used card: surface fill + thin border + optional shadow.
  static BoxDecoration surfaceCard(
    AppThemeColors colors, {
    BorderRadius? radius,
    bool shadow = true,
    double borderWidth = 0.5,
  }) =>
      BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: radius ?? BorderRadiusManager.radiusAll20,
        border: Border.all(color: colors.borderColor, width: borderWidth),
        boxShadow: shadow ? colors.cardShadow : null,
      );

  /// Surface card without shadow — detail sections, bare lists.
  static BoxDecoration surfaceCardBare(
    AppThemeColors colors, {
    BorderRadius? radius,
    double borderWidth = 0.5,
  }) =>
      BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: radius ?? BorderRadiusManager.radiusAll12,
        border: Border.all(color: colors.borderColor, width: borderWidth),
      );

  /// Traffic-row container — dynamic background (block-tinted or surface).
  static BoxDecoration trafficRow(Color bgColor, AppThemeColors colors) => BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadiusManager.radiusAll12,
        border: Border.all(color: colors.borderColor, width: 0.5),
      );

  /// AI-side chat bubble.
  static BoxDecoration aiBubble(AppThemeColors colors) => BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadiusManager.chatBubbleAi,
        border: Border.all(color: colors.borderColor, width: 0.5),
      );

  /// Container with a single top border — chat input bar.
  static BoxDecoration topBorder(AppThemeColors colors) => BoxDecoration(
        color: colors.surfaceLight,
        border: Border(top: BorderSide(color: colors.borderColor, width: 0.5)),
      );

  /// Container with a single bottom border — control bar.
  static BoxDecoration bottomBorder(AppThemeColors colors) => BoxDecoration(
        color: colors.surfaceLight,
        border: Border(bottom: BorderSide(color: colors.borderColor, width: 0.5)),
      );

  /// Brand logo container on auth screens.
  static BoxDecoration brandLogo(AppThemeColors colors) => BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadiusManager.radiusAll20,
        border: Border.all(color: colors.borderColor),
        boxShadow: colors.cardShadow,
      );

  /// App-info logo container in Settings → About.
  static BoxDecoration aboutLogo(AppThemeColors colors) => BoxDecoration(
        color: colors.navyLight,
        borderRadius: BorderRadiusManager.radiusAll12,
        border: Border.all(color: colors.borderColor),
      );

  /// Floating navigation bar container.
  static BoxDecoration navBar(AppThemeColors colors) => BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadiusManager.radiusAll40,
        boxShadow: navBarShadow,
      );

  /// Clear-button background pill.
  static BoxDecoration clearButton(AppThemeColors colors) => BoxDecoration(
        color: colors.borderColor.withValues(alpha: 0.6),
        borderRadius: BorderRadiusManager.radiusAll8,
      );

  /// Toggle-tile icon container — primary tint when active, muted border when off.
  static BoxDecoration toggleIcon(AppThemeColors colors, {required bool active}) => BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.15)
            : colors.borderColor.withValues(alpha: 0.6),
        borderRadius: BorderRadiusManager.radiusAll10,
      );

  /// Filter chip — tinted + bordered when selected, plain surface when idle.
  static BoxDecoration filterChip(
    AppThemeColors colors,
    Color color, {
    required bool selected,
  }) =>
      BoxDecoration(
        color: selected ? color.withValues(alpha: 0.18) : colors.surfaceLight,
        borderRadius: BorderRadiusManager.radiusAll20,
        border: Border.all(
          color: selected ? color : colors.borderColor,
          width: selected ? 1.5 : 0.5,
        ),
      );

  /// Bottom-sheet drag handle.
  static BoxDecoration sheetHandle(AppThemeColors colors) => BoxDecoration(
        color: colors.borderColor,
        borderRadius: BorderRadiusManager.radiusAll2,
      );

  /// Animated glow wrapper for focused text fields.
  static BoxDecoration inputFocusGlow(BorderRadius radius, {required bool focused}) => BoxDecoration(
        borderRadius: radius,
        boxShadow: focused ? AppColors.glowShadow(AppColors.primary) : null,
      );

  // ─── INPUT DECORATION ──────────────────────────────────────────────────────

  /// Standard outlined InputDecoration used across all text fields.
  static InputDecoration inputField(
    AppThemeColors colors, {
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    BorderRadius? radius,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    double borderWidth = 1.0,
  }) {
    final r = radius ?? BorderRadiusManager.radiusAll12;
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      filled: true,
      fillColor: colors.surfaceDark,
      isDense: isDense,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintStyle: hintStyle ?? getRegularTextStyle(fontSize: FontSizesManager.s14, color: colors.textDisabled),
      labelStyle: labelStyle ?? getRegularTextStyle(fontSize: FontSizesManager.s14, color: colors.textMuted),
      border: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: colors.borderColor, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: colors.borderColor, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: const BorderSide(color: AppColors.statusDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: const BorderSide(color: AppColors.statusDanger, width: 1.5),
      ),
    );
  }
}
