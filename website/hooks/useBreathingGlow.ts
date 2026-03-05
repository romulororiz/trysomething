"use client";

import { useReducedMotion } from "./useReducedMotion";

/**
 * Returns the CSS class for the breathing glow effect.
 * Returns empty string if reduced motion is preferred.
 */
export function useBreathingGlow(): string {
  const reduced = useReducedMotion();
  return reduced ? "" : "breathing-glow";
}
