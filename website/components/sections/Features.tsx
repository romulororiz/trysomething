"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { Sparkles, Map, MessageCircle } from "lucide-react";

const features = [
  {
    number: "01",
    icon: Sparkles,
    title: "AI that actually knows you",
    description:
      "Five minutes of honest answers. Not a personality quiz — an algorithm that weighs your time, budget, energy, and the things that light you up. One hobby. The right one.",
    accent: {
      glow: "rgba(218, 165, 32, 0.12)",
      glowStrong: "rgba(218, 165, 32, 0.25)",
      text: "text-[#DAA520]",
      bg: "bg-[#DAA520]",
      border: "border-[#DAA520]/15",
      dot: "bg-[#DAA520]",
    },
    stats: ["150+ hobbies analyzed", "5-minute match", "Personalized reasoning"],
  },
  {
    number: "02",
    icon: Map,
    title: "A roadmap, not a reading list",
    description:
      "Day one: what to buy, where to go, what to do first. Week one: your first small win. Month one: a new part of your identity. Every step is concrete.",
    accent: {
      glow: "rgba(255, 107, 107, 0.10)",
      glowStrong: "rgba(255, 107, 107, 0.22)",
      text: "text-coral",
      bg: "bg-coral",
      border: "border-coral/15",
      dot: "bg-coral",
    },
    stats: ["4-week guided plan", "Starter kit with prices", "Common pitfalls flagged"],
  },
  {
    number: "03",
    icon: MessageCircle,
    title: "A coach that notices when you stall",
    description:
      "Not a chatbot that cheers you on. An AI coach that reads your pace, spots the drop-off, and says exactly the right thing to pull you back in.",
    accent: {
      glow: "rgba(90, 158, 143, 0.10)",
      glowStrong: "rgba(90, 158, 143, 0.22)",
      text: "text-[#7DBDAB]",
      bg: "bg-[#7DBDAB]",
      border: "border-[#7DBDAB]/15",
      dot: "bg-[#7DBDAB]",
    },
    stats: ["Adaptive pacing", "Rescue mode", "Reflection prompts"],
  },
];

function FeatureCard({
  feature,
  index,
}: {
  feature: (typeof features)[0];
  index: number;
}) {
  const { ref, inView } = useInView({ threshold: 0.15 });
  const Icon = feature.icon;
  const isReversed = index % 2 === 1;

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 60 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{
        duration: 0.9,
        delay: 0.1,
        ease: [0.33, 1, 0.68, 1],
      }}
      className="relative"
    >
      {/* Glass card container */}
      <div
        className={`relative rounded-3xl border ${feature.accent.border} bg-glass overflow-hidden transition-all duration-500 hover:border-glass-hover`}
        style={{
          boxShadow: `0 0 80px ${feature.accent.glow}, inset 0 1px 0 rgba(255,255,255,0.04)`,
        }}
      >
        {/* Subtle noise texture overlay */}
        <div className="noise absolute inset-0 pointer-events-none" />

        {/* Accent glow in top corner */}
        <div
          className="absolute -top-24 pointer-events-none w-[300px] h-[300px] rounded-full blur-3xl opacity-40"
          style={{
            background: `radial-gradient(circle, ${feature.accent.glowStrong}, transparent 70%)`,
            ...(isReversed ? { right: "-80px" } : { left: "-80px" }),
          }}
        />

        <div
          className={`relative z-10 flex flex-col ${
            isReversed ? "md:flex-row-reverse" : "md:flex-row"
          } items-start gap-8 md:gap-12 lg:gap-16 p-8 md:p-12 lg:p-16`}
        >
          {/* Icon + number side */}
          <div className="flex-shrink-0 flex flex-col items-center gap-4">
            {/* Icon with glow ring */}
            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={inView ? { opacity: 1, scale: 1 } : {}}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="relative"
            >
              {/* Glow behind icon */}
              <div
                className="absolute inset-0 rounded-2xl blur-xl scale-150 opacity-50"
                style={{
                  background: `radial-gradient(circle, ${feature.accent.glowStrong}, transparent 70%)`,
                }}
              />
              <div
                className={`relative w-16 h-16 md:w-20 md:h-20 rounded-2xl ${feature.accent.border} border bg-surface-elevated/80 backdrop-blur-sm flex items-center justify-center`}
              >
                <Icon
                  size={32}
                  className={feature.accent.text}
                  strokeWidth={1.5}
                />
              </div>
            </motion.div>

            {/* Number below icon */}
            <motion.span
              initial={{ opacity: 0 }}
              animate={inView ? { opacity: 1 } : {}}
              transition={{ duration: 0.5, delay: 0.4 }}
              className={`font-serif italic text-5xl md:text-6xl ${feature.accent.text} opacity-20 select-none leading-none`}
            >
              {feature.number}
            </motion.span>
          </div>

          {/* Content side */}
          <div className="flex-1 min-w-0">
            <motion.h3
              initial={{ opacity: 0, y: 20 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-[clamp(1.5rem,3vw,2.25rem)] font-bold leading-tight tracking-tight mb-4"
            >
              {feature.title}
            </motion.h3>

            <motion.p
              initial={{ opacity: 0, y: 16 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.6, delay: 0.35 }}
              className="text-base md:text-lg text-text-secondary leading-relaxed max-w-lg mb-8"
            >
              {feature.description}
            </motion.p>

            {/* Stats as subtle glass chips */}
            <motion.div
              initial={{ opacity: 0, y: 12 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.5 }}
              className="flex flex-wrap gap-3"
            >
              {feature.stats.map((stat) => (
                <span
                  key={stat}
                  className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-surface-elevated/60 border border-glass-border text-xs font-medium text-text-muted tracking-wide"
                >
                  <span
                    className={`w-1.5 h-1.5 rounded-full ${feature.accent.dot}`}
                  />
                  {stat}
                </span>
              ))}
            </motion.div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

export function Features() {
  const { ref: headerRef, inView: headerInView } = useInView({
    threshold: 0.2,
  });

  return (
    <section id="features" className="relative py-32 md:py-48 overflow-hidden">
      {/* Atmospheric blooms */}
      <div
        className="absolute top-1/4 right-0 w-[600px] h-[600px] translate-x-1/3 pointer-events-none opacity-20"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(218,165,32,0.15), transparent 70%)",
        }}
      />
      <div
        className="absolute bottom-1/4 left-0 w-[500px] h-[500px] -translate-x-1/3 pointer-events-none opacity-20"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(255,107,107,0.10), transparent 70%)",
        }}
      />

      <div className="max-w-5xl mx-auto px-6">
        {/* Section header */}
        <div ref={headerRef} className="max-w-2xl mb-20 md:mb-28">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            What you get
          </motion.p>

          <StaggeredText
            text="Three things nobody else gives you."
            as="h2"
            className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-tight tracking-tight"
            highlightWords={["nobody"]}
            stagger={0.07}
          />

          <motion.p
            initial={{ opacity: 0, y: 16 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-6 text-lg text-text-secondary leading-relaxed"
          >
            Not features for the sake of features. Three pillars that turn
            &ldquo;I should try something&rdquo; into &ldquo;I&rsquo;m doing
            this.&rdquo;
          </motion.p>
        </div>

        {/* Stacked feature cards */}
        <div className="space-y-12 md:space-y-16">
          {features.map((feature, i) => (
            <FeatureCard key={feature.number} feature={feature} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
