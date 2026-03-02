"use client";

import { useRef, useState } from "react";
import { motion, useInView, AnimatePresence } from "framer-motion";
import { DollarSign, Check, AlertTriangle } from "lucide-react";
import { GlassCard } from "@/components/ui/GlassCard";
import { TextReveal } from "@/components/ui/TextReveal";
import { hobbies } from "@/lib/hobbies";
import { cn } from "@/lib/utils";

type TabId = "kit" | "roadmap" | "pitfalls";

const tabs: { id: TabId; label: string }[] = [
  { id: "kit", label: "Starter Kit" },
  { id: "roadmap", label: "Roadmap" },
  { id: "pitfalls", label: "Pitfalls" },
];

export function DetailShowcase() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });
  const [activeTab, setActiveTab] = useState<TabId>("kit");
  const [completedSteps, setCompletedSteps] = useState<Set<string>>(new Set());
  const hobby = hobbies[0]; // Pottery

  const toggleStep = (stepId: string) => {
    setCompletedSteps((prev) => {
      const next = new Set(prev);
      if (next.has(stepId)) next.delete(stepId);
      else next.add(stepId);
      return next;
    });
  };

  return (
    <section className="relative py-20 px-6 md:px-12" ref={ref}>
      <div className="max-w-7xl mx-auto">
        {/* Overline */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5 }}
          className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-4 text-center"
        >
          BEGINNER-FRIENDLY CONTENT
        </motion.p>

        {/* Headline with strikethrough on "Google it" */}
        <TextReveal
          text='No more "just Google it."'
          as="h2"
          className="font-serif text-[36px] md:text-[44px] font-bold leading-tight text-near-black mb-4 justify-center"
          staggerMs={80}
        />

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="font-sans text-[15px] leading-relaxed text-driftwood text-center max-w-xl mx-auto mb-12"
        >
          Every hobby comes with a complete starter package: what to buy, what
          to avoid, and exactly what to do first.
        </motion.p>

        {/* Tab bar */}
        <div className="flex justify-center gap-2 mb-8">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={cn(
                "px-5 py-2.5 rounded-badge font-sans text-sm font-semibold transition-all cursor-pointer",
                activeTab === tab.id
                  ? "bg-coral text-white"
                  : "bg-sand text-driftwood hover:text-near-black"
              )}
              style={{ transitionDuration: "250ms" }}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Tab content */}
        <div className="max-w-2xl mx-auto">
          <AnimatePresence mode="wait">
            {activeTab === "kit" && (
              <motion.div
                key="kit"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.25 }}
              >
                <GlassCard className="p-6">
                  <h3 className="font-sans text-lg font-bold text-near-black mb-4">
                    Starter Kit for {hobby.name}
                  </h3>
                  <div className="space-y-3">
                    {hobby.kitItems.map((item, i) => (
                      <div
                        key={i}
                        className="flex items-center justify-between py-3 border-b border-sand-dark/30 last:border-0"
                      >
                        <div className="flex items-center gap-3">
                          <DollarSign
                            size={16}
                            className="text-coral/60 flex-shrink-0"
                          />
                          <span className="font-sans text-[15px] text-near-black">
                            {item.name}
                          </span>
                          {item.essential && (
                            <span className="px-2 py-0.5 rounded-badge bg-coral-pale text-coral font-mono text-[10px] font-bold">
                              ESSENTIAL
                            </span>
                          )}
                        </div>
                        <span className="font-mono text-sm font-bold text-coral">
                          {item.price}
                        </span>
                      </div>
                    ))}
                  </div>
                </GlassCard>
              </motion.div>
            )}

            {activeTab === "roadmap" && (
              <motion.div
                key="roadmap"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.25 }}
              >
                <GlassCard className="p-6">
                  <h3 className="font-sans text-lg font-bold text-near-black mb-4">
                    Your First Steps
                  </h3>
                  <div className="space-y-4">
                    {hobby.roadmapSteps.map((step, i) => {
                      const isComplete = completedSteps.has(step.id);
                      const allDone = completedSteps.size === hobby.roadmapSteps.length;

                      return (
                        <div key={step.id}>
                          <button
                            onClick={() => toggleStep(step.id)}
                            className={cn(
                              "w-full flex items-start gap-4 p-4 rounded-tile transition-colors text-left cursor-pointer",
                              isComplete ? "bg-coral-pale" : "bg-warm-white"
                            )}
                            style={{ transitionDuration: "200ms" }}
                          >
                            {/* Animated checkbox — matching roadmap_step_tile.dart */}
                            <div className="relative flex-shrink-0 mt-0.5">
                              <motion.div
                                className="w-7 h-7 rounded-full border-2 flex items-center justify-center"
                                style={{
                                  borderColor: isComplete ? "#FF6B6B" : "#363650",
                                  backgroundColor: isComplete ? "#FF6B6B" : "transparent",
                                }}
                                animate={{
                                  borderColor: isComplete ? "#FF6B6B" : "#363650",
                                  backgroundColor: isComplete ? "#FF6B6B" : "transparent",
                                }}
                                transition={{ duration: 0.2, ease: "easeInOut" }}
                              >
                                <motion.div
                                  initial={false}
                                  animate={{
                                    scale: isComplete ? 1 : 0,
                                    opacity: isComplete ? 1 : 0,
                                  }}
                                  transition={{
                                    scale: {
                                      type: "spring",
                                      stiffness: 500,
                                      damping: 15,
                                      duration: 0.24,
                                    },
                                    opacity: { duration: 0.12 },
                                  }}
                                >
                                  <Check size={14} className="text-white" strokeWidth={3} />
                                </motion.div>
                              </motion.div>
                            </div>

                            <div className="flex-1">
                              <div className="flex items-center gap-2 mb-1">
                                <span className="font-mono text-[11px] text-warm-gray">
                                  Step {i + 1}
                                </span>
                                <span className="px-2 py-0.5 rounded-badge bg-sand font-mono text-[11px] text-driftwood">
                                  {step.timeEstimate}
                                </span>
                              </div>
                              <p
                                className={cn(
                                  "font-sans text-[15px] font-semibold transition-colors",
                                  isComplete
                                    ? "text-driftwood line-through"
                                    : "text-near-black"
                                )}
                                style={{ transitionDuration: "200ms" }}
                              >
                                {step.title}
                              </p>
                              <p className="font-sans text-sm text-driftwood mt-1">
                                {step.description}
                              </p>
                            </div>
                          </button>

                          {/* Milestone badge when all steps complete */}
                          {i === hobby.roadmapSteps.length - 1 && (
                            <AnimatePresence>
                              {allDone && (
                                <motion.div
                                  initial={{ scale: 0, opacity: 0 }}
                                  animate={{ scale: 1, opacity: 1 }}
                                  exit={{ scale: 0, opacity: 0 }}
                                  transition={{
                                    type: "spring",
                                    stiffness: 400,
                                    damping: 20,
                                  }}
                                  className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-badge bg-amber-pale"
                                >
                                  <span className="font-mono text-[10px] font-bold text-amber tracking-wide">
                                    MILESTONE REACHED
                                  </span>
                                </motion.div>
                              )}
                            </AnimatePresence>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </GlassCard>
              </motion.div>
            )}

            {activeTab === "pitfalls" && (
              <motion.div
                key="pitfalls"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.25 }}
              >
                <GlassCard className="p-6">
                  <h3 className="font-sans text-lg font-bold text-near-black mb-4">
                    Common Mistakes to Avoid
                  </h3>
                  <div className="space-y-4">
                    {hobby.pitfalls.map((pitfall, i) => (
                      <div key={i} className="flex items-start gap-3 p-4 rounded-tile bg-warm-white">
                        <AlertTriangle
                          size={18}
                          className="text-amber flex-shrink-0 mt-0.5"
                        />
                        <p className="font-sans text-[15px] leading-relaxed text-near-black">
                          {pitfall}
                        </p>
                      </div>
                    ))}
                  </div>
                </GlassCard>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </section>
  );
}
