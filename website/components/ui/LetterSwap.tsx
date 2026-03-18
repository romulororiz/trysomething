"use client";

import { useState, useCallback } from "react";
import { motion } from "framer-motion";

interface LetterSwapProps {
  text: string;
  hoverText?: string;
  className?: string;
  /** Stagger delay between letters (seconds) */
  stagger?: number;
}

/**
 * 3D letter swap on hover — each character rotates on X axis
 * to reveal alternate text. Inspired by React Bits Letter Swap.
 */
export function LetterSwap({
  text,
  hoverText,
  className = "",
  stagger = 0.03,
}: LetterSwapProps) {
  const [hovered, setHovered] = useState(false);
  const alt = hoverText || text;

  const handleEnter = useCallback(() => setHovered(true), []);
  const handleLeave = useCallback(() => setHovered(false), []);

  return (
    <span
      className={`inline-flex overflow-hidden cursor-pointer ${className}`}
      onMouseEnter={handleEnter}
      onMouseLeave={handleLeave}
      style={{ perspective: "600px" }}
      aria-label={text}
    >
      {text.split("").map((char, i) => {
        const altChar = alt[i] || char;
        const isSpace = char === " ";

        return (
          <span
            key={i}
            className="relative inline-block"
            style={{
              width: isSpace ? "0.3em" : undefined,
              transformStyle: "preserve-3d",
            }}
          >
            {/* Front face (default) */}
            <motion.span
              className="inline-block"
              animate={{
                rotateX: hovered ? -90 : 0,
                opacity: hovered ? 0 : 1,
              }}
              transition={{
                duration: 0.35,
                delay: i * stagger,
                ease: [0.33, 1, 0.68, 1],
              }}
              style={{
                transformOrigin: "bottom",
                backfaceVisibility: "hidden",
              }}
            >
              {isSpace ? "\u00A0" : char}
            </motion.span>

            {/* Back face (hover) */}
            <motion.span
              className="absolute top-0 left-0 inline-block text-coral"
              animate={{
                rotateX: hovered ? 0 : 90,
                opacity: hovered ? 1 : 0,
              }}
              transition={{
                duration: 0.35,
                delay: i * stagger,
                ease: [0.33, 1, 0.68, 1],
              }}
              style={{
                transformOrigin: "top",
                backfaceVisibility: "hidden",
              }}
            >
              {isSpace ? "\u00A0" : altChar}
            </motion.span>
          </span>
        );
      })}
    </span>
  );
}
