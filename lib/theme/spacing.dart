import 'package:flutter/material.dart';

/// TrySomething — Spacing & Design Tokens
///
/// 4px grid system. Every spacing value derives from multiples of 4.
class Spacing {
  Spacing._();

  // ═══════════════════════════════════════════════════
  //  SPACING (4px grid)
  // ═══════════════════════════════════════════════════
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ═══════════════════════════════════════════════════
  //  BORDER RADII
  // ═══════════════════════════════════════════════════
  static const double radiusCard = 22;
  static const double radiusTile = 16;
  static const double radiusButton = 14;
  static const double radiusInput = 12;
  static const double radiusSmall = 10;
  static const double radiusBadge = 100; // pill
  static const double radiusMilestone = 100;

  static const BorderRadius cardBorderRadius =
      BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius tileBorderRadius =
      BorderRadius.all(Radius.circular(radiusTile));
  static const BorderRadius buttonBorderRadius =
      BorderRadius.all(Radius.circular(radiusButton));
  static const BorderRadius inputBorderRadius =
      BorderRadius.all(Radius.circular(radiusInput));
  static const BorderRadius badgeBorderRadius =
      BorderRadius.all(Radius.circular(radiusBadge));

  // ═══════════════════════════════════════════════════
  //  SIZES
  // ═══════════════════════════════════════════════════
  static const double cardHeight = 480;
  static const double heroHeight = 350;
  static const double bottomNavHeight = 82;
  static const double buttonPrimaryHeight = 54;
  static const double buttonSecondaryHeight = 46;
  static const double searchBarHeight = 46;
  static const double iconButtonSize = 40;
  static const double iconButtonSizeLg = 46;
  static const double checkboxSize = 28;
  static const double checkboxSizeSm = 32;
  static const double categoryIconSize = 50;
  static const double thumbnailSize = 50;

  // ═══════════════════════════════════════════════════
  //  SHADOWS
  // ═══════════════════════════════════════════════════
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> specBarShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════
  //  GRADIENTS
  // ═══════════════════════════════════════════════════
  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000A0A0F), // transparent
      Color(0x660A0A0F), // 0.4 at 55%
      Color(0xEB0A0A0F), // 0.92 at 100%
    ],
    stops: [0.3, 0.55, 1.0],
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000A0A0F), // cream transparent
      Color(0xB30A0A0F), // cream @ 0.7
      Color(0xFF0A0A0F), // cream solid
    ],
    stops: [0.25, 0.65, 1.0],
  );

  static const LinearGradient ctaFadeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000A0A0F),
      Color(0xFF0A0A0F),
    ],
    stops: [0.0, 0.3],
  );

  // ═══════════════════════════════════════════════════
  //  PAGE PADDING HELPERS
  // ═══════════════════════════════════════════════════
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets screenPaddingTop = EdgeInsets.only(top: 52);
  static const EdgeInsets screenPaddingBottom = EdgeInsets.only(bottom: 82);
}
