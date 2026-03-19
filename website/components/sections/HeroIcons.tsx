"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { motion } from "framer-motion";
import Lottie from "lottie-react";

/* ─── Static Lottie imports ────────────────────────────────── */

import bicycleData from "@/public/lottie/bicycle.json";
import bonfireData from "@/public/lottie/bonfire.json";
import bookData from "@/public/lottie/book.json";
import cameraData from "@/public/lottie/camera.json";
import cookingData from "@/public/lottie/cooking.json";
import musicData from "@/public/lottie/music.json";
import plantData from "@/public/lottie/plant.json";
import skateboardData from "@/public/lottie/skateboard.json";
import stargazingData from "@/public/lottie/stargazing.json";
import puzzleData from "@/public/lottie/puzzle.json";
import pencilData from "@/public/lottie/pencil.json";

/* ─── Icon configuration ───────────────────────────────────── */

interface IconConfig {
  data: object;
  /** % from left edge */
  x: number;
  /** % from top edge */
  y: number;
  /** px width/height */
  size: number;
  /** target opacity (0.15–0.35) */
  opacity: number;
  /** parallax depth multiplier (0.5–1.5) */
  depth: number;
  /** stagger delay in seconds */
  delay: number;
  /** vertical bob distance in px */
  bob: number;
  /** rotation tilt in degrees */
  tilt: number;
  /** hide on mobile (<768px) */
  mobileHide?: boolean;
}

/**
 * 9 icons positioned around the edges/corners, avoiding the center clear zone
 * (25-75% x, 25-65% y) where the headline and CTA sit.
 */
const icons: IconConfig[] = [
  // Top-left cluster
  {
    data: bicycleData,
    x: 8,
    y: 12,
    size: 65,
    opacity: 0.3,
    depth: 1.2,
    delay: 0,
    bob: 10,
    tilt: 2,
  },
  {
    data: cookingData,
    x: 22,
    y: 5,
    size: 50,
    opacity: 0.22,
    depth: 0.7,
    delay: 0.3,
    bob: 6,
    tilt: 1.5,
    mobileHide: true,
  },
  // Top-right
  {
    data: cameraData,
    x: 85,
    y: 15,
    size: 55,
    opacity: 0.25,
    depth: 0.9,
    delay: 0.5,
    bob: 8,
    tilt: -1.8,
  },
  // Left side
  {
    data: skateboardData,
    x: 4,
    y: 55,
    size: 58,
    opacity: 0.28,
    depth: 1.1,
    delay: 0.8,
    bob: 12,
    tilt: 1.2,
  },
  // Right side
  {
    data: plantData,
    x: 92,
    y: 48,
    size: 50,
    opacity: 0.26,
    depth: 0.6,
    delay: 0.6,
    bob: 7,
    tilt: -1,
    mobileHide: true,
  },
  // Bottom-left
  {
    data: bookData,
    x: 12,
    y: 78,
    size: 52,
    opacity: 0.25,
    depth: 0.5,
    delay: 1.0,
    bob: 5,
    tilt: 1.5,
  },
  // Bottom-right
  {
    data: musicData,
    x: 82,
    y: 72,
    size: 60,
    opacity: 0.3,
    depth: 1.0,
    delay: 0.4,
    bob: 9,
    tilt: -2,
  },
  // Bottom-center-right
  {
    data: bonfireData,
    x: 78,
    y: 85,
    size: 48,
    opacity: 0.22,
    depth: 0.5,
    delay: 1.2,
    bob: 6,
    tilt: 0.8,
    mobileHide: true,
  },
  // Bottom-center-left
  {
    data: stargazingData,
    x: 18,
    y: 88,
    size: 46,
    opacity: 0.22,
    depth: 0.6,
    delay: 1.4,
    bob: 5,
    tilt: -0.8,
  },

  // ── Duplicates — same icons, far from originals, more visible ──

  // bicycle duplicate → bottom-right area
  {
    data: bicycleData,
    x: 88,
    y: 82,
    size: 44,
    opacity: 0.22,
    depth: 0.5,
    delay: 1.6,
    bob: 5,
    tilt: -1,
    mobileHide: true,
  },
  // music duplicate → top-left area
  {
    data: musicData,
    x: 3,
    y: 8,
    size: 42,
    opacity: 0.2,
    depth: 0.4,
    delay: 1.8,
    bob: 5,
    tilt: 1,
    mobileHide: true,
  },
  // camera duplicate → left-bottom
  {
    data: cameraData,
    x: 2,
    y: 72,
    size: 40,
    opacity: 0.2,
    depth: 0.55,
    delay: 2.0,
    bob: 5,
    tilt: 0.8,
  },
  // plant duplicate → top-center-left
  {
    data: plantData,
    x: 15,
    y: 3,
    size: 36,
    opacity: 0.18,
    depth: 0.45,
    delay: 1.9,
    bob: 4,
    tilt: -0.6,
    mobileHide: true,
  },

  // ── Fill icons — near text corridors ──

  // Left of headline
  {
    data: puzzleData,
    x: 17,
    y: 35,
    size: 44,
    opacity: 0.2,
    depth: 0.5,
    delay: 0.7,
    bob: 6,
    tilt: 1.2,
    mobileHide: true,
  },
  // Right of headline
  {
    data: pencilData,
    x: 83,
    y: 38,
    size: 42,
    opacity: 0.2,
    depth: 0.55,
    delay: 0.9,
    bob: 5,
    tilt: -0.9,
    mobileHide: true,
  },
  // Below CTA left
  {
    data: cookingData,
    x: 32,
    y: 80,
    size: 38,
    opacity: 0.18,
    depth: 0.4,
    delay: 1.5,
    bob: 5,
    tilt: 0.7,
  },
  // Below CTA right
  {
    data: stargazingData,
    x: 65,
    y: 83,
    size: 40,
    opacity: 0.18,
    depth: 0.5,
    delay: 1.7,
    bob: 5,
    tilt: -0.6,
  },
  // Upper-left corridor
  {
    data: bonfireData,
    x: 10,
    y: 28,
    size: 38,
    opacity: 0.18,
    depth: 0.45,
    delay: 1.1,
    bob: 5,
    tilt: 0.8,
  },
  // Upper-right corridor
  {
    data: bookData,
    x: 90,
    y: 30,
    size: 36,
    opacity: 0.18,
    depth: 0.4,
    delay: 1.3,
    bob: 4,
    tilt: -0.7,
  },

  // ── 3 more to fill remaining gaps ──

  // Left of subtext area
  {
    data: skateboardData,
    x: 20,
    y: 58,
    size: 36,
    opacity: 0.16,
    depth: 0.5,
    delay: 1.0,
    bob: 5,
    tilt: 1.4,
    mobileHide: true,
  },
  // Right of subtext area
  {
    data: puzzleData,
    x: 80,
    y: 55,
    size: 34,
    opacity: 0.15,
    depth: 0.45,
    delay: 1.2,
    bob: 4,
    tilt: -1.1,
    mobileHide: true,
  },
  // Top center-right (gap between cooking and camera)
  {
    data: pencilData,
    x: 55,
    y: 3,
    size: 32,
    opacity: 0.14,
    depth: 0.4,
    delay: 0.4,
    bob: 4,
    tilt: 0.6,
    mobileHide: true,
  },
];

