"use client";

import { cn } from "@/lib/utils";

interface GlassCardProps {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
  padding?: "none" | "sm" | "md" | "lg";
}

const paddingMap = {
  none: "",
  sm: "p-4",
  md: "p-6",
  lg: "p-8",
};

export function GlassCard({
  children,
  className,
  hover = false,
  padding = "md",
}: GlassCardProps) {
  return (
    <div
      className={cn(
        "glass-card noise",
        paddingMap[padding],
        hover && "cursor-pointer",
        className
      )}
    >
      {children}
    </div>
  );
}
