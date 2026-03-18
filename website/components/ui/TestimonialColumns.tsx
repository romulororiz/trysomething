"use client";

import { motion } from "framer-motion";
import type { Testimonial } from "@/lib/data";

/**
 * Single testimonial card for the scrolling wall.
 * Uses <div> (not <li>) to avoid nested <li> inside the loop wrapper.
 */
function TestimonialCard({ testimonial }: { testimonial: Testimonial }) {
  return (
    <motion.div
      whileHover={{
        scale: 1.03,
        y: -8,
        transition: { type: "spring", stiffness: 400, damping: 17 },
      }}
      className="p-6 md:p-8 rounded-2xl border border-glass-border bg-surface-elevated/80 backdrop-blur-sm cursor-default select-none group transition-shadow duration-300 hover:shadow-[0_20px_50px_rgba(0,0,0,0.25)] hover:border-glass-hover"
    >
      {/* Quote */}
      <p className="text-text-secondary text-sm md:text-base leading-relaxed">
        &ldquo;{testimonial.quote}&rdquo;
      </p>

      {/* Attribution */}
      <div className="flex items-center gap-3 mt-5">
        {/* Gradient avatar */}
        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-coral/25 via-bloom-teal/20 to-bloom-burgundy/25 flex items-center justify-center ring-1 ring-glass-border group-hover:ring-glass-hover transition-all flex-shrink-0">
          <span className="text-sm font-bold text-text-primary">
            {testimonial.name[0]}
          </span>
        </div>
        <div>
          <p className="text-sm font-semibold text-text-primary">
            {testimonial.name}
          </p>
          <div className="flex items-center gap-1.5 mt-0.5">
            <span className="text-xs text-text-muted">{testimonial.hobby}</span>
            <span className="w-0.5 h-0.5 rounded-full bg-text-whisper" />
            <span className="text-xs text-coral font-medium">
              {testimonial.duration}
            </span>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

/**
 * Auto-scrolling column of testimonial cards.
 * Duplicates content for seamless infinite loop.
 * Uses plain divs — no <ul>/<li> nesting issues.
 */
function ScrollingColumn({
  testimonials,
  duration = 15,
  className = "",
}: {
  testimonials: Testimonial[];
  duration?: number;
  className?: string;
}) {
  return (
    <div className={`overflow-hidden ${className}`}>
      <motion.div
        animate={{ translateY: "-50%" }}
        transition={{
          duration,
          repeat: Infinity,
          ease: "linear",
          repeatType: "loop",
        }}
        className="flex flex-col gap-5 pb-5"
      >
        {/* Render twice for seamless loop */}
        {[0, 1].map((copy) => (
          <div key={copy} className="flex flex-col gap-5" aria-hidden={copy === 1 || undefined}>
            {testimonials.map((t, i) => (
              <TestimonialCard key={`${copy}-${i}`} testimonial={t} />
            ))}
          </div>
        ))}
      </motion.div>
    </div>
  );
}

/**
 * 3-column auto-scrolling testimonial wall.
 * Each column scrolls at a different speed.
 * Top/bottom mask gradient fades edges.
 * Mobile: single column.
 */
export function TestimonialColumns({
  testimonials,
}: {
  testimonials: Testimonial[];
}) {
  // Split testimonials across 3 columns
  const col1 = testimonials.slice(0, Math.ceil(testimonials.length / 3));
  const col2 = testimonials.slice(
    Math.ceil(testimonials.length / 3),
    Math.ceil((testimonials.length * 2) / 3)
  );
  const col3 = testimonials.slice(Math.ceil((testimonials.length * 2) / 3));

  // If not enough for 3 cols, duplicate
  const padded1 = col1.length > 0 ? col1 : testimonials;
  const padded2 = col2.length > 0 ? col2 : testimonials;
  const padded3 = col3.length > 0 ? col3 : testimonials;

  return (
    <div
      className="flex justify-center gap-5 max-h-[680px] overflow-hidden"
      style={{
        maskImage:
          "linear-gradient(to bottom, transparent, black 8%, black 92%, transparent)",
        WebkitMaskImage:
          "linear-gradient(to bottom, transparent, black 8%, black 92%, transparent)",
      }}
      role="region"
      aria-label="Testimonials"
    >
      <ScrollingColumn testimonials={padded1} duration={18} />
      <ScrollingColumn
        testimonials={padded2}
        duration={22}
        className="hidden md:block"
      />
      <ScrollingColumn
        testimonials={padded3}
        duration={16}
        className="hidden lg:block"
      />
    </div>
  );
}
