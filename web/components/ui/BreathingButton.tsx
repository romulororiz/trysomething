"use client";

import { forwardRef } from "react";
import { cn } from "@/lib/utils";
import { useBreathingGlow } from "@/hooks/useBreathingGlow";

interface BreathingButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  size?: "default" | "large";
}

/**
 * Coral CTA button with breathing glow animation.
 * Matching Flutter's TryTodayButton: 1800ms glow cycle, coral shadow pulse.
 */
export const BreathingButton = forwardRef<
  HTMLButtonElement,
  BreathingButtonProps
>(({ children, className, size = "default", ...props }, ref) => {
  const glowClass = useBreathingGlow();

  return (
    <button
      ref={ref}
      className={cn(
        "relative font-sans font-bold text-white bg-coral rounded-[100px] cursor-pointer",
        "transition-transform active:scale-[0.97]",
        glowClass,
        size === "large" ? "px-10 py-4 text-base" : "px-8 py-3 text-sm",
        className
      )}
      style={{ transitionDuration: "120ms" }}
      {...props}
    >
      {children}
    </button>
  );
});

BreathingButton.displayName = "BreathingButton";
