import 'dart:ui';

/// TrySomething — Midnight Neon Color Palette
///
/// Dark-mode first. Bold, vibrant, premium.
/// Brand identity: Electric violet — energy, creativity, depth.
/// Primary action: Hot coral — the "try this" spark.
/// Highlights: Gold — milestones, streaks, achievement.
/// Success: Mint cyan — progress, completion, growth.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════
  //  BASE / NEUTRALS (dark scale, lightest = text)
  // ═══════════════════════════════════════════════════
  static const Color cream = Color(0xFF0A0A0F);
  static const Color warmWhite = Color(0xFF141420);
  static const Color sand = Color(0xFF1E1E2E);
  static const Color sandDark = Color(0xFF2A2A3C);
  static const Color stone = Color(0xFF363650);
  static const Color warmGray = Color(0xFF6B6B80);
  static const Color driftwood = Color(0xFFA0A0B8);
  static const Color espresso = Color(0xFFC0C0D0);
  static const Color darkBrown = Color(0xFFD8D8E8);
  static const Color nearBlack = Color(0xFFF8F8FC);

  // ═══════════════════════════════════════════════════
  //  ACCENT — HOT CORAL (Primary Action / CTA)
  // ═══════════════════════════════════════════════════
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralLight = Color(0xFFFF8A8A);
  static const Color coralPale = Color(0xFF2E1820);
  static const Color coralDeep = Color(0xFFE55555);
  static const Color redHeart = Color(0xFFFF4757);

  // ═══════════════════════════════════════════════════
  //  ACCENT — GOLD (Secondary / Highlight)
  // ═══════════════════════════════════════════════════
  static const Color amber = Color(0xFFFBBF24);
  static const Color amberLight = Color(0xFFFCD34D);
  static const Color amberPale = Color(0xFF2E2518);
  static const Color amberDeep = Color(0xFFD4A017);

  // ═══════════════════════════════════════════════════
  //  ACCENT — ELECTRIC VIOLET (Brand / Depth)
  // ═══════════════════════════════════════════════════
  static const Color indigo = Color(0xFF7C3AED);
  static const Color indigoLight = Color(0xFF9461F7);
  static const Color indigoPale = Color(0xFF201540);
  static const Color indigoDeep = Color(0xFF6025D0);

  // ═══════════════════════════════════════════════════
  //  SUPPORTING
  // ═══════════════════════════════════════════════════
  static const Color sage = Color(0xFF06D6A0);
  static const Color sagePale = Color(0xFF0A2A1A);
  static const Color rose = Color(0xFFFB7185);
  static const Color rosePale = Color(0xFF2A1018);
  static const Color sky = Color(0xFF38BDF8);
  static const Color skyPale = Color(0xFF0A1A2A);

  // ═══════════════════════════════════════════════════
  //  SEMANTIC
  // ═══════════════════════════════════════════════════
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFFF4757);

  // ═══════════════════════════════════════════════════
  //  CATEGORY ACCENTS (vibrant on dark)
  // ═══════════════════════════════════════════════════
  static const Color catCreative = Color(0xFFD946EF);
  static const Color catOutdoors = Color(0xFF06D6A0);
  static const Color catFitness = Color(0xFFFF4757);
  static const Color catMaker = Color(0xFFFBBF24);
  static const Color catMusic = Color(0xFF818CF8);
  static const Color catFood = Color(0xFFFB923C);
  static const Color catCollecting = Color(0xFF38BDF8);
  static const Color catMind = Color(0xFF7C3AED);
  static const Color catSocial = Color(0xFFF472B6);

  // ═══════════════════════════════════════════════════
  //  BADGE-SPECIFIC BORDERS (dark tints)
  // ═══════════════════════════════════════════════════
  static const Color costBorder = Color(0xFF3D1E1E);
  static const Color timeBorder = Color(0xFF3D3515);
  static const Color diffBorder = Color(0xFF153D30);

  /// Returns category color by category ID string.
  static Color categoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'creative':
        return catCreative;
      case 'outdoors':
        return catOutdoors;
      case 'fitness':
        return catFitness;
      case 'maker':
      case 'maker/diy':
        return catMaker;
      case 'music':
        return catMusic;
      case 'food':
        return catFood;
      case 'collecting':
        return catCollecting;
      case 'mind':
        return catMind;
      case 'social':
        return catSocial;
      default:
        return warmGray;
    }
  }
}
