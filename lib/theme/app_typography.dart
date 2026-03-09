import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// TrySomething — Cinematic Typography Scale
///
/// Dramatic hierarchy: hero (36pt) → caption (12pt) = 3x ratio.
/// Headings: Source Serif 4 (warm editorial)
/// Body:     DM Sans (clean geometric sans)
/// Data:     IBM Plex Mono (stats, specs, numbers)
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════
  //  NEW SEMANTIC SCALE — Warm Cinematic Minimalism
  // ═══════════════════════════════════════════════════

  /// Hero — 36pt, cinematic screen headlines
  static TextStyle get hero => GoogleFonts.sourceSerif4(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -0.5,
      );

  /// Display — 28pt, section titles and emphasis
  static TextStyle get display => GoogleFonts.sourceSerif4(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.3,
      );

  /// Title — 20pt, card titles and sub-sections
  static TextStyle get title => GoogleFonts.sourceSerif4(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Body — 15pt, standard reading text
  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
        letterSpacing: 0.1,
      );

  /// Caption — 12pt, metadata and labels
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.4,
        letterSpacing: 0.3,
      );

  /// Data — 13pt mono, specs and badges as warm gray text
  static TextStyle get data => GoogleFonts.ibmPlexMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// DataLarge — 48pt mono, big stat numbers
  static TextStyle get dataLarge => GoogleFonts.ibmPlexMono(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  /// Button — 16pt, CTA text (dark on coral)
  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.background,
        height: 1.0,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════
  //  LEGACY NAMES — mapped to cinematic scale
  //  Kept to avoid breaking existing references.
  // ═══════════════════════════════════════════════════

  // Serif headings — remapped to cinematic sizes
  static TextStyle get serifDisplay => hero; // 36pt (was 38pt)

  static TextStyle get serifHero => hero; // 36pt

  static TextStyle get serifTitle => display; // 28pt (was 32pt)

  static TextStyle get serifHeading => GoogleFonts.sourceSerif4(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get serifSubheading => title; // 20pt (was 22pt)

  static TextStyle get serifCardTitle => display.copyWith(
        color: AppColors.textPrimary,
      );

  // Sans body — remapped with warm colors
  static TextStyle get sansSection => GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get sansBody => body;

  static TextStyle get sansBodySmall => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get sansLabel => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get sansCaption => caption;

  static TextStyle get sansTiny => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
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
        color: AppColors.textPrimary,
      );

  static TextStyle get sansCtaSecondary => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
      );

  static TextStyle get sansButton => button;

  // Overline
  static TextStyle get overline => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get categoryLabel => overline;

  // Mono — remapped with warm colors, no more coral tints
  static TextStyle get monoTimer => dataLarge;

  static TextStyle get monoLarge => GoogleFonts.ibmPlexMono(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoMedium => GoogleFonts.ibmPlexMono(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoBadge => data.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get monoBadgeSmall => data.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get monoCaption => GoogleFonts.ibmPlexMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get monoTiny => data.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get monoMilestone => data.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      );
}
