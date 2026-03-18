"use client";

import { useRef, useState, useEffect } from "react";
import { motion } from "framer-motion";
import dynamic from "next/dynamic";
import { useInView } from "@/hooks/useInView";
import { howItWorksSteps } from "@/lib/data";
import { StaggeredText } from "@/components/ui/StaggeredText";

/* Lazy-load the Three.js scene (no SSR) */
const JourneyScene = dynamic(
  () =>
    import("@/components/canvas/JourneyScene").then((m) => m.JourneyScene),
  { ssr: false }
);

/* ─── Step accent config ─────────────────────────────────────── */

const stepAccents = [
  {
    border: "border-[#5A9E8F]/25",
    glow: "shadow-[0_0_60px_rgba(90,158,143,0.06)]",
    number: "text-[#7DBDAB]",
    label: "text-[#7DBDAB]/70",
    dot: "bg-[#7DBDAB]",
    gradientFrom: "from-[#5A9E8F]/8",
  },
  {
    border: "border-coral/25",
    glow: "shadow-[0_0_60px_rgba(255,107,107,0.06)]",
    number: "text-coral",
    label: "text-coral/70",
    dot: "bg-coral",
    gradientFrom: "from-coral/8",
  },
  {
    border: "border-[#DAA520]/25",
    glow: "shadow-[0_0_60px_rgba(218,165,32,0.06)]",
    number: "text-[#DAA520]",
    label: "text-[#DAA520]/70",
    dot: "bg-[#DAA520]",
    gradientFrom: "from-[#DAA520]/8",
  },
];

/* ─── Component ──────────────────────────────────────────────── */

