import 'dart:ui';

/// TrySomething — Warm Cinematic Minimalism Palette
///
/// Black + warm cream + ONE coral accent for CTAs only.
/// Inspired by DoReset, Kinfolk, Headspace.
/// Typography and labels differentiate categories — not color.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════
  //  BACKGROUNDS
  // ═══════════════════════════════════════════════════
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF111116);
  static const Color surfaceElevated = Color(0xFF1A1A20);

  // ═══════════════════════════════════════════════════
  //  TEXT — WARM, not pure white
  // ═══════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFF5F0EB);     // Warm cream
  static const Color textSecondary = Color(0xFFB0A89E);    // Warm gray
  static const Color textMuted = Color(0xFF6B6360);        // Warm dark gray
  static const Color textWhisper = Color(0xFF3D3835);      // Barely visible

  // ═══════════════════════════════════════════════════
  //  ACCENT — Coral for CTAs ONLY
  // ═══════════════════════════════════════════════════
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentMuted = Color(0x33FF6B6B);      // Coral at 20%

  // ═══════════════════════════════════════════════════
  //  SUCCESS — sparingly for completed states
  // ═══════════════════════════════════════════════════
  static const Color success = Color(0xFF06D6A0);
  static const Color successMuted = Color(0x3306D6A0);

  // ═══════════════════════════════════════════════════
  //  BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════
  static const Color border = Color(0xFF1E1E24);
  static const Color borderLight = Color(0x331E1E24);

  // ═══════════════════════════════════════════════════
  //  GLASS / OVERLAY
  // ═══════════════════════════════════════════════════
  static const Color glassBackground = Color(0x15FFFFFF);  // White at 8%
  static const Color glassBorder = Color(0x20FFFFFF);      // White at 12%

  // ═══════════════════════════════════════════════════
  //  SEMANTIC
  // ═══════════════════════════════════════════════════
  static const Color warning = Color(0xFFB0A89E);
  static const Color error = Color(0xFFFF6B6B);

  // ═══════════════════════════════════════════════════
  //  LEGACY NAMES — mapped to warm cinematic palette
  //  Kept to avoid breaking existing references.
  //  Migrate to semantic names above over time.
  // ═══════════════════════════════════════════════════

  // Neutrals (old cool blue-gray → new warm brown-gray)
  static const Color cream = background;           // 0xFF0A0A0F — darkest
  static const Color warmWhite = surface;           // 0xFF111116
  static const Color sand = surfaceElevated;        // 0xFF1A1A20
  static const Color sandDark = Color(0xFF242420);  // Slightly lighter surface
  static const Color stone = textWhisper;           // 0xFF3D3835
  static const Color warmGray = textMuted;          // 0xFF6B6360
  static const Color driftwood = textSecondary;     // 0xFFB0A89E
  static const Color espresso = textSecondary;      // 0xFFB0A89E
  static const Color darkBrown = textPrimary;       // 0xFFF5F0EB
  static const Color nearBlack = textPrimary;       // 0xFFF5F0EB — lightest

  // Coral accent (unchanged)
  static const Color coral = accent;                // 0xFFFF6B6B
  static const Color coralLight = Color(0xFFFF8A8A);
  static const Color coralPale = Color(0xFF1E1512); // Warm dark tint
  static const Color coralDeep = Color(0xFFE55555);
  static const Color redHeart = accent;

  // Amber → neutralized to warm gray (no more gold highlights)
  static const Color amber = textMuted;
  static const Color amberLight = textMuted;
  static const Color amberPale = surfaceElevated;
  static const Color amberDeep = textMuted;

  // Indigo → neutralized to warm gray (no more purple accents)
  static const Color indigo = textMuted;
  static const Color indigoLight = textMuted;
  static const Color indigoPale = surfaceElevated;
  static const Color indigoDeep = textMuted;

  // Supporting → neutralized
  static const Color sage = success;
  static const Color sagePale = Color(0xFF0A1A14);
  static const Color rose = textMuted;
  static const Color rosePale = surfaceElevated;
  static const Color sky = textMuted;
  static const Color skyPale = surfaceElevated;

  // Category accents → ALL neutralized to warm gray
  static const Color catCreative = textMuted;
  static const Color catOutdoors = textMuted;
  static const Color catFitness = textMuted;
  static const Color catMaker = textMuted;
  static const Color catMusic = textMuted;
  static const Color catFood = textMuted;
  static const Color catCollecting = textMuted;
  static const Color catMind = textMuted;
  static const Color catSocial = textMuted;

  // Badge borders → unified to single border color
  static const Color costBorder = border;
  static const Color timeBorder = border;
  static const Color diffBorder = border;

  /// Returns category color — now always warm gray (no color differentiation).
  static Color categoryColor(String categoryId) => textMuted;
}
