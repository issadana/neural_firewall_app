import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BorderRadiusManager {
  BorderRadiusManager._();

  static final BorderRadius radiusAll2  = BorderRadius.circular(2).r;
  static final BorderRadius radiusAll3  = BorderRadius.circular(3).r;
  static final BorderRadius radiusAll4  = BorderRadius.circular(4).r;
  static final BorderRadius radiusAll6  = BorderRadius.circular(6).r;
  static final BorderRadius radiusAll8  = BorderRadius.circular(8).r;
  static final BorderRadius radiusAll10 = BorderRadius.circular(10).r;
  static final BorderRadius radiusAll11 = BorderRadius.circular(11).r;
  static final BorderRadius radiusAll12 = BorderRadius.circular(12).r;
  static final BorderRadius radiusAll14 = BorderRadius.circular(14).r;
  static final BorderRadius radiusAll16 = BorderRadius.circular(16).r;
  static final BorderRadius radiusAll18 = BorderRadius.circular(18).r;
  static final BorderRadius radiusAll19 = BorderRadius.circular(19).r;
  static final BorderRadius radiusAll20 = BorderRadius.circular(20).r;
  static final BorderRadius radiusAll22 = BorderRadius.circular(22).r;
  static final BorderRadius radiusAll24 = BorderRadius.circular(24).r;
  static final BorderRadius radiusAll26 = BorderRadius.circular(26).r;
  static final BorderRadius radiusAll28 = BorderRadius.circular(28).r;
  static final BorderRadius radiusAll32 = BorderRadius.circular(32).r;
  static final BorderRadius radiusAll36 = BorderRadius.circular(36).r;
  static final BorderRadius radiusAll40 = BorderRadius.circular(40).r;
  static final BorderRadius radiusAll50 = BorderRadius.circular(50).r;
  static final BorderRadius radiusAll99 = BorderRadius.circular(99).r;

  /// Semantic aliases for the most common uses.
  static final BorderRadius card  = radiusAll24;
  static final BorderRadius image = radiusAll20;
  static final BorderRadius pill  = radiusAll99;
  static final BorderRadius input = radiusAll12;
  static final BorderRadius sheet = radiusAll32;

  /// Asymmetric shapes.
  static final BorderRadius leftRounded12 = const BorderRadius.only(
    topLeft: Radius.circular(12),
    bottomLeft: Radius.circular(12),
  ).r;

  static final BorderRadius topRounded24 = const BorderRadius.vertical(
    top: Radius.circular(24),
  ).r;

  /// Chat bubble shapes.
  static final BorderRadius chatBubbleUser = const BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(4),
  ).r;

  static final BorderRadius chatBubbleAi = const BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(16),
  ).r;
}
