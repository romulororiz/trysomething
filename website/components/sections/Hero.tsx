"use client";

import { motion } from "framer-motion";
import { ChevronDown } from "lucide-react";
import dynamic from "next/dynamic";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { MagneticButton } from "@/components/ui/MagneticButton";

/* Lazy-load Three.js hero scene (no SSR) */
const HeroEnvironment = dynamic(
  () =>
    import("@/components/canvas/HeroEnvironment").then(
      (m) => m.HeroEnvironment
    ),
  { ssr: false }
);

const fadeUp = (delay: number) => ({
  initial: { opacity: 0, y: 24 },
  animate: { opacity: 1, y: 0 },
  transition: {
    duration: 0.8,
    delay,
    ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
  },
});

export function Hero() {
  const scrollToNext = () => {
    const el = document.querySelector("#problem");
    el?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Three.js particle background */}
      <HeroEnvironment />

      {/* Subtle gradient overlay for text readability */}
      <div
        className="absolute inset-0 z-[1] pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse 80% 60% at 50% 50%, rgba(5,5,8,0.3) 0%, rgba(5,5,8,0.6) 60%, rgba(5,5,8,0.85) 100%)",
        }}
      />

      {/* Centered content */}
      <div className="relative z-10 max-w-4xl mx-auto px-6 text-center">
        {/* Eyebrow */}
        <motion.p
          {...fadeUp(0.2)}
          className="text-sm font-medium text-text-muted uppercase tracking-[0.25em] mb-8"
        >
          Stop scrolling. Start something.
        </motion.p>

        {/* Headline — cinematic, large, serif */}
        <StaggeredText
          text="Discover the hobby you were made for."
          as="h1"
          className="text-[clamp(2.5rem,6vw,5rem)] font-bold leading-[1.05] tracking-tight"
          highlightWords={["hobby"]}
          delay={0.4}
          stagger={0.07}
        />

        {/* Subtitle — max 2 lines */}
        <motion.p
          {...fadeUp(1.2)}
          className="mt-8 text-lg sm:text-xl text-text-secondary leading-relaxed max-w-2xl mx-auto"
        >
          AI-powered matching finds your perfect hobby. Step-by-step roadmaps
          show you exactly how to start. A personal coach keeps you going.
        </motion.p>

        {/* Single CTA */}
        <motion.div {...fadeUp(1.6)} className="mt-12 flex justify-center">
          <MagneticButton
            variant="primary"
            size="lg"
            breathing
            href="#waitlist"
          >
            Get Early Access
          </MagneticButton>
        </motion.div>

        {/* Subtle subtext */}
        <motion.p
          {...fadeUp(2.0)}
          className="mt-6 text-xs text-text-whisper"
        >
          Coming soon to iPhone &amp; Android
        </motion.p>
      </div>

      {/* Scroll indicator */}
      <motion.button
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2.5 }}
        onClick={scrollToNext}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 text-text-whisper hover:text-text-muted transition-colors cursor-pointer z-10"
        aria-label="Scroll down"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
        >
          <ChevronDown size={24} />
        </motion.div>
      </motion.button>
    </section>
  );
}
