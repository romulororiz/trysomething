import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// TrySomething — Type Scale
///
/// Headings: Source Serif 4 (warm editorial)
/// Body:     DM Sans (clean geometric sans)
/// Numbers:  IBM Plex Mono (friendly data density)
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════
  //  SERIF — Source Serif 4 (Headings)
  // ═══════════════════════════════════════════════════

  static TextStyle get serifDisplay => GoogleFonts.sourceSerif4(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.3,
        color: AppColors.nearBlack,
      );

  static TextStyle get serifHero => GoogleFonts.sourceSerif4(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.05,
        color: AppColors.nearBlack,
      );

  static TextStyle get serifTitle => GoogleFonts.sourceSerif4(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: AppColors.nearBlack,
      );

  static TextStyle get serifHeading => GoogleFonts.sourceSerif4(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.nearBlack,
      );

  static TextStyle get serifSubheading => GoogleFonts.sourceSerif4(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.nearBlack,
      );

  static TextStyle get serifCardTitle => GoogleFonts.sourceSerif4(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Colors.white,
      );

  // ═══════════════════════════════════════════════════
  //  SANS — DM Sans (Body)
  // ═══════════════════════════════════════════════════

  static TextStyle get sansSection => GoogleFonts.dmSans(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.nearBlack,
      );

  static TextStyle get sansBody => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: AppColors.nearBlack,
      );

  static TextStyle get sansBodySmall => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.driftwood,
      );

  static TextStyle get sansLabel => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.nearBlack,
      );

  static TextStyle get sansCaption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.driftwood,
      );

  static TextStyle get sansTiny => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.warmGray,
      );

  static TextStyle get sansNav => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get sansCta => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Colors.white,
      );

  static TextStyle get sansCtaSecondary => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.coral,
      );

  static TextStyle get sansButton => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.nearBlack,
      );

  // ═══════════════════════════════════════════════════
  //  OVERLINE
  // ═══════════════════════════════════════════════════

  static TextStyle get overline => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.warmGray,
      );

  static TextStyle get categoryLabel => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.nearBlack,
      );

  // ═══════════════════════════════════════════════════
  //  MONO — IBM Plex Mono (Numbers / Specs)
  // ═══════════════════════════════════════════════════

  static TextStyle get monoTimer => GoogleFonts.ibmPlexMono(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: AppColors.coral,
      );

  static TextStyle get monoLarge => GoogleFonts.ibmPlexMono(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.coral,
      );

  static TextStyle get monoMedium => GoogleFonts.ibmPlexMono(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.coral,
      );

  static TextStyle get monoBadge => GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get monoBadgeSmall => GoogleFonts.ibmPlexMono(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get monoCaption => GoogleFonts.ibmPlexMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.warmGray,
      );

  static TextStyle get monoTiny => GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get monoMilestone => GoogleFonts.ibmPlexMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      );
}
