"use client";

import { useRef, useState, useCallback } from "react";
import { motion, useInView, AnimatePresence } from "framer-motion";
import { Heart } from "lucide-react";
import { TextReveal } from "@/components/ui/TextReveal";
import { SpecBadge } from "@/components/ui/SpecBadge";
import { CategoryChip } from "@/components/ui/CategoryChip";
import { hobbies, type HobbyData } from "@/lib/hobbies";
import { categoryColors } from "@/lib/tokens";
import { cn } from "@/lib/utils";

export function FeedShowcase() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });
  const [activeHobby, setActiveHobby] = useState<HobbyData>(hobbies[0]);
  const [saved, setSaved] = useState(false);
  const [particles, setParticles] = useState<Array<{ id: number; angle: number; color: string }>>([]);
  const [ringBurst, setRingBurst] = useState(false);

  // Save animation — exact match of hobby_card.dart _ActionButton
  const handleSave = useCallback(() => {
    setSaved((prev) => {
      if (!prev) {
        // Trigger ring burst
        setRingBurst(true);
        setTimeout(() => setRingBurst(false), 500);

        // Spawn 7 particles
        const newParticles = Array.from({ length: 7 }, (_, i) => ({
          id: Date.now() + i,
          angle: (i / 7) * 360,
          color: [
            "#FF6B6B",
            "#FBBF24",
            "#7C3AED",
            "#06D6A0",
            "#FB7185",
            "#818CF8",
            "#FB923C",
          ][i],
        }));
        setParticles(newParticles);
        setTimeout(() => setParticles([]), 700);
      }
      return !prev;
    });
  }, []);

  const switchHobby = (hobby: HobbyData) => {
    setSaved(false);
    setActiveHobby(hobby);
  };

  const catColor = categoryColors[activeHobby.category];

  return (
    <section
      id="features"
      className="relative py-20 px-6 md:px-12"
      ref={ref}
    >
      <div className="max-w-7xl mx-auto">
        <div className="flex flex-col lg:flex-row items-center gap-16">
          {/* Text — 40% */}
          <div className="flex-1 max-w-md">
            <motion.p
              initial={{ opacity: 0 }}
              animate={inView ? { opacity: 1 } : {}}
              transition={{ duration: 0.5 }}
              className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-4"
            >
              DISCOVERY FEED
            </motion.p>

            <TextReveal
              text="Swipe. Save. Start."
              as="h2"
              className="font-serif text-[36px] md:text-[44px] font-bold leading-tight text-near-black mb-4"
              staggerMs={100}
            />

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="font-sans text-[15px] leading-relaxed text-driftwood mb-8"
            >
              Your personal discovery feed adapts to what you love. Every card
              is a door to a new world.
            </motion.p>

            {/* Category chips */}
            <div className="flex flex-wrap gap-2">
              {hobbies.map((h) => (
                <CategoryChip
                  key={h.id}
                  category={h.category}
                  label={h.name}
                  active={h.id === activeHobby.id}
                  onClick={() => switchHobby(h)}
                />
              ))}
            </div>
          </div>

          {/* Interactive card — 60% */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={inView ? { opacity: 1, x: 0 } : {}}
            transition={{
              duration: 0.6,
              delay: 0.2,
              ease: [0.33, 1, 0.68, 1],
            }}
            className="flex-shrink-0 w-full max-w-sm"
          >
            <div
              className="relative rounded-card overflow-hidden cursor-pointer select-none"
              style={{
                height: 480,
                boxShadow:
                  "0 8px 32px rgba(0,0,0,0.24), 0 2px 8px rgba(0,0,0,0.14)",
              }}
            >
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeHobby.id}
                  initial={{ opacity: 0, x: 30 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -30 }}
                  transition={{ duration: 0.35, ease: [0.33, 1, 0.68, 1] }}
                  className="absolute inset-0"
                >
                  {/* Background gradient placeholder */}
                  <div
                    className="absolute inset-0"
                    style={{
                      background: `linear-gradient(135deg, ${catColor}30, ${catColor}08, #0A0A0F)`,
                    }}
                  />

                  {/* Card gradient overlay — stops 0.3, 0.55, 1.0 */}
                  <div
                    className="absolute inset-0"
                    style={{
                      background: `linear-gradient(to bottom,
                        transparent 30%,
                        rgba(10,10,15,0.4) 55%,
                        rgba(10,10,15,0.92) 100%
                      )`,
                    }}
                  />

                  {/* Save button — top right */}
                  <div className="absolute top-4 right-4 z-10">
                    <button
                      onClick={handleSave}
                      className="relative w-11 h-11 rounded-full flex items-center justify-center cursor-pointer"
                      style={{
                        background: "rgba(0,0,0,0.35)",
                        border: "1px solid rgba(255,255,255,0.25)",
                      }}
                      aria-label={saved ? "Unsave hobby" : "Save hobby"}
                    >
                      {/* Ring burst */}
                      {ringBurst && (
                        <motion.div
                          initial={{ scale: 0, opacity: 0.8 }}
                          animate={{ scale: 2.5, opacity: 0 }}
                          transition={{ duration: 0.4, ease: "easeOut" }}
                          className="absolute w-full h-full rounded-full border-2 border-coral"
                        />
                      )}

                      {/* Heart icon with pop bounce */}
                      <motion.div
                        animate={
                          saved
                            ? {
                                scale: [1, 0.75, 1.3, 0.95, 1],
                              }
                            : { scale: 1 }
                        }
                        transition={{
                          duration: 0.5,
                          ease: [0.33, 1, 0.68, 1],
                        }}
                      >
                        <Heart
                          size={20}
                          className={cn(
                            "transition-colors",
                            saved
                              ? "fill-coral text-coral"
                              : "fill-none text-white/90"
                          )}
                          style={{ transitionDuration: "200ms" }}
                        />
                      </motion.div>

                      {/* Scatter particles */}
                      <AnimatePresence>
                        {particles.map((p) => {
                          const rad = (p.angle * Math.PI) / 180;
                          return (
                            <motion.div
                              key={p.id}
                              initial={{ scale: 1, opacity: 1, x: 0, y: 0 }}
                              animate={{
                                x: Math.cos(rad) * 24,
                                y: Math.sin(rad) * 24,
                                scale: 0,
                                opacity: 0,
                              }}
                              exit={{ opacity: 0 }}
                              transition={{
                                duration: 0.6,
                                ease: "easeOut",
                              }}
                              className="absolute w-2 h-2 rounded-full"
                              style={{
                                background: `radial-gradient(circle, ${p.color}, transparent)`,
                              }}
                            />
                          );
                        })}
                      </AnimatePresence>
                    </button>
                  </div>

                  {/* Category chip — top left */}
                  <div className="absolute top-4 left-4">
                    <span
                      className="px-3 py-1 rounded-badge font-sans text-[10px] font-bold uppercase tracking-[1.5px] text-white"
                      style={{ backgroundColor: catColor }}
                    >
                      {activeHobby.category}
                    </span>
                  </div>

                  {/* Content overlay — bottom */}
                  <div className="absolute bottom-0 left-0 right-0 p-6">
                    {/* Tags */}
                    <div className="flex flex-wrap gap-2 mb-2">
                      {activeHobby.tags.map((tag) => (
                        <span
                          key={tag}
                          className="font-sans text-[11px] font-medium text-amber-light"
                        >
                          {tag}
                        </span>
                      ))}
                    </div>

                    {/* Title */}
                    <h3 className="font-serif text-[30px] font-bold text-white leading-tight mb-2">
                      {activeHobby.name}
                    </h3>

                    {/* Hook */}
                    <p className="font-sans text-sm text-white/70 leading-relaxed mb-4 line-clamp-2">
                      {activeHobby.hook}
                    </p>

                    {/* Spec badges */}
                    <div className="flex flex-wrap gap-2">
                      <SpecBadge type="cost" value={activeHobby.cost} />
                      <SpecBadge type="time" value={activeHobby.time} />
                      <SpecBadge
                        type="difficulty"
                        value={activeHobby.difficulty}
                      />
                    </div>
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
