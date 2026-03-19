"use client";

/**
 * CSS-only iPhone mockup frame.
 *
 * Renders a dark device frame with:
 * - Rounded rectangle body (40px radius)
 * - Dynamic island notch at top center
 * - Inner screen area with overflow:hidden and 32px radius
 * - Subtle warm ambient glow shadow
 * - Scales responsively via className override
 *
 * Children render inside the "screen" area.
 */
export function ExperiencePhone({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`relative flex-shrink-0 w-[280px] h-[580px] ${className}`}
    >
      {/* Device frame */}
      <div
        className="absolute inset-0 rounded-[40px]"
        style={{
          border: "2px solid rgba(255,255,255,0.08)",
          background: "#111111",
          boxShadow:
            "0 0 80px rgba(255,107,107,0.04), 0 0 160px rgba(255,107,107,0.02), 0 25px 60px rgba(0,0,0,0.5)",
        }}
      />

      {/* Dynamic island notch */}
      <div
        className="absolute top-[10px] left-1/2 -translate-x-1/2 z-20"
        style={{
          width: 90,
          height: 24,
          borderRadius: 14,
          background: "#000",
          border: "1px solid rgba(255,255,255,0.05)",
        }}
      />

      {/* Inner screen area */}
      <div
        className="absolute overflow-hidden"
        style={{
          top: 6,
          left: 6,
          right: 6,
          bottom: 6,
          borderRadius: 34,
          background: "#0A0A0F",
        }}
      >
        {children}
      </div>
    </div>
  );
}
