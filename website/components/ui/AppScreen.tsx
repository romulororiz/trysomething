"use client";

import Image from "next/image";
import { motion } from "framer-motion";

export interface AppScreenShot {
  src: string;
  alt: string;
}

/* Cropped app screenshots are 1080x2222 → 0.486 aspect ratio */
export const SCREEN_ASPECT = 1080 / 2222;

const STEP_GLOWS = [
  "rgba(218,165,32,0.14)", // Match — warm gold
  "rgba(255,107,107,0.16)", // Start — coral
  "rgba(13,148,136,0.14)", // Stay — teal
  "rgba(159,18,57,0.16)", // Grow — burgundy
];

/**
 * AppScreen — floating device frame with crossfading real app screens.
 *
 * All screens stay mounted (stacked absolutely) so switching steps never
 * re-decodes an image — only opacity/scale animate. The glow behind the
 * device tints per step as a quiet "something changed" cue.
 */
export function AppScreen({
  screens,
  activeIndex,
  className = "",
}: {
  screens: AppScreenShot[];
  activeIndex: number;
  className?: string;
}) {
  const glow = STEP_GLOWS[activeIndex % STEP_GLOWS.length];

  return (
    <div className={`relative ${className}`} style={{ perspective: 1400 }}>
      {/* Ambient glow — tinted per step */}
      <motion.div
        aria-hidden="true"
        className="absolute inset-[-18%] pointer-events-none rounded-full"
        animate={{
          background: `radial-gradient(ellipse at 50% 55%, ${glow}, transparent 65%)`,
        }}
        transition={{ duration: 0.9 }}
      />

      {/* Floating device */}
      <motion.div
        className="relative h-full"
        animate={{ y: [0, -9, 0] }}
        transition={{ duration: 7, repeat: Infinity, ease: "easeInOut" }}
        style={{ transform: "rotateY(-5deg) rotateX(1.5deg)" }}
      >
        <div
          className="relative h-full rounded-[40px] p-[9px]"
          style={{
            aspectRatio: `${SCREEN_ASPECT}`,
            background: "linear-gradient(160deg, #1D1D25 0%, #0B0B10 55%, #14141B 100%)",
            border: "1px solid rgba(255,255,255,0.14)",
            boxShadow:
              "0 40px 90px rgba(0,0,0,0.55), 0 12px 32px rgba(0,0,0,0.45), inset 0 1px 0 rgba(255,255,255,0.12)",
          }}
        >
          <div className="relative w-full h-full rounded-[31px] overflow-hidden bg-[#050508]">
            {screens.map((screen, i) => (
              <motion.div
                key={screen.src}
                className="absolute inset-0"
                initial={false}
                animate={{
                  opacity: i === activeIndex ? 1 : 0,
                  scale: i === activeIndex ? 1 : 1.04,
                }}
                transition={{ duration: 0.55, ease: [0.33, 1, 0.68, 1] }}
              >
                <Image
                  src={screen.src}
                  alt={i === activeIndex ? screen.alt : ""}
                  fill
                  sizes="(min-width: 768px) 320px, 220px"
                  className="object-cover object-top"
                  priority={i === 0}
                />
              </motion.div>
            ))}
          </div>
        </div>
      </motion.div>
    </div>
  );
}
