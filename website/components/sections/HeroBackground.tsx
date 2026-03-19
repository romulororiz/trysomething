"use client";

/**
 * HeroBackground — Pure black with barely-visible warm glow + noise grain.
 *
 * The gradient is intentionally almost invisible (3% opacity warm gold).
 * It prevents the "LCD black" digital feeling by adding the tiniest warm center.
 * The .noise class (defined in globals.css) adds 2-3% opacity grain texture.
 */
export function HeroBackground() {
  return (
    <div className="absolute inset-0 bg-black pointer-events-none">
      {/* Ultra-subtle warm radial glow — barely perceptible */}
      <div
        className="absolute inset-0"
        style={{
          background:
            "radial-gradient(ellipse at 50% 40%, rgba(212,160,84,0.03) 0%, transparent 70%)",
        }}
      />

      {/* Noise grain texture — reuses existing .noise::after from globals.css */}
      <div className="noise absolute inset-0 opacity-[0.03]" />
    </div>
  );
}
