"use client";

import { useRef, useEffect } from "react";
import { useReducedMotion } from "@/hooks/useReducedMotion";

const PARTICLE_COUNT = 30;
const PARTICLE_COLORS = [
  "#FF6B6B", // coral
  "#FBBF24", // amber
  "#7C3AED", // indigo
  "#06D6A0", // sage
  "#FB7185", // rose
];

interface Particle {
  x: number;
  y: number;
  size: number;
  alpha: number;
  speed: number;
  wobbleFreq: number;
  wobbleFreq2: number;
  wobbleAmp: number;
  wobbleAmp2: number;
  color: string;
  depth: number; // 0=far, 1=mid, 2=near
}

/**
 * Celebration particles matching Flutter's _ParticlePainter.
 * 30 depth-stratified glowing orbs rising with dual sine-wave wobble.
 */
export function CelebrationParticles() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const reduced = useReducedMotion();

  useEffect(() => {
    if (reduced) return;

    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const resize = () => {
      canvas.width = canvas.offsetWidth * window.devicePixelRatio;
      canvas.height = canvas.offsetHeight * window.devicePixelRatio;
      ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
    };
    resize();
    window.addEventListener("resize", resize);

    // Initialize particles with 3 depth layers
    const particles: Particle[] = Array.from({ length: PARTICLE_COUNT }, (_, i) => {
      const depthIndex = i < 10 ? 0 : i < 20 ? 1 : 2;
      const depthScale = [0.3, 0.6, 1.0][depthIndex];
      const depthAlpha = [0.20, 0.35, 0.50][depthIndex];

      return {
        x: Math.random() * canvas.offsetWidth,
        y: Math.random() * canvas.offsetHeight,
        size: (3 + Math.random() * 4) * depthScale,
        alpha: depthAlpha,
        speed: (0.3 + Math.random() * 0.5) * depthScale,
        wobbleFreq: 0.5 + Math.random() * 1.5,
        wobbleFreq2: 0.3 + Math.random() * 1.0,
        wobbleAmp: 10 + Math.random() * 20,
        wobbleAmp2: 5 + Math.random() * 10,
        color: PARTICLE_COLORS[Math.floor(Math.random() * PARTICLE_COLORS.length)],
        depth: depthIndex,
      };
    });

    let animId: number;
    let time = 0;

    const draw = () => {
      const w = canvas.offsetWidth;
      const h = canvas.offsetHeight;

      ctx.clearRect(0, 0, w, h);
      time += 0.016;

      for (const p of particles) {
        // Move upward, wrap around
        p.y -= p.speed;
        if (p.y < -20) p.y = h + 20;

        // Dual sine-wave wobble
        const wobbleX =
          Math.sin(time * p.wobbleFreq + p.x * 0.01) * p.wobbleAmp +
          Math.sin(time * p.wobbleFreq2 + p.y * 0.02) * p.wobbleAmp2;

        const drawX = p.x + wobbleX;

        // Fade near top and bottom edges (clamped to [0,1] to prevent negative alpha)
        const edgeFade = Math.max(0, Math.min(p.y / 100, (h - p.y) / 100, 1));
        const finalAlpha = p.alpha * edgeFade;

        // Helper: clamp alpha to valid hex byte
        const alphaHex = (a: number) =>
          Math.max(0, Math.min(255, Math.round(a * 255)))
            .toString(16)
            .padStart(2, "0");

        // Radial gradient per particle (bright center → transparent edge)
        const gradient = ctx.createRadialGradient(
          drawX, p.y, 0,
          drawX, p.y, p.size * 2
        );
        gradient.addColorStop(0, `${p.color}${alphaHex(finalAlpha * 0.8)}`);
        gradient.addColorStop(0.4, `${p.color}${alphaHex(finalAlpha * 0.5)}`);
        gradient.addColorStop(1, `${p.color}00`);

        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.arc(drawX, p.y, p.size * 2, 0, Math.PI * 2);
        ctx.fill();

        // Inner core glow (80% alpha)
        ctx.fillStyle = `${p.color}${alphaHex(finalAlpha * 0.8)}`;
        ctx.beginPath();
        ctx.arc(drawX, p.y, p.size * 0.5, 0, Math.PI * 2);
        ctx.fill();
      }

      animId = requestAnimationFrame(draw);
    };

    animId = requestAnimationFrame(draw);

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener("resize", resize);
    };
  }, [reduced]);

  if (reduced) return null;

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full pointer-events-none"
      aria-hidden="true"
    />
  );
}
