import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontFamilyManager {
  FontFamilyManager._();
  static const String body = 'Figtree';
}

const String fontFamily = FontFamilyManager.body;

class FontWeightManager {
  FontWeightManager._();
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class FontSizesManager {
  FontSizesManager._();

  static double headerButtonHeight = 42.w;

  static const double s8 = 8;
  static const double s9 = 9; // badge label
  static const double s10 = 10; // tab labels / badges
  static const double s11 = 11; // secondary meta
  static const double s12 = 12; // meta / timestamps
  static const double s13 = 13; // meta / timestamps
  static const double s14 = 14; // secondary body
  static const double s15 = 15; // secondary body
  static const double s16 = 16; // primary body / link medium
  static const double s17 = 17; // app bar title
  static const double s18 = 18; // dialog title small
  static const double s19 = 19;
  static const double s20 = 20; // card heading
  static const double s21 = 21; // event hero (Georgia bold)
  static const double s22 = 22;
  static const double s24 = 24; // headings/xsmall
  static const double s25 = 25; // convention header
  static const double s28 = 28; // stat value large
  static const double s30 = 30; // event card headline
  static const double s32 = 32;
  static const double s34 = 34; // brand title / hero
  static const double s36 = 36;
  static const double s48 = 48;
  static const double s72 = 72;
}
