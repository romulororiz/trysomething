"use client";

import { useRef, useState, useEffect, useCallback } from "react";
import { motion, useInView, AnimatePresence } from "framer-motion";
import { TextReveal } from "@/components/ui/TextReveal";
import { Star, ChevronLeft, ChevronRight } from "lucide-react";

const testimonials = [
  {
    name: "Sarah K.",
    hobby: "Pottery",
    hobbyColor: "#D946EF",
    quote:
      "I've had that pottery class bookmarked for years. TrySomething made me actually go.",
    avatar: "S",
  },
  {
    name: "Marcus T.",
    hobby: "Bouldering",
    hobbyColor: "#FF4757",
    quote:
      "The starter kit list was perfect. I didn't overbuy or underbuy for my first session.",
    avatar: "M",
  },
  {
    name: "Priya L.",
    hobby: "Sourdough",
    hobbyColor: "#FB923C",
    quote:
      'I\'m on a 47-day baking streak. This app turned "maybe someday" into "every Tuesday."',
    avatar: "P",
  },
];

/** Compute the offset of card at `index` relative to `activeIndex`, wrapping around. */
function getOffset(index: number, activeIndex: number, total: number): number {
  let diff = index - activeIndex;
  if (diff > Math.floor(total / 2)) diff -= total;
  if (diff < -Math.floor(total / 2)) diff += total;
  return diff;
}

/** Split text into words for staggered animation. */
function StaggeredQuote({
  text,
  isActive,
}: {
  text: string;
  isActive: boolean;
}) {
  const words = text.split(" ");

  return (
    <AnimatePresence mode="wait">
      {isActive && (
        <motion.p
          key={text}
          className="font-sans text-[15px] leading-relaxed text-near-black mb-6"
          initial="hidden"
          animate="visible"
          exit="hidden"
          variants={{
            hidden: {},
            visible: {
              transition: {
                staggerChildren: 0.03,
              },
            },
          }}
        >
          <motion.span
            variants={{
              hidden: { opacity: 0 },
              visible: { opacity: 1 },
            }}
            transition={{ duration: 0.3 }}
          >
            &ldquo;
          </motion.span>
          {words.map((word, i) => (
            <motion.span
              key={i}
              variants={{
                hidden: { opacity: 0, y: 8 },
                visible: { opacity: 1, y: 0 },
              }}
              transition={{ duration: 0.3 }}
              className="inline-block mr-[0.3em]"
            >
              {word}
            </motion.span>
          ))}
          <motion.span
            variants={{
              hidden: { opacity: 0 },
              visible: { opacity: 1 },
            }}
            transition={{ duration: 0.3 }}
          >
            &rdquo;
          </motion.span>
        </motion.p>
      )}
    </AnimatePresence>
  );
}

