"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Layers, Package, Map, CheckCircle } from "lucide-react";

const features = [
  {
    icon: Layers,
    title: "Discovery Feed",
    description:
      "Swipe through curated hobby cards. Each card gives you the 'vibe' and basic requirements in seconds.",
    bullets: ["Personalized AI matching", "Community-rated hobbies"],
  },
  {
    icon: Package,
    title: "Starter Kits",
    description:
      "Stop overthinking gear. Get clear breakdowns of initial costs and the essential gear you actually need.",
    bullets: ["Low-budget entry paths", "One-click shopping lists"],
  },
  {
    icon: Map,
    title: "Roadmaps",
    description:
      "Step-by-step milestones to guide your journey. From your first 15 minutes to your first 15 hours.",
    bullets: ["Actionable daily goals", "Trackable progress stats"],
  },
];

export function FeaturesSection() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });

  return (
    <section id="features" className="py-24" ref={ref}>
      <div className="max-w-7xl mx-auto px-6">
        {/* Top area: two-column layout */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 md:gap-16 mb-16">
          {/* Left column */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, ease: [0.33, 1, 0.68, 1] }}
          >
            <p className="text-coral uppercase tracking-widest text-sm font-bold mb-4">
              OUR PHILOSOPHY
            </p>
            <h2 className="font-serif text-4xl md:text-6xl font-bold text-near-black leading-tight">
              Everything you need to actually start.
            </h2>
          </motion.div>

          {/* Right column */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{
              duration: 0.5,
              delay: 0.15,
              ease: [0.33, 1, 0.68, 1],
            }}
            className="flex items-center"
          >
            <p className="text-driftwood text-lg leading-relaxed">
              The hardest part of a new hobby is knowing where to begin. We
              remove the intimidation barrier by curating exact equipment lists,
              cost breakdowns, and 30-day milestones.
            </p>
          </motion.div>
        </div>

        {/* Feature cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {features.map((feature, i) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 30 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{
                duration: 0.5,
                delay: i * 0.12 + 0.3,
                ease: [0.33, 1, 0.68, 1],
              }}
              className="glass hover-glow p-8 rounded-2xl"
            >
              {/* Icon */}
              <div className="w-14 h-14 rounded-xl bg-coral/10 flex items-center justify-center mb-6">
                <feature.icon size={28} className="text-coral" />
              </div>

              {/* Title */}
              <h3 className="text-2xl font-bold text-near-black mb-3">
                {feature.title}
              </h3>

              {/* Description */}
              <p className="text-driftwood leading-relaxed mb-5">
                {feature.description}
              </p>

              {/* Bullets */}
              <ul className="space-y-2">
                {feature.bullets.map((bullet) => (
                  <li key={bullet} className="flex items-center gap-2">
                    <CheckCircle size={18} className="text-coral flex-shrink-0" />
                    <span className="text-driftwood text-sm">{bullet}</span>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
