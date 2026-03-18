"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";

interface StaggeredTextProps {
  text: string;
  as?: "h1" | "h2" | "h3" | "p" | "span";
  className?: string;
  /** Words to render in Instrument Serif italic */
  highlightWords?: string[];
  /** Delay before animation starts (seconds) */
  delay?: number;
  /** Stagger delay between words (seconds) */
  stagger?: number;
  /** Animate from Y offset (px) */
  fromY?: number;
}

const wordVariants = {
  hidden: (fromY: number) => ({
    opacity: 0,
    y: fromY,
    filter: "blur(4px)",
  }),
  visible: {
    opacity: 1,
    y: 0,
    filter: "blur(0px)",
    transition: {
      duration: 0.6,
      ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
    },
  },
};

export function StaggeredText({
  text,
  as: Tag = "h1",
  className = "",
  highlightWords = [],
  delay = 0,
  stagger = 0.08,
  fromY = 40,
}: StaggeredTextProps) {
  const { ref, inView } = useInView({ threshold: 0.2 });
  const words = text.split(" ");

  const highlightSet = new Set(
    highlightWords.map((w) => w.toLowerCase())
  );

  return (
    <Tag ref={ref} className={className} aria-label={text}>
      <motion.span
        initial="hidden"
        animate={inView ? "visible" : "hidden"}
        variants={{
          visible: {
            transition: {
              staggerChildren: stagger,
              delayChildren: delay,
            },
          },
        }}
        className="inline"
      >
        {words.map((word, i) => {
          const isHighlight = highlightSet.has(word.toLowerCase().replace(/[.,!?]/, ""));
          return (
            <motion.span
              key={`${word}-${i}`}
              custom={fromY}
              variants={wordVariants}
              className={`inline-block mr-[0.3em] ${
                isHighlight ? "font-serif italic text-coral" : ""
              }`}
              style={{ willChange: "transform, opacity, filter" }}
            >
              {word}
            </motion.span>
          );
        })}
      </motion.span>
    </Tag>
  );
}
