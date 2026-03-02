"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { CelebrationParticles } from "@/components/canvas/CelebrationParticles";
import { BreathingButton } from "@/components/ui/BreathingButton";
import { TextReveal } from "@/components/ui/TextReveal";
import { useMagneticCursor } from "@/hooks/useMagneticCursor";

export function FinalCTA() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-100px" });
  const ctaRef = useMagneticCursor<HTMLButtonElement>({ strength: 0.3, radius: 25 });

  return (
    <section
      id="download"
      ref={ref}
      className="relative min-h-screen flex items-center justify-center overflow-hidden"
    >
      {/* Vibrant gradient blobs (intensified for finale) */}
      <div className="absolute inset-0 pointer-events-none" aria-hidden="true">
        <div
          className="absolute w-[700px] h-[700px] rounded-full"
          style={{
            background:
              "radial-gradient(circle, rgba(255,107,107,0.20) 0%, transparent 70%)",
            top: "5%",
            left: "10%",
            animation: "blob-drift-1 22s ease-in-out infinite",
          }}
        />
        <div
          className="absolute w-[600px] h-[600px] rounded-full"
          style={{
            background:
              "radial-gradient(circle, rgba(124,58,237,0.15) 0%, transparent 70%)",
            top: "20%",
            right: "5%",
            animation: "blob-drift-2 28s ease-in-out infinite",
          }}
        />
        <div
          className="absolute w-[650px] h-[650px] rounded-full"
          style={{
            background:
              "radial-gradient(circle, rgba(251,191,36,0.12) 0%, transparent 70%)",
            bottom: "0%",
            left: "25%",
            animation: "blob-drift-3 25s ease-in-out infinite",
          }}
        />
      </div>

      {/* Celebration particles */}
      <CelebrationParticles />

      {/* Noise overlay */}
      <div className="noise-overlay" style={{ opacity: 0.05 }} />

      {/* Content */}
      <div className="relative z-10 text-center px-6 max-w-2xl mx-auto">
        <TextReveal
          text="Ready to try something?"
          as="h2"
          className="font-serif text-[42px] md:text-[56px] font-bold leading-tight text-near-black mb-6 justify-center"
          highlight={["something?"]}
          staggerMs={100}
        />

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="font-sans text-lg text-driftwood mb-10"
        >
          Download free. No credit card. No commitment. Just possibility.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, scale: 0 }}
          animate={
            inView
              ? { opacity: 1, scale: 1 }
              : {}
          }
          transition={{
            type: "spring",
            stiffness: 300,
            damping: 20,
            delay: 0.8,
          }}
        >
          <BreathingButton ref={ctaRef} size="large">
            Download for Free
          </BreathingButton>
        </motion.div>

        {/* Store badges */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5, delay: 1.2 }}
          className="flex items-center justify-center gap-4 mt-8"
        >
          {/* Apple App Store badge */}
          <a href="#" className="cursor-pointer hover:brightness-110 transition-all" style={{ transitionDuration: "200ms" }}>
            <svg width="135" height="44" viewBox="0 0 135 44" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="135" height="44" rx="8" fill="#0A0A0F" />
              <rect x="0.5" y="0.5" width="134" height="43" rx="7.5" stroke="#363650" strokeOpacity="0.6" />
              {/* Apple logo */}
              <path d="M28.5 12.8c1.1-1.3 1.8-3.1 1.6-4.8-1.6.1-3.4 1-4.5 2.3-1 1.1-1.8 2.9-1.6 4.6 1.7.1 3.5-.9 4.5-2.1zm1.6 2.3c-2.5-.1-4.6 1.4-5.8 1.4-1.2 0-3-.1.4-4.4 1.3-5.7 1.3-2.5 0-4.5 1.5-5.3 2.7l-.1.1c-.7 1.1-1.1 2.6-1 4.5.2 2.8 1.3 5.9 2.8 7.9 1.2 1.6 2.3 2.5 3.3 2.5.4 0 .8-.1 1.2-.3.5-.2 1.1-.5 2-.5.8 0 1.3.3 1.9.5.4.2.9.3 1.5.3 1.4 0 2.5-1.3 3.5-2.7.6-.8 1-1.6 1.3-2.2l.1-.2c-1.5-.7-2.8-2.3-2.8-4.5 0-1.9 1-3.4 2.4-4.3-.9-1.3-2.3-2.1-3.9-2.1z" fill="white" />
              {/* Text */}
              <text x="44" y="17" fill="#A0A0B8" fontFamily="system-ui, -apple-system, sans-serif" fontSize="8" fontWeight="400">Download on the</text>
              <text x="44" y="32" fill="white" fontFamily="system-ui, -apple-system, sans-serif" fontSize="15" fontWeight="600">App Store</text>
            </svg>
          </a>

          {/* Google Play badge */}
          <a href="#" className="cursor-pointer hover:brightness-110 transition-all" style={{ transitionDuration: "200ms" }}>
            <svg width="148" height="44" viewBox="0 0 148 44" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect width="148" height="44" rx="8" fill="#0A0A0F" />
              <rect x="0.5" y="0.5" width="147" height="43" rx="7.5" stroke="#363650" strokeOpacity="0.6" />
              {/* Play Store triangle */}
              <path d="M16 10.5l12.5 11.5L16 33.5V10.5z" fill="url(#play-grad)" />
              <path d="M16 10.5l8.5 7.8 4-3.7L16 10.5z" fill="#34A853" />
              <path d="M16 33.5l8.5-7.8 4 3.7L16 33.5z" fill="#EA4335" />
              <path d="M28.5 22l-4-3.7 4-3.8L33 18l-4.5 4z" fill="#FBBC04" />
              <path d="M28.5 22l-4 3.7 4 3.8L33 26l-4.5-4z" fill="#4285F4" />
              <defs>
                <linearGradient id="play-grad" x1="16" y1="10.5" x2="16" y2="33.5" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#34A853" />
                  <stop offset="1" stopColor="#EA4335" />
                </linearGradient>
              </defs>
              {/* Text */}
              <text x="40" y="17" fill="#A0A0B8" fontFamily="system-ui, -apple-system, sans-serif" fontSize="8" fontWeight="400">GET IT ON</text>
              <text x="40" y="32" fill="white" fontFamily="system-ui, -apple-system, sans-serif" fontSize="15" fontWeight="600">Google Play</text>
            </svg>
          </a>
        </motion.div>

        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5, delay: 1.4 }}
          className="font-sans text-xs text-warm-gray mt-6"
        >
          Available on iOS and Android. Also works on web.
        </motion.p>
      </div>
    </section>
  );
}
