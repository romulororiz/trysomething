"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";

/* ─── Constants ──────────────────────────────────────────── */

const EASE: [number, number, number, number] = [0.33, 1, 0.68, 1];
const CORAL = "#FF6B6B";

/* ─── RevealLine — scroll-triggered fade-up with blur ────── */

function RevealLine({
  children,
  delay = 0,
  className = "",
}: {
  children: React.ReactNode;
  delay?: number;
  className?: string;
}) {
  const { ref, inView } = useInView({ threshold: 0.4 });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 28, filter: "blur(4px)" }}
      animate={inView ? { opacity: 1, y: 0, filter: "blur(0px)" } : {}}
      transition={{ duration: 0.8, delay, ease: EASE }}
      className={className}
      style={{ willChange: "transform, opacity, filter" }}
    >
      {children}
    </motion.div>
  );
}

/* ─── Value anchor (text block with coral accent line) ───── */

function ValueAnchor({
  title,
  description,
  delay,
}: {
  title: string;
  description: string;
  delay: number;
}) {
  const { ref, inView } = useInView({ threshold: 0.3 });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 24 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.7, delay, ease: EASE }}
      className="flex gap-5"
    >
      {/* Coral accent line */}
      <div
        className="flex-shrink-0 w-[3px] rounded-full self-stretch"
        style={{ backgroundColor: CORAL, opacity: 0.5 }}
      />
      <div>
        <h4 className="text-base md:text-lg font-bold text-[#FAFAFA] leading-snug">
          {title}
        </h4>
        <p className="mt-1.5 text-sm text-[#8A8A9A] leading-relaxed">
          {description}
        </p>
      </div>
    </motion.div>
  );
}

/* ─── Main component ─────────────────────────────────────── */

/**
 * Solution — "The before and after"
 *
 * A pure typographic editorial section. Three phases:
 * 1. Problem narrative — left-aligned, line-by-line reveals
 * 2. Subtle coral divider
 * 3. Answer — centered layout with statement + value anchors
 */
export function Solution() {
  const { ref: sectionRef, inView: sectionInView } = useInView({
    threshold: 0.02,
  });

  const { ref: answerRef, inView: answerInView } = useInView({
    threshold: 0.15,
  });

  return (
    <section
      id="solution"
      ref={sectionRef}
      className="relative overflow-hidden"
      style={{ backgroundColor: "#000" }}
    >
      {/* ═══════════════════════════════════════════════════════
          PHASE 1 — The Problem
          ═══════════════════════════════════════════════════════ */}
      <div className="py-28 md:py-40">
        <div
          className="absolute top-[15%] right-0 w-[500px] h-[500px] translate-x-1/3 pointer-events-none opacity-[0.06]"
          style={{
            background:
              "radial-gradient(ellipse at center, rgba(255,107,107,0.3), transparent 70%)",
          }}
        />

        <div className="max-w-4xl mx-auto px-6 md:px-10">
          {/* Eyebrow */}
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={sectionInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6 }}
            className="text-xs font-semibold uppercase tracking-[0.25em] mb-14 md:mb-18"
            style={{ color: "#5A5A6A" }}
          >
            Sound familiar?
          </motion.p>

          {/* Narrative lines */}
          <div className="space-y-10 md:space-y-14">
            <RevealLine>
              <p
                className="text-[clamp(1.5rem,3.5vw,2.8rem)] font-bold leading-[1.2] tracking-tight"
                style={{ color: "#F0EBE3" }}
              >
                You&apos;ve been meaning to start{" "}
                <span className="font-serif italic text-coral">something</span>{" "}
                new.
              </p>
            </RevealLine>

            <RevealLine delay={0.08}>
              <p
                className="text-[clamp(1.5rem,3.5vw,2.8rem)] font-bold leading-[1.2] tracking-tight"
                style={{ color: "#F0EBE3" }}
              >
                A hobby. A passion. Anything that isn&apos;t scrolling, working,
                or waiting for the weekend.
              </p>
            </RevealLine>

            <RevealLine delay={0.1}>
              <p
                className="text-xl md:text-2xl leading-relaxed max-w-2xl"
                style={{ color: "#8A8A9A" }}
              >
                But every time you try to figure out what, you end up lost in a
                sea of listicles, YouTube rabbit holes, and abandoned shopping
                carts.
              </p>
            </RevealLine>
          </div>

          {/* The punch */}
          <div className="mt-16 md:mt-24 space-y-5">
            <RevealLine>
              <p className="text-[clamp(1.5rem,3.5vw,2.8rem)] font-bold leading-[1.2] tracking-tight text-[#FAFAFA]">
                So you do nothing.
              </p>
            </RevealLine>

            <RevealLine delay={0.15}>
              <p className="text-[clamp(1.25rem,2.5vw,2rem)] font-bold font-serif italic tracking-tight text-coral">
                Again.
              </p>
            </RevealLine>
          </div>
        </div>
      </div>

      {/* ═══════════════════════════════════════════════════════
          PHASE 2 — Subtle coral divider (not a fat line)
          ═══════════════════════════════════════════════════════ */}
      <div className="max-w-3xl mx-auto px-6 md:px-10 my-8 md:my-16">
        <motion.div
          className="w-full h-px opacity-30"
          style={{
            background: `linear-gradient(90deg, transparent 0%, ${CORAL} 50%, transparent 100%)`,
          }}
          initial={{ scaleX: 0 }}
          whileInView={{ scaleX: 1 }}
          viewport={{ once: true, margin: "-60px" }}
          transition={{ duration: 1.2, ease: [0.23, 1, 0.32, 1] }}
        />
      </div>

      {/* ═══════════════════════════════════════════════════════
          PHASE 3 — The Answer (CENTERED)
          ═══════════════════════════════════════════════════════ */}
      <div ref={answerRef} className="py-20 md:py-32">
        <div className="max-w-4xl mx-auto px-6 md:px-10 text-center">
          {/* Eyebrow */}
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={answerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold uppercase tracking-[0.25em] mb-8"
            style={{ color: "#5A5A6A" }}
          >
            The answer
          </motion.p>

          {/* Bold centered statement */}
          <motion.h3
            initial={{ opacity: 0, y: 28 }}
            animate={answerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, ease: EASE }}
            className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-[1.1] tracking-tight text-[#FAFAFA] max-w-3xl mx-auto"
          >
            What if someone just told you{" "}
            <span className="font-serif italic text-coral">exactly</span> what
            to try, and{" "}
            <span className="font-serif italic text-coral">exactly</span> how to
            start?
          </motion.h3>

          {/* Three value anchors — centered row on desktop, stacked on mobile */}
          <div className="mt-16 md:mt-20 grid grid-cols-1 md:grid-cols-3 gap-10 md:gap-8 text-left max-w-4xl mx-auto">
            <ValueAnchor
              title="AI that knows you"
              description="Not random suggestions. Personalized to your time, budget, and personality."
              delay={0.15}
            />
            <ValueAnchor
              title="A roadmap, not a reading list"
              description="Step one. Step two. Your first win in a week."
              delay={0.25}
            />
            <ValueAnchor
              title="A coach that stays with you"
              description="Encouragement, adjustments, momentum."
              delay={0.35}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
