/**
 * TrySomething Design Tokens
 * Ported from Flutter theme: app_colors.dart, spacing.dart, motion.dart
 */

// ═══════════════════════════════════════════════════
//  COLORS — Midnight Neon Palette
// ═══════════════════════════════════════════════════

export const colors = {
  // Neutrals (dark → light)
  cream: "#0A0A0F",
  warmWhite: "#141420",
  sand: "#1E1E2E",
  sandDark: "#2A2A3C",
  stone: "#363650",
  warmGray: "#6B6B80",
  driftwood: "#A0A0B8",
  espresso: "#C0C0D0",
  darkBrown: "#D8D8E8",
  nearBlack: "#F8F8FC",

  // Accent — Hot Coral (CTA)
  coral: "#FF6B6B",
  coralLight: "#FF8A8A",
  coralPale: "#2E1820",
  coralDeep: "#E55555",
  redHeart: "#FF4757",

  // Accent — Gold
  amber: "#FBBF24",
  amberLight: "#FCD34D",
  amberPale: "#2E2518",
  amberDeep: "#D4A017",

  // Accent — Electric Violet (Brand)
  indigo: "#7C3AED",
  indigoLight: "#9461F7",
  indigoPale: "#201540",
  indigoDeep: "#6025D0",

  // Supporting
  sage: "#06D6A0",
  sagePale: "#0A2A1A",
  rose: "#FB7185",
  rosePale: "#2A1018",
  sky: "#38BDF8",
  skyPale: "#0A1A2A",

  // Semantic
  success: "#06D6A0",
  warning: "#FBBF24",
  error: "#FF4757",

  // Category accents
  catCreative: "#D946EF",
  catOutdoors: "#06D6A0",
  catFitness: "#FF4757",
  catMaker: "#FBBF24",
  catMusic: "#818CF8",
  catFood: "#FB923C",
  catCollecting: "#38BDF8",
  catMind: "#7C3AED",
  catSocial: "#F472B6",
} as const;

// ═══════════════════════════════════════════════════
//  SPACING — 4px grid
// ═══════════════════════════════════════════════════

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 48,
} as const;

// ═══════════════════════════════════════════════════
//  RADII
// ═══════════════════════════════════════════════════

export const radii = {
  card: 22,
  tile: 16,
  button: 14,
  input: 12,
  small: 10,
  badge: 100,
} as const;

// ═══════════════════════════════════════════════════
//  MOTION
// ═══════════════════════════════════════════════════

export const motion = {
  // Durations (ms)
  fast: 150,
  normal: 250,
  slow: 350,
  hero: 500,
  spring: 400,
  breathing: 1800,
  cardPress: 150,
  buttonPress: 120,
  buttonRelease: 200,
  tabSwitch: 250,

  // Easing
  easeOutCubic: [0.33, 1, 0.68, 1] as const,
  easeInOutCubic: [0.65, 0, 0.35, 1] as const,

  // Scale values
  cardPressScale: 0.975,
  buttonPressScale: 0.97,
  saveBounceScale: 1.2,
  categoryPressScale: 1.12,

  // Parallax
  parallaxFactor: 0.5,
  maxParallaxOffset: 80,
} as const;

// ═══════════════════════════════════════════════════
//  Z-INDEX SCALE (per ui-ux-pro-max)
// ═══════════════════════════════════════════════════

export const zIndex = {
  content: 10,
  sticky: 20,
  overlay: 30,
  modal: 50,
} as const;

// ═══════════════════════════════════════════════════
//  CATEGORY MAP
// ═══════════════════════════════════════════════════

export type CategoryId =
  | "creative"
  | "outdoors"
  | "fitness"
  | "maker"
  | "music"
  | "food"
  | "collecting"
  | "mind"
  | "social";

export const categoryColors: Record<CategoryId, string> = {
  creative: colors.catCreative,
  outdoors: colors.catOutdoors,
  fitness: colors.catFitness,
  maker: colors.catMaker,
  music: colors.catMusic,
  food: colors.catFood,
  collecting: colors.catCollecting,
  mind: colors.catMind,
  social: colors.catSocial,
};

export const categoryLabels: Record<CategoryId, string> = {
  creative: "Creative",
  outdoors: "Outdoors",
  fitness: "Fitness",
  maker: "Maker/DIY",
  music: "Music",
  food: "Food",
  collecting: "Collecting",
  mind: "Mind",
  social: "Social",
};
