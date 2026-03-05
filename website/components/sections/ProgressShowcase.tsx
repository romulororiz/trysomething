"use client";

import { useRef, useState, useEffect } from "react";
import { motion, useInView, AnimatePresence } from "framer-motion";
import { TextReveal } from "@/components/ui/TextReveal";
import { GlassCard } from "@/components/ui/GlassCard";
import { cn } from "@/lib/utils";
import {
  Bookmark,
  Footprints,
  Flame,
  Trophy,
  Check,
  Sparkles,
} from "lucide-react";

const statuses = [
  {
    label: "Saved",
    color: "#A0A0B8",
    description: "Hobbies you're interested in",
  },
  {
    label: "Trying",
    color: "#FF6B6B",
    description: "First steps taken",
  },
  {
    label: "Active",
    color: "#06D6A0",
    description: "Regular practice",
  },
  {
    label: "Done",
    color: "#FBBF24",
    description: "Skills mastered",
  },
];

/* ─── Panel data ─── */

const savedHobbies = [
  { name: "Pottery", color: "#D946EF" },
  { name: "Hiking", color: "#06D6A0" },
  { name: "Guitar", color: "#818CF8" },
  { name: "Sourdough", color: "#FB923C" },
  { name: "Chess", color: "#7C3AED" },
];

const tryingHobbies = [
  { name: "Pottery", color: "#D946EF", progress: 65, steps: "4 / 6 steps" },
  { name: "Hiking", color: "#06D6A0", progress: 30, steps: "2 / 7 steps" },
  { name: "Guitar", color: "#818CF8", progress: 15, steps: "1 / 8 steps" },
];

const activeHobbies = [
  { name: "Yoga", color: "#FF4757" },
  { name: "Bouldering", color: "#FF4757" },
];

const doneHobbies = [
  { name: "Origami", color: "#FBBF24" },
];

const doneSteps = ["Materials", "Basics", "First Project", "Advanced", "Mastery"];

// 7 cols x 7 rows heatmap data (0-4 intensity levels)
const heatmapData = [
  [0, 1, 0, 2, 1, 0, 3],
  [1, 2, 3, 1, 0, 2, 4],
  [0, 1, 2, 4, 3, 1, 2],
  [2, 0, 1, 3, 4, 2, 1],
  [1, 3, 2, 0, 1, 3, 2],
  [0, 2, 1, 2, 0, 4, 1],
  [3, 1, 0, 1, 2, 1, 0],
];

const heatmapOpacities = [0.05, 0.15, 0.3, 0.5, 0.8];
const dayLabels = ["S", "M", "T", "W", "T", "F", "S"];

/* ─── Saved Panel ─── */
function SavedPanel() {
  return (
    <div className="flex flex-col items-center flex-1 justify-center">
      <div className="flex items-center gap-2 mb-5 self-start">
        <Bookmark size={14} className="text-driftwood" />
        <p className="font-sans text-sm font-semibold text-near-black">
          Your Watchlist
        </p>
      </div>

      <div className="flex flex-wrap gap-2.5 justify-center">
        {savedHobbies.map((hobby, i) => (
          <motion.div
            key={hobby.name}
            initial={{ opacity: 0, y: 14, scale: 0.85 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{
              duration: 0.4,
              delay: i * 0.09,
              type: "spring",
              stiffness: 280,
              damping: 22,
            }}
            className="px-3.5 py-2 rounded-badge flex items-center gap-2 cursor-default"
            style={{ backgroundColor: `${hobby.color}15`, border: `1px solid ${hobby.color}25` }}
          >
            <Bookmark size={12} style={{ color: hobby.color }} />
            <span
              className="font-sans text-xs font-semibold"
              style={{ color: hobby.color }}
            >
              {hobby.name}
            </span>
          </motion.div>
        ))}
      </div>

      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="font-sans text-xs text-warm-gray mt-5"
      >
        Tap any hobby to start your journey
      </motion.p>
    </div>
  );
}

/* ─── Trying Panel ─── */
function TryingPanel() {
  return (
    <div className="flex flex-col flex-1 gap-4 justify-center">
      <div className="flex items-center gap-2 self-start">
        <Footprints size={14} className="text-coral" />
        <p className="font-sans text-sm font-semibold text-near-black">
          In Progress
        </p>
      </div>

      {tryingHobbies.map((hobby, i) => (
        <motion.div
          key={hobby.name}
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.45, delay: i * 0.13, ease: [0.33, 1, 0.68, 1] }}
          className="w-full"
        >
          <div className="flex items-center justify-between mb-1.5">
            <div className="flex items-center gap-2">
              <div
                className="w-2 h-2 rounded-full"
                style={{ backgroundColor: hobby.color }}
              />
              <span className="font-sans text-xs font-semibold text-near-black">
                {hobby.name}
              </span>
            </div>
            <span className="font-mono text-[10px] text-warm-gray">
              {hobby.steps}
            </span>
          </div>
          <div className="w-full h-2.5 rounded-full bg-sand-dark/20 overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${hobby.progress}%` }}
              transition={{
                duration: 0.9,
                delay: i * 0.13 + 0.2,
                ease: [0.33, 1, 0.68, 1],
              }}
              className="h-full rounded-full relative"
              style={{ backgroundColor: hobby.color }}
            >
              {/* Shimmer on the bar */}
              <motion.div
                className="absolute inset-0 rounded-full"
                style={{
                  background: `linear-gradient(90deg, transparent 0%, ${hobby.color}40 50%, transparent 100%)`,
                }}
                animate={{ x: ["-100%", "200%"] }}
                transition={{
                  duration: 1.5,
                  delay: i * 0.13 + 1,
                  ease: "easeInOut",
                }}
              />
            </motion.div>
          </div>
        </motion.div>
      ))}

      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.6 }}
        className="font-sans text-xs text-warm-gray mt-1"
      >
        Keep going — consistency beats intensity
      </motion.p>
    </div>
  );
}

