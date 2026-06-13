import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Sentri/core/resources/border_radius_manager.dart';
import 'package:Sentri/core/resources/color_manager.dart';
import 'package:Sentri/core/resources/font_manager.dart';
import 'package:Sentri/core/resources/padding_manager.dart';
import 'package:Sentri/core/resources/text_style_manager.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: ColorManager.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary:     AppColors.primary,
        secondary:   AppColors.accent,
        surface:     ColorManager.darkSurface,
        onPrimary:   ColorManager.white,
        onSecondary: ColorManager.white,
        onSurface:   ColorManager.white,
        error:       AppColors.statusDanger,
        onError:     ColorManager.white,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor:    ColorManager.white,
        displayColor: ColorManager.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.darkBackground,
        foregroundColor: ColorManager.white,
        elevation: 0,
        surfaceTintColor: ColorManager.transparent,
        shadowColor:      ColorManager.transparent,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor:         ColorManager.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness:     Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          color:       ColorManager.white,
          fontSize:    FontSizesManager.s17,
          fontWeight:  FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color:       ColorManager.darkSurface,
        elevation:   0,
        shadowColor: ColorManager.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusManager.radiusAll20,
          side: const BorderSide(color: ColorManager.darkBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: ColorManager.white,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: FontSizesManager.s16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: FontSizesManager.s14, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: ColorManager.darkSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: ColorManager.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: ColorManager.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: AppColors.statusDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: AppColors.statusDanger, width: 1.5),
        ),
        labelStyle: getRegularTextStyle(fontSize: FontSizesManager.s14, color: ColorManager.darkTextMuted),
        hintStyle:  getRegularTextStyle(fontSize: FontSizesManager.s14, color: ColorManager.darkTextDisabled),
        contentPadding:  EdgeInsets.all(PaddingManager.spacing800),
        prefixIconColor: ColorManager.darkTextDisabled,
        suffixIconColor: ColorManager.darkTextMuted,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     ColorManager.darkSurface,
        selectedItemColor:   AppColors.primary,
        unselectedItemColor: ColorManager.darkTextDisabled,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: ColorManager.darkSurfaceElev,
        surfaceTintColor: ColorManager.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusManager.radiusAll24,
          side: const BorderSide(color: ColorManager.darkBorder, width: 0.5),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return ColorManager.darkTextDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.35);
          }
          return ColorManager.darkBorder;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor:   AppColors.primary,
        inactiveTrackColor: ColorManager.darkBorder,
        thumbColor:         AppColors.primary,
        overlayColor:       AppColors.primary.withValues(alpha: 0.15),
        trackHeight: 3,
      ),

      dividerTheme: const DividerThemeData(
        color:     ColorManager.darkBorder,
        thickness: 0.5,
      ),

      listTileTheme: const ListTileThemeData(
        tileColor:  ColorManager.transparent,
        textColor:  ColorManager.white,
        iconColor:  ColorManager.darkTextSecondary,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: ColorManager.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorManager.darkSurfaceElev,
        contentTextStyle: GoogleFonts.inter(color: ColorManager.white, fontSize: FontSizesManager.s14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusManager.radiusAll12),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      extensions: [AppThemeColors.dark()],
    );
  }

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: ColorManager.lightBackground,

      colorScheme: const ColorScheme.light(
        primary:     AppColors.primary,
        secondary:   AppColors.navy,
        surface:     ColorManager.lightSurface,
        onPrimary:   ColorManager.white,
        onSecondary: ColorManager.white,
        onSurface:   ColorManager.lightTextPrimary,
        error:       AppColors.statusDanger,
        onError:     ColorManager.white,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor:    ColorManager.lightTextPrimary,
        displayColor: ColorManager.lightTextPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.lightBackground,
        foregroundColor: ColorManager.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: ColorManager.transparent,
        shadowColor:      ColorManager.transparent,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor:          ColorManager.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness:     Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          color:        ColorManager.lightTextPrimary,
          fontSize:     FontSizesManager.s17,
          fontWeight:   FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color:       ColorManager.lightSurface,
        elevation:   0,
        shadowColor: ColorManager.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusManager.radiusAll20,
          side: const BorderSide(color: ColorManager.lightBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: ColorManager.white,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: FontSizesManager.s16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: FontSizesManager.s14, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: ColorManager.lightSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: ColorManager.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: ColorManager.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: AppColors.statusDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadiusManager.radiusAll12,
          borderSide: const BorderSide(color: AppColors.statusDanger, width: 1.5),
        ),
        labelStyle: getRegularTextStyle(fontSize: FontSizesManager.s14, color: ColorManager.lightTextMuted),
        hintStyle:  getRegularTextStyle(fontSize: FontSizesManager.s14, color: ColorManager.lightTextDisabled),
        contentPadding:  EdgeInsets.all(PaddingManager.spacing800),
        prefixIconColor: ColorManager.lightTextDisabled,
        suffixIconColor: ColorManager.lightTextMuted,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     ColorManager.lightSurface,
        selectedItemColor:   AppColors.primary,
        unselectedItemColor: ColorManager.lightTextDisabled,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor:  ColorManager.lightSurface,
        surfaceTintColor: ColorManager.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusManager.radiusAll24,
          side: const BorderSide(color: ColorManager.lightBorder, width: 0.5),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return ColorManager.lightTextDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.35);
          }
          return ColorManager.lightBorder;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor:   AppColors.primary,
        inactiveTrackColor: ColorManager.lightBorder,
        thumbColor:         AppColors.primary,
        overlayColor:       AppColors.primary.withValues(alpha: 0.15),
        trackHeight: 3,
      ),

      dividerTheme: const DividerThemeData(
        color:     ColorManager.lightBorder,
        thickness: 0.5,
      ),

      listTileTheme: const ListTileThemeData(
        tileColor:  ColorManager.transparent,
        textColor:  ColorManager.lightTextPrimary,
        iconColor:  ColorManager.lightTextSecondary,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: ColorManager.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorManager.lightSurface,
        contentTextStyle: GoogleFonts.inter(color: ColorManager.lightTextPrimary, fontSize: FontSizesManager.s14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusManager.radiusAll12),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      extensions: [AppThemeColors.light()],
    );
  }
}
