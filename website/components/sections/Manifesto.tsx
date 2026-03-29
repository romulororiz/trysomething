"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";

/**
 * Manifesto — Scrub-reveal with heavy blur-to-sharp + parallax.
 *
 * Starts very blurry & scaled down. As user scrolls, each element
 * sharpens and drifts into place at different rates (parallax).
 * Extended section height (200vh) for a long, cinematic reveal.
 */

export function Manifesto() {
  const containerRef = useRef<HTMLDivElement>(null);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });

  // --- Global container transforms ---
  // Heavy blur: 30px → 0 over first 35% of scroll
  const globalBlur = useTransform(scrollYProgress, [0.0, 0.35], [30, 0]);
  const globalBlurFilter = useTransform(globalBlur, (v) =>
    `blur(${Math.max(0, v)}px)`
  );
  // Scale from 0.8 → 1.0
  const globalScale = useTransform(scrollYProgress, [0.0, 0.35], [0.8, 1]);
  // 3D rotation
  const globalRotateX = useTransform(scrollYProgress, [0.0, 0.3], [20, 0]);

  // --- "A GENTLE MANIFESTO" overline — fastest parallax (arrives first) ---
  const overlineY = useTransform(scrollYProgress, [0.0, 0.3], [80, 0]);
  const overlineOpacity = useTransform(
    scrollYProgress,
    [0.05, 0.2, 0.75, 0.9],
    [0, 1, 1, 0]
  );

  // --- "Stop" — medium-fast parallax ---
  const stopY = useTransform(scrollYProgress, [0.0, 0.32], [120, 0]);
  const stopOpacity = useTransform(
    scrollYProgress,
    [0.05, 0.22, 0.75, 0.9],
    [0, 1, 1, 0]
  );

  // --- "scrolling." — slightly slower (drifts in from further) ---
  const scrollingY = useTransform(scrollYProgress, [0.0, 0.35], [160, 0]);
  const scrollingX = useTransform(scrollYProgress, [0.0, 0.35], [40, 0]);
  const scrollingOpacity = useTransform(
    scrollYProgress,
    [0.08, 0.25, 0.75, 0.9],
    [0, 1, 1, 0]
  );

  // --- "Start" — arrives after "Stop" ---
  const startY = useTransform(scrollYProgress, [0.1, 0.38], [140, 0]);
  const startOpacity = useTransform(
    scrollYProgress,
    [0.12, 0.3, 0.75, 0.9],
    [0, 1, 1, 0]
  );

  // --- "something." — slowest parallax word (most dramatic drift) ---
  const somethingY = useTransform(scrollYProgress, [0.1, 0.4], [180, 0]);
  const somethingX = useTransform(scrollYProgress, [0.1, 0.4], [-30, 0]);
  const somethingOpacity = useTransform(
    scrollYProgress,
    [0.15, 0.35, 0.75, 0.9],
    [0, 1, 1, 0]
  );
  // Extra: "something." gets its own subtle blur that clears later
  const somethingBlur = useTransform(scrollYProgress, [0.1, 0.4], [15, 0]);
  const somethingBlurFilter = useTransform(somethingBlur, (v) =>
    `blur(${Math.max(0, v)}px)`
  );

  // --- Subtext — arrives last, gentle fade-up ---
  const subY = useTransform(scrollYProgress, [0.25, 0.45], [50, 0]);
  const subOpacity = useTransform(
    scrollYProgress,
    [0.3, 0.45, 0.75, 0.9],
    [0, 1, 1, 0]
  );

  // --- Decorative line / divider that grows in ---
  const lineScaleX = useTransform(scrollYProgress, [0.2, 0.4], [0, 1]);
  const lineOpacity = useTransform(
    scrollYProgress,
    [0.2, 0.35, 0.75, 0.9],
    [0, 0.3, 0.3, 0]
  );

  return (
    <section
      ref={containerRef}
      className="relative py-20 md:py-0 md:min-h-[100vh]"
      aria-label="Manifesto"
    >
      {/* Sticky centered container */}
      <div className="md:sticky md:top-0 md:h-screen flex items-center justify-center overflow-hidden">
        {/* Atmospheric blooms */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[500px] bloom-burgundy opacity-25 pointer-events-none" />
        <div className="absolute top-1/3 left-1/4 w-[500px] h-[500px] bloom-teal opacity-15 pointer-events-none" />

        <div className="perspective-container max-w-5xl mx-auto px-6 text-center relative">
          {/* Global transform wrapper — blur + scale + 3D rotation */}
          <motion.div
            className="text-3d-reveal"
            style={{
              filter: globalBlurFilter,
              scale: globalScale,
              rotateX: globalRotateX,
            }}
          >
            {/* Overline */}
            <motion.p
              style={{ y: overlineY, opacity: overlineOpacity }}
              className="text-sm font-medium text-text-muted uppercase tracking-[0.3em] mb-8"
            >
              A gentle manifesto
            </motion.p>

            {/* Line 1 — "Stop scrolling." with split-word parallax */}
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-8xl font-bold leading-[1.05] tracking-tight text-text-primary">
              <motion.span
                style={{ y: stopY, opacity: stopOpacity }}
                className="inline-block mr-[0.3em]"
              >
                Stop
              </motion.span>
              <motion.span
                style={{
                  y: scrollingY,
                  x: scrollingX,
                  opacity: scrollingOpacity,
                }}
                className="inline-block font-serif italic text-text-secondary"
              >
                scrolling.
              </motion.span>
            </h2>

            {/* Line 2 — "Start something." with split-word parallax */}
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-8xl font-bold leading-[1.05] tracking-tight mt-3">
              <motion.span
                style={{ y: startY, opacity: startOpacity }}
                className="inline-block mr-[0.3em]"
              >
                Start
              </motion.span>
              <motion.span
                style={{
                  y: somethingY,
                  x: somethingX,
                  opacity: somethingOpacity,
                  filter: somethingBlurFilter,
                }}
                className="inline-block font-serif italic text-coral"
              >
                something.
              </motion.span>
            </h2>

            {/* Decorative line */}
            <motion.div
              style={{ scaleX: lineScaleX, opacity: lineOpacity }}
              className="mt-10 mx-auto h-px w-32 bg-gradient-to-r from-transparent via-text-muted to-transparent origin-center"
            />

            {/* Subtext */}
            <motion.p
              style={{ y: subY, opacity: subOpacity }}
              className="mt-10 text-lg md:text-xl text-text-secondary max-w-lg mx-auto leading-relaxed"
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
