"use client";

import { useRef, useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ChevronDown } from "lucide-react";
import { GradientBlobs } from "@/components/canvas/GradientBlobs";
import { BreathingButton } from "@/components/ui/BreathingButton";
import { TextReveal } from "@/components/ui/TextReveal";
export function HeroSection() {
  const [showHint, setShowHint] = useState(true);
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const timer = setTimeout(() => setShowHint(false), 4000);
    return () => clearTimeout(timer);
  }, []);

  const scrollToFeatures = () => {
    document.querySelector("#solution")?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <section
      ref={sectionRef}
      className="relative min-h-screen flex items-center overflow-hidden"
    >
      {/* Background blobs */}
      <GradientBlobs />

      {/* Content */}
      <div className="relative z-10 w-full max-w-7xl mx-auto px-6 md:px-12 py-24">
        <div className="flex flex-col lg:flex-row items-center gap-16 lg:gap-20">
          {/* Text content — 60% */}
          <div className="flex-1 max-w-2xl">
            {/* Overline */}
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="font-mono text-[11px] font-semibold tracking-[2px] text-warm-gray uppercase mb-6"
            >
              HOBBY DISCOVERY APP
            </motion.p>

            {/* Headline */}
            <TextReveal
              text="You've been meaning to try something new."
              as="h1"
              className="font-serif text-[42px] md:text-[64px] font-bold leading-[1.05] tracking-tight text-near-black mb-6"
              highlight={["something"]}
              staggerMs={100}
              delay={400}
            />

            {/* Subheadline */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{
                duration: 0.6,
                delay: 0.9,
                ease: [0.33, 1, 0.68, 1],
              }}
              className="font-sans text-lg leading-relaxed text-driftwood max-w-lg mb-10"
            >
              Discover 72+ hobbies, get beginner-friendly guidance, and track
              your journey from &ldquo;maybe&rdquo; to mastery.
            </motion.p>

            {/* CTAs */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{
                duration: 0.4,
                delay: 1.1,
                ease: [0.33, 1, 0.68, 1],
              }}
              className="flex flex-wrap items-center gap-4"
            >
              <BreathingButton size="large">
                Start Discovering
              </BreathingButton>

              <button
                onClick={scrollToFeatures}
                className="font-sans text-sm font-semibold text-coral hover:text-coral-light transition-colors cursor-pointer px-4 py-3"
                style={{ transitionDuration: "200ms" }}
              >
                See how it works &darr;
              </button>
            </motion.div>
          </div>

          {/* Phone mockup area — 40% */}
          <motion.div
            initial={{ opacity: 0, x: 60 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{
              duration: 0.8,
              delay: 0.6,
              ease: [0.33, 1, 0.68, 1],
            }}
            className="flex-shrink-0 relative w-[280px] md:w-[320px] h-[560px] md:h-[640px]"
          >
            {/* Phone frame placeholder — will be replaced with 3D in Phase 4 */}
            <div
              className="w-full h-full rounded-[40px] overflow-hidden border-2 border-sand-dark/60 bg-warm-white"
              style={{
                boxShadow:
                  "0 8px 32px rgba(0,0,0,0.24), 0 2px 8px rgba(0,0,0,0.14), inset 0 1px 0 rgba(255,255,255,0.05)",
              }}
            >
              {/* Screen content — gradient mockup of the app feed */}
              <div className="w-full h-full bg-gradient-to-b from-warm-white via-cream to-sand flex flex-col items-center justify-center gap-4 p-6">
                <div className="w-16 h-16 rounded-2xl bg-coral/20 flex items-center justify-center">
                  <span className="font-serif text-2xl font-bold text-coral">T</span>
                </div>
                <p className="font-serif text-lg font-bold text-near-black text-center">TrySomething</p>
                <p className="font-sans text-xs text-warm-gray text-center">Your discovery feed awaits</p>

                {/* Mini card previews */}
                {["Pottery", "Bouldering", "Sourdough"].map((name, i) => (
                  <div
                    key={name}
                    className="w-full h-16 rounded-tile bg-sand/80 border border-sand-dark/40 flex items-center gap-3 px-4"
                    style={{ opacity: 1 - i * 0.15 }}
                  >
                    <div
                      className="w-10 h-10 rounded-xl"
                      style={{
                        background: [
                          "linear-gradient(135deg, #D946EF30, #D946EF10)",
                          "linear-gradient(135deg, #FF475730, #FF475710)",
                          "linear-gradient(135deg, #FB923C30, #FB923C10)",
                        ][i],
                      }}
                    />
                    <div>
                      <p className="font-sans text-sm font-semibold text-near-black">{name}</p>
                      <p className="font-sans text-[10px] text-warm-gray">Tap to explore</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Floating glow behind phone */}
            <div
              className="absolute -inset-8 -z-10 rounded-[60px]"
              style={{
                background:
                  "radial-gradient(circle, rgba(124,58,237,0.10) 0%, transparent 60%)",
              }}
            />
          </motion.div>
        </div>
      </div>

      {/* Scroll hint */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: showHint ? 0.6 : 0 }}
        transition={{ duration: 0.5 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 1.5, repeat: Infinity }}
        >
          <ChevronDown size={24} className="text-warm-gray" />
        </motion.div>
      </motion.div>
    </section>
  );
}
