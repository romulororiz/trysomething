"use client";

import { useRef, useEffect, useState } from "react";
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
 * Floating Lottie icons as ambient background for mobile only.
 * Icons drift across the screen with organic scroll-driven parallax —
 * large elliptical orbits that make them wander, not stay on edges.
 */

const ICON_FILTER = "brightness(0.9) saturate(0.85)";

const ambientIcons = [
  // Scattered across the viewport, NOT pinned to edges
  { data: bicycleData, x: 15, y: 5, size: 48, opacity: 0.32, bob: 6, delay: 0, driftX: 30, driftY: -0.09, phase: 0 },
  { data: cameraData, x: 65, y: 12, size: 44, opacity: 0.32, bob: 5, delay: 0.4, driftX: -25, driftY: -0.13, phase: 1.2 },
  { data: bookData, x: 40, y: 28, size: 42, opacity: 0.32, bob: 4, delay: 0.8, driftX: 35, driftY: -0.07, phase: 2.5 },
  { data: musicData, x: 75, y: 38, size: 46, opacity: 0.32, bob: 5, delay: 0.3, driftX: -20, driftY: -0.15, phase: 0.8 },
  { data: plantData, x: 25, y: 52, size: 40, opacity: 0.32, bob: 4, delay: 1.0, driftX: 28, driftY: -0.08, phase: 3.2 },
  { data: cookingData, x: 55, y: 65, size: 44, opacity: 0.32, bob: 5, delay: 0.6, driftX: -32, driftY: -0.12, phase: 1.8 },
  { data: bonfireData, x: 10, y: 75, size: 42, opacity: 0.32, bob: 4, delay: 1.2, driftX: 22, driftY: -0.06, phase: 4.0 },
  { data: pencilData, x: 70, y: 85, size: 40, opacity: 0.32, bob: 4, delay: 0.9, driftX: -28, driftY: -0.10, phase: 2.0 },
];

export function MobileAmbientIcons() {
  const [mounted, setMounted] = useState(false);
  const [scrollY, setScrollY] = useState(0);
  const rafRef = useRef(0);
  const targetRef = useRef(0);

  // Defer rendering to avoid SSR hydration mismatch
  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted) return;
    const onScroll = () => {
      targetRef.current = window.scrollY;
    };

    const tick = () => {
      setScrollY((prev) => {
        const next = prev + (targetRef.current - prev) * 0.08;
        return Math.abs(next - prev) < 0.5 ? prev : next;
      });
      rafRef.current = requestAnimationFrame(tick);
    };

    window.addEventListener("scroll", onScroll, { passive: true });
    rafRef.current = requestAnimationFrame(tick);

    return () => {
      window.removeEventListener("scroll", onScroll);
      cancelAnimationFrame(rafRef.current);
    };
  }, [mounted]);

  if (!mounted) return null;

  return (
    <div className="fixed inset-0 z-[1] pointer-events-none overflow-hidden md:hidden">
      {ambientIcons.map((icon, i) => {
        // Elliptical orbit — each icon swings horizontally on a sine wave
        // with its own phase offset, so they all wander independently
        const orbitX = Math.sin(scrollY * 0.0015 + icon.phase) * icon.driftX;
        // Vertical parallax at different speeds
        const parallaxY = scrollY * icon.driftY;
        // Secondary gentle sway for extra organic feel
        const sway = Math.cos(scrollY * 0.001 + icon.phase * 2) * 5;

        return (
          <motion.div
            key={i}
            className="absolute will-change-transform"
            style={{
              left: `${icon.x}%`,
              top: `${icon.y}%`,
              width: icon.size,
              height: icon.size,
              transform: `translate3d(${orbitX + sway}px, ${parallaxY}px, 0)`,
            }}
            initial={{ opacity: 0 }}
            animate={{ opacity: icon.opacity }}
            transition={{ duration: 2, delay: 0.5 + icon.delay }}
          >
            <motion.div
              animate={{
                y: [0, -icon.bob, 0, icon.bob * 0.3, 0],
                rotate: [0, 3, 0, -2, 0],
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
        );
      })}
    </div>
  );
}
