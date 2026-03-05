"use client";

import { cn } from "@/lib/utils";

interface GlassCardProps {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
}

/**
 * Glassmorphism card matching Flutter's GlassContainer.
 * backdrop-blur + sand bg at 85% + noise grain texture.
 */
export function GlassCard({
  children,
  className,
  hover = false,
}: GlassCardProps) {
  return (
    <div
      className={cn(
        "glass",
        hover &&
          "transition-shadow cursor-pointer hover:border-stone hover:shadow-[0_8px_32px_rgba(0,0,0,0.24),0_2px_8px_rgba(0,0,0,0.14)]",
        className
      )}
      style={hover ? { transitionDuration: "250ms" } : undefined}
    >
      {children}
    </div>
  );
}
