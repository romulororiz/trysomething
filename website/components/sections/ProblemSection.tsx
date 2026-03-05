"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Search, Clock, TrendingDown } from "lucide-react";
import { GlassCard } from "@/components/ui/GlassCard";
import { TextReveal } from "@/components/ui/TextReveal";

const painPoints = [
  {
    icon: Search,
    question: '"I want to try something, but what?"',
    body: "You scroll Pinterest boards and bookmark YouTube videos. But you never actually start.",
  },
  {
    icon: Clock,
    question: '"Where do I even begin?"',
    body: "Every hobby guide assumes you already know the basics. You just want someone to say: do this first.",
  },
  {
    icon: TrendingDown,
    question: '"What if I waste money?"',
    body: "You've been burned before. That guitar in the closet. Those running shoes with the tags still on.",
  },
];

export function ProblemSection() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });

  return (
    <section className="relative pt-20 pb-28 px-6 md:px-12" ref={ref}>
      <div className="max-w-7xl mx-auto">
        {/* Overline */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5 }}
          className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-4 text-center"
        >
          THE PROBLEM
        </motion.p>

        {/* Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12 mb-16">
          {painPoints.map((point, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 40 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{
                duration: 0.5,
                delay: i * 0.15,
                ease: [0.33, 1, 0.68, 1],
              }}
            >
              <GlassCard hover className="p-8 h-full">
                {/* Icon */}
                <div className="w-12 h-12 rounded-tile bg-coral-pale flex items-center justify-center mb-6">
                  <motion.div
                    initial={{ color: "#6B6B80" }}
                    animate={inView ? { color: "#FF6B6B" } : {}}
                    transition={{ duration: 0.6, delay: i * 0.15 + 0.3 }}
                  >
                    <point.icon size={24} />
                  </motion.div>
                </div>

                {/* Question — serif italic with wave underline */}
                <p className="font-serif text-xl font-bold text-near-black mb-3 leading-snug wave-underline visible">
                  {point.question}
                </p>

                {/* Body */}
                <p className="font-sans text-[15px] leading-relaxed text-driftwood">
                  {point.body}
                </p>
              </GlassCard>
            </motion.div>
          ))}
        </div>

        {/* Closing statement */}
        <TextReveal
          text="Starting a hobby should feel exciting, not overwhelming."
          as="p"
          className="font-serif text-2xl md:text-3xl font-bold text-near-black text-center max-w-2xl mx-auto leading-snug"
          highlight={["exciting,"]}
          staggerMs={60}
        />

        {/* Visual separator */}
        <div className="mt-16 mx-auto w-24 h-px bg-gradient-to-r from-transparent via-stone to-transparent" />
      </div>
    </section>
  );
}
