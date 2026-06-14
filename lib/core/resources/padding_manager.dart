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
  static const double p1 = 1;
  static const double p3 = 3;
  static const double p5 = 5;
  static const double p6 = 6;
  static const double p7 = 7;
  static const double p9 = 9;
  static const double p10 = 10;
  static const double p18 = 18;
  static const double p26 = 26;
  static const double p28 = 28;
  static const double p32 = 32;
  static const double p48 = 48;
  static const double p80 = 80;

  // ── Symmetric horizontal paddings ────────────────────────────────────
  static EdgeInsets paddingHorizontal2 =
      const EdgeInsets.symmetric(horizontal: 2).w;
  static EdgeInsets paddingHorizontal5 =
      const EdgeInsets.symmetric(horizontal: 5).w;
  static EdgeInsets paddingHorizontal8 =
      const EdgeInsets.symmetric(horizontal: 8).w;
  static EdgeInsets paddingHorizontal12 =
      const EdgeInsets.symmetric(horizontal: 12).w;
  static EdgeInsets paddingHorizontal14 =
      const EdgeInsets.symmetric(horizontal: 14).w;
  static EdgeInsets paddingHorizontal16 =
      const EdgeInsets.symmetric(horizontal: 16).w;
  static EdgeInsets paddingHorizontal24 =
      const EdgeInsets.symmetric(horizontal: 24).w;

  // ── Symmetric vertical paddings ──────────────────────────────────────
  static EdgeInsets paddingVertical5 =
      const EdgeInsets.symmetric(vertical: 5).h;
  static EdgeInsets paddingVertical16 =
      const EdgeInsets.symmetric(vertical: 16).h;
  static EdgeInsets paddingVertical40 =
      const EdgeInsets.symmetric(vertical: 40).h;

  // ── All-side paddings ────────────────────────────────────────────────
  static EdgeInsets paddingAll3p5 = const EdgeInsets.all(3.5).w;
  static EdgeInsets paddingAll6 = const EdgeInsets.all(6).w;
  static EdgeInsets paddingAll12 = const EdgeInsets.all(12).w;
  static EdgeInsets paddingAll16 = const EdgeInsets.all(16).w;
  static EdgeInsets paddingAll24 = const EdgeInsets.all(24).w;
  static EdgeInsets paddingAll28 = const EdgeInsets.all(28).w;

  // ── Symmetric horizontal + vertical paddings ─────────────────────────
  static EdgeInsets paddingH6V1 =
      const EdgeInsets.symmetric(horizontal: 6, vertical: 1).w;
  static EdgeInsets paddingH7V2 =
      const EdgeInsets.symmetric(horizontal: 7, vertical: 2).w;
  static EdgeInsets paddingH8V2 =
      const EdgeInsets.symmetric(horizontal: 8, vertical: 2).w;
  static EdgeInsets paddingH8V3 =
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3).w;
  static EdgeInsets paddingH12V3 =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 3).w;
  static EdgeInsets paddingH16V3 =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 3).w;
  static EdgeInsets paddingH8V8 =
      const EdgeInsets.symmetric(horizontal: 8, vertical: 8).w;
  static EdgeInsets paddingH8V14 =
      const EdgeInsets.symmetric(horizontal: 8, vertical: 14).w;
  static EdgeInsets paddingH10V3 =
      const EdgeInsets.symmetric(horizontal: 10, vertical: 3).w;
  static EdgeInsets paddingH10V4 =
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4).w;
  static EdgeInsets paddingH10V6 =
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6).w;
  static EdgeInsets paddingH12V6 =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6).w;
  static EdgeInsets paddingH12V7 =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 7).w;
  static EdgeInsets paddingH12V9 =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 9).w;
  static EdgeInsets paddingH14V6 =
      const EdgeInsets.symmetric(horizontal: 14, vertical: 6).w;
  static EdgeInsets paddingH14V7 =
      const EdgeInsets.symmetric(horizontal: 14, vertical: 7).w;
  static EdgeInsets paddingH14V10 =
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10).w;
  static EdgeInsets paddingH16V4 =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4).w;
  static EdgeInsets paddingH16V5 =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 5).w;
  static EdgeInsets paddingH16V8 =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8).w;
  static EdgeInsets paddingH16V12 =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12).w;
  static EdgeInsets paddingH18V16 =
      const EdgeInsets.symmetric(horizontal: 18, vertical: 16).w;

  // ── fromLTRB paddings ────────────────────────────────────────────────
  static EdgeInsets paddingLTRB16_8_16_4 =
      EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h);
  static EdgeInsets paddingLTRB16_0_16_12 =
      EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h);
  static EdgeInsets paddingLTRB16_12_12_8 =
      EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 8.h);
  static EdgeInsets paddingLTRB20_12_20_32 =
      EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h);
  static EdgeInsets paddingLTRB16_16_16_8 =
      EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h);
  static EdgeInsets paddingLTRB16_20_16_8 =
      EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h);
  static EdgeInsets paddingLTRB16_4_16_8 =
      EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h);
  static EdgeInsets paddingLTRB16_8_16_8 =
      EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h);
  static EdgeInsets paddingLTRB16_14_16_10 =
      EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h);

  // ── Single / multi-edge paddings ─────────────────────────────────────
  static EdgeInsets paddingTop4 = const EdgeInsets.only(top: 4).h;
  static EdgeInsets paddingTop4Bottom16 =
      const EdgeInsets.only(top: 4, bottom: 16).h;
  static EdgeInsets paddingTop4Bottom24 =
      const EdgeInsets.only(top: 4, bottom: 24).h;
  static EdgeInsets paddingBottom32 = const EdgeInsets.only(bottom: 32).h;
  static EdgeInsets paddingRight8 = const EdgeInsets.only(right: 8).w;
  static EdgeInsets paddingRight24 = const EdgeInsets.only(right: 24).w;
  static EdgeInsets bubbleMargin =
      EdgeInsets.only(top: 4.h, bottom: 4.h, left: 16.w, right: 48.w);

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
