"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Compass, BookOpen, TrendingUp } from "lucide-react";
import { TextReveal } from "@/components/ui/TextReveal";

const pillars = [
  {
    icon: Compass,
    label: "Discover",
    description:
      "A feed of 72+ hobbies tailored to your vibe, budget, and available time.",
    color: "#FF6B6B",
    bgColor: "#FF6B6B15",
  },
  {
    icon: BookOpen,
    label: "Learn",
    description:
      "Beginner-friendly starter kits, step-by-step roadmaps, and common pitfalls to avoid.",
    color: "#7C3AED",
    bgColor: "#7C3AED15",
  },
  {
    icon: TrendingUp,
    label: "Track",
    description:
      "Save hobbies, check off milestones, build streaks, and watch your progress grow.",
    color: "#06D6A0",
    bgColor: "#06D6A015",
  },
];

export function SolutionSection() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });

  return (
    <section id="solution" className="relative pt-28 pb-20 px-6 md:px-12" ref={ref}>
      <div className="max-w-7xl mx-auto text-center">
        {/* Overline */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5 }}
          className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-4"
        >
          THE SOLUTION
        </motion.p>

        {/* Headline */}
        <TextReveal
          text="Everything you need to actually start."
          as="h2"
          className="font-serif text-[36px] md:text-[48px] font-bold leading-tight text-near-black mb-16 justify-center"
          highlight={["actually"]}
          staggerMs={80}
        />

        {/* Three pillars */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          {pillars.map((pillar, i) => (
            <motion.div
              key={pillar.label}
              initial={{ opacity: 0, y: 30 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{
                duration: 0.5,
                delay: i * 0.12 + 0.3,
                ease: [0.33, 1, 0.68, 1],
              }}
              className="flex flex-col items-center text-center"
            >
              {/* Icon circle */}
              <div
                className="w-20 h-20 rounded-full flex items-center justify-center mb-6"
                style={{ backgroundColor: pillar.bgColor }}
              >
                <pillar.icon size={32} style={{ color: pillar.color }} />
              </div>

              {/* Label */}
              <h3
                className="font-sans text-xl font-bold mb-3"
                style={{ color: pillar.color }}
              >
                {pillar.label}
              </h3>

              {/* Description */}
              <p className="font-sans text-[15px] leading-relaxed text-driftwood max-w-xs">
                {pillar.description}
              </p>
            </motion.div>
          ))}
        </div>

        {/* Connection line SVG */}
        <motion.div
          initial={{ scaleX: 0 }}
          animate={inView ? { scaleX: 1 } : {}}
          transition={{
            duration: 0.8,
            delay: 0.6,
            ease: [0.33, 1, 0.68, 1],
          }}
          className="hidden md:block w-2/3 h-px bg-gradient-to-r from-coral via-indigo to-sage mx-auto mt-8 origin-left"
          style={{ opacity: 0.3 }}
        />
      </div>
    </section>
  );
}
