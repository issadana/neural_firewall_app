import 'dart:async';
import 'dart:math' as math;
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/decoration_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'package:Sentri/core/services/toast/toast_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double _kIconDiscOpacity = 0.12;
const double _kMaxCardWidth = 250;

class AppToastCard extends StatefulWidget {
  const AppToastCard({
    required this.variant,
    required this.message,
    required this.duration,
    required this.onDismissed,
    this.title,
    super.key,
  });

  final ToastVariant variant;
  final String message;
  final String? title;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<AppToastCard> createState() => _AppToastCardState();
}

class _AppToastCardState extends State<AppToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _autoDismiss;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _opacity = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(curved);
    unawaited(_controller.forward());
    _autoDismiss = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_leaving) return;
    _leaving = true;
    _autoDismiss?.cancel();
    if (mounted) await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final maxWidth = math.min(
      _kMaxCardWidth.w,
      media.size.width - PaddingManager.spacing800.w * 2,
    );
    return Positioned(
      top: media.padding.top + PaddingManager.spacing700.h,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < 0) _dismiss();
              },
              child: Material(
                color: ColorManager.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: PaddingManager.spacing200.w,
                      vertical: PaddingManager.spacing300.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.surface,
                      borderRadius: BorderRadiusManager.pill,
                      boxShadow: DecorationManager.toastShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: PaddingManager.spacing200.w),
                        _ToastLeadingIcon(variant: widget.variant),
                        SizedBox(width: PaddingManager.spacing400.w),
                        Flexible(
                          child: _ToastCopy(
                            title: widget.title,
                            message: widget.message,
                          ),
                        ),
                        SizedBox(width: PaddingManager.spacing400.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastLeadingIcon extends StatelessWidget {
  const _ToastLeadingIcon({required this.variant});

  final ToastVariant variant;

  @override
  Widget build(BuildContext context) => Container(
        width: 25.r,
        height: 25.r,
        decoration: DecorationManager.circleIcon(variant.color, alpha: _kIconDiscOpacity),
        alignment: Alignment.center,
        child: Icon(variant.icon, color: variant.color, size: 18),
      );
}

class _ToastCopy extends StatelessWidget {
  const _ToastCopy({required this.title, required this.message});

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return Text(
        message,
        style: getMediumTextStyle(
          fontSize: FontSizesManager.s12.sp,
          color: ColorManager.textPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: getSemiBoldTextStyle(
            fontSize: FontSizesManager.s14.sp,
            color: ColorManager.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: PaddingManager.spacing200.h),
        Text(
          message,
          style: getRegularTextStyle(
            fontSize: FontSizesManager.s13.sp,
            color: ColorManager.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
