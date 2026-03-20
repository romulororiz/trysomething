"use client";

import { motion } from "framer-motion";
import { StoreBadges } from "@/components/ui/StoreBadges";

/* ─── Constants ──────────────────────────────────────────── */

const EASE: [number, number, number, number] = [0.33, 1, 0.68, 1];
const WORD_STAGGER = 0.07;
const ACCENT = "#FF6B6B";

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

      {/* ── Store badges ── */}
      <motion.div
        initial={{ opacity: 0, y: 20, scale: 0.95 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ duration: 0.8, delay: 1.3, ease: EASE }}
        className="mt-12"
      >
        <StoreBadges />
      </motion.div>

      {/* ── Available now ── */}
      <motion.p
        {...fadeUp(1.7)}
        className="mt-5 text-xs"
        style={{ color: "#3D3835" }}
      >
        Available on iPhone &amp; Android
      </motion.p>
    </div>
  );
}
