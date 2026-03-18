/**
 * TrySomething — Design Tokens (v2: Warm Cinematic Minimalism)
 * Premium dark base with teal/burgundy atmospheric bloom
 */

export const colors = {
  // Core surfaces
  bg: "#050508",
  surface: "#0C0C12",
  surfaceElevated: "#14141A",
  surfaceBright: "#1C1C24",

  // Text hierarchy
  textPrimary: "#F0EBE3",
  textSecondary: "#A09890",
  textMuted: "#5C5550",
  textWhisper: "#3D3835",

  // Accent — Coral (CTAs only)
  coral: "#FF6B6B",
  coralHover: "#FF8585",
  coralMuted: "rgba(255, 107, 107, 0.15)",
  coralGlow: "rgba(255, 107, 107, 0.4)",

  // Atmospheric bloom (environmental only, never UI)
  bloomTeal: "#0D9488",
  bloomTealMuted: "rgba(13, 148, 136, 0.15)",
  bloomBurgundy: "#9F1239",
  bloomBurgundyMuted: "rgba(159, 18, 57, 0.12)",

  // Glass
  glass: "rgba(255, 255, 255, 0.06)",
  glassBorder: "rgba(255, 255, 255, 0.10)",
  glassHover: "rgba(255, 255, 255, 0.12)",
  glassBorderHover: "rgba(255, 255, 255, 0.18)",

  // Semantic
  success: "#06D6A0",
  warning: "#FBBF24",
} as const;

export const motion = {
  fast: 150,
  normal: 250,
  slow: 400,
  hero: 600,
  stagger: 80,
  breathing: 2000,

  easeOut: [0.33, 1, 0.68, 1] as const,
  easeInOut: [0.65, 0, 0.35, 1] as const,
  spring: { type: "spring" as const, stiffness: 100, damping: 20 },
} as const;

export const zIndex = {
  base: 0,
  content: 10,
  sticky: 20,
  overlay: 30,
  nav: 40,
  modal: 50,
} as const;

// ═══════════════════════════════════════════════════
//  CATEGORY MAP (retained for compatibility)
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
  creative: "#D946EF",
  outdoors: "#06D6A0",
  fitness: "#FF4757",
  maker: "#FBBF24",
  music: "#818CF8",
  food: "#FB923C",
  collecting: "#38BDF8",
  mind: "#7C3AED",
  social: "#F472B6",
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
