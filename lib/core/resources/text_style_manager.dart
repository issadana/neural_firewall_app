import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:flutter/material.dart';

TextStyle _getTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  String? family,
  double? height,
  double? letterSpacing,
  Color? color,
}) => TextStyle(
  fontFamily: family ?? fontFamily,
  fontWeight: fontWeight,
  fontSize: fontSize,
  color: color ?? ColorManager.textPrimary,
  height: height,
  letterSpacing: letterSpacing,
  overflow: TextOverflow.fade,
);

TextStyle getRegularTextStyle({
  required double fontSize,
  String? family,
  double? height,
  double? letterSpacing,
  Color? color,
}) => _getTextStyle(
  fontSize: fontSize,
  fontWeight: FontWeightManager.regular,
  family: family,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

TextStyle getMediumTextStyle({
  required double fontSize,
  String? family,
  double? height,
  double? letterSpacing,
  Color? color,
}) => _getTextStyle(
  fontSize: fontSize,
  fontWeight: FontWeightManager.medium,
  family: family,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

TextStyle getSemiBoldTextStyle({
  required double fontSize,
  String? family,
  double? height,
  double? letterSpacing,
  Color? color,
}) => _getTextStyle(
  fontSize: fontSize,
  fontWeight: FontWeightManager.semiBold,
  family: family,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

TextStyle getBoldTextStyle({
  required double fontSize,
  String? family,
  double? height,
  double? letterSpacing,
  Color? color,
}) => _getTextStyle(
  fontSize: fontSize,
  fontWeight: FontWeightManager.bold,
  family: family,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

/// Backwards-compat alias (old typo name).
TextStyle getMeduimTextStyle({
  required double fontSize,
  String? family,
  double? height,
  double? letterSpacing,
  Color? color,
}) => getMediumTextStyle(
  fontSize: fontSize,
  family: family,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);
