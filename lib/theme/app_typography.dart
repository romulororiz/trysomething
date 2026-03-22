import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// TrySomething — Premium Typography Scale
///
/// Disciplined 2-voice hierarchy:
///   Headings + Body:  Manrope (warm geometric humanist sans)
///   Hero moments only: Instrument Serif (editorial, cinematic)
///   Data/timer only:   IBM Plex Mono (functional, never decorative)
///
/// Serif appears in ≤5 places across the entire app:
///   splash headline, onboarding hero, match results, detail hero, paywall hero.
/// Everything else is Manrope.
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════
  //  HERO — Manrope ExtraBold (clean, smooth, impactful)
  // ═══════════════════════════════════════════════════

  /// Hero — 36pt, cinematic headlines (splash, onboarding, paywall, detail hero)
  static TextStyle get hero => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.1,
        letterSpacing: -0.8,
      );

  // ═══════════════════════════════════════════════════
  //  PRIMARY SCALE — Manrope (everything else)
  // ═══════════════════════════════════════════════════

  /// Display — 28pt, large section headers
  static TextStyle get display => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.3,
      );

  /// Title — 20pt, card titles, sub-sections, screen titles
  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Body — 15pt, standard reading text
  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
        letterSpacing: 0.1,
      );

  /// Caption — 12pt, metadata, labels, chips
  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        height: 1.4,
        letterSpacing: 0.2,
      );

  /// Button — 16pt, CTA text
  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.0,
        letterSpacing: 0.5,
      );

  /// Thing — 10pt, fine print, disclaimers
  static TextStyle get thing => GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w200,
        color: AppColors.textMuted,
        height: 1.4,
      );

  // ═══════════════════════════════════════════════════
  //  DATA — IBM Plex Mono (functional only: timer, specs)
  // ═══════════════════════════════════════════════════

  /// Data — 13pt mono, specs and cost text
  static TextStyle get data => GoogleFonts.ibmPlexMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// DataLarge — 48pt mono, session timer and big stat numbers
  static TextStyle get dataLarge => GoogleFonts.ibmPlexMono(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  // ═══════════════════════════════════════════════════
  //  LEGACY ALIASES — all redirected to Manrope
  //  These prevent breaking existing screen references.
  //  All serif aliases now point to Manrope equivalents
  //  EXCEPT serifDisplay/serifHero which stay as hero.
  // ═══════════════════════════════════════════════════

  // Serif aliases — hero stays Instrument Serif, rest → Manrope
  static TextStyle get serifDisplay => hero; // 36pt Instrument Serif
  static TextStyle get serifHero => hero; // 36pt Instrument Serif
  static TextStyle get serifTitle => display; // 28pt Manrope (was serif)
  static TextStyle get serifHeading => title.copyWith(fontSize: 24); // Manrope
  static TextStyle get serifSubheading => title; // 20pt Manrope
  static TextStyle get serifCardTitle => display; // 28pt Manrope

  // Sans aliases — all Manrope now (were DM Sans)
  static TextStyle get sansSection => GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get sansBody => body;

  static TextStyle get sansBodySmall => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get sansBodySmallThinItalic => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        height: 1.5,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get sansBodySmallItalic => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get sansLabel => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get sansCaption => caption;

  static TextStyle get sansTiny => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get sansNav => GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get sansCta => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.textPrimary,
      );

  static TextStyle get sansCtaSecondary => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
      );

  static TextStyle get sansButton => button;

  // Overline
  static TextStyle get overline => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get categoryLabel => overline;

  // Mono aliases — IBM Plex Mono, kept for functional use only
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
