"use client";

import { motion, AnimatePresence } from "framer-motion";
import Lottie from "lottie-react";

import bicycleData from "@/public/lottie/bicycle.json";
import cameraData from "@/public/lottie/camera.json";
import musicData from "@/public/lottie/music.json";
import plantData from "@/public/lottie/plant.json";
import cookingData from "@/public/lottie/cooking.json";
import bookData from "@/public/lottie/book.json";

/* ─── Config ─────────────────────────────────────────────── */

const ICON_FILTER = "brightness(0.9) saturate(0.85)";
const EASE: [number, number, number, number] = [0.23, 1, 0.32, 1];

const visualIcons = [
  bicycleData,
  cameraData,
  musicData,
  plantData,
  cookingData,
  bookData,
];

/* ─── Formation positions per step ───────────────────────── */

interface IconPos {
  x: string;
  y: string;
  opacity: number;
  size: number;
}

/** Step 0 — MATCH: scattered/searching — "so many options" */
const matchPositions: IconPos[] = [
  { x: "15%", y: "18%", opacity: 0.25, size: 50 },
  { x: "72%", y: "12%", opacity: 0.32, size: 46 },
  { x: "42%", y: "68%", opacity: 0.2, size: 54 },
  { x: "82%", y: "58%", opacity: 0.28, size: 42 },
  { x: "22%", y: "48%", opacity: 0.26, size: 48 },
  { x: "58%", y: "38%", opacity: 0.22, size: 44 },
];

/** Step 1 — START: one highlighted center, others recede — "found it" */
const startPositions: IconPos[] = [
  { x: "6%", y: "14%", opacity: 0.08, size: 34 },
  { x: "86%", y: "10%", opacity: 0.08, size: 30 },
  { x: "44%", y: "42%", opacity: 0.55, size: 78 }, // CENTER — the match
  { x: "88%", y: "74%", opacity: 0.08, size: 30 },
  { x: "8%", y: "78%", opacity: 0.08, size: 32 },
  { x: "76%", y: "48%", opacity: 0.08, size: 28 },
];

/** Step 2 — STAY: diagonal path — "your roadmap" */
const stayPositions: IconPos[] = [
  { x: "8%", y: "72%", opacity: 0.38, size: 42 },
  { x: "22%", y: "58%", opacity: 0.42, size: 44 },
  { x: "38%", y: "46%", opacity: 0.45, size: 46 },
  { x: "54%", y: "36%", opacity: 0.48, size: 48 },
  { x: "70%", y: "26%", opacity: 0.5, size: 50 },
  { x: "86%", y: "16%", opacity: 0.52, size: 52 },
];

/** Step 3 — GROW: radial bloom — "this is your life now" */
const growPositions: IconPos[] = [
  { x: "48%", y: "8%", opacity: 0.5, size: 54 },
  { x: "84%", y: "28%", opacity: 0.46, size: 50 },
  { x: "78%", y: "68%", opacity: 0.44, size: 48 },
  { x: "48%", y: "82%", opacity: 0.48, size: 52 },
  { x: "14%", y: "64%", opacity: 0.46, size: 50 },
  { x: "16%", y: "24%", opacity: 0.44, size: 48 },
];

const formations = [matchPositions, startPositions, stayPositions, growPositions];

/* ─── Connecting path for STAY step ──────────────────────── */

function StayPath() {
  return (
    <svg className="absolute inset-0 w-full h-full pointer-events-none">
      <motion.path
        d="M 58 340 C 130 280, 200 240, 260 210 C 320 180, 400 140, 470 120 C 540 100, 600 70, 680 50"
        stroke="rgba(255,107,107,0.12)"
        strokeWidth="1.5"
        fill="none"
        strokeDasharray="5 8"
        strokeLinecap="round"
        initial={{ pathLength: 0, opacity: 0 }}
        animate={{ pathLength: 1, opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 1.2, ease: "easeOut" }}
      />
    </svg>
  );
}

/* ─── Glow behind center icon for START step ─────────────── */

function CenterGlow() {
  return (
    <motion.div
      className="absolute rounded-full pointer-events-none"
      style={{
        left: "44%",
        top: "42%",
        width: 140,
        height: 140,
        transform: "translate(-50%, -50%)",
        background:
          "radial-gradient(circle, rgba(255,107,107,0.1) 0%, transparent 70%)",
      }}
      initial={{ opacity: 0, scale: 0.4 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.4 }}
      transition={{ duration: 0.6 }}
    />
  );
}

/* ─── Component ──────────────────────────────────────────── */

interface Props {
  activeStep: number;
  isMobile?: boolean;
}

export function HowItWorksVisual({ activeStep, isMobile }: Props) {
  const positions = formations[activeStep] ?? formations[0];
  const sizeScale = isMobile ? 0.65 : 1;

  return (
    <div className="relative w-full h-full">
      {/* Special effects per step */}
      <AnimatePresence>
        {activeStep === 1 && <CenterGlow key="glow" />}
        {activeStep === 2 && <StayPath key="path" />}
      </AnimatePresence>

      {/* Icons — animate between formations */}
      {visualIcons.map((iconData, i) => {
        const pos = positions[i];
        const s = pos.size * sizeScale;

        return (
          <motion.div
            key={i}
            className="absolute pointer-events-none"
            animate={{
              left: pos.x,
              top: pos.y,
              opacity: pos.opacity,
              width: s,
              height: s,
            }}
            transition={{
              duration: 0.8,
              delay: i * 0.06,
              ease: EASE,
            }}
            style={{ filter: ICON_FILTER }}
          >
            <Lottie
              animationData={iconData}
              loop
              autoplay
              style={{ width: s, height: s }}
            />
          </motion.div>
        );
      })}
    </div>
  );
}
