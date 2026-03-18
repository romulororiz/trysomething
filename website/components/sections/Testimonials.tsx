"use client";

import { useRef, useState } from "react";
import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { StaggeredText } from "@/components/ui/StaggeredText";

/* ── Stats ── */
const stats = [
  { value: "2,400+", label: "hobbies matched", accent: "rgba(218,165,32,0.6)" },
  { value: "87%", label: "still going at week 4", accent: "rgba(255,107,107,0.6)" },
  { value: "48h", label: "average time to first session", accent: "rgba(125,189,171,0.6)" },
];

/* ── Testimonials ── */
const testimonials = [
  {
    quote:
      "I\u2019d been meaning to try pottery for three years. TrySomething got me to a wheel in 48 hours.",
    name: "Mara K.",
    hobby: "Pottery",
    duration: "Week 4",
  },
  {
    quote:
      "The roadmap changed everything. I didn\u2019t have to figure out what to do next\u2014it was just there, waiting.",
    name: "Jonas R.",
    hobby: "Bouldering",
    duration: "Week 3",
  },
  {
    quote:
      "I almost quit watercolors after one bad session. The coach sent the exact message I needed to pick up the brush again.",
    name: "Lena S.",
    hobby: "Watercolor",
    duration: "Week 2",
  },
];

/* ── 3D Tilt Card ── */
function TiltCard({
  children,
  className = "",
  index,
}: {
  children: React.ReactNode;
  className?: string;
  index: number;
}) {
  const cardRef = useRef<HTMLDivElement>(null);
  const [transform, setTransform] = useState("perspective(800px) rotateX(0deg) rotateY(0deg)");
  const [glare, setGlare] = useState({ x: 50, y: 50, opacity: 0 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const card = cardRef.current;
    if (!card) return;
    const rect = card.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;
    const rotateX = (y - 0.5) * -12;
    const rotateY = (x - 0.5) * 12;
    setTransform(`perspective(800px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02,1.02,1.02)`);
    setGlare({ x: x * 100, y: y * 100, opacity: 0.08 });
  };

  const handleMouseLeave = () => {
    setTransform("perspective(800px) rotateX(0deg) rotateY(0deg) scale3d(1,1,1)");
    setGlare({ x: 50, y: 50, opacity: 0 });
  };

  const { ref, inView } = useInView({ threshold: 0.15 });

  return (
    <div ref={ref}>
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={inView ? { opacity: 1, y: 0 } : {}}
        transition={{
          duration: 0.8,
          delay: 0.15 + index * 0.12,
          ease: [0.33, 1, 0.68, 1],
        }}
      >
        <div
          ref={cardRef}
          onMouseMove={handleMouseMove}
          onMouseLeave={handleMouseLeave}
          className={`relative rounded-2xl border border-glass-border bg-glass overflow-hidden transition-transform duration-300 ease-out cursor-default ${className}`}
          style={{
            transform,
            transformStyle: "preserve-3d",
          }}
        >
          {/* Glare overlay */}
          <div
            className="absolute inset-0 pointer-events-none transition-opacity duration-300 rounded-2xl"
            style={{
              background: `radial-gradient(circle at ${glare.x}% ${glare.y}%, rgba(255,255,255,${glare.opacity}), transparent 60%)`,
            }}
          />
          {/* Noise texture */}
          <div className="noise absolute inset-0 pointer-events-none" />
          {/* Content */}
          <div className="relative z-10">{children}</div>
        </div>
      </motion.div>
    </div>
  );
}

/* ── Main Section ── */
export function Testimonials() {
  const { ref: headerRef, inView: headerInView } = useInView({ threshold: 0.2 });
  const { ref: statsRef, inView: statsInView } = useInView({ threshold: 0.2 });

  return (
    <section
      id="testimonials"
      className="relative py-32 md:py-48 overflow-hidden"
    >
      {/* Atmospheric blooms */}
      <div
        className="absolute bottom-1/4 left-0 w-[500px] h-[500px] -translate-x-1/3 pointer-events-none opacity-15"
        style={{
          background: "radial-gradient(ellipse at center, rgba(159,18,57,0.2), transparent 70%)",
        }}
      />
      <div
        className="absolute top-1/4 right-0 w-[400px] h-[400px] translate-x-1/3 pointer-events-none opacity-12"
        style={{
          background: "radial-gradient(ellipse at center, rgba(218,165,32,0.15), transparent 70%)",
        }}
      />

      <div className="max-w-5xl mx-auto px-6">
        {/* Section header */}
        <div ref={headerRef} className="text-center mb-16 md:mb-24">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            Real people, real starts
          </motion.p>

          <StaggeredText
            text="They kept saying someday."
            as="h2"
            className="text-[clamp(1.75rem,4vw,3.25rem)] font-bold leading-tight tracking-tight"
            highlightWords={["someday."]}
            stagger={0.07}
          />

          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={headerInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-5 text-lg text-text-secondary max-w-md mx-auto"
          >
            Then someday arrived.
          </motion.p>
        </div>

        {/* Stats row */}
        <div ref={statsRef} className="grid grid-cols-3 gap-4 md:gap-8 mb-16 md:mb-24 max-w-3xl mx-auto">
          {stats.map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, y: 30 }}
              animate={statsInView ? { opacity: 1, y: 0 } : {}}
              transition={{
                duration: 0.7,
                delay: 0.1 + i * 0.1,
                ease: [0.33, 1, 0.68, 1],
              }}
              className="text-center"
            >
              <div
                className="text-[clamp(1.75rem,4vw,3rem)] font-bold tracking-tight leading-none"
                style={{
                  background: `linear-gradient(135deg, var(--color-text-primary), ${stat.accent})`,
                  WebkitBackgroundClip: "text",
                  WebkitTextFillColor: "transparent",
                  backgroundClip: "text",
                }}
              >
                {stat.value}
              </div>
              <p className="text-xs md:text-sm text-text-muted mt-2 tracking-wide">
                {stat.label}
              </p>
            </motion.div>
          ))}
        </div>

        {/* Testimonial cards — asymmetric layout */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-5 md:gap-6">
          {testimonials.map((t, i) => (
            <TiltCard
              key={t.name}
              index={i}
              className={i === 1 ? "md:translate-y-8" : ""}
            >
              <div className="p-7 md:p-8">
                {/* Quote mark */}
                <span className="block font-serif italic text-3xl text-text-whisper leading-none mb-4 select-none">
                  &ldquo;
                </span>

                {/* Quote text */}
                <p className="text-text-secondary text-sm md:text-base leading-relaxed">
                  {t.quote}
                </p>

                {/* Divider */}
                <div className="mt-6 mb-5 h-px w-12 bg-gradient-to-r from-glass-border to-transparent" />

                {/* Attribution */}
                <div className="flex items-center gap-3">
                  {/* Avatar */}
                  <div className="w-9 h-9 rounded-full bg-gradient-to-br from-coral/20 via-surface-elevated to-surface-bright flex items-center justify-center ring-1 ring-glass-border flex-shrink-0">
                    <span className="text-xs font-bold text-text-primary">
                      {t.name[0]}
                    </span>
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-text-primary leading-tight">
                      {t.name}
                    </p>
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <span className="text-xs text-text-muted">{t.hobby}</span>
                      <span className="w-0.5 h-0.5 rounded-full bg-text-whisper" />
                      <span className="text-xs text-coral font-medium">
                        {t.duration}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </TiltCard>
          ))}
        </div>
      </div>
    </section>
  );
}