export function HowItWorks() {
  const { ref: sectionRef, inView } = useInView({ threshold: 0.05 });
  const stepsContainerRef = useRef<HTMLDivElement>(null);
  const [activeStep, setActiveStep] = useState(0);

  /* Track which step is closest to viewport center */
  useEffect(() => {
    const handleScroll = () => {
      if (!stepsContainerRef.current) return;
      const steps =
        stepsContainerRef.current.querySelectorAll("[data-step]");
      const viewportCenter = window.innerHeight * 0.45;

      let closestIndex = 0;
      let closestDistance = Infinity;

      steps.forEach((step, i) => {
        const rect = step.getBoundingClientRect();
        const distance = Math.abs(
          rect.top + rect.height / 2 - viewportCenter
        );
        if (distance < closestDistance) {
          closestDistance = distance;
          closestIndex = i;
        }
      });

      setActiveStep(closestIndex);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    handleScroll();
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <section
      id="how-it-works"
      ref={sectionRef}
      className="relative py-32 md:py-48 overflow-hidden"
    >
      {/* Atmospheric blooms — warm tones */}
      <div
        className="absolute top-1/4 right-0 w-[600px] h-[600px] translate-x-1/3 pointer-events-none opacity-[0.07]"
        style={{
          background:
            "radial-gradient(circle, rgba(218,165,32,0.6), transparent 70%)",
          filter: "blur(80px)",
        }}
      />
      <div
        className="absolute bottom-1/3 left-0 w-[500px] h-[500px] -translate-x-1/3 pointer-events-none opacity-[0.05]"
        style={{
          background:
            "radial-gradient(circle, rgba(255,107,107,0.5), transparent 70%)",
          filter: "blur(80px)",
        }}
      />

      <div className="max-w-7xl mx-auto px-6">
        {/* Section header */}
        <div className="max-w-2xl mb-20 md:mb-32">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-5"
          >
            How it works
          </motion.p>

          <StaggeredText
            text="Three steps from maybe to momentum."
            as="h2"
            className="text-[clamp(2rem,4.5vw,3.5rem)] font-bold leading-[1.1] tracking-tight"
            highlightWords={["momentum"]}
            stagger={0.07}
          />

          <motion.p
            initial={{ opacity: 0, y: 16 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.6 }}
            className="mt-6 text-lg text-text-secondary leading-relaxed max-w-lg"
          >
            No overwhelm. No endless browsing. Just a clear path from
            &ldquo;maybe&rdquo; to doing.
          </motion.p>
        </div>

        {/* Asymmetric layout: steps left, 3D scene right */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-start">
          {/* Left — Step cards */}
          <div ref={stepsContainerRef} className="space-y-6 lg:space-y-8">
            {howItWorksSteps.map((step, i) => {
              const accent = stepAccents[i];
              const isActive = i === activeStep;

              return (
                <motion.div
                  key={step.step}
                  data-step={i}
                  initial={{ opacity: 0, y: 40 }}
                  animate={inView ? { opacity: 1, y: 0 } : {}}
                  transition={{
                    duration: 0.7,
                    delay: 0.3 + i * 0.15,
                    ease: [0.33, 1, 0.68, 1] as [
                      number,
                      number,
                      number,
                      number,
                    ],
                  }}
                  className={`group relative rounded-2xl border transition-all duration-700 cursor-default ${
                    isActive
                      ? `bg-gradient-to-br ${accent.gradientFrom} to-transparent ${accent.border} ${accent.glow} p-8 md:p-10`
                      : "bg-transparent border-glass-border/30 p-8 md:p-10 opacity-50 hover:opacity-70"
                  }`}
                  onClick={() => setActiveStep(i)}
                >
                  {/* Step number + title row */}
                  <div className="flex items-center gap-4 mb-4">
                    <span
                      className={`text-2xl font-bold tabular-nums transition-colors duration-500 ${
                        isActive ? accent.number : "text-text-whisper"
                      }`}
                    >
                      {step.step}
                    </span>
                    <div
                      className={`h-px transition-all duration-500 ${
                        isActive ? "w-8" : "w-4"
                      } ${isActive ? accent.dot : "bg-text-whisper/40"}`}
                    />
                    <span
                      className={`text-xs font-semibold uppercase tracking-[0.15em] transition-colors duration-500 ${
                        isActive ? accent.label : "text-text-whisper"
                      }`}
                    >
                      {step.title}
                    </span>
                  </div>

                  {/* Headline */}
                  <h3
                    className={`text-xl md:text-2xl font-bold leading-snug tracking-tight transition-colors duration-500 ${
                      isActive ? "text-text-primary" : "text-text-muted"
                    }`}
                  >
                    {step.headline}
                  </h3>

                  {/* Description — expands when active */}
                  <motion.div
                    initial={false}
                    animate={{
                      opacity: isActive ? 1 : 0,
                      height: isActive ? "auto" : 0,
                      marginTop: isActive ? 14 : 0,
                    }}
                    transition={{ duration: 0.4, ease: "easeOut" }}
                    className="overflow-hidden"
                  >
                    <p className="text-text-secondary text-[15px] leading-relaxed max-w-md">
                      {step.description}
                    </p>
                  </motion.div>
                </motion.div>
              );
            })}
          </div>

          {/* Right — 3D journey scene (sticky on desktop) */}
          <div className="hidden lg:block">
            <div className="sticky top-32">
              <div className="h-[480px] rounded-2xl overflow-hidden relative">
                {/* Subtle border glow */}
                <div className="absolute inset-0 rounded-2xl border border-glass-border/20" />

                <JourneyScene activeStep={activeStep} />

                {/* Step indicator dots */}
                <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-3 z-10">
                  {howItWorksSteps.map((_, i) => (
                    <button
                      key={i}
                      onClick={() => setActiveStep(i)}
                      className={`rounded-full transition-all duration-500 ${
                        i === activeStep
                          ? `w-7 h-1.5 ${stepAccents[i].dot}`
                          : "w-1.5 h-1.5 bg-text-whisper/30 hover:bg-text-whisper/50"
                      }`}
                    />
                  ))}
                </div>
              </div>

              {/* Active step label below the scene */}
              <div className="mt-4 text-center">
                <motion.p
                  key={activeStep}
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3 }}
                  className={`text-xs font-semibold uppercase tracking-[0.15em] ${stepAccents[activeStep]?.label || "text-text-muted"}`}
                >
                  {howItWorksSteps[activeStep]?.title}
                </motion.p>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile — Compact step indicators (visible only on mobile) */}
        <div className="flex lg:hidden justify-center mt-10 gap-3">
          {howItWorksSteps.map((_, i) => (
            <button
              key={i}
              onClick={() => setActiveStep(i)}
              className={`rounded-full transition-all duration-500 ${
                i === activeStep
                  ? `w-8 h-2 ${stepAccents[i].dot}`
                  : "w-2 h-2 bg-text-whisper/30"
              }`}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