export function SocialProofSection() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-50px" });
  const [activeIndex, setActiveIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const prevActiveRef = useRef(activeIndex);

  const total = testimonials.length;

  const goNext = useCallback(() => {
    setActiveIndex((prev) => (prev + 1) % total);
  }, [total]);

  const goPrev = useCallback(() => {
    setActiveIndex((prev) => (prev - 1 + total) % total);
  }, [total]);

  // Auto-rotate every 5 seconds, pause on hover
  useEffect(() => {
    if (isPaused || !inView) return;
    const interval = setInterval(goNext, 5000);
    return () => clearInterval(interval);
  }, [isPaused, inView, goNext]);

  // Track previous activeIndex for wrapping detection
  useEffect(() => {
    prevActiveRef.current = activeIndex;
  }, [activeIndex]);

  return (
    <section id="community" className="relative py-20 px-6 md:px-12" ref={ref}>
      <div className="max-w-7xl mx-auto">
        {/* Overline */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5 }}
          className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-4 text-center"
        >
          COMMUNITY
        </motion.p>

        <TextReveal
          text="People are actually starting."
          as="h2"
          className="font-serif text-[36px] md:text-[44px] font-bold leading-tight text-near-black mb-16 justify-center"
          highlight={["actually"]}
          staggerMs={80}
        />

        {/* Carousel */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: [0.33, 1, 0.68, 1] }}
          className="relative max-w-3xl mx-auto"
          onMouseEnter={() => setIsPaused(true)}
          onMouseLeave={() => setIsPaused(false)}
        >
          {/* Carousel track — clipped so side cards peek from edges */}
          <div className="relative h-[320px] overflow-hidden">
            {testimonials.map((t, i) => {
              const offset = getOffset(i, activeIndex, total);
              const isActive = offset === 0;
              const prevOffset = getOffset(i, prevActiveRef.current, total);
              const isWrapping = Math.abs(offset - prevOffset) > 1;

              const translateX = offset * 80;
              const scale = isActive ? 1 : 0.85;
              const opacity = isActive ? 1 : 0.4;
              const zIndex = isActive ? 3 : 1;

              return (
                <motion.div
                  key={i}
                  className="absolute inset-0 flex items-center justify-center"
                  animate={{
                    x: `${translateX}%`,
                    scale,
                    opacity,
                  }}
                  transition={isWrapping ? {
                    x: { duration: 0 },
                    scale: { duration: 0 },
                    opacity: { duration: 0 },
                  } : {
                    duration: 0.5,
                    ease: [0.33, 1, 0.68, 1],
                  }}
                  style={{ zIndex }}
                >
                  <div
                    className="glass p-6 w-full max-w-md relative"
                    style={{
                      pointerEvents: isActive ? "auto" : "none",
                    }}
                  >
                    {/* Colored top accent */}
                    <div
                      className="absolute top-0 left-0 right-0 h-1 rounded-t-card"
                      style={{ backgroundColor: t.hobbyColor }}
                    />

                    {/* Decorative quote mark */}
                    <span
                      className="absolute top-4 left-4 font-serif text-[80px] text-coral leading-none select-none pointer-events-none"
                      style={{ opacity: 0.15 }}
                    >
                      &ldquo;
                    </span>

                    <div className="relative pt-8">
                      {/* Star rating */}
                      <div className="flex gap-1 mb-3">
                        {Array.from({ length: 5 }).map((_, starIdx) => (
                          <Star
                            key={starIdx}
                            size={16}
                            className="fill-coral text-coral"
                          />
                        ))}
                      </div>

                      {/* Quote with staggered word animation */}
                      <StaggeredQuote text={t.quote} isActive={isActive} />

                      {/* Author */}
                      <div className="flex items-center gap-3">
                        {/* Glow avatar */}
                        <div className="relative">
                          <div
                            className="absolute -inset-1 rounded-full opacity-40 blur-sm"
                            style={{ backgroundColor: t.hobbyColor }}
                          />
                          <div
                            className="relative w-14 h-14 rounded-full flex items-center justify-center font-sans text-lg font-bold text-white"
                            style={{
                              background: `linear-gradient(135deg, ${t.hobbyColor}, ${t.hobbyColor}cc)`,
                              boxShadow: `0 0 16px ${t.hobbyColor}40`,
                            }}
                          >
                            {t.avatar}
                          </div>
                        </div>
                        <div>
                          <p className="font-sans text-sm font-semibold text-near-black">
                            {t.name}
                          </p>
                          <span
                            className="px-2 py-0.5 rounded-badge font-sans text-[10px] font-bold uppercase tracking-wider text-white"
                            style={{ backgroundColor: t.hobbyColor }}
                          >
                            {t.hobby}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </div>

          {/* Navigation arrows — positioned at container edges, vertically centered */}
          <button
            onClick={goPrev}
            aria-label="Previous testimonial"
            className="absolute left-2 md:-left-5 top-1/2 -translate-y-1/2 z-10 w-10 h-10 rounded-full bg-sand/80 border border-sand-dark/60 backdrop-blur-sm flex items-center justify-center text-driftwood hover:text-near-black transition-colors duration-200"
          >
            <ChevronLeft size={20} />
          </button>
          <button
            onClick={goNext}
            aria-label="Next testimonial"
            className="absolute right-2 md:-right-5 top-1/2 -translate-y-1/2 z-10 w-10 h-10 rounded-full bg-sand/80 border border-sand-dark/60 backdrop-blur-sm flex items-center justify-center text-driftwood hover:text-near-black transition-colors duration-200"
          >
            <ChevronRight size={20} />
          </button>

          {/* Dot indicators */}
          <div className="flex justify-center gap-2 mt-6">
            {testimonials.map((_, i) => (
              <button
                key={i}
                onClick={() => setActiveIndex(i)}
                aria-label={`Go to testimonial ${i + 1}`}
                className="transition-all duration-300"
              >
                <div
                  className={`rounded-full transition-all duration-300 ${
                    i === activeIndex
                      ? "w-3 h-3 bg-coral"
                      : "w-2 h-2 bg-warm-gray/50"
                  }`}
                />
              </button>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
