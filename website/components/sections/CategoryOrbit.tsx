"use client";

import { useRef, useMemo, useState, useCallback } from "react";
import { motion, AnimatePresence, useInView } from "framer-motion";
import {
  Palette,
  Mountain,
  Dumbbell,
  Wrench,
  Music,
  ChefHat,
  Gem,
  Brain,
  Users,
} from "lucide-react";
import { TextReveal } from "@/components/ui/TextReveal";
import { categoryColors, categoryLabels, type CategoryId } from "@/lib/tokens";

const categories: {
  id: CategoryId;
  icon: React.ElementType;
  samples: string[];
}[] = [
  { id: "creative", icon: Palette, samples: ["Pottery", "Watercolor", "Photography", "Calligraphy"] },
  { id: "outdoors", icon: Mountain, samples: ["Hiking", "Kayaking", "Stargazing", "Rock Climbing"] },
  { id: "fitness", icon: Dumbbell, samples: ["Bouldering", "Yoga", "Parkour", "Martial Arts"] },
  { id: "maker", icon: Wrench, samples: ["Woodworking", "3D Printing", "Leathercraft", "Electronics"] },
  { id: "music", icon: Music, samples: ["Guitar", "Piano", "DJing", "Singing"] },
  { id: "food", icon: ChefHat, samples: ["Sourdough", "Fermentation", "Sushi", "Pasta Making"] },
  { id: "collecting", icon: Gem, samples: ["Vinyl Records", "Vintage Cameras", "Coins", "Rare Books"] },
  { id: "mind", icon: Brain, samples: ["Chess", "Meditation", "Journaling", "Language Learning"] },
  { id: "social", icon: Users, samples: ["Board Games", "Improv", "Book Club", "Volunteering"] },
];

const DEG = Math.PI / 180;

/** Quadratic bezier from (x1,y1) to (x2,y2) with a perpendicular control-point offset. */
function curvedLine(
  x1: number, y1: number,
  x2: number, y2: number,
  curvature: number = 0.15,
): { d: string; length: number } {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const len = Math.sqrt(dx * dx + dy * dy);
  if (len === 0) return { d: `M${x1},${y1} L${x2},${y2}`, length: 0 };
  // perpendicular offset (clockwise)
  const px = dy / len;
  const py = -dx / len;
  const offset = len * curvature;
  const cx = (x1 + x2) / 2 + px * offset;
  const cy = (y1 + y2) / 2 + py * offset;
  return {
    d: `M${x1},${y1} Q${cx},${cy} ${x2},${y2}`,
    length: len * 1.12,
  };
}

