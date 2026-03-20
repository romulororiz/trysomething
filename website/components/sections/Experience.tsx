"use client";

import { useRef, useState, useCallback, useEffect } from "react";
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

const screens = [
  {
    id: "quiz",
    leftText: "2 minutes. That\u2019s all it takes.",
    rightText: "No signup walls. No credit card. Just honest questions.",
    component: QuizScreen,
  },
  {
    id: "matches",
    leftText: "AI that actually gets you.",
    rightText: "Not \u2018100 hobbies to try.\u2019 Three that fit your life.",
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

export function Experience() {
  const sectionRef = useRef<HTMLElement>(null);
  const pinRef = useRef<HTMLDivElement>(null);
  const [activeScreen, setActiveScreen] = useState(0);
  const activeRef = useRef(0);
  const { ref: headerRef, inView: headerInView } = useInView({ threshold: 0.3 });

  const updateScreen = useCallback((idx: number) => {
    if (activeRef.current !== idx) {
      activeRef.current = idx;
      setActiveScreen(idx);
    }
  }, []);

  // GSAP pin — desktop only via CSS matchMedia
  useEffect(() => {
    if (!sectionRef.current || !pinRef.current) return;

    const mm = gsap.matchMedia();
    mm.add("(min-width: 768px)", () => {
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
    });

    return () => mm.revert();
  }, [updateScreen]);

  const ScreenComponent = screens[activeScreen].component;

  return (
    <section id="experience" ref={sectionRef} className="relative">
      {/* ═══ DESKTOP: pinned with phone mockup + flanking text ═══ */}
      <div
        ref={pinRef}
        className="relative hidden md:flex md:flex-col md:h-screen bg-black overflow-hidden"
      >
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

        <div className="flex-1 flex flex-row items-center justify-center max-w-6xl mx-auto px-10 pb-20 gap-0 min-h-0">
          <div className="flex flex-1 justify-end pr-14">
            <div className="max-w-[220px] text-right">
              <FlankText
                text={screens[activeScreen].leftText}
                screenKey={screens[activeScreen].id + "-l"}
                className="text-xl lg:text-2xl font-bold leading-snug text-[#FAFAFA]"
              />
            </div>
          </div>

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

        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex gap-2">
          {screens.map((s, i) => (
            <div
              key={s.id}
              className="rounded-full transition-all duration-300"
              style={{
                width: i === activeScreen ? 24 : 8,
                height: 8,
                background: i === activeScreen ? "#FF6B6B" : "rgba(255,255,255,0.12)",
              }}
            />
          ))}
        </div>
      </div>

      {/* ═══ MOBILE: clean stacked text cards, no phone, no pin ═══ */}
      <div className="md:hidden bg-black py-16 px-5 overflow-hidden">
        <motion.p
          initial={{ opacity: 0, y: 12 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-[10px] font-semibold uppercase tracking-[0.25em] mb-3 text-center"
          style={{ color: "#6A6A7A" }}
        >
          The experience
        </motion.p>
        <motion.h2
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.1, ease: EASE }}
          className="text-[22px] font-bold leading-[1.15] tracking-tight text-[#FAFAFA] mb-8 text-center"
        >
          Feel it before you{" "}
          <span className="font-serif italic text-coral">try</span> it.
        </motion.h2>

        <div className="flex flex-col gap-4">
          {screens.map((screen, i) => (
            <motion.div
              key={screen.id}
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
              {/* Coral accent top edge */}
              <div className="absolute top-0 left-0 right-0 h-[2px] bg-coral opacity-20" />

              <div className="px-5 py-4">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-[10px] font-bold text-coral tabular-nums">
                    {String(i + 1).padStart(2, "0")}
                  </span>
                  <div className="h-px w-4 bg-coral/30" />
                </div>
                <p className="text-[15px] font-bold text-[#FAFAFA] leading-snug mb-1.5">
                  {screen.leftText}
                </p>
                <p className="text-[12px] leading-[1.6]" style={{ color: "#8A8A9A" }}>
                  {screen.rightText}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
