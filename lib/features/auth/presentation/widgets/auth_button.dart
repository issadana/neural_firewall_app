import 'package:flutter/material.dart';

import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/theme/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: isLoading
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadiusManager.radiusAll28,
              )
            : DecorationManager.primaryButtonBox(
                radius: BorderRadiusManager.radiusAll28,
                glow: true,
              ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.transparent,
            foregroundColor: ColorManager.white,
            disabledBackgroundColor: ColorManager.transparent,
            shadowColor: ColorManager.transparent,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorManager.white),
                  ),
                )
              : Text(
                  label,
                  style: getSemiBoldTextStyle(
                    fontSize: FontSizesManager.s16,
                    letterSpacing: 0.5,
                    color: ColorManager.white,
                  ),
                ),
        ),
      ),
    );
  }
}
