"use client";

import { useRef, useState } from "react";
import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { useSmoothScroll } from "@/components/layout/SmoothScroll";

const EASE: [number, number, number, number] = [0.33, 1, 0.68, 1];

/* ── Real numbers only — every claim verifiable in the product ── */
const facts = [
  {
    value: "150+",
    label: "hobbies curated by hand",
    accent: "rgba(218,165,32,0.6)",
  },
  {
    value: "CHF",
    label: "exact starter costs, every kit",
    accent: "rgba(255,107,107,0.6)",
  },
  {
    value: "4wk",
    label: "roadmap from first try to habit",
    accent: "rgba(125,189,171,0.6)",
  },
  {
    value: "1",
    label: "hobby at a time, by design",
    accent: "rgba(255,107,107,0.6)",
  },
];

/* ── 3D Tilt Card (kept from the old testimonials — it earned its place) ── */
function TiltCard({ children }: { children: React.ReactNode }) {
  const cardRef = useRef<HTMLDivElement>(null);
  const [transform, setTransform] = useState(
    "perspective(900px) rotateX(0deg) rotateY(0deg)"
  );
  const [glare, setGlare] = useState({ x: 50, y: 50, opacity: 0 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const card = cardRef.current;
    if (!card) return;
    const rect = card.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;
    const rotateX = (y - 0.5) * -6;
    const rotateY = (x - 0.5) * 6;
    setTransform(
      `perspective(900px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.01,1.01,1.01)`
    );
    setGlare({ x: x * 100, y: y * 100, opacity: 0.07 });
  };

  const handleMouseLeave = () => {
    setTransform("perspective(900px) rotateX(0deg) rotateY(0deg) scale3d(1,1,1)");
    setGlare({ x: 50, y: 50, opacity: 0 });
  };

  return (
    <div
      ref={cardRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className="relative rounded-2xl border border-glass-border bg-glass overflow-hidden transition-transform duration-300 ease-out"
      style={{ transform, transformStyle: "preserve-3d" }}
    >
      <div
        className="absolute inset-0 pointer-events-none transition-opacity duration-300 rounded-2xl"
        style={{
          background: `radial-gradient(circle at ${glare.x}% ${glare.y}%, rgba(255,255,255,${glare.opacity}), transparent 60%)`,
        }}
      />
      <div className="noise absolute inset-0 pointer-events-none" aria-hidden="true" />
      <div className="relative z-10">{children}</div>
    </div>
  );
}

/**
 * Proof — "The honest part."
 *
 * Replaces fabricated testimonials/stats with radical honesty:
 * the app is new, in closed beta, and every number shown is
 * verifiable in the product. Turns "no users yet" into
 * "first cohort" exclusivity.
 */
export function Proof() {
  const { ref: headerRef, inView: headerInView } = useInView({ threshold: 0.2 });
  const { ref: factsRef, inView: factsInView } = useInView({ threshold: 0.2 });
  const { scrollTo } = useSmoothScroll();

  return (
    <section id="proof" className="relative py-28 md:py-40 overflow-hidden">
      {/* Atmospheric blooms */}
      <div
        className="absolute bottom-1/4 left-0 w-[500px] h-[500px] -translate-x-1/3 pointer-events-none opacity-15"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(159,18,57,0.2), transparent 70%)",
        }}
        aria-hidden="true"
      />
      <div
        className="absolute top-1/4 right-0 w-[400px] h-[400px] translate-x-1/3 pointer-events-none opacity-12"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(218,165,32,0.15), transparent 70%)",
        }}
        aria-hidden="true"
      />

      <div className="max-w-5xl mx-auto px-6">
        {/* ── Header ── */}
        <div ref={headerRef} className="text-center mb-14 md:mb-20">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            The honest part
          </motion.p>

          <motion.h2
            initial={{ opacity: 0, y: 24 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8, ease: EASE }}
            className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-tight tracking-tight"
          >
            We&rsquo;re new. No fake
            <span className="font-serif italic text-coral"> five-star reviews</span>{" "}
            here.
          </motion.h2>

          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="mt-5 text-lg text-text-secondary max-w-lg mx-auto"
          >
            Just a few things that are actually true.
          </motion.p>
        </div>

        {/* ── Facts row ── */}
        <div
          ref={factsRef}
          className="grid grid-cols-2 md:grid-cols-4 gap-x-4 gap-y-10 md:gap-8 mb-16 md:mb-24 max-w-4xl mx-auto"
        >
          {facts.map((fact, i) => (
            <motion.div
              key={fact.label}
              initial={{ opacity: 0, y: 30 }}
              animate={factsInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.7, delay: 0.1 + i * 0.1, ease: EASE }}
              className="text-center"
            >
              <div
                className="text-[clamp(1.75rem,4vw,3rem)] font-bold tracking-tight leading-none"
                style={{
                  background: `linear-gradient(135deg, var(--color-text-primary), ${fact.accent})`,
                  WebkitBackgroundClip: "text",
                  WebkitTextFillColor: "transparent",
                  backgroundClip: "text",
                }}
              >
                {fact.value}
              </div>
              <p className="text-xs md:text-sm text-text-secondary mt-2 tracking-wide max-w-[160px] mx-auto">
                {fact.label}
              </p>
            </motion.div>
          ))}
        </div>

        {/* ── Beta invitation card ── */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ duration: 0.8, ease: EASE }}
          className="max-w-2xl mx-auto"
        >
          <TiltCard>
            <div className="accent-stripe-coral p-7 md:p-10 text-center">
              <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-coral mb-4">
                Closed beta &middot; Switzerland
              </p>
              <p className="text-xl md:text-2xl font-bold leading-snug tracking-tight text-text-primary">
                The first cohort is starting{" "}
                <span className="font-serif italic text-coral">right now</span>.
              </p>
              <p className="mt-4 text-sm md:text-base text-text-secondary leading-relaxed max-w-md mx-auto">
                Early testers get the full app free while we polish it &mdash;
                and every piece of feedback shapes what TrySomething becomes.
              </p>
              <button
                onClick={() => scrollTo("#download")}
                className="mt-7 px-7 py-3.5 rounded-full text-sm font-semibold text-white bg-coral hover:bg-coral-hover transition-colors duration-200 cursor-pointer active:scale-[0.97]"
              >
                Join the first cohort
              </button>
            </div>
          </TiltCard>

          {/* Founder line — small, human, true */}
          <motion.p
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="mt-8 text-center text-sm text-text-muted"
          >
            Built by one person in Switzerland who finally stopped saying{" "}
            <span className="font-serif italic">someday</span>.
          </motion.p>
        </motion.div>
      </div>
    </section>
  );
}
