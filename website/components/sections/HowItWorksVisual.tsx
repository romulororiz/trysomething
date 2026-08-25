"use client";

import { motion } from "framer-motion";
import Lottie from "lottie-react";

import { AppScreen } from "@/components/ui/AppScreen";
import { stepScreens } from "@/lib/data";

import cameraData from "@/public/lottie/camera.json";
import musicData from "@/public/lottie/music.json";
import plantData from "@/public/lottie/plant.json";
import bookData from "@/public/lottie/book.json";
import bonfireData from "@/public/lottie/bonfire.json";

/* ─── Supporting cast: hobby icons orbiting the device ────── */

const orbitIcons = [
  { data: cameraData, x: "6%", y: "12%", size: 44, opacity: 0.3, dur: 9 },
  { data: musicData, x: "86%", y: "8%", size: 40, opacity: 0.26, dur: 11 },
  { data: plantData, x: "90%", y: "62%", size: 46, opacity: 0.3, dur: 10 },
  { data: bookData, x: "4%", y: "70%", size: 42, opacity: 0.26, dur: 12 },
  { data: bonfireData, x: "78%", y: "86%", size: 38, opacity: 0.22, dur: 9.5 },
];

/* ─── Component ──────────────────────────────────────────── */

interface Props {
  activeStep: number;
  isMobile?: boolean;
}

/**
 * HowItWorksVisual — the real app, front and center.
 *
 * A floating device shows the actual screen for the active step
 * (one continuous candle-making journey: discover → first step →
 * coach → proud journal entry). Lottie hobby icons orbit behind
 * as quiet atmosphere — the phone carries the story now.
 */
export function HowItWorksVisual({ activeStep }: Props) {
  return (
    <div className="relative w-full h-full flex items-center justify-center">
      {/* Orbiting icons — behind the device */}
      {orbitIcons.map((icon, i) => (
        <motion.div
          key={i}
          className="absolute pointer-events-none"
          style={{
            left: icon.x,
            top: icon.y,
            width: icon.size,
            height: icon.size,
            opacity: icon.opacity,
            filter: "brightness(0.9) saturate(0.85)",
          }}
          animate={{ y: [0, -10, 0, 6, 0], rotate: [0, 3, 0, -2, 0] }}
          transition={{ duration: icon.dur, repeat: Infinity, ease: "easeInOut" }}
          aria-hidden="true"
        >
          <Lottie
            animationData={icon.data}
            loop
            autoplay
            style={{ width: icon.size, height: icon.size }}
          />
        </motion.div>
      ))}

      {/* The device — sized to the pinned column height */}
      <AppScreen
        screens={stepScreens}
        activeIndex={activeStep}
        className="h-[min(92%,560px)]"
      />
    </div>
  );
}