export function CategoryOrbit() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });
  const [selectedDesktop, setSelectedDesktop] = useState<CategoryId | null>(null);
  const [selectedMobile, setSelectedMobile] = useState<CategoryId | null>(null);

  // Orbit: smaller radii to leave room for hobby branches
  const RX = 200;
  const RY = 120;
  const BRANCH_DIST = 148; // distance from category to hobby leaf
  const SPREAD_DEG = 38; // degrees between each hobby branch

  // Category positions on ellipse
  const orbitPositions = useMemo(() => {
    return categories.map((_, i) => {
      const angle = (i / categories.length) * Math.PI * 2 - Math.PI / 2;
      return {
        x: Math.cos(angle) * RX,
        y: Math.sin(angle) * RY,
        angle,
      };
    });
  }, []);

  // Main branch lines (center → category)
  const mainBranches = useMemo(() => {
    return orbitPositions.map((pos) => curvedLine(0, 0, pos.x, pos.y, 0.12));
  }, [orbitPositions]);

  // Hobby leaf positions for each category (fanning outward)
  const hobbyPositions = useMemo(() => {
    return orbitPositions.map((pos) => {
      const baseAngle = pos.angle;
      return categories[0].samples.map((_, j) => {
        // Fan out: 4 hobbies at offsets from the radial direction
        const offset = (j - 1.5) * SPREAD_DEG * DEG;
        const angle = baseAngle + offset;
        return {
          x: pos.x + Math.cos(angle) * BRANCH_DIST,
          y: pos.y + Math.sin(angle) * BRANCH_DIST,
        };
      });
    });
  }, [orbitPositions]);

  const handleDesktopClick = useCallback((id: CategoryId) => {
    setSelectedDesktop((prev) => (prev === id ? null : id));
  }, []);

  const handleMobileClick = useCallback((id: CategoryId) => {
    setSelectedMobile((prev) => (prev === id ? null : id));
  }, []);

  const selectedIdx = selectedDesktop
    ? categories.findIndex((c) => c.id === selectedDesktop)
    : -1;

  return (
    <section
      id="categories"
      className="relative py-20 px-6 md:px-12"
      ref={ref}
    >
      <div className="max-w-7xl mx-auto w-full text-center">
        <TextReveal
          text="9 categories. Endless possibilities."
          as="h2"
          className="font-serif text-[36px] md:text-[52px] font-bold leading-tight text-near-black mb-4 justify-center"
          staggerMs={80}
        />

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="font-sans text-lg text-driftwood mb-12"
        >
          New hobbies added regularly — powered by AI and curated by humans.
        </motion.p>

        {/* Desktop: Mind map */}
        <div className="hidden md:flex justify-center">
          <div
            className="relative"
            style={{ width: 800, height: 620 }}
          >
            {/* SVG layer: all lines (main branches + hobby sub-branches) */}
            <svg
              className="absolute inset-0 pointer-events-none"
              width={800}
              height={620}
              viewBox="-400 -310 800 620"
            >
              {/* Main branch lines: center → category */}
              {categories.map((cat, i) => {
                const color = categoryColors[cat.id];
                const { d, length } = mainBranches[i];
                const isSelected = selectedDesktop === cat.id;
                const hasSelection = selectedDesktop !== null;
                const lineDelay = i * 0.07 + 0.5;

                return (
                  <motion.path
                    key={`main-${cat.id}`}
                    d={d}
                    fill="none"
                    stroke={color}
                    strokeLinecap="round"
                    initial={{
                      strokeDasharray: length,
                      strokeDashoffset: length,
                      opacity: 0,
                    }}
                    animate={
                      inView
                        ? {
                            strokeDashoffset: 0,
                            opacity: isSelected ? 0.9 : hasSelection ? 0.12 : 0.3,
                            strokeWidth: isSelected ? 2 : 1,
                          }
                        : {}
                    }
                    transition={{
                      strokeDashoffset: { duration: 0.5, delay: lineDelay, ease: [0.33, 1, 0.68, 1] },
                      opacity: { duration: 0.3, delay: isSelected || hasSelection ? 0 : lineDelay },
                      strokeWidth: { duration: 0.25 },
                    }}
                  />
                );
              })}

              {/* Hobby sub-branch lines: category → hobby leaf (only for selected) */}
              <AnimatePresence>
                {selectedIdx >= 0 && categories[selectedIdx].samples.map((_, j) => {
                  const cat = categories[selectedIdx];
                  const color = categoryColors[cat.id];
                  const catPos = orbitPositions[selectedIdx];
                  const hobbyPos = hobbyPositions[selectedIdx][j];
                  const branch = curvedLine(catPos.x, catPos.y, hobbyPos.x, hobbyPos.y, 0.08);

                  return (
                    <motion.path
                      key={`branch-${cat.id}-${j}`}
                      d={branch.d}
                      fill="none"
                      stroke={color}
                      strokeWidth={1.5}
                      strokeLinecap="round"
                      initial={{
                        strokeDasharray: branch.length,
                        strokeDashoffset: branch.length,
                        opacity: 0,
                      }}
                      animate={{
                        strokeDashoffset: 0,
                        opacity: 0.7,
                      }}
                      exit={{
                        strokeDashoffset: branch.length,
                        opacity: 0,
                      }}
                      transition={{
                        strokeDashoffset: { duration: 0.4, delay: j * 0.06, ease: [0.33, 1, 0.68, 1] },
                        opacity: { duration: 0.3, delay: j * 0.06 },
                      }}
                    />
                  );
                })}
              </AnimatePresence>

              {/* Center node */}
              <motion.circle
                cx={0}
                cy={0}
                r={6}
                fill="#7C3AED"
                initial={{ opacity: 0, scale: 0 }}
                animate={inView ? { opacity: 0.8, scale: 1 } : {}}
                transition={{ duration: 0.4, delay: 0.3 }}
              />
              {/* Center pulse on selection */}
              <AnimatePresence>
                {selectedDesktop && (
                  <motion.circle
                    key="pulse"
                    cx={0}
                    cy={0}
                    fill="none"
                    stroke="#7C3AED"
                    strokeWidth={2}
                    initial={{ r: 6, opacity: 0.7 }}
                    animate={{ r: 24, opacity: 0 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.6, ease: "easeOut" }}
                  />
                )}
              </AnimatePresence>
            </svg>

            {/* Central glow */}
            <motion.div
              className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-20 h-20 rounded-full pointer-events-none"
              style={{
                background: "radial-gradient(circle, rgba(124,58,237,0.35) 0%, transparent 70%)",
              }}
              animate={{ scale: [1, 1.2, 1], opacity: [0.5, 0.7, 0.5] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            />

            {/* Category pill nodes */}
            {categories.map((cat, i) => {
              const pos = orbitPositions[i];
              const color = categoryColors[cat.id];
              const Icon = cat.icon;
              const isSelected = selectedDesktop === cat.id;
              const hasSelection = selectedDesktop !== null;

              return (
                <motion.button
                  key={cat.id}
                  initial={{ opacity: 0, scale: 0 }}
                  animate={
                    inView
                      ? {
                          opacity: hasSelection && !isSelected ? 0.4 : 1,
                          scale: 1,
                          x: pos.x,
                          y: pos.y,
                        }
                      : {}
                  }
                  transition={{
                    duration: 0.5,
                    delay: i * 0.07 + 0.4,
                    type: "spring",
                    stiffness: 300,
                    damping: 25,
                    opacity: { duration: 0.3 },
                  }}
                  whileHover={{ scale: 1.12, transition: { duration: 0.2 } }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => handleDesktopClick(cat.id)}
                  className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 cursor-pointer focus:outline-none z-[2]"
                >
                  <div
                    className="flex items-center gap-2 px-4 py-2.5 rounded-badge transition-all"
                    style={{
                      backgroundColor: color,
                      boxShadow: isSelected
                        ? `0 0 28px ${color}99, 0 0 8px ${color}66`
                        : `0 0 16px ${color}44`,
                      transitionDuration: "250ms",
                      outline: isSelected ? `2px solid ${color}` : "none",
                      outlineOffset: "3px",
                    }}
                  >
                    <Icon size={16} className="text-white" />
                    <span className="font-sans text-[10px] font-bold uppercase tracking-[1.5px] text-white">
                      {categoryLabels[cat.id]}
                    </span>
                  </div>
                </motion.button>
              );
            })}

            {/* Hobby leaf nodes (appear at end of sub-branches for selected category) */}
            <AnimatePresence>
              {selectedIdx >= 0 && categories[selectedIdx].samples.map((sample, j) => {
                const hobbyPos = hobbyPositions[selectedIdx][j];
                const color = categoryColors[categories[selectedIdx].id];

                return (
                  <motion.div
                    key={`hobby-${categories[selectedIdx].id}-${j}`}
                    initial={{ opacity: 0, scale: 0 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0 }}
                    transition={{
                      duration: 0.35,
                      delay: j * 0.07 + 0.15,
                      type: "spring",
                      stiffness: 400,
                      damping: 22,
                    }}
                    className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none z-[1]"
                    style={{
                      x: hobbyPos.x,
                      y: hobbyPos.y,
                    }}
                  >
                    <div
                      className="px-3 py-1.5 rounded-badge font-sans text-[11px] font-semibold text-white whitespace-nowrap"
                      style={{
                        backgroundColor: `${color}cc`,
                        boxShadow: `0 0 12px ${color}40`,
                      }}
                    >
                      {sample}
                    </div>
                  </motion.div>
                );
              })}
            </AnimatePresence>
          </div>
        </div>

        {/* Mobile: 3x3 grid */}
        <div className="md:hidden grid grid-cols-3 gap-3">
          {categories.map((cat, i) => {
            const color = categoryColors[cat.id];
            const Icon = cat.icon;
            const isExpanded = selectedMobile === cat.id;

            return (
              <motion.button
                key={cat.id}
                initial={{ opacity: 0, y: 20 }}
                animate={inView ? { opacity: 1, y: 0 } : {}}
                transition={{
                  duration: 0.4,
                  delay: i * 0.08 + 0.3,
                }}
                layout
                onClick={() => handleMobileClick(cat.id)}
                className="flex flex-col items-center gap-2 p-4 rounded-tile bg-warm-white cursor-pointer active:scale-[0.97] transition-transform text-center focus:outline-none"
                style={{
                  borderLeft: `3px solid ${color}`,
                  transitionDuration: "150ms",
                }}
              >
                <Icon size={24} style={{ color }} />
                <span className="font-sans text-[10px] font-bold uppercase tracking-wider text-driftwood">
                  {categoryLabels[cat.id]}
                </span>

                <AnimatePresence>
                  {isExpanded && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: "auto" }}
                      exit={{ opacity: 0, height: 0 }}
                      transition={{ duration: 0.25, ease: [0.33, 1, 0.68, 1] }}
                      className="flex flex-col gap-1.5 w-full overflow-hidden"
                    >
                      <div className="w-6 mx-auto my-1 border-t border-sand-dark" />
                      {cat.samples.map((sample, j) => (
                        <motion.span
                          key={sample}
                          initial={{ opacity: 0, x: -8 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{
                            duration: 0.2,
                            delay: j * 0.05,
                          }}
                          className="font-sans text-[11px] text-driftwood"
                        >
                          {sample}
                        </motion.span>
                      ))}
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.button>
            );
          })}
        </div>
      </div>
    </section>
  );
}
