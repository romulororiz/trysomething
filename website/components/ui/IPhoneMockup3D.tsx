"use client";

/**
 * Pixel-perfect iPhone mockup adapted from 21st.dev.
 * Uses direct CSS dimensions (not transform: scale) to avoid layout issues.
 */

import React, { type CSSProperties, type ReactNode } from "react";
import { cn } from "@/lib/utils";

export interface IPhoneMockup3DProps {
  children?: ReactNode;
  className?: string;
  /** Width of the rendered phone in CSS pixels. Height is auto (16:9-ish ratio). */
  width?: number;
  /** Screen background color */
  screenBg?: string;
}

/* iPhone 15 Pro aspect ratio: (393+24) / (852+24) = 417/876 ≈ 0.476 */
const ASPECT = 417 / 876;
const BEZEL_RATIO = 12 / 417; // bezel as fraction of outer width
const RADIUS_RATIO = 68 / 417; // outer radius as fraction of outer width
const SCREEN_RADIUS_RATIO = 56 / 417;
const ISLAND_W_RATIO = 126 / 417;
const ISLAND_H_RATIO = 37 / 876;
const ISLAND_R_RATIO = 20 / 417;
const HOME_W_RATIO = 134 / 417;
const HOME_H_RATIO = 5 / 876;

function shade(hex: string, pct: number): string {
  const m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex.trim());
  if (!m) return hex;
  const [r, g, b] = [parseInt(m[1], 16), parseInt(m[2], 16), parseInt(m[3], 16)];
  const k = (100 + pct) / 100;
  const c = (v: number) => Math.max(0, Math.min(255, Math.round(v * k)));
  return `#${c(r).toString(16).padStart(2, "0")}${c(g).toString(16).padStart(2, "0")}${c(b).toString(16).padStart(2, "0")}`;
}

export function IPhoneMockup3D({
  children,
  className,
  width = 280,
  screenBg = "#050508",
}: IPhoneMockup3DProps) {
  const h = width / ASPECT;
  const bezel = width * BEZEL_RATIO;
  const outerR = width * RADIUS_RATIO;
  const screenR = width * SCREEN_RADIUS_RATIO;
  const islandW = width * ISLAND_W_RATIO;
  const islandH = h * ISLAND_H_RATIO;
  const islandR = width * ISLAND_R_RATIO;
  const homeW = width * HOME_W_RATIO;
  const homeH = h * HOME_H_RATIO;

  const colorHex = "#1c1e22"; // space-black
  const frameGradient = `linear-gradient(145deg, ${shade(colorHex, 12)} 0%, ${colorHex} 35%, ${shade(colorHex, -18)} 100%)`;

  const frame: CSSProperties = {
    width,
    height: h,
    borderRadius: outerR,
    background: frameGradient,
    padding: bezel,
    boxSizing: "border-box",
    boxShadow: [
      `0 ${h * 0.03}px ${h * 0.07}px rgba(0,0,0,0.5)`,
      `0 ${h * 0.01}px ${h * 0.025}px rgba(0,0,0,0.35)`,
      "inset 0 1px 0 rgba(255,255,255,0.08)",
      "inset 0 -1px 0 rgba(255,255,255,0.03)",
    ].join(", "),
    position: "relative",
    overflow: "hidden",
  };

  const screen: CSSProperties = {
    width: "100%",
    height: "100%",
    borderRadius: screenR,
    position: "relative",
    overflow: "hidden",
    background: screenBg,
    boxShadow:
      "inset 0 0 0 1px rgba(255,255,255,0.04), inset 0 8px 16px rgba(0,0,0,0.4), inset 0 -6px 12px rgba(0,0,0,0.25)",
  };

  return (
    <div className={cn("relative inline-block flex-shrink-0", className)}>
      <div style={frame}>
        <div style={screen}>
          {/* Dynamic Island */}
          <div
            aria-hidden
            style={{
              position: "absolute",
              top: bezel * 0.4,
              left: "50%",
              transform: "translateX(-50%)",
              width: islandW,
              height: islandH,
              borderRadius: islandR,
              background: "#000",
              boxShadow: "0 1px 3px rgba(0,0,0,0.8)",
              zIndex: 20,
            }}
          />

          {/* Content */}
          <div
            style={{
              position: "absolute",
              inset: 0,
              overflow: "hidden",
              zIndex: 10,
            }}
          >
            {children}
          </div>

          {/* Home indicator */}
          <div
            aria-hidden
            style={{
              position: "absolute",
              bottom: bezel * 0.5,
              left: "50%",
              transform: "translateX(-50%)",
              width: homeW,
              height: Math.max(homeH, 3),
              borderRadius: homeH,
              background: "linear-gradient(180deg, rgba(255,255,255,0.5), rgba(255,255,255,0.2))",
              zIndex: 20,
              pointerEvents: "none",
            }}
          />
        </div>

        {/* Top bezel highlight */}
        <div
          className="absolute top-0 left-[20%] right-[20%] h-px pointer-events-none"
          style={{
            background: "linear-gradient(to right, transparent, rgba(255,255,255,0.1), transparent)",
          }}
        />
      </div>
    </div>
  );
}