/* ─── Active Panel (Heatmap) ─── */
function ActivePanel() {
  return (
    <div className="flex flex-col items-center flex-1">
      <div className="flex items-center gap-2 mb-4 w-full flex-wrap">
        <Flame size={14} className="text-sage" />
        <p className="font-sans text-sm font-semibold text-near-black">
          Activity Heatmap
        </p>
        <motion.div
          initial={{ opacity: 0, scale: 0 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3, type: "spring", stiffness: 300, damping: 20 }}
          className="ml-auto px-2.5 py-1 rounded-badge flex items-center gap-1.5"
          style={{ backgroundColor: "rgba(6, 214, 160, 0.12)" }}
        >
          <Flame size={11} className="text-sage" />
          <span className="font-mono text-[10px] font-bold text-sage">
            12 day streak
          </span>
        </motion.div>
      </div>

      {/* Active hobbies row */}
      <div className="flex items-center gap-2 mb-3 justify-center">
        {activeHobbies.map((hobby, i) => (
          <motion.div
            key={hobby.name}
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: i * 0.1 + 0.1, type: "spring", stiffness: 300, damping: 22 }}
            className="px-2.5 py-1 rounded-badge flex items-center gap-1.5"
            style={{ backgroundColor: `${hobby.color}15` }}
          >
            <div
              className="w-1.5 h-1.5 rounded-full"
              style={{ backgroundColor: hobby.color }}
            />
            <span
              className="font-sans text-[10px] font-semibold"
              style={{ color: `${hobby.color}cc` }}
            >
              {hobby.name}
            </span>
          </motion.div>
        ))}
      </div>

      {/* Heatmap grid */}
      <div className="flex flex-col gap-1.5">
        {heatmapData.map((row, rowIdx) => (
          <div key={rowIdx} className="flex items-center gap-1.5">
            <span className="font-mono text-[10px] text-warm-gray w-4 text-right mr-1">
              {dayLabels[rowIdx]}
            </span>
            {row.map((level, colIdx) => (
              <motion.div
                key={colIdx}
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{
                  duration: 0.2,
                  delay: (heatmapData.length - 1 - rowIdx + colIdx) * 0.03,
                }}
                className="w-8 h-8 rounded-md"
                style={{
                  backgroundColor: `rgba(6, 214, 160, ${heatmapOpacities[level]})`,
                }}
              />
            ))}
          </div>
        ))}
      </div>

      {/* Legend */}
      <div className="flex items-center gap-2 mt-3">
        <span className="font-mono text-[10px] text-warm-gray">Less</span>
        {heatmapOpacities.slice(0, 4).map((opacity, i) => (
          <div
            key={i}
            className="w-3 h-3 rounded-sm"
            style={{ backgroundColor: `rgba(6, 214, 160, ${opacity})` }}
          />
        ))}
        <span className="font-mono text-[10px] text-warm-gray">More</span>
      </div>
    </div>
  );
}

