"use client";

import { cn } from "@/lib/utils";

/**
 * Gradient blobs matching Flutter's _GradientBlobPainter.
 * Three radial gradients (coral, amber, violet) rendered as a single
 * composited background to avoid per-blob GPU layers.
 */
export function GradientBlobs({ className }: { className?: string }) {
  return (
    <div
      className={cn("absolute inset-0 overflow-hidden pointer-events-none", className)}
      aria-hidden="true"
      style={{
        background: [
          "radial-gradient(ellipse 600px 600px at 25% 30%, rgba(255,107,107,0.14) 0%, transparent 70%)",
          "radial-gradient(ellipse 500px 500px at 75% 45%, rgba(251,191,36,0.11) 0%, transparent 70%)",
          "radial-gradient(ellipse 550px 550px at 45% 80%, rgba(124,58,237,0.09) 0%, transparent 70%)",
        ].join(", "),
      }}
    />
  );
}
