"use client";

import { motion } from "framer-motion";
import { ChevronDown } from "lucide-react";
import { HeroBackground } from "./HeroBackground";
import { HeroIcons } from "./HeroIcons";
import { HeroContent } from "./HeroContent";
import { useSmoothScroll } from "@/components/layout/SmoothScroll";

/**
 * Hero — "Quiet luxury constellation"
 *
 * Pure black background. Floating Lottie hobby icons as ghostly golden
 * constellations. Large centered text with warm gold accent. No WebGL.
 *
 * Layer order:
 *   z-0  HeroBackground (black + warm glow + noise)
 *   z-1  HeroIcons      (floating Lottie constellation)
 *   z-10 HeroContent    (text + CTA)
 */
export function Hero() {
  const { scrollTo } = useSmoothScroll();

  const scrollToNext = () => {
    scrollTo("#solution");
  };

  return (
    <section className="relative h-screen h-dvh overflow-hidden">
      <HeroBackground />
      <HeroIcons />
      <HeroContent />

      {/* Scroll indicator */}
      <motion.button
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2.5 }}
        onClick={scrollToNext}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 z-10 cursor-pointer"
        style={{ color: "#3D3835" }}
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
