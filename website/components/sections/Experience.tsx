"use client";

import { useRef, useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { ExperiencePhone } from "./ExperiencePhone";
import {
  QuizScreen,
  MatchesScreen,
  RoadmapScreen,
  CoachScreen,
} from "./ExperienceScreens";

gsap.registerPlugin(ScrollTrigger);

/* ─── Screen data ─────────────────────────────────────────── */

const screens = [
  {
    id: "quiz",
    leftText: "2 minutes. That's all it takes.",
    rightText: "No signup walls. No credit card. Just honest questions.",
    component: QuizScreen,
  },
  {
    id: "matches",
    leftText: "AI that actually gets you.",
    rightText: "Not '100 hobbies to try.' Three that fit your life.",
    component: MatchesScreen,
  },
  {
    id: "roadmap",
    leftText: "Every step spelled out.",
    rightText: "What to buy. Where to go. What to expect. Done.",
    component: RoadmapScreen,
  },
  {
    id: "coach",
    leftText: "A coach that never judges.",
    rightText: "Adapts to your pace. Celebrates your wins.",
    component: CoachScreen,
  },
];

const EASE: [number, number, number, number] = [0.33, 1, 0.68, 1];

/* ─── Flanking text with AnimatePresence ──────────────────── */

function FlankText({
  text,
  screenKey,
  className = "",
  style,
}: {
  text: string;
  screenKey: string;
  className?: string;
  style?: React.CSSProperties;
}) {
  return (
    <AnimatePresence mode="wait">
      <motion.p
        key={screenKey}
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -12 }}
        transition={{ duration: 0.45, ease: EASE }}
        className={className}
        style={style}
      >
        {text}
      </motion.p>
    </AnimatePresence>
  );
}

/* ─── Main component ──────────────────────────────────────── */

export function Experience() {
  const sectionRef = useRef<HTMLElement>(null);
  const pinRef = useRef<HTMLDivElement>(null);
  const [activeScreen, setActiveScreen] = useState(0);
  const activeRef = useRef(0);
  const [isMobile, setIsMobile] = useState(false);
  const { ref: headerRef, inView: headerInView } = useInView({
    threshold: 0.3,
  });

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
  }, []);

  const updateScreen = useCallback((idx: number) => {
    if (activeRef.current !== idx) {
      activeRef.current = idx;
      setActiveScreen(idx);
    }
  }, []);

  // GSAP ScrollTrigger pin — DESKTOP ONLY
  useEffect(() => {
    if (!sectionRef.current || !pinRef.current || isMobile) return;

    const ctx = gsap.context(() => {
      ScrollTrigger.create({
        trigger: sectionRef.current,
        start: "top top",
        end: () => `+=${window.innerHeight * 3.5}`,
        pin: pinRef.current!,
        pinSpacing: true,
        scrub: 0.5,
        onUpdate: (self) => {
          const idx = Math.min(3, Math.floor(self.progress * 4));
          updateScreen(idx);
        },
      });
    }, sectionRef);

    return () => ctx.revert();
  }, [updateScreen, isMobile]);

  /* ─── MOBILE: No pin, no phone mockup. Simple stacked cards. ─── */
  if (isMobile) {
    return (
      <section id="experience" className="relative bg-black py-20 px-6">
        <div ref={headerRef} className="text-center mb-10">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold uppercase tracking-[0.25em] mb-3"
            style={{ color: "#6A6A7A" }}
          >
            The experience
          </motion.p>
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.1, ease: EASE }}
            className="text-2xl font-bold leading-[1.1] tracking-tight text-[#FAFAFA]"
          >
            Feel it before you{" "}
            <span className="font-serif italic text-coral">try</span> it.
          </motion.h2>
        </div>

        <div className="flex flex-col gap-6">
          {screens.map((screen, i) => (
            <motion.div
              key={screen.id}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-40px" }}
              transition={{ duration: 0.6, delay: i * 0.08, ease: EASE }}
              className="border-l-[3px] border-coral/30 rounded-xl px-5 py-5 bg-white/[0.03]"
            >
              <p className="text-lg font-bold text-[#FAFAFA] leading-snug mb-2">
                {screen.leftText}
              </p>
              <p className="text-sm leading-relaxed" style={{ color: "#8A8A9A" }}>
                {screen.rightText}
              </p>
            </motion.div>
          ))}
        </div>
      </section>
    );
  }

  /* ─── DESKTOP: Pinned with phone mockup + flanking text ─── */
  const ScreenComponent = screens[activeScreen].component;

  return (
    <section id="experience" ref={sectionRef} className="relative">
      <div
        ref={pinRef}
        className="relative h-screen bg-black overflow-hidden flex flex-col"
      >
        {/* Section header */}
        <div
          ref={headerRef}
          className="flex-shrink-0 text-center pt-24 pb-6 px-6"
        >
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold uppercase tracking-[0.25em] mb-3"
            style={{ color: "#6A6A7A" }}
          >
            The experience
          </motion.p>
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.1, ease: EASE }}
            className="text-[clamp(1.5rem,3.5vw,2.5rem)] font-bold leading-[1.1] tracking-tight text-[#FAFAFA]"
          >
            Feel it before you{" "}
            <span className="font-serif italic text-coral">try</span> it.
          </motion.h2>
        </div>

        {/* Main content */}
        <div className="flex-1 flex flex-row items-center justify-center max-w-6xl mx-auto px-10 pb-20 gap-0 min-h-0">
          {/* Left flanking text */}
          <div className="flex flex-1 justify-end pr-14">
            <div className="max-w-[220px] text-right">
              <FlankText
                text={screens[activeScreen].leftText}
                screenKey={screens[activeScreen].id + "-l"}
                className="text-xl lg:text-2xl font-bold leading-snug text-[#FAFAFA]"
              />
            </div>
          </div>

          {/* Phone mockup */}
          <div className="flex-shrink-0 relative">
            <ExperiencePhone className="w-[280px] h-[580px]">
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeScreen}
                  initial={{ opacity: 0, scale: 0.96 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.94 }}
                  transition={{ duration: 0.45, ease: EASE }}
                  className="w-full h-full"
                >
                  <ScreenComponent />
                </motion.div>
              </AnimatePresence>
            </ExperiencePhone>
          </div>

          {/* Right flanking text */}
          <div className="flex flex-1 pl-14">
            <div className="max-w-[240px]">
              <FlankText
                text={screens[activeScreen].rightText}
                screenKey={screens[activeScreen].id + "-r"}
                className="text-base lg:text-lg leading-relaxed"
                style={{ color: "#8A8A9A" }}
              />
            </div>
          </div>
        </div>

        {/* Screen indicator dots */}
        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-2">
          {screens.map((s, i) => (
            <div
              key={s.id}
              className="rounded-full transition-all duration-300"
              style={{
                width: i === activeScreen ? 24 : 8,
                height: 8,
                background:
                  i === activeScreen ? "#FF6B6B" : "rgba(255,255,255,0.12)",
              }}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
