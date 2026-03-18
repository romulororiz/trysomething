"use client";

import { useRef, useState, useEffect } from "react";
import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { howItWorksSteps } from "@/lib/data";
import { StaggeredText } from "@/components/ui/StaggeredText";

const accentMap: Record<
  string,
  {
    pill: string;
    border: string;
    glow: string;
    gradient: string;
    line: string;
    stepBg: string;
  }
> = {
  teal: {
    pill: "bg-bloom-teal/15 text-bloom-teal border-bloom-teal/30",
    border: "border-bloom-teal/20",
    glow: "shadow-[0_0_60px_rgba(13,148,136,0.06)]",
    gradient: "from-bloom-teal/6 via-transparent to-transparent",
    line: "from-bloom-teal",
    stepBg: "bg-bloom-teal/8",
  },
  coral: {
    pill: "bg-coral/15 text-coral border-coral/30",
    border: "border-coral/20",
    glow: "shadow-[0_0_60px_rgba(255,107,107,0.06)]",
    gradient: "from-coral/6 via-transparent to-transparent",
    line: "from-coral",
    stepBg: "bg-coral/8",
  },
  burgundy: {
    pill: "bg-bloom-burgundy/15 text-bloom-burgundy border-bloom-burgundy/30",
    border: "border-bloom-burgundy/20",
    glow: "shadow-[0_0_60px_rgba(159,18,57,0.06)]",
    gradient: "from-bloom-burgundy/6 via-transparent to-transparent",
    line: "from-bloom-burgundy",
    stepBg: "bg-bloom-burgundy/8",
  },
};

export function HowItWorks() {
  const { ref: sectionRef, inView } = useInView({ threshold: 0.05 });
  const containerRef = useRef<HTMLDivElement>(null);
  const [activeStep, setActiveStep] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      if (!containerRef.current) return;
      const steps = containerRef.current.querySelectorAll("[data-step]");
      const viewportCenter = window.innerHeight * 0.4;

      let closestIndex = 0;
      let closestDistance = Infinity;

      steps.forEach((step, i) => {
        const rect = step.getBoundingClientRect();
        const distance = Math.abs(rect.top + rect.height / 2 - viewportCenter);
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
      className="relative py-32 md:py-40"
    >
      <div className="absolute top-1/3 right-0 w-[500px] h-[500px] bloom-teal opacity-20 translate-x-1/3 pointer-events-none" />

      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <div className="max-w-2xl mb-24">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            How it works
          </motion.p>

          <StaggeredText
            text="Three steps from maybe to momentum."
            as="h2"
            className="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight tracking-tight"
            highlightWords={["momentum"]}
            stagger={0.07}
          />
        </div>

        <div ref={containerRef} className="relative">
          <div className="grid grid-cols-1 lg:grid-cols-[200px_1fr] gap-8 lg:gap-16">
            {/* Sticky left indicator (desktop) */}
            <div className="hidden lg:block">
              <div className="sticky top-40 space-y-6">
                {howItWorksSteps.map((step, i) => {
                  const a = accentMap[step.accent];
                  return (
                    <button
                      key={step.step}
                      onClick={() => {
                        containerRef.current
                          ?.querySelector(`[data-step="${i}"]`)
                          ?.scrollIntoView({
                            behavior: "smooth",
                            block: "center",
                          });
                      }}
                      className={`flex items-center gap-3 transition-all duration-300 cursor-pointer ${
                        i === activeStep
                          ? "opacity-100"
                          : "opacity-30 hover:opacity-50"
                      }`}
                    >
                      <div
                        className={`w-10 h-10 rounded-xl border flex items-center justify-center text-sm font-bold transition-all duration-300 ${
                          i === activeStep
                            ? a.pill
                            : "border-text-whisper text-text-whisper"
                        }`}
                      >
                        {step.step}
                      </div>
                      <span
                        className={`text-sm font-semibold transition-colors duration-300 ${
                          i === activeStep
                            ? "text-text-primary"
                            : "text-text-whisper"
                        }`}
                      >
                        {step.title}
                      </span>
                    </button>
                  );
                })}

                {/* Progress line */}
                <div className="ml-5 w-px h-20 bg-text-whisper/20 relative overflow-hidden">
                  <motion.div
                    className={`absolute top-0 left-0 w-full bg-gradient-to-b ${
                      accentMap[howItWorksSteps[activeStep].accent].line
                    } to-transparent`}
                    animate={{
                      height: `${
                        ((activeStep + 1) / howItWorksSteps.length) * 100
                      }%`,
                    }}
                    transition={{
                      duration: 0.5,
                      ease: [0.33, 1, 0.68, 1] as [
                        number,
                        number,
                        number,
                        number,
                      ],
                    }}
                  />
                </div>
              </div>
            </div>

            {/* Step cards — premium treatment */}
            <div className="space-y-8 lg:space-y-12">
              {howItWorksSteps.map((step, i) => {
                const a = accentMap[step.accent];
                const isActive = i === activeStep;

                return (
                  <motion.div
                    key={step.step}
                    data-step={i}
                    initial={{ opacity: 0, y: 50, scale: 0.97 }}
                    animate={inView ? { opacity: 1, y: 0, scale: 1 } : {}}
                    transition={{
                      duration: 0.7,
                      delay: 0.2 + i * 0.12,
                      ease: [0.33, 1, 0.68, 1] as [
                        number,
                        number,
                        number,
                        number,
                      ],
                    }}
                    className={`relative overflow-hidden rounded-2xl border bg-surface-elevated/80 backdrop-blur-sm transition-all duration-500 ${
                      isActive
                        ? `${a.border} ${a.glow}`
                        : "border-glass-border opacity-50"
                    }`}
                  >
                    {/* Top gradient accent */}
                    <div
                      className={`absolute top-0 left-0 right-0 h-40 bg-gradient-to-b ${a.gradient} pointer-events-none`}
                    />

                    <div className="relative z-10 p-8 md:p-10">
                      {/* Mobile step badge */}
                      <div className="flex items-center gap-3 mb-6 lg:hidden">
                        <div
                          className={`w-10 h-10 rounded-xl border flex items-center justify-center text-sm font-bold ${a.pill}`}
                        >
                          {step.step}
                        </div>
                        <span className="text-sm font-semibold text-text-primary">
                          {step.title}
                        </span>
                      </div>

                      {/* Large step number watermark (desktop) */}
                      <span className="hidden lg:block absolute -right-2 -top-4 text-[120px] font-bold leading-none select-none pointer-events-none text-text-primary/[0.03]">
                        {step.step}
                      </span>

                      <h3 className="text-2xl md:text-3xl font-bold text-text-primary mb-4">
                        {step.headline}
                      </h3>

                      <p className="text-text-secondary leading-relaxed max-w-lg">
                        {step.description}
                      </p>
                    </div>
                  </motion.div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
