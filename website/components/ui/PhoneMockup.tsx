"use client";

import { cn } from "@/lib/utils";

interface PhoneMockupProps {
  children: React.ReactNode;
  className?: string;
  /** Scale factor for responsive sizing */
  scale?: "sm" | "md" | "lg";
}

const scaleMap = {
  sm: "w-[220px] h-[440px]",
  md: "w-[280px] h-[560px]",
  lg: "w-[320px] h-[640px]",
};

/**
 * Premium phone frame with notch, bezel glow, and drop shadow.
 * Content renders inside the screen area.
 */
export function PhoneMockup({
  children,
  className = "",
  scale = "md",
}: PhoneMockupProps) {
  return (
    <div
      className={cn(
        "phone-frame relative flex-shrink-0",
        scaleMap[scale],
        className
      )}
    >
      {/* Dynamic island / notch */}
      <div className="phone-notch" />

      {/* Screen content */}
      <div className="relative w-full h-full overflow-hidden bg-bg">
        {children}
      </div>

      {/* Bezel highlight (top edge) */}
      <div className="absolute top-0 left-[15%] right-[15%] h-px bg-gradient-to-r from-transparent via-white/20 to-transparent" />

      {/* Ambient glow behind frame */}
      <div className="absolute -inset-8 -z-10 rounded-[60px] bg-gradient-to-b from-coral/5 via-transparent to-bloom-teal/5 blur-2xl" />
    </div>
  );
}
