"use client";

import { useEffect } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

// Register GSAP plugins once
if (typeof window !== "undefined") {
  gsap.registerPlugin(ScrollTrigger);
}

export { gsap, ScrollTrigger };

/**
 * Hook to create scroll-triggered animations.
 * Cleans up on unmount automatically.
 */
export function useScrollAnimation(
  callback: (gsapInstance: typeof gsap) => gsap.core.Timeline | gsap.core.Tween | void,
  deps: React.DependencyList = []
) {
  useEffect(() => {
    const ctx = gsap.context(() => {
      callback(gsap);
    });

    return () => ctx.revert();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}
