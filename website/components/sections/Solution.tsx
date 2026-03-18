"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { Compass, Package, Flame } from "lucide-react";

const pillars = [
  {
    icon: Compass,
    title: "Personalized matching",
    description:
      "Not a catalogue. An algorithm that understands your time, budget, energy, and personality — then surfaces one perfect match.",
    accent: {
      icon: "text-bloom-teal",
      bg: "bg-bloom-teal/10",
      border: "group-hover:border-bloom-teal/25",
      glow: "group-hover:shadow-[0_0_50px_rgba(13,148,136,0.08)]",
      gradient: "from-bloom-teal/8 via-transparent to-transparent",
      line: "bg-bloom-teal",
    },
    stats: ["150+ hobbies", "5 min quiz", "1 perfect match"],
  },
  {
    icon: Package,
    title: "Everything to start",
    description:
      "A starter kit with exact prices. A step-by-step roadmap. Common pitfalls to avoid. No research rabbit holes — just begin.",
    accent: {
      icon: "text-coral",
      bg: "bg-coral/10",
      border: "group-hover:border-coral/25",
      glow: "group-hover:shadow-[0_0_50px_rgba(255,107,107,0.08)]",
      gradient: "from-coral/8 via-transparent to-transparent",
      line: "bg-coral",
    },
    stats: ["Full starter kit", "4-week roadmap", "Cost breakdown"],
  },
  {
    icon: Flame,
    title: "A reason to keep going",
    description:
      "A weekly plan that adapts. An AI coach that notices when you stall. Reflection prompts that make progress visible.",
    accent: {
      icon: "text-bloom-burgundy",
      bg: "bg-bloom-burgundy/10",
      border: "group-hover:border-bloom-burgundy/25",
      glow: "group-hover:shadow-[0_0_50px_rgba(159,18,57,0.08)]",
      gradient: "from-bloom-burgundy/8 via-transparent to-transparent",
      line: "bg-bloom-burgundy",
    },
    stats: ["AI coach", "30-day plan", "Rescue mode"],
  },
];

export function Solution() {
  const { ref, inView } = useInView({ threshold: 0.1 });

  return (
    <section ref={ref} className="relative py-32 md:py-40">
      {/* Background bloom */}
      <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bloom-teal opacity-20 -translate-x-1/3 translate-y-1/4 pointer-events-none" />

      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <div className="max-w-2xl mb-20">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            The solution
          </motion.p>

          <StaggeredText
            text="Match. Start. Stay with it."
            as="h2"
            className="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight tracking-tight"
            highlightWords={["Stay"]}
            stagger={0.08}
          />

          <motion.p
            initial={{ opacity: 0, y: 16 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-6 text-lg text-text-secondary leading-relaxed"
          >
            TrySomething replaces the entire &ldquo;figuring it out&rdquo;
            phase with a clear path from curiosity to committed.
          </motion.p>
        </div>

        {/* Premium pillar cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {pillars.map((pillar, i) => {
            const Icon = pillar.icon;
            return (
              <motion.div
                key={pillar.title}
                initial={{ opacity: 0, y: 50, scale: 0.97 }}
                animate={inView ? { opacity: 1, y: 0, scale: 1 } : {}}
                transition={{
                  duration: 0.7,
                  delay: 0.3 + i * 0.12,
                  ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
                }}
                className="group"
              >
                <div
                  className={`relative overflow-hidden rounded-2xl border border-glass-border bg-surface-elevated/80 backdrop-blur-sm p-8 h-full flex flex-col transition-all duration-500 ${pillar.accent.glow} ${pillar.accent.border} cursor-default`}
                >
                  {/* Top gradient accent */}
                  <div
                    className={`absolute top-0 left-0 right-0 h-32 bg-gradient-to-b ${pillar.accent.gradient} pointer-events-none`}
                  />

                  {/* Top accent line */}
                  <div
                    className={`absolute top-0 left-8 right-8 h-[2px] ${pillar.accent.line} opacity-40 rounded-full`}
                  />

                  <div className="relative z-10 flex flex-col h-full">
                    {/* Icon with backdrop */}
                    <div className="relative mb-8">
                      <div
                        className={`w-14 h-14 rounded-2xl ${pillar.accent.bg} flex items-center justify-center`}
                      >
                        <Icon size={24} className={pillar.accent.icon} />
                      </div>
                      {/* Icon ambient glow */}
                      <div
                        className={`absolute inset-0 w-14 h-14 rounded-2xl ${pillar.accent.bg} blur-xl opacity-50`}
                      />
                    </div>

                    {/* Title — sans serif, bold */}
                    <h3 className="text-xl font-bold text-text-primary mb-3">
                      {pillar.title}
                    </h3>

                    {/* Description */}
                    <p className="text-sm text-text-secondary leading-relaxed mb-8">
                      {pillar.description}
                    </p>

                    {/* Stats chips */}
                    <div className="mt-auto flex flex-wrap gap-2">
                      {pillar.stats.map((stat) => (
                        <span
                          key={stat}
                          className="px-2.5 py-1 rounded-lg bg-glass border border-glass-border text-[11px] font-medium text-text-muted"
                        >
                          {stat}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Hover gradient overlay */}
                  <div className="absolute inset-0 bg-gradient-to-br from-white/[0.02] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
