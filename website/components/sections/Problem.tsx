"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";

/**
 * Problem section — emotional scroll-triggered text reveals.
 *
 * Design: Cinematic pacing, large impactful typography, generous whitespace.
 * Each line fades in as the user scrolls, creating a narrative flow.
 * Accent-colored keywords draw attention to emotional beats.
 * No cards, no grids — just powerful text that breathes.
 */

interface RevealLineProps {
  children: React.ReactNode;
  delay?: number;
  className?: string;
}

function RevealLine({ children, delay = 0, className = "" }: RevealLineProps) {
  const { ref, inView } = useInView({ threshold: 0.4 });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 32, filter: "blur(4px)" }}
      animate={
        inView
          ? { opacity: 1, y: 0, filter: "blur(0px)" }
          : {}
      }
      transition={{
        duration: 0.8,
        delay,
        ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
      }}
      className={className}
      style={{ willChange: "transform, opacity, filter" }}
    >
      {children}
    </motion.div>
  );
}

export function Problem() {
  const { ref: sectionRef, inView: sectionInView } = useInView({
    threshold: 0.05,
  });

  return (
    <section
      id="problem"
      ref={sectionRef}
      className="relative py-40 md:py-56 overflow-hidden"
    >
      {/* Gradient transition from hero — no hard line */}
      <div className="absolute top-0 left-0 right-0 h-48 bg-gradient-to-b from-bg/80 to-transparent pointer-events-none" />

      {/* Atmospheric bloom — warm, subtle */}
      <div className="absolute top-1/4 right-0 w-[600px] h-[600px] bloom-burgundy opacity-20 translate-x-1/3 pointer-events-none" />
      <div className="absolute bottom-1/4 left-0 w-[500px] h-[500px] bloom-coral opacity-15 -translate-x-1/3 pointer-events-none" />

      <div className="max-w-4xl mx-auto px-6">
        {/* Eyebrow */}
        <motion.p
          initial={{ opacity: 0, y: 12 }}
          animate={sectionInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-xs font-semibold text-text-muted uppercase tracking-[0.25em] mb-16 md:mb-24"
        >
          Sound familiar?
        </motion.p>

        {/* Emotional text reveals — each line a beat */}
        <div className="space-y-12 md:space-y-16">
          <RevealLine>
            <p className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-[1.15] tracking-tight">
              You&apos;ve been meaning to start
              <span className="font-serif italic text-coral"> something</span> new.
            </p>
          </RevealLine>

          <RevealLine delay={0.1}>
            <p className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-[1.15] tracking-tight">
              For months. Maybe years.
            </p>
          </RevealLine>

          <RevealLine delay={0.15}>
            <p className="text-xl md:text-2xl text-text-secondary leading-relaxed max-w-2xl">
              You&apos;ve saved Pinterest boards. Watched YouTube tutorials at 2am.
              Bookmarked gear lists you never came back to.
            </p>
          </RevealLine>

          <RevealLine delay={0.1}>
            <p className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-[1.15] tracking-tight">
              But you never actually
              <span className="font-serif italic text-coral"> started.</span>
            </p>
          </RevealLine>
        </div>

        {/* The turn — spacer then the quiet insight */}
        <div className="mt-24 md:mt-32">
          <RevealLine>
            <p className="text-lg md:text-xl text-text-secondary leading-relaxed max-w-xl">
              Not because you&apos;re lazy. Not because you don&apos;t care.
            </p>
          </RevealLine>

          <RevealLine delay={0.15}>
            <p className="mt-8 text-2xl md:text-3xl font-bold text-text-primary leading-snug max-w-2xl">
              Because choosing is overwhelming.
              <br />
              Starting alone is intimidating.
              <br />
              <span className="text-text-muted">And nobody shows you how.</span>
            </p>
          </RevealLine>
        </div>

        {/* Closing beat — the bridge to the solution */}
        <RevealLine delay={0.1}>
          <p className="mt-24 md:mt-32 text-lg text-text-muted text-center">
            Until now.
          </p>
        </RevealLine>
      </div>
    </section>
  );
}
