"use client";

import { useRef, useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { howItWorksSteps } from "@/lib/data";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { HowItWorksVisual } from "./HowItWorksVisual";

gsap.registerPlugin(ScrollTrigger);

/* ─── Step accent colors ─────────────────────────────────── */

const stepAccents = [
  { border: "border-[#5A9E8F]", color: "text-[#7DBDAB]", dot: "bg-[#7DBDAB]" },
  { border: "border-coral", color: "text-coral", dot: "bg-coral" },
  { border: "border-[#9F1239]", color: "text-[#C45A72]", dot: "bg-[#C45A72]" },
  { border: "border-coral", color: "text-coral", dot: "bg-coral" },
];

const EASE: [number, number, number, number] = [0.23, 1, 0.32, 1];

/* ─── Component ──────────────────────────────────────────── */

export function HowItWorks() {
  const sectionRef = useRef<HTMLElement>(null);
  const pinRef = useRef<HTMLDivElement>(null);
  const [activeStep, setActiveStep] = useState(0);
  const activeStepRef = useRef(0);
  const [isMobile, setIsMobile] = useState(false);
  const { ref: headerRef, inView: headerInView } = useInView({ threshold: 0.3 });

  const updateStep = useCallback((step: number) => {
    if (activeStepRef.current !== step) {
      activeStepRef.current = step;
      setActiveStep(step);
    }
  }, []);

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
  }, []);

  // GSAP ScrollTrigger pin
  useEffect(() => {
    if (!sectionRef.current || !pinRef.current) return;

    const ctx = gsap.context(() => {
      ScrollTrigger.create({
        trigger: sectionRef.current,
        start: "top top",
        end: () => `+=${window.innerHeight * (howItWorksSteps.length + 0.5)}`,
        pin: pinRef.current!,
        pinSpacing: true,
        scrub: 0.5,
        onUpdate: (self) => {
          const step = Math.min(
            howItWorksSteps.length - 1,
            Math.floor(self.progress * howItWorksSteps.length)
          );
          updateStep(step);
        },
      });
    }, sectionRef);

    return () => ctx.revert();
  }, [updateStep]);

  return (
    <section id="how-it-works" ref={sectionRef} className="relative">
      <div
        ref={pinRef}
        className="relative h-screen bg-black overflow-hidden flex flex-col"
      >
        {/* ─── Section header (in flow, not absolute) ─── */}
        <div
          ref={headerRef}
          className="flex-shrink-0 max-w-7xl w-full mx-auto px-6 md:px-10 pt-16 md:pt-20 pb-6 md:pb-8"
        >
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold uppercase tracking-[0.25em] mb-3 mt-10"
            style={{ color: "#6A6A7A" }}
          >
            How it works
          </motion.p>
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.15, ease: EASE }}
            className="text-[clamp(1.5rem,3.5vw,2.5rem)] font-bold leading-[1.1] tracking-tight text-[#FAFAFA] max-w-md"
          >
            Four steps from{" "}
            <span className="font-serif italic text-coral">maybe</span> to
            momentum.
          </motion.h2>
        </div>

        {/* ─── Main content: cards left + visual right ─── */}
        <div className="flex-1 flex flex-col md:flex-row items-stretch max-w-7xl w-full mx-auto px-6 md:px-10 pb-10 md:pb-16 min-h-0">
          {/* Left — Step cards */}
          <div className="w-full md:w-[42%] flex flex-col justify-center gap-2 md:gap-2.5 flex-shrink-0 order-2 md:order-1">
            {howItWorksSteps.map((step, i) => {
              const isActive = i === activeStep;
              const accent = stepAccents[i];

              return (
                <motion.div
                  key={step.step}
                  animate={{
                    opacity: isActive ? 1 : 0.3,
                    x: isActive ? 0 : -4,
                    scale: isActive ? 1 : 0.98,
                  }}
                  transition={{ duration: 0.5, ease: EASE }}
                  className={`relative rounded-xl px-5 py-3.5 md:px-6 md:py-4 transition-colors duration-500 cursor-default ${
                    isActive
                      ? `border-l-[3px] ${accent.border} bg-white/[0.03] backdrop-blur-sm`
                      : "border-l-[3px] border-transparent"
                  }`}
                >
                  {/* Step number + label row */}
                  <div className="flex items-center gap-3 mb-0.5">
                    <span
                      className={`text-base md:text-lg font-bold tabular-nums transition-colors duration-500 ${
                        isActive ? accent.color : "text-[#3D3835]"
                      }`}
                    >
                      {step.step}
                    </span>
                    <div
                      className={`h-px transition-all duration-500 ${
                        isActive ? "w-6" : "w-3"
                      } ${isActive ? accent.dot : "bg-[#3D3835]"}`}
                    />
                    <span
                      className={`text-[10px] font-semibold uppercase tracking-[0.15em] transition-colors duration-500 ${
                        isActive ? accent.color : "text-[#3D3835]"
                      }`}
                    >
                      {step.title}
                    </span>
                  </div>

                  {/* Headline */}
                  <h3
                    className={`text-base md:text-lg font-bold leading-snug tracking-tight transition-colors duration-500 ${
                      isActive ? "text-[#FAFAFA]" : "text-[#6B6360]"
                    }`}
                  >
                    {step.headline}
                  </h3>

                  {/* Description — expands only when active */}
                  <motion.div
                    initial={false}
                    animate={{
                      opacity: isActive ? 1 : 0,
                      height: isActive ? "auto" : 0,
                      marginTop: isActive ? 6 : 0,
                    }}
                    transition={{ duration: 0.4, ease: "easeInOut" }}
                    className="overflow-hidden"
                  >
                    <p
                      className="text-[13px] leading-relaxed max-w-sm"
                      style={{ color: "#8A8A9A" }}
                    >
                      {step.description}
                    </p>
                  </motion.div>
                </motion.div>
              );
            })}

            {/* Progress dots */}
            <div className="flex items-center gap-2 mt-2 ml-5">
              {howItWorksSteps.map((_, i) => (
                <div
                  key={i}
                  className={`rounded-full transition-all duration-500 ${
                    i === activeStep
                      ? `w-6 h-1.5 ${stepAccents[i].dot}`
                      : i < activeStep
                        ? `w-1.5 h-1.5 ${stepAccents[i].dot} opacity-40`
                        : "w-1.5 h-1.5 bg-[#3D3835]"
                  }`}
                />
              ))}
            </div>
          </div>

          {/* Right — Lottie formation visual */}
          <div className="w-full md:w-[58%] h-[30vh] md:h-full relative order-1 md:order-2 mb-4 md:mb-0 md:ml-4">
            <HowItWorksVisual activeStep={activeStep} isMobile={isMobile} />
          </div>
        </div>
      </div>
    </section>
  );
}
