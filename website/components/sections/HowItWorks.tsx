"use client";

import { useRef, useState, useCallback, useEffect } from "react";
import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { howItWorksSteps } from "@/lib/data";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { HowItWorksVisual } from "./HowItWorksVisual";

gsap.registerPlugin(ScrollTrigger);

const stepAccents = [
  { border: "border-coral", color: "text-coral", dot: "bg-coral" },
  { border: "border-coral", color: "text-coral", dot: "bg-coral" },
  { border: "border-coral", color: "text-coral", dot: "bg-coral" },
  { border: "border-coral", color: "text-coral", dot: "bg-coral" },
];

const EASE: [number, number, number, number] = [0.23, 1, 0.32, 1];

export function HowItWorks() {
  const sectionRef = useRef<HTMLElement>(null);
  const pinRef = useRef<HTMLDivElement>(null);
  const [activeStep, setActiveStep] = useState(0);
  const activeStepRef = useRef(0);
  const { ref: headerRef, inView: headerInView } = useInView({ threshold: 0.3 });

  const updateStep = useCallback((step: number) => {
    if (activeStepRef.current !== step) {
      activeStepRef.current = step;
      setActiveStep(step);
    }
  }, []);

  // GSAP pin — only activates on desktop via CSS matchMedia (no JS isMobile)
  useEffect(() => {
    if (!sectionRef.current || !pinRef.current) return;

    const mm = gsap.matchMedia();
    mm.add("(min-width: 768px)", () => {
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
    });

    return () => mm.revert();
  }, [updateStep]);

  return (
    <section id="how-it-works" ref={sectionRef} className="relative">
      {/* ═══ DESKTOP: pinned viewport with Lottie visual ═══ */}
      <div
        ref={pinRef}
        className="relative hidden md:flex md:flex-col md:h-screen bg-black overflow-hidden"
      >
        <div
          ref={headerRef}
          className="flex-shrink-0 max-w-7xl w-full mx-auto px-10 pt-20 pb-8"
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

        <div className="flex-1 flex flex-row items-stretch max-w-7xl w-full mx-auto px-10 pb-16 min-h-0">
          <div className="w-[42%] flex flex-col justify-center gap-2.5 flex-shrink-0">
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
                  className={`relative rounded-xl px-6 py-4 transition-colors duration-500 cursor-default ${
                    isActive
                      ? `border-l-[3px] ${accent.border} bg-white/[0.03]`
                      : "border-l-[3px] border-transparent"
                  }`}
                >
                  <div className="flex items-center gap-3 mb-0.5">
                    <span className={`text-lg font-bold tabular-nums transition-colors duration-500 ${isActive ? accent.color : "text-[#3D3835]"}`}>
                      {step.step}
                    </span>
                    <div className={`h-px transition-all duration-500 ${isActive ? "w-6" : "w-3"} ${isActive ? accent.dot : "bg-[#3D3835]"}`} />
                    <span className={`text-[10px] font-semibold uppercase tracking-[0.15em] transition-colors duration-500 ${isActive ? accent.color : "text-[#3D3835]"}`}>
                      {step.title}
                    </span>
                  </div>
                  <h3 className={`text-lg font-bold leading-snug tracking-tight transition-colors duration-500 ${isActive ? "text-[#FAFAFA]" : "text-[#6B6360]"}`}>
                    {step.headline}
                  </h3>
                  <motion.div
                    initial={false}
                    animate={{ opacity: isActive ? 1 : 0, height: isActive ? "auto" : 0, marginTop: isActive ? 6 : 0 }}
                    transition={{ duration: 0.4, ease: "easeInOut" }}
                    className="overflow-hidden"
                  >
                    <p className="text-[13px] leading-relaxed max-w-sm" style={{ color: "#8A8A9A" }}>{step.description}</p>
                  </motion.div>
                </motion.div>
              );
            })}
            <div className="flex items-center gap-2 mt-2 ml-5">
              {howItWorksSteps.map((_, i) => (
                <div
                  key={i}
                  className={`rounded-full transition-all duration-500 ${
                    i === activeStep ? `w-6 h-1.5 ${stepAccents[i].dot}` : i < activeStep ? `w-1.5 h-1.5 ${stepAccents[i].dot} opacity-40` : "w-1.5 h-1.5 bg-[#3D3835]"
                  }`}
                />
              ))}
            </div>
          </div>
          <div className="w-[58%] h-full relative ml-4">
            <HowItWorksVisual activeStep={activeStep} isMobile={false} />
          </div>
        </div>
      </div>

      {/* ═══ MOBILE: simple scrolling cards, no pin, no Lottie ═══ */}
      <div className="md:hidden bg-black py-16 px-5 overflow-hidden">
        <motion.p
          initial={{ opacity: 0, y: 12 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-[10px] font-semibold uppercase tracking-[0.25em] mb-3"
          style={{ color: "#6A6A7A" }}
        >
          How it works
        </motion.p>
        <motion.h2
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.1, ease: EASE }}
          className="text-[22px] font-bold leading-[1.15] tracking-tight text-[#FAFAFA] mb-8"
        >
          Four steps from{" "}
          <span className="font-serif italic text-coral">maybe</span> to
          momentum.
        </motion.h2>

        <div className="flex flex-col gap-4">
          {howItWorksSteps.map((step, i) => {
            const accent = stepAccents[i];
            return (
              <motion.div
                key={step.step}
                initial={{ opacity: 0, y: 24 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-30px" }}
                transition={{ duration: 0.55, delay: i * 0.08, ease: EASE }}
                className="relative rounded-xl overflow-hidden"
                style={{
                  background: "rgba(255,255,255,0.03)",
                  border: "0.5px solid rgba(255,255,255,0.06)",
                }}
              >
                {/* Accent top edge */}
                <div className={`absolute top-0 left-0 right-0 h-[2px] ${accent.dot} opacity-30`} />

                <div className="px-5 py-4">
                  <div className="flex items-center gap-2.5 mb-2">
                    <div className={`w-7 h-7 rounded-lg flex items-center justify-center text-[11px] font-bold ${accent.color}`}
                      style={{ background: "rgba(255,255,255,0.04)", border: "0.5px solid rgba(255,255,255,0.08)" }}>
                      {step.step}
                    </div>
                    <span className={`text-[10px] font-semibold uppercase tracking-[0.12em] ${accent.color}`}>{step.title}</span>
                  </div>
                  <h3 className="text-[15px] font-bold leading-snug tracking-tight text-[#FAFAFA]">{step.headline}</h3>
                  <p className="mt-2 text-[12px] leading-[1.6]" style={{ color: "#8A8A9A" }}>{step.description}</p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
