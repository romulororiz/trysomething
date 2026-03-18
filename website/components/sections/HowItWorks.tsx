"use client";

import { useRef, useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import dynamic from "next/dynamic";
import { useInView } from "@/hooks/useInView";
import { howItWorksSteps } from "@/lib/data";
import { StaggeredText } from "@/components/ui/StaggeredText";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

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
  const { ref: headerRef, inView } = useInView({ threshold: 0.3 });
  const sectionRef = useRef<HTMLElement>(null);
  const pinContainerRef = useRef<HTMLDivElement>(null);
  const [activeStep, setActiveStep] = useState(0);
  const activeStepRef = useRef(0);

  /* Sync ref with state to avoid stale closures in ScrollTrigger */
  const updateActiveStep = useCallback((step: number) => {
    if (activeStepRef.current !== step) {
      activeStepRef.current = step;
      setActiveStep(step);
    }
  }, []);

  /* ─── GSAP ScrollTrigger pin ─────────────────────────────── */
  useEffect(() => {
    if (!sectionRef.current || !pinContainerRef.current) return;

    const ctx = gsap.context(() => {
      ScrollTrigger.create({
        trigger: sectionRef.current,
        start: "top top",
        end: () => `+=${window.innerHeight * (howItWorksSteps.length + 0.5)}`,
        pin: pinContainerRef.current!,
        pinSpacing: true,
        scrub: true,
        onUpdate: (self) => {
          const progress = self.progress;
          const stepCount = howItWorksSteps.length;
          const step = Math.min(
            Math.floor(progress * stepCount),
            stepCount - 1
          );
          updateActiveStep(step);
        },
      });
    }, sectionRef);

    return () => ctx.revert();
  }, [updateActiveStep]);

  return (
    <section
      id="how-it-works"
      ref={sectionRef}
      className="relative"
    >
      <div ref={pinContainerRef} className="relative min-h-screen overflow-hidden">
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

        <div className="max-w-7xl mx-auto px-6 py-24 md:py-32 flex flex-col h-screen justify-center">
          {/* Section header */}
          <div ref={headerRef} className="max-w-2xl mb-12 md:mb-16">
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
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-16 items-start flex-1 min-h-0">
            {/* Left — Step cards (stacked, only active one expanded) */}
            <div className="space-y-4 lg:space-y-5">
              {howItWorksSteps.map((step, i) => {
                const accent = stepAccents[i];
                const isActive = i === activeStep;

                return (
                  <motion.div
                    key={step.step}
                    initial={{ opacity: 0, y: 30 }}
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
                    className={`group relative rounded-2xl border transition-all duration-700 cursor-pointer ${
                      isActive
                        ? `bg-gradient-to-br ${accent.gradientFrom} to-transparent ${accent.border} ${accent.glow} p-6 md:p-8`
                        : "bg-transparent border-glass-border/30 p-6 md:p-8 opacity-40 hover:opacity-60"
                    }`}
                    onClick={() => updateActiveStep(i)}
                  >
                    {/* Step number + title row */}
                    <div className="flex items-center gap-4 mb-2">
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
                      className={`text-lg md:text-xl font-bold leading-snug tracking-tight transition-colors duration-500 ${
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
                        marginTop: isActive ? 10 : 0,
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

              {/* Progress bar showing scroll position through steps */}
              <div className="flex items-center gap-3 pt-4">
                {howItWorksSteps.map((_, i) => (
                  <button
                    key={i}
                    onClick={() => updateActiveStep(i)}
                    className={`rounded-full transition-all duration-500 ${
                      i === activeStep
                        ? `w-8 h-2 ${stepAccents[i].dot}`
                        : i < activeStep
                          ? `w-2 h-2 ${stepAccents[i].dot} opacity-40`
                          : "w-2 h-2 bg-text-whisper/30"
                    }`}
                  />
                ))}
              </div>
            </div>

            {/* Right — 3D journey scene (visible on desktop) */}
            <div className="hidden lg:flex items-center justify-center">
              <div className="w-full h-[420px] rounded-2xl overflow-hidden relative">
                {/* Subtle border glow */}
                <div className="absolute inset-0 rounded-2xl border border-glass-border/20" />

                <JourneyScene activeStep={activeStep} />

                {/* Active step label below the scene */}
                <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-10">
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
        </div>
      </div>
    </section>
  );
}
