"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { problemCards } from "@/lib/data";
import { StaggeredText } from "@/components/ui/StaggeredText";

/**
 * Premium problem card with layered visual depth:
 * - Gradient accent stripe on left edge
 * - Large number as a watermark behind content
 * - Animated border glow on hover
 * - No serif fonts on card text (serif only in big standalone headings)
 */
function ProblemCard({
  number,
  label,
  question,
  detail,
  index,
}: {
  number: string;
  label: string;
  question: string;
  detail: string;
  index: number;
}) {
  const { ref, inView } = useInView({ threshold: 0.3 });

  // Per-card accent color for visual differentiation
  const accents = [
    {
      stripe: "from-coral via-coral/60 to-transparent",
      glow: "group-hover:shadow-[0_0_40px_rgba(255,107,107,0.08)]",
      numberColor: "text-coral/[0.07]",
      dotColor: "bg-coral",
    },
    {
      stripe: "from-bloom-teal via-bloom-teal/60 to-transparent",
      glow: "group-hover:shadow-[0_0_40px_rgba(13,148,136,0.08)]",
      numberColor: "text-bloom-teal/[0.07]",
      dotColor: "bg-bloom-teal",
    },
    {
      stripe: "from-bloom-burgundy via-bloom-burgundy/60 to-transparent",
      glow: "group-hover:shadow-[0_0_40px_rgba(159,18,57,0.08)]",
      numberColor: "text-bloom-burgundy/[0.07]",
      dotColor: "bg-bloom-burgundy",
    },
  ];

  const accent = accents[index % accents.length];

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 50, scale: 0.97 }}
      animate={inView ? { opacity: 1, y: 0, scale: 1 } : {}}
      transition={{
        duration: 0.7,
        delay: index * 0.12,
        ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
      }}
      className="group relative"
    >
      <div
        className={`relative overflow-hidden rounded-2xl border border-glass-border bg-surface-elevated/80 backdrop-blur-sm p-8 md:p-10 h-full flex flex-col transition-all duration-500 ${accent.glow} group-hover:border-glass-hover cursor-default`}
      >
        {/* Left accent stripe */}
        <div
          className={`absolute left-0 top-0 bottom-0 w-[3px] bg-gradient-to-b ${accent.stripe}`}
        />

        {/* Watermark number behind content */}
        <span
          className={`absolute -right-4 -top-6 text-[140px] font-bold leading-none select-none pointer-events-none ${accent.numberColor}`}
        >
          {number}
        </span>

        {/* Content — no serif fonts here */}
        <div className="relative z-10 flex flex-col h-full">
          {/* Label with dot */}
          <div className="flex items-center gap-2 mb-6">
            <div className={`w-2 h-2 rounded-full ${accent.dotColor}`} />
            <span className="text-xs font-semibold text-text-muted uppercase tracking-[0.15em]">
              {label}
            </span>
          </div>

          {/* Question — bold sans, coral accent, NOT serif */}
          <h3 className="text-xl md:text-2xl font-bold text-coral leading-snug mb-4">
            {question}
          </h3>

          {/* Detail */}
          <p className="text-text-secondary text-sm leading-relaxed mt-auto">
            {detail}
          </p>
        </div>

        {/* Subtle hover gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-br from-white/[0.02] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />
      </div>
    </motion.div>
  );
}

export function Problem() {
  const { ref: sectionRef, inView: sectionInView } = useInView({
    threshold: 0.1,
  });

  return (
    <section
      id="problem"
      ref={sectionRef}
      className="relative py-32 md:py-40"
    >
      {/* Atmospheric bloom */}
      <div className="absolute top-0 right-0 w-[500px] h-[500px] bloom-burgundy opacity-30 translate-x-1/3 -translate-y-1/4 pointer-events-none" />

      <div className="max-w-6xl mx-auto px-6">
        {/* Section header */}
        <div className="max-w-2xl mb-20">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={sectionInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            The problem
          </motion.p>

          <StaggeredText
            text="Everyone wants a hobby. Almost nobody starts."
            as="h2"
            className="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight tracking-tight"
            highlightWords={["nobody"]}
            stagger={0.06}
          />
        </div>

        {/* Problem cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {problemCards.map((card, i) => (
            <ProblemCard key={card.number} {...card} index={i} />
          ))}
        </div>

        {/* Closing statement — no serif on closing text */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={sectionInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="mt-16 text-center text-lg text-text-secondary max-w-lg mx-auto"
        >
          Starting a hobby should feel exciting, not overwhelming.
          <span className="block mt-2 text-text-primary font-semibold">
            We built something to fix that.
          </span>
        </motion.p>
      </div>
    </section>
  );
}
