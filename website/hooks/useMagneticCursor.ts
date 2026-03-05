"use client";

import { useRef, useCallback, useEffect } from "react";
import { useReducedMotion } from "./useReducedMotion";

interface MagneticOptions {
  strength?: number;
  radius?: number;
}

/**
 * Magnetic cursor effect — element gently follows cursor within radius.
 * Matching the CTA button feel from the Flutter app.
 */
export function useMagneticCursor<T extends HTMLElement>(
  options: MagneticOptions = {}
) {
  const { strength = 0.3, radius = 15 } = options;
  const ref = useRef<T>(null);
  const reduced = useReducedMotion();

  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (reduced || !ref.current) return;

      const el = ref.current;
      const rect = el.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      const distX = e.clientX - centerX;
      const distY = e.clientY - centerY;
      const dist = Math.sqrt(distX * distX + distY * distY);

      if (dist < rect.width / 2 + radius) {
        el.style.transform = `translate3d(${distX * strength}px, ${distY * strength}px, 0)`;
      } else {
        el.style.transform = "translate3d(0, 0, 0)";
      }
    },
    [strength, radius, reduced]
  );

  const handleMouseLeave = useCallback(() => {
    if (ref.current) {
      ref.current.style.transform = "translate3d(0, 0, 0)";
    }
  }, []);

  useEffect(() => {
    if (reduced) return;

    const el = ref.current;
    if (!el) return;

    const parent = el.parentElement || document;
    parent.addEventListener("mousemove", handleMouseMove as EventListener);
    el.addEventListener("mouseleave", handleMouseLeave);

    return () => {
      parent.removeEventListener("mousemove", handleMouseMove as EventListener);
      el.removeEventListener("mouseleave", handleMouseLeave);
    };
  }, [handleMouseMove, handleMouseLeave, reduced]);

  return ref;
}
