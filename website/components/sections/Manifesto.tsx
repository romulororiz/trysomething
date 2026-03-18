"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform, MotionValue } from "framer-motion";

/**
 * 3D Text Reveal — single use editorial moment.
 *
 * Key fix: text reaches full readability by 25% scroll progress
 * and STAYS fully readable until 75%, giving a wide reading window.
 * The section height is reduced to 150vh so it doesn't drag on.
 */

function useMotionBlur(value: MotionValue<number>) {
  // Create a motion value that maps to a blur CSS filter string
  const blurValue = useTransform(value, [0.05, 0.2], [10, 0]);
  return useTransform(blurValue, (v) => `blur(${v}px)`);
}

export function Manifesto() {
  const containerRef = useRef<HTMLDivElement>(null);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });

  // Text arrives at full readability EARLY (by 0.25) and stays until 0.75
  const rotateX = useTransform(scrollYProgress, [0.05, 0.25], [25, 0]);
  const mainOpacity = useTransform(
    scrollYProgress,
    [0.05, 0.2, 0.75, 0.9],
    [0, 1, 1, 0]
  );
  const scale = useTransform(scrollYProgress, [0.05, 0.25], [0.9, 1]);
  const y = useTransform(scrollYProgress, [0.05, 0.25], [40, 0]);
  const blurFilter = useMotionBlur(scrollYProgress);

  // "Start something" line — arrives slightly after "Stop scrolling"
  const line2Opacity = useTransform(
    scrollYProgress,
    [0.15, 0.3, 0.75, 0.9],
    [0, 1, 1, 0]
  );
  const line2Y = useTransform(scrollYProgress, [0.15, 0.3], [24, 0]);

  // Subtext — arrives last
  const subOpacity = useTransform(
    scrollYProgress,
    [0.25, 0.38, 0.75, 0.9],
    [0, 1, 1, 0]
  );

  return (
    <section
      ref={containerRef}
      className="relative py-20 md:py-0 md:min-h-[150vh]"
      aria-label="Manifesto"
    >
      {/* Sticky centered container */}
      <div className="md:sticky md:top-0 md:h-screen flex items-center justify-center">
        {/* Atmospheric blooms */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bloom-burgundy opacity-25 pointer-events-none" />
        <div className="absolute top-1/3 left-1/4 w-[500px] h-[500px] bloom-teal opacity-15 pointer-events-none" />

        <div className="perspective-container max-w-5xl mx-auto px-6 text-center relative">
          <motion.div
            className="text-3d-reveal"
            style={{
              rotateX,
              opacity: mainOpacity,
              scale,
              y,
              filter: blurFilter,
            }}
          >
            {/* Overline */}
            <p className="text-sm font-medium text-text-muted uppercase tracking-[0.3em] mb-8">
              A gentle manifesto
            </p>

            {/* Line 1 — "Stop scrolling." */}
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-8xl font-bold leading-[1.05] tracking-tight text-text-primary">
              Stop{" "}
              <span className="font-serif italic text-text-secondary">
                scrolling.
              </span>
            </h2>

            {/* Line 2 — "Start something." (slightly delayed) */}
            <motion.h2
              style={{ opacity: line2Opacity, y: line2Y }}
              className="text-4xl sm:text-5xl md:text-6xl lg:text-8xl font-bold leading-[1.05] tracking-tight mt-3"
            >
              Start{" "}
              <span className="font-serif italic text-coral">something.</span>
            </motion.h2>

            {/* Subtext */}
            <motion.p
              style={{ opacity: subOpacity }}
              className="mt-12 text-lg md:text-xl text-text-secondary max-w-lg mx-auto leading-relaxed"
            >
              You don&apos;t need more inspiration.
              <br />
              You need a first step — and someone to walk it with you.
            </motion.p>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
