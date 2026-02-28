import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// TrySomething — ThemeData (Midnight Neon dark mode)
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.coral,
        onPrimary: Colors.white,
        secondary: AppColors.amber,
        onSecondary: Colors.white,
        tertiary: AppColors.indigo,
        onTertiary: Colors.white,
        surface: AppColors.warmWhite,
        onSurface: AppColors.nearBlack,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.sandDark,
        surfaceContainerHighest: AppColors.sand,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.sourceSerif4(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          height: 1.12,
          color: AppColors.nearBlack,
        ),
        displayMedium: GoogleFonts.sourceSerif4(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.1,
          color: AppColors.nearBlack,
        ),
        displaySmall: GoogleFonts.sourceSerif4(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.nearBlack,
        ),
        headlineLarge: GoogleFonts.sourceSerif4(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.05,
          color: AppColors.nearBlack,
        ),
        headlineMedium: GoogleFonts.sourceSerif4(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.nearBlack,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.nearBlack,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.nearBlack,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.65,
          color: AppColors.nearBlack,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.driftwood,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.driftwood,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.coral,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          color: AppColors.warmGray,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.nearBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.sourceSerif4(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.nearBlack,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.warmWhite,
        selectedItemColor: AppColors.coral,
        unselectedItemColor: AppColors.warmGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.warmWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.coral,
          minimumSize: const Size(double.infinity, 46),
          side: BorderSide.none,
          backgroundColor: AppColors.sand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.warmGray,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.coral,
        inactiveTrackColor: AppColors.sandDark,
        thumbColor: AppColors.coral,
        overlayColor: AppColors.coral.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
      dividerColor: AppColors.sandDark,
      splashColor: AppColors.coral.withValues(alpha: 0.08),
      highlightColor: AppColors.coral.withValues(alpha: 0.04),
    );
  }
}
