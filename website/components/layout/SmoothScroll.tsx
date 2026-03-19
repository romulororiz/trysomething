"use client";

import { useEffect, useRef, createContext, useContext, useCallback } from "react";
import Lenis from "lenis";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

/* ─── Context to expose Lenis instance to children ────────── */

const LenisContext = createContext<{ scrollTo: (target: string | number) => void }>({
  scrollTo: () => {},
});

export function useSmoothScroll() {
  return useContext(LenisContext);
}

export function SmoothScroll({ children }: { children: React.ReactNode }) {
  const lenisRef = useRef<Lenis | null>(null);

  useEffect(() => {
    const mql = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (mql.matches) return;

    const lenis = new Lenis({
      lerp: 0.1,
      smoothWheel: true,
    });
    lenisRef.current = lenis;

    lenis.on("scroll", ScrollTrigger.update);

    gsap.ticker.add((time) => {
      lenis.raf(time * 1000);
    });
    gsap.ticker.lagSmoothing(0);

    return () => {
      lenis.destroy();
      lenisRef.current = null;
    };
  }, []);

  const scrollTo = useCallback((target: string | number) => {
    if (lenisRef.current) {
      // Lenis scrollTo handles CSS selectors and accounts for the actual
      // scroll position. We also need to force GSAP ScrollTrigger to
      // refresh so pinned offsets are current.
      ScrollTrigger.refresh();
      lenisRef.current.scrollTo(target, { offset: 0, duration: 1.2 });
    } else {
      // Fallback for reduced-motion / no Lenis
      if (typeof target === "string") {
        const el = document.querySelector(target);
        el?.scrollIntoView({ behavior: "smooth" });
      } else {
        window.scrollTo({ top: target, behavior: "smooth" });
      }
    }
  }, []);

  return (
    <LenisContext.Provider value={{ scrollTo }}>
      {children}
    </LenisContext.Provider>
  );
}
