import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/spaces_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/widgets/pressable_buttons/app_pressable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double _kDisabledOpacity = 0.45;

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.customHeight,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.customIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? customHeight;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null && !isLoading;
    return AppPressable(
      onPressed: isLoading ? null : onPressed,
      pressedScale: 0.96,
      child: Opacity(
        opacity: isDisabled ? _kDisabledOpacity : 1,
        child: Container(
          height: customHeight ?? 48.h,
          alignment: Alignment.center,
          padding: PaddingManager.paddingHorizontal5,
          decoration: DecorationManager.solidButton(
            color: backgroundColor,
            borderColor: borderColor,
            radius: BorderRadiusManager.radiusAll24,
          ),
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CupertinoActivityIndicator(
                    color: textColor ?? ColorManager.white,
                  ),
                )
              : customIcon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customIcon!,
                    SpacesManager.w5,
                    Text(
                      label,
                      style: getMediumTextStyle(
                        fontSize: FontSizesManager.s16,
                        color: textColor ?? ColorManager.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: getMediumTextStyle(
                    fontSize: FontSizesManager.s16,
                    color: textColor ?? ColorManager.white,
                  ),
                ),
        ),
      ),
    );
  }
}
