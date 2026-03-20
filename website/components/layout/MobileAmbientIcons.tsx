"use client";

import { motion } from "framer-motion";
import Lottie from "lottie-react";

import bicycleData from "@/public/lottie/bicycle.json";
import cameraData from "@/public/lottie/camera.json";
import bookData from "@/public/lottie/book.json";
import musicData from "@/public/lottie/music.json";
import plantData from "@/public/lottie/plant.json";
import cookingData from "@/public/lottie/cooking.json";
import bonfireData from "@/public/lottie/bonfire.json";
import pencilData from "@/public/lottie/pencil.json";

/**
 * Very subtle floating Lottie icons as ambient background for mobile.
 * Fixed position, covers entire viewport, extremely low opacity.
 * Hidden on desktop (icons are in the hero there).
 */

const ICON_FILTER = "brightness(0.9) saturate(0.85)";

const ambientIcons = [
  { data: bicycleData, x: 5, y: 8, size: 34, opacity: 0.07, bob: 6, delay: 0 },
  { data: cameraData, x: 80, y: 15, size: 30, opacity: 0.06, bob: 5, delay: 0.4 },
  { data: bookData, x: 10, y: 35, size: 28, opacity: 0.05, bob: 4, delay: 0.8 },
  { data: musicData, x: 85, y: 45, size: 32, opacity: 0.07, bob: 5, delay: 0.3 },
  { data: plantData, x: 15, y: 60, size: 26, opacity: 0.05, bob: 4, delay: 1.0 },
  { data: cookingData, x: 78, y: 70, size: 30, opacity: 0.06, bob: 5, delay: 0.6 },
  { data: bonfireData, x: 8, y: 82, size: 28, opacity: 0.05, bob: 4, delay: 1.2 },
  { data: pencilData, x: 82, y: 90, size: 26, opacity: 0.06, bob: 4, delay: 0.9 },
];

export function MobileAmbientIcons() {
  return (
    <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden md:hidden">
      {ambientIcons.map((icon, i) => (
        <motion.div
          key={i}
          className="absolute"
          style={{
            left: `${icon.x}%`,
            top: `${icon.y}%`,
            width: icon.size,
            height: icon.size,
          }}
          initial={{ opacity: 0 }}
          animate={{ opacity: icon.opacity }}
          transition={{ duration: 2, delay: 0.5 + icon.delay }}
        >
          <motion.div
            animate={{
              y: [0, -icon.bob, 0, icon.bob * 0.3, 0],
            }}
            transition={{
              duration: 8 + i * 0.5,
              repeat: Infinity,
              ease: "easeInOut",
            }}
            style={{ filter: ICON_FILTER }}
          >
            <Lottie
              animationData={icon.data}
              loop
              autoplay
              style={{ width: icon.size, height: icon.size }}
            />
          </motion.div>
        </motion.div>
      ))}
    </div>
  );
}