/* ─── Done Panel ─── */
function DonePanel() {
  return (
    <div className="flex flex-col items-center flex-1">
      <div className="flex items-center gap-2 mb-5 self-start">
        <Trophy size={14} style={{ color: "#FBBF24" }} />
        <p className="font-sans text-sm font-semibold text-near-black">
          Mastered
        </p>
      </div>

      {doneHobbies.map((hobby) => (
        <div key={hobby.name} className="flex flex-col items-center gap-3 w-full">
          {/* Trophy circle */}
          <motion.div
            initial={{ scale: 0, rotate: -20 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{
              duration: 0.5,
              delay: 0.1,
              type: "spring",
              stiffness: 200,
              damping: 18,
            }}
            className="relative w-20 h-20 rounded-full flex items-center justify-center"
            style={{ backgroundColor: `${hobby.color}18` }}
          >
            <Trophy size={32} style={{ color: hobby.color }} />
            {/* Sparkle accents */}
            {[
              { x: -14, y: -18, delay: 0.4 },
              { x: 18, y: -12, delay: 0.55 },
              { x: 12, y: 16, delay: 0.7 },
            ].map((spark, si) => (
              <motion.div
                key={si}
                className="absolute"
                style={{ left: `calc(50% + ${spark.x}px)`, top: `calc(50% + ${spark.y}px)` }}
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: [0, 1, 0], scale: [0, 1.2, 0] }}
                transition={{
                  duration: 0.8,
                  delay: spark.delay,
                  repeat: Infinity,
                  repeatDelay: 2,
                }}
              >
                <Sparkles size={10} style={{ color: hobby.color }} />
              </motion.div>
            ))}
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.25 }}
            className="text-center"
          >
            <p className="font-sans text-base font-bold text-near-black">
              {hobby.name}
            </p>
            <p className="font-mono text-[10px] text-warm-gray mt-0.5">
              All steps completed
            </p>
          </motion.div>

          {/* Completed step pills */}
          <div className="flex flex-wrap gap-1.5 justify-center mt-1">
            {doneSteps.map((step, j) => (
              <motion.div
                key={step}
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{
                  delay: 0.4 + j * 0.09,
                  type: "spring",
                  stiffness: 350,
                  damping: 20,
                }}
                className="px-2.5 py-1 rounded-badge flex items-center gap-1"
                style={{ backgroundColor: `${hobby.color}12`, border: `1px solid ${hobby.color}20` }}
              >
                <Check size={10} style={{ color: hobby.color }} />
                <span
                  className="font-sans text-[10px] font-medium"
                  style={{ color: `${hobby.color}cc` }}
                >
                  {step}
                </span>
              </motion.div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

/* ─── Animated height panel container ─── */
function PanelContainer({ activeStatus }: { activeStatus: string }) {
  const contentRef = useRef<HTMLDivElement>(null);
  const [height, setHeight] = useState<number | undefined>(undefined);

  // ResizeObserver watches the inner content div and updates height
  // whenever its size changes (panel swap, content reflow, etc.)
  useEffect(() => {
    const el = contentRef.current;
    if (!el) return;
    const ro = new ResizeObserver(([entry]) => {
      const h = entry.borderBoxSize?.[0]?.blockSize ?? entry.contentRect.height;
      setHeight(h);
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  return (
    <motion.div
      animate={{ height: height ?? "auto" }}
      initial={false}
      transition={{ duration: 0.35, ease: [0.33, 1, 0.68, 1] }}
      className="w-full overflow-hidden flex items-center"
      style={{ minHeight: 280 }}
    >
      <div ref={contentRef} className="w-full">
        <AnimatePresence mode="wait">
          <motion.div
            key={activeStatus}
            initial={{ opacity: 0, x: 16 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -16 }}
            transition={{ duration: 0.3, ease: [0.33, 1, 0.68, 1] }}
            className="w-full"
          >
            {activeStatus === "Saved" && <SavedPanel />}
            {activeStatus === "Trying" && <TryingPanel />}
            {activeStatus === "Active" && <ActivePanel />}
            {activeStatus === "Done" && <DonePanel />}
          </motion.div>
        </AnimatePresence>
      </div>
    </motion.div>
  );
}

/* ─── Main Component ─── */
export function ProgressShowcase() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });
  const [activeStatus, setActiveStatus] = useState("Saved");

  return (
    <section id="progress" className="relative py-20 px-6 md:px-12" ref={ref}>
      <div className="max-w-7xl mx-auto text-center">
        {/* Overline */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5 }}
          className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-4"
        >
          PROGRESS TRACKING
        </motion.p>

        <TextReveal
          text='From "Saved" to "Mastered."'
          as="h2"
          className="font-serif text-[36px] md:text-[44px] font-bold leading-tight text-near-black mb-6 justify-center"
          staggerMs={80}
        />

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="font-sans text-[15px] leading-relaxed text-driftwood max-w-lg mx-auto mb-16"
        >
          Track every hobby&apos;s journey. Build streaks. Hit milestones. See
          how far you&apos;ve come.
        </motion.p>

        {/* Combined timeline + dynamic panel card */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.5 }}
          className="max-w-3xl mx-auto"
        >
          <GlassCard className="p-6 md:p-8">
            <div className="flex flex-col md:flex-row md:items-stretch gap-8 md:gap-10">

              {/* Left: Vertical status timeline */}
              <div className="flex flex-col items-center md:items-start gap-0 md:min-w-[200px]">
                <p className="font-sans text-sm font-semibold text-near-black mb-5 self-start">
                  Hobby Journey
                </p>

                <div className="flex flex-col gap-0">
                  {statuses.map((status, i) => {
                    const isActive = activeStatus === status.label;
                    const isLast = i === statuses.length - 1;

                    return (
                      <div key={status.label} className="flex items-stretch">
                        {/* Dot + connecting line column */}
                        <div className="flex flex-col items-center mr-3">
                          {/* Dot */}
                          <motion.button
                            initial={{ scale: 0 }}
                            animate={inView ? { scale: 1 } : {}}
                            transition={{
                              duration: 0.4,
                              delay: i * 0.15 + 0.6,
                              type: "spring",
                              stiffness: 400,
                              damping: 20,
                            }}
                            onClick={() => setActiveStatus(status.label)}
                            className="relative cursor-pointer flex-shrink-0"
                          >
                            {isActive && (
                              <motion.div
                                layoutId="timeline-ring"
                                className="absolute -inset-2 rounded-full"
                                style={{
                                  boxShadow: `0 0 12px ${status.color}60, 0 0 24px ${status.color}30`,
                                  border: `2px solid ${status.color}80`,
                                }}
                                transition={{
                                  type: "spring",
                                  stiffness: 300,
                                  damping: 25,
                                }}
                              />
                            )}
                            <div
                              className={cn(
                                "w-3.5 h-3.5 rounded-full transition-transform duration-200",
                                isActive && "scale-125"
                              )}
                              style={{ backgroundColor: status.color }}
                            />
                          </motion.button>

                          {/* Connecting line */}
                          {!isLast && (
                            <motion.div
                              initial={{ scaleY: 0 }}
                              animate={inView ? { scaleY: 1 } : {}}
                              transition={{
                                duration: 0.35,
                                delay: i * 0.15 + 0.7,
                                ease: [0.33, 1, 0.68, 1],
                              }}
                              className="w-0.5 flex-1 min-h-[28px] origin-top"
                              style={{
                                background: `linear-gradient(to bottom, ${status.color}, ${statuses[i + 1].color})`,
                              }}
                            />
                          )}
                        </div>

                        {/* Label + description */}
                        <motion.div
                          initial={{ opacity: 0, x: -8 }}
                          animate={inView ? { opacity: 1, x: 0 } : {}}
                          transition={{
                            duration: 0.35,
                            delay: i * 0.15 + 0.65,
                          }}
                          className={cn(
                            "pb-5 cursor-pointer text-left",
                            isLast && "pb-0"
                          )}
                          onClick={() => setActiveStatus(status.label)}
                        >
                          <p
                            className={cn(
                              "font-sans text-sm font-semibold leading-none transition-colors duration-200",
                              isActive ? "text-near-black" : "text-driftwood"
                            )}
                          >
                            {status.label}
                          </p>
                          <p
                            className={cn(
                              "font-sans text-xs mt-1 transition-all duration-200",
                              isActive
                                ? "text-driftwood font-medium"
                                : "text-warm-gray"
                            )}
                            style={
                              isActive
                                ? { color: `${status.color}cc` }
                                : undefined
                            }
                          >
                            {status.description}
                          </p>
                        </motion.div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Divider */}
              <div className="hidden md:block w-px bg-sand-dark/30 self-stretch" />
              <div className="block md:hidden h-px bg-sand-dark/30 w-full" />

              {/* Right: Dynamic panel based on active status */}
              <div className="flex-1 flex items-center overflow-hidden">
                <PanelContainer activeStatus={activeStatus} />
              </div>
            </div>
          </GlassCard>
        </motion.div>
      </div>
    </section>
  );
}
