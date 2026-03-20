"use client";

import { motion } from "framer-motion";

/* ─── Constants ──────────────────────────────────────────── */

const EASE: [number, number, number, number] = [0.33, 1, 0.68, 1];
const WORD_STAGGER = 0.07;
const ACCENT = "#FF6B6B";

/** Split headline into words, marking which is the accent word */
const HEADLINE_WORDS = "Discover the hobby you were made for.".split(" ");
const ACCENT_WORD = "hobby";

/* ─── Helpers ────────────────────────────────────────────── */

function fadeUp(delay: number) {
  return {
    initial: { opacity: 0, y: 24 },
    animate: { opacity: 1, y: 0 },
    transition: { duration: 0.8, delay, ease: EASE },
  };
}

/* ─── Component ──────────────────────────────────────────── */

/**
 * HeroContent — centered text + CTA, layered above the Lottie icons.
 *
 * Typography hierarchy:
 * 1. Pre-heading: tiny uppercase tracking → sets brand voice
 * 2. Headline: massive fluid type, "hobby" in warm gold italic serif
 * 3. Subtext: 1-2 lines of benefit copy
 * 4. CTA: warm gold button (NOT coral, NOT pill)
 * 5. Platform hint: barely visible
 */
export function HeroContent() {
  return (
    <div className="relative z-10 flex flex-col items-center justify-center text-center h-full px-6">
      {/* ── Pre-heading ── */}
      <motion.p
        {...fadeUp(0.2)}
        className="text-xs font-medium uppercase tracking-[0.25em] mb-8"
        style={{ color: "#6A6A7A" }}
      >
        Stop scrolling. Start something.
      </motion.p>

      {/* ── Headline — word-by-word stagger ── */}
      <h1
        className="text-[clamp(2.5rem,6vw,5rem)] font-bold leading-[1.05] tracking-tight max-w-4xl"
        aria-label="Discover the hobby you were made for."
      >
        {HEADLINE_WORDS.map((word, i) => {
          const isAccent =
            word.toLowerCase().replace(/[.,!?]/, "") === ACCENT_WORD;

          return (
            <motion.span
              key={`${word}-${i}`}
              initial={{ opacity: 0, y: 40, filter: "blur(4px)" }}
              animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
              transition={{
                duration: 0.7,
                delay: 0.5 + i * WORD_STAGGER,
                ease: EASE,
              }}
              className={`inline-block mr-[0.3em] ${
                isAccent ? "font-serif italic" : ""
              }`}
              style={{
                color: isAccent ? ACCENT : "#FAFAFA",
                willChange: "transform, opacity, filter",
              }}
            >
              {word}
            </motion.span>
          );
        })}
      </h1>

      {/* ── Subtext ── */}
      <motion.p
        {...fadeUp(0.9)}
        className="mt-8 text-lg sm:text-xl leading-relaxed max-w-[600px] mx-auto"
        style={{ color: "#8A8A9A" }}
      >
        AI-powered matching finds your perfect hobby. Step-by-step roadmaps
        show you exactly how to start. A personal coach keeps you going.
      </motion.p>

      {/* ── CTA button — warm gold, rounded-[10px], NOT pill ── */}
      <motion.a
        href="#waitlist"
        initial={{ opacity: 0, y: 20, scale: 0.95 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.8, delay: 1.3, ease: EASE }}
        className="mt-12 inline-block px-10 py-4 font-semibold text-base rounded-full cursor-pointer transition-all duration-300 hover:scale-[1.03]"
        style={{
          backgroundColor: ACCENT,
          color: "#FFFFFF",
          boxShadow: "0 0 0 rgba(255,107,107,0)",
        }}
        whileHover={{
          boxShadow: "0 0 30px rgba(255,107,107,0.35)",
        }}
      >
        Get Early Access
      </motion.a>

      {/* ── Platform hint ── */}
      <motion.p
        {...fadeUp(1.7)}
        className="mt-6 text-xs"
        style={{ color: "#3D3835" }}
      >
        Coming soon to iPhone &amp; Android
      </motion.p>
    </div>
  );
}
