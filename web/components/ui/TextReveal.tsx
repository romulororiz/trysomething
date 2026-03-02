"use client";

import { useRef, useEffect, useState } from "react";
import { cn } from "@/lib/utils";

interface TextRevealProps {
  text: string;
  as?: "h1" | "h2" | "h3" | "p" | "span";
  className?: string;
  staggerMs?: number;
  highlight?: string[];
  delay?: number;
}

export function TextReveal({
  text,
  as: Tag = "h2",
  className,
  staggerMs = 80,
  highlight = [],
  delay = 0,
}: TextRevealProps) {
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setTimeout(() => setVisible(true), delay);
          observer.disconnect();
        }
      },
      { threshold: 0.2, rootMargin: "0px 0px -50px 0px" }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [delay]);

  const words = text.split(" ");

  return (
    <Tag
      ref={ref as React.RefObject<HTMLHeadingElement>}
      className={cn(className)}
      style={{ display: "flex", flexWrap: "wrap", gap: "0 0.35em" }}
    >
      {words.map((word, i) => {
        const isHighlight = highlight.some(
          (h) => h.toLowerCase() === word.toLowerCase().replace(/[.,!?]$/, "")
        );

        return (
          <span
            key={i}
            style={{ overflow: "hidden", display: "inline-block" }}
          >
            <span
              className={cn(
                isHighlight && "text-coral wave-underline",
                isHighlight && visible && "wave-underline visible"
              )}
              style={{
                display: "inline-block",
                transform: visible ? "translateY(0)" : "translateY(100%)",
                transition: `transform 500ms cubic-bezier(0.33, 1, 0.68, 1) ${i * staggerMs}ms`,
              }}
            >
              {word}
            </span>
          </span>
        );
      })}
    </Tag>
  );
}
