import 'dart:ui';

/// TrySomething — Sunset Analog Color Palette
///
/// Light-mode first. Warm, editorial, magazine-quality.
/// Primary action: Warm coral — the "try this" energy.
/// Highlights: Golden amber — milestones, streaks, warmth.
/// Depth: Soft indigo — sophistication without coldness.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════
  //  BASE / NEUTRALS
  // ═══════════════════════════════════════════════════
  static const Color cream = Color(0xFFFFF9F5);
  static const Color warmWhite = Color(0xFFFFFDFB);
  static const Color sand = Color(0xFFF5EDE6);
  static const Color sandDark = Color(0xFFE8DDD3);
  static const Color stone = Color(0xFFD4C8BC);
  static const Color warmGray = Color(0xFFA89B8E);
  static const Color driftwood = Color(0xFF7A6E62);
  static const Color espresso = Color(0xFF524840);
  static const Color darkBrown = Color(0xFF3A322C);
  static const Color nearBlack = Color(0xFF1E1A17);

  // ═══════════════════════════════════════════════════
  //  ACCENT — WARM CORAL (Primary Action)
  // ═══════════════════════════════════════════════════
  static const Color coral = Color(0xFFE8734A);
  static const Color coralLight = Color(0xFFF0956E);
  static const Color coralPale = Color(0xFFFFF0EB);
  static const Color coralDeep = Color(0xFFD45E35);
  static const Color redHeart = Color.fromARGB(255, 255, 34, 0);

  // ═══════════════════════════════════════════════════
  //  ACCENT — GOLDEN AMBER (Secondary / Highlight)
  // ═══════════════════════════════════════════════════
  static const Color amber = Color(0xFFE5A630);
  static const Color amberLight = Color(0xFFF0C060);
  static const Color amberPale = Color(0xFFFFF8E8);
  static const Color amberDeep = Color(0xFFC48B1A);

  // ═══════════════════════════════════════════════════
  //  ACCENT — SOFT INDIGO (Depth / Sophistication)
  // ═══════════════════════════════════════════════════
  static const Color indigo = Color(0xFF5B6AAF);
  static const Color indigoLight = Color(0xFF7B88C4);
  static const Color indigoPale = Color(0xFFECEEF7);
  static const Color indigoDeep = Color(0xFF444F8A);

  // ═══════════════════════════════════════════════════
  //  SUPPORTING
  // ═══════════════════════════════════════════════════
  static const Color sage = Color(0xFF7EA47E);
  static const Color sagePale = Color(0xFFEDF4ED);
  static const Color rose = Color(0xFFC47878);
  static const Color rosePale = Color(0xFFF7EDED);
  static const Color sky = Color(0xFF6AA8C4);
  static const Color skyPale = Color(0xFFEAF3F8);

  // ═══════════════════════════════════════════════════
  //  SEMANTIC
  // ═══════════════════════════════════════════════════
  static const Color success = Color(0xFF5EA87E);
  static const Color warning = Color(0xFFE5A630);
  static const Color error = Color(0xFFC45858);

  // ═══════════════════════════════════════════════════
  //  CATEGORY ACCENTS
  // ═══════════════════════════════════════════════════
  static const Color catCreative = Color(0xFFC47878);
  static const Color catOutdoors = Color(0xFF7EA47E);
  static const Color catFitness = Color(0xFFE8734A);
  static const Color catMaker = Color(0xFFE5A630);
  static const Color catMusic = Color(0xFF5B6AAF);
  static const Color catFood = Color(0xFFC48B1A);
  static const Color catCollecting = Color(0xFF6AA8C4);
  static const Color catMind = Color(0xFF5B6AAF);
  static const Color catSocial = Color(0xFFE8734A);

  // ═══════════════════════════════════════════════════
  //  BADGE-SPECIFIC BORDERS
  // ═══════════════════════════════════════════════════
  static const Color costBorder = Color(0xFFF0D0C4);
  static const Color timeBorder = Color(0xFFF0E0B0);
  static const Color diffBorder = Color(0xFFCCD0E4);

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
