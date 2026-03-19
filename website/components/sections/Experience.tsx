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
  const { ref: headerRef, inView: headerInView } = useInView({
    threshold: 0.3,
  });

  const updateScreen = useCallback((idx: number) => {
    if (activeRef.current !== idx) {
      activeRef.current = idx;
      setActiveScreen(idx);
    }
  }, []);

  // GSAP ScrollTrigger pin
  useEffect(() => {
    if (!sectionRef.current || !pinRef.current) return;

    const mm = gsap.matchMedia();

    mm.add(
      {
        desktop: "(min-width: 768px)",
        mobile: "(max-width: 767px)",
      },
      (context) => {
        const { desktop } = context.conditions as { desktop: boolean; mobile: boolean };

        ScrollTrigger.create({
          trigger: sectionRef.current,
          start: "top top",
          end: () =>
            `+=${window.innerHeight * (desktop ? 3.5 : 2.5)}`,
          pin: pinRef.current!,
          pinSpacing: true,
          scrub: 0.5,
          onUpdate: (self) => {
            const idx = Math.min(3, Math.floor(self.progress * 4));
            updateScreen(idx);
          },
        });
      }
    );

    return () => mm.revert();
  }, [updateScreen]);

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
          className="flex-shrink-0 text-center pt-20 md:pt-24 pb-4 md:pb-6 px-6"
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

        {/* Main content — flanking text + phone + flanking text */}
        <div className="flex-1 flex flex-col md:flex-row items-center justify-center max-w-6xl mx-auto px-6 md:px-10 pb-16 md:pb-20 gap-6 md:gap-0 min-h-0">
          {/* Left flanking text (desktop) */}
          <div className="hidden md:flex flex-1 justify-end pr-10 lg:pr-14">
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
            <ExperiencePhone className="w-[240px] h-[500px] md:w-[280px] md:h-[580px]">
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

          {/* Right flanking text (desktop) */}
          <div className="hidden md:flex flex-1 pl-10 lg:pl-14">
            <div className="max-w-[240px]">
              <FlankText
                text={screens[activeScreen].rightText}
                screenKey={screens[activeScreen].id + "-r"}
                className="text-base lg:text-lg leading-relaxed"
                style={{ color: "#8A8A9A" }}
              />
            </div>
          </div>

          {/* Mobile flanking text (below phone, only left/punchy text) */}
          <div className="md:hidden text-center px-4">
            <FlankText
              text={screens[activeScreen].leftText}
              screenKey={screens[activeScreen].id + "-m"}
              className="text-lg font-bold leading-snug text-[#FAFAFA]"
            />
          </div>
        </div>

        {/* Screen indicator dots */}
        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-2">
          {screens.map((s, i) => (
            <div
              key={s.id}
              className="rounded-full transition-all duration-400"
              style={{
                width: i === activeScreen ? 24 : 8,
                height: 8,
                background:
                  i === activeScreen
                    ? "#FF6B6B"
                    : "rgba(255,255,255,0.12)",
              }}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
