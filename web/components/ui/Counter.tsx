"use client";

import { useRef, useEffect, useState, useCallback } from "react";
import { useReducedMotion } from "@/hooks/useReducedMotion";
import { cn } from "@/lib/utils";

interface CounterProps {
  end: number;
  suffix?: string;
  prefix?: string;
  duration?: number;
  className?: string;
}

/**
 * Animated number counter. Counts up from 0 to end value.
 * Uses IBM Plex Mono (monoTimer style) by default.
 */
export function Counter({
  end,
  suffix = "",
  prefix = "",
  duration = 2000,
  className,
}: CounterProps) {
  const ref = useRef<HTMLSpanElement>(null);
  const [value, setValue] = useState(0);
  const [started, setStarted] = useState(false);
  const reduced = useReducedMotion();

  const animate = useCallback(() => {
    if (reduced) {
      setValue(end);
      return;
    }

    const startTime = performance.now();
    const step = (now: number) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // Ease out cubic
      const eased = 1 - Math.pow(1 - progress, 3);
      setValue(Math.round(eased * end));

      if (progress < 1) {
        requestAnimationFrame(step);
      }
    };
    requestAnimationFrame(step);
  }, [end, duration, reduced]);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !started) {
          setStarted(true);
          animate();
          observer.disconnect();
        }
      },
      { threshold: 0.5 }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [animate, started]);

  return (
    <span
      ref={ref}
      className={cn("font-mono font-bold tabular-nums", className)}
      aria-live="polite"
    >
      {prefix}
      {value}
      {suffix}
    </span>
  );
}