/* ─── Cinematic ease ─────────────────────────────────────── */

const ENTRANCE_EASE: [number, number, number, number] = [0.23, 1, 0.32, 1];

/* ─── CSS filter — keep coral tint, just soften slightly ──── */

const ICON_FILTER = "brightness(0.9) saturate(0.85)";

/* ─── Component ──────────────────────────────────────────── */

export function HeroIcons() {
  const mouseRef = useRef({ x: 0, y: 0 });
  const [mouse, setMouse] = useState({ x: 0, y: 0 });
  const [isMobile, setIsMobile] = useState(false);
  const rafRef = useRef<number>(0);

  // Detect mobile on mount
  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
  }, []);

  // Mouse parallax — throttled via rAF
  const handleMouseMove = useCallback((e: MouseEvent) => {
    mouseRef.current = {
      x: (e.clientX / window.innerWidth - 0.5) * 2,
      y: (e.clientY / window.innerHeight - 0.5) * 2,
    };
  }, []);

  useEffect(() => {
    if (isMobile) return; // No parallax on mobile

    window.addEventListener("mousemove", handleMouseMove, { passive: true });

    // Smooth interpolation loop
    const tick = () => {
      setMouse((prev) => ({
        x: prev.x + (mouseRef.current.x - prev.x) * 0.06,
        y: prev.y + (mouseRef.current.y - prev.y) * 0.06,
      }));
      rafRef.current = requestAnimationFrame(tick);
    };
    rafRef.current = requestAnimationFrame(tick);

    return () => {
      window.removeEventListener("mousemove", handleMouseMove);
      cancelAnimationFrame(rafRef.current);
    };
  }, [isMobile, handleMouseMove]);

  // Filter visible icons on mobile — much more aggressive
  const visibleIcons = isMobile
    ? icons.filter((icon) => !icon.mobileHide)
    : icons;

  return (
    <div className="absolute inset-0 z-[1] pointer-events-none overflow-hidden">
      {visibleIcons.map((icon, i) => {
        const mobileScale = isMobile ? 0.6 : 1;
        const px = icon.depth * 15;
        const py = icon.depth * 10;
        // Clamp X position so icon + size never exceeds viewport
        const iconPx = icon.size * mobileScale;
        const maxX = isMobile ? Math.min(icon.x, 88) : icon.x;

        return (
          <motion.div
            key={i}
            className="absolute"
            style={{
              left: `${maxX}%`,
              top: `${icon.y}%`,
              width: iconPx,
              height: iconPx,
              // Clamp to viewport — prevent overflow
              maxWidth: `calc(100vw - ${maxX}vw)`,
              transform: isMobile
                ? undefined
                : `translate(${mouse.x * px}px, ${mouse.y * py}px)`,
            }}
            /* ── Entrance animation (one-time) ── */
            initial={{ opacity: 0, scale: 0.5 }}
            animate={{ opacity: icon.opacity, scale: 1 }}
            transition={{
              duration: 1.2,
              delay: 0.3 + icon.delay * 0.3,
              ease: ENTRANCE_EASE,
            }}
          >
            {/* ── Floating animation (infinite) ── */}
            <motion.div
              animate={{
                y: [0, -icon.bob, 0, icon.bob * 0.4, 0],
                rotate: [0, icon.tilt, 0, -icon.tilt * 0.5, 0],
              }}
              transition={{
                duration: 5 + i * 0.4,
                repeat: Infinity,
                ease: "easeInOut",
              }}
              style={{ filter: ICON_FILTER }}
            >
              <Lottie
                animationData={icon.data}
                loop
                autoplay
                style={{
                  width: icon.size * mobileScale,
                  height: icon.size * mobileScale,
                }}
              />
            </motion.div>
          </motion.div>
        );
      })}
    </div>
  );
}
