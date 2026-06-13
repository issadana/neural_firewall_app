import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaddingManager {
  PaddingManager._();
  static EdgeInsets appHorizontalPadding = const EdgeInsets.symmetric(
    horizontal: horizontal,
  ).w;
  static EdgeInsets appTotalPadding = const EdgeInsets.only(
    left: left,
    right: right,
    top: top,
    bottom: bottom,
  ).w;
  static EdgeInsets appTotalWithBackButtonPadding = const EdgeInsets.only(
    left: left,
    right: right,
    top: topWithBackButton,
    bottom: bottom,
  ).w;
  static EdgeInsets appTotalWithStepperPadding = const EdgeInsets.symmetric(
    horizontal: horizontal,
    vertical: bottom,
  ).w;
  static EdgeInsets appPaddingWithoutTop = const EdgeInsets.only(
    left: left,
    right: right,
    bottom: bottom,
  ).w;
  static EdgeInsets appPaddingWithoutBottom = const EdgeInsets.only(
    left: left,
    right: right,
    top: top,
  ).w;
  static EdgeInsets appVerticalPadding = const EdgeInsets.only(
    top: top,
    bottom: bottom,
  ).h;
  static EdgeInsets appVerticalPaddingWithBackButtonAtTheTop =
      const EdgeInsets.only(top: topWithBackButton, bottom: bottom).h;
  static EdgeInsets appVerticalPaddingWithStepper = const EdgeInsets.symmetric(
    vertical: bottom,
  ).h;
  static EdgeInsets appTopPadding = const EdgeInsets.only(top: top).h;
  static EdgeInsets appTopPaddingWithBackButton = const EdgeInsets.only(
    top: topWithBackButton,
  ).h;
  static EdgeInsets appTopPaddingWithStepper = const EdgeInsets.only(
    top: bottom,
  ).h;
  static EdgeInsets appBottomPadding = const EdgeInsets.only(bottom: bottom).h;
  static EdgeInsets appLeftPadding = const EdgeInsets.only(left: left).w;
  static EdgeInsets appRightPadding = const EdgeInsets.only(right: right).w;
  static EdgeInsets paddingAll20 = const EdgeInsets.all(20).w;
  static EdgeInsets paddingVertical20 = const EdgeInsets.symmetric(
    vertical: 20,
  ).w;
  static EdgeInsets paddingHorizontal20 = const EdgeInsets.symmetric(
    horizontal: 20,
  ).w;
  static EdgeInsets contentPaddingV12H16 = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ).w;
  static EdgeInsets contentPaddingV15H20 = const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 15,
  ).w;
  static EdgeInsets contentPaddingV7H14 = const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 7,
  ).w;
  static EdgeInsets paddingVertical4 = const EdgeInsets.symmetric(
    vertical: PaddingManager.p4,
  ).h;
  static EdgeInsets paddingVertical8 = const EdgeInsets.symmetric(
    vertical: PaddingManager.p8,
  ).h;
  static EdgeInsets paddingVertical12 = EdgeInsets.symmetric(vertical: 12).h;

  static const double left = 20;
  static const double right = 20;
  static const double bottom = 50;
  static const double top = 80;
  static const double horizontal = 20;
  static const double topWithBackButton = 60;
  static const double p16 = 16;
  static const double p15 = 15;
  static const double p14 = 14;
  static const double p12 = 12;
  static const double p20 = 20;
  static const double p24 = 24;
  static const double p30 = 30;
  static const double p40 = 40;
  static const double p4 = 4;
  static const double p8 = 8;
  static const double p2 = 2;

  // ── Figma spacing tokens (8pt grid) ──────────────────────────────────
  // Mirrors Spacing/{Non,400,800,...} variables from the NAM design file.
  static const double spacingNone = 0; // Spacing/Non
  static const double spacing200 = 4; // Spacing/200
  static const double spacing300 = 6; // Spacing/300
  static const double spacing400 = 8; // Spacing/400
  static const double spacing500 = 10; // Spacing/500
  static const double spacing600 = 12; // Spacing/600
  static const double spacing700 = 14; // Spacing/700
  static const double spacing800 = 16; // Spacing/800
  static const double spacing1000 = 20; // Spacing/1000
  static const double spacing1200 = 24; // Spacing/1200
  static const double spacing1600 = 32; // Spacing/1600
  static const double spacing2000 = 40; // Spacing/2000
  static const double spacing3200 = 64; // Spacing/3200
  static const double spacing6400 = 128; // Spacing/6400

  // Common card paddings used in the NAM design.
  static EdgeInsets card = const EdgeInsets.all(spacing1000).w; // 20
  static EdgeInsets cardHeader = const EdgeInsets.symmetric(
    horizontal: spacing1000,
    vertical: spacing800,
  ).w;
  static EdgeInsets pillButton = const EdgeInsets.symmetric(
    horizontal: spacing800,
    vertical: 10,
  ).w;
  static EdgeInsets chip = const EdgeInsets.symmetric(
    horizontal: spacing600,
    vertical: spacing400,
  ).w;

  static EdgeInsets screenListPadding = EdgeInsets.fromLTRB(
    PaddingManager.spacing1000.w,
    Platform.isIOS ? 125.h : 110.h,
    PaddingManager.spacing1000.w,
    110.h,
  );
}
