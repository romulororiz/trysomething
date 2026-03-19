"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useInView } from "@/hooks/useInView";

/* ─── Constants ──────────────────────────────────────────── */

const CORAL = "#FF6B6B";
const EASE: [number, number, number, number] = [0.23, 1, 0.32, 1];

const features = [
  {
    number: "01",
    claim: "AI matching that actually knows you",
    detail:
      'Not a quiz that spits out "try yoga." Our AI cross-references your personality, schedule, budget, location, and energy levels to find hobbies with real compatibility scores.',
    accent: "knows you",
  },
  {
    number: "02",
    claim: "A roadmap for your first 30 days",
    detail:
      'Day 1: what to buy (with exact prices). Day 3: your first session. Week 2: your first milestone. No googling "how to start [hobby] for beginners" ever again.',
    accent: "first 30 days",
  },
  {
    number: "03",
    claim: "A personal AI coach in your pocket",
    detail:
      "Checks in when you need motivation. Adjusts the plan when life gets busy. Celebrates wins you didn't know mattered. Like a patient friend who happens to be an expert.",
    accent: "AI coach",
  },
  {
    number: "04",
    claim: "Zero overwhelm, by design",
    detail:
      "Three hobby matches, not three hundred. One step at a time, not a wall of content. We removed every excuse between you and starting.",
    accent: "by design",
  },
  {
    number: "05",
    claim: "Real progress you can feel",
    detail:
      'Milestone tracking, streak counts, and a visual journey map. When your brain says "I never stick with anything," your progress page says otherwise.',
    accent: "you can feel",
  },
  {
    number: "06",
    claim: "Built for people who are tired of planning",
    detail:
      "No research phase. No comparison spreadsheets. No \"I'll start Monday.\" Open the app, answer a few questions, and you're doing something new today.",
    accent: "tired of planning",
  },
];

/* ─── Accent text highlighter ─────────────────────────────── */

function renderWithAccent(text: string, accent: string) {
  const idx = text.indexOf(accent);
  if (idx === -1) return <>{text}</>;

  return (
    <>
      {text.slice(0, idx)}
      <span className="font-serif italic" style={{ color: CORAL }}>
        {accent}
      </span>
      {text.slice(idx + accent.length)}
    </>
  );
}

/* ─── Feature Row ─────────────────────────────────────────── */

function FeatureRow({
  feature,
  index,
  isMobile,
  mobileOpenIndex,
  onMobileToggle,
}: {
  feature: (typeof features)[number];
  index: number;
  isMobile: boolean;
  mobileOpenIndex: number | null;
  onMobileToggle: (i: number) => void;
}) {
  const [hovered, setHovered] = useState(false);

  // On desktop: hover opens. On mobile: click toggles (accordion).
  const isOpen = isMobile ? mobileOpenIndex === index : hovered;

  const handleClick = () => {
    if (isMobile) onMobileToggle(index);
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.6, delay: index * 0.08, ease: EASE }}
      className="border-b border-white/[0.06] cursor-pointer select-none"
      onClick={handleClick}
      onMouseEnter={() => !isMobile && setHovered(true)}
      onMouseLeave={() => !isMobile && setHovered(false)}
      style={{
        borderLeft: isOpen
          ? `2px solid ${CORAL}40`
          : "2px solid transparent",
        transition: "border-color 0.3s ease",
      }}
    >
      {/* Collapsed row */}
      <div className="flex items-center py-5 md:py-7 gap-4 md:gap-8 px-2 md:px-4">
        {/* Number */}
        <span
          className="text-xs md:text-sm font-mono w-6 md:w-8 shrink-0 tabular-nums"
          style={{ color: CORAL, opacity: 0.4 }}
        >
          {feature.number}
        </span>

        {/* Claim text */}
        <motion.h3
          className="text-lg md:text-2xl lg:text-[1.75rem] text-[#FAFAFA] flex-1 font-light leading-snug tracking-tight"
          animate={{ x: isOpen ? 4 : 0 }}
          transition={{ duration: 0.3, ease: EASE }}
        >
          {renderWithAccent(feature.claim, feature.accent)}
        </motion.h3>

        {/* Toggle icon */}
        <motion.span
          className="text-lg md:text-xl shrink-0 w-8 h-8 md:w-10 md:h-10 flex items-center justify-center"
          style={{ color: "#6A6A7A" }}
          animate={{ rotate: isOpen ? 45 : 0 }}
          transition={{ duration: 0.3, ease: EASE }}
        >
          +
        </motion.span>
      </div>

      {/* Expandable detail */}
      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.4, ease: EASE }}
            className="overflow-hidden"
          >
            <p
              className="text-sm md:text-base pl-12 md:pl-[72px] pr-12 pb-5 md:pb-7 max-w-2xl leading-relaxed"
              style={{ color: "#8A8A9A" }}
            >
              {feature.detail}
            </p>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

/* ─── Main component ──────────────────────────────────────── */

/**
 * WhatYouGet — Typographic accordion.
 *
 * 6 bold claims as a vertical list. Hover (desktop) or tap (mobile)
 * to expand details. No cards, no icons, no grids.
 * Coral accent words tell a micro-story across all 6 rows.
 */
export function WhatYouGet() {
  const { ref: sectionRef, inView } = useInView({ threshold: 0.05 });
  const [isMobile, setIsMobile] = useState(false);
  const [mobileOpenIndex, setMobileOpenIndex] = useState<number | null>(null);

  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768);
    check();
    window.addEventListener("resize", check);
    return () => window.removeEventListener("resize", check);
  }, []);

  const handleMobileToggle = useCallback(
    (i: number) => {
      setMobileOpenIndex(mobileOpenIndex === i ? null : i);
    },
    [mobileOpenIndex]
  );

  return (
    <section
      id="what-you-get"
      ref={sectionRef}
      className="relative w-full py-28 md:py-40"
      style={{ backgroundColor: "#000" }}
    >
      <div className="max-w-5xl mx-auto px-6 md:px-10">
        {/* Section label */}
        <motion.p
          initial={{ opacity: 0, y: 12 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="text-xs font-semibold uppercase tracking-[0.25em] mb-12 md:mb-16"
          style={{ color: "#6A6A7A" }}
        >
          What you get
        </motion.p>

        {/* Feature list */}
        <div className="border-t border-white/[0.06]">
          {features.map((feature, i) => (
            <FeatureRow
              key={feature.number}
              feature={feature}
              index={i}
              isMobile={isMobile}
              mobileOpenIndex={mobileOpenIndex}
              onMobileToggle={handleMobileToggle}
            />
          ))}
        </div>

        {/* Closing statement */}
        <motion.p
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-30px" }}
          transition={{ duration: 0.7, delay: 0.3, ease: EASE }}
          className="mt-16 md:mt-20 text-center text-sm"
          style={{ color: "#6A6A7A" }}
        >
          All of this.{" "}
          <span className="font-serif italic" style={{ color: CORAL }}>
            One app
          </span>
          . Launching soon.
        </motion.p>
      </div>
    </section>
  );
}
