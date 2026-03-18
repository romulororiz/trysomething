"use client";

import { motion } from "framer-motion";
import { ChevronDown } from "lucide-react";
import { HeroEnvironment } from "@/components/canvas/HeroEnvironment";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { MagneticButton } from "@/components/ui/MagneticButton";
import { IPhoneMockup3D } from "@/components/ui/IPhoneMockup3D";

const fadeUp = (delay: number) => ({
  initial: { opacity: 0, y: 24 },
  animate: { opacity: 1, y: 0 },
  transition: {
    duration: 0.7,
    delay,
    ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
  },
});

/**
 * Accurate miniature of the actual Home tab (Tab 1).
 * Matches: greeting, hobby card with roadmap step, coach chip, glass dock nav.
 */
function HomeScreenPreview() {
  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] overflow-hidden relative">
      {/* Status bar */}
      <div className="pt-[14%] px-[6%] flex items-center justify-between">
        <span className="text-[8px] text-[#6B6360] font-medium">9:41</span>
        <div className="flex gap-0.5 items-center">
          <div className="w-2 h-1 rounded-sm bg-[#3D3835]" />
          <div className="w-1 h-1 rounded-full bg-[#3D3835]" />
        </div>
      </div>

      {/* Greeting */}
      <div className="px-[6%] mt-[3%]">
        <p className="text-[7px] text-[#6B6360]">Good morning</p>
        <p className="text-[12px] font-bold text-[#F5F0EB] mt-0.5 font-serif">
          Your next step
        </p>
      </div>

      {/* Active hobby card — glass style */}
      <div
        className="mx-[5%] mt-[3%] rounded-[10px] p-[4%] flex-1 flex flex-col min-h-0"
        style={{
          background: "rgba(255,255,255,0.08)",
          border: "0.5px solid rgba(255,255,255,0.12)",
        }}
      >
        {/* Overline + icon */}
        <div className="flex items-start justify-between">
          <div className="flex-1 min-w-0">
            <p className="text-[6px] text-[#6B6360] uppercase tracking-wider font-semibold">
              Week 2 of Pottery
            </p>
            <p className="text-[10px] font-bold text-[#F5F0EB] mt-0.5 font-serif">
              Center your first bowl
            </p>
          </div>
          <div className="w-5 h-5 rounded-md bg-[#0D9488]/20 flex items-center justify-center flex-shrink-0 ml-1">
            <span className="text-[8px]">&#x1F3FA;</span>
          </div>
        </div>

        {/* Progress */}
        <div className="mt-[5%] h-[2px] rounded-full bg-[#1A1A20] overflow-hidden">
          <div className="h-full w-[42%] rounded-full bg-gradient-to-r from-[#FF6B6B] to-[#FF8585]" />
        </div>
        <p className="text-[6px] text-[#6B6360] mt-0.5">Step 5 of 12</p>

        {/* Start session CTA */}
        <div className="mt-[4%] py-[4%] rounded-full bg-[#FF6B6B] text-center">
          <p className="text-[8px] font-bold text-white">Start session</p>
        </div>

        <div className="flex-1" />

        {/* This week mini bar */}
        <div className="mt-[3%]">
          <p className="text-[5px] text-[#6B6360] uppercase tracking-wider font-semibold mb-1">
            This week
          </p>
          <div className="flex gap-[2px]">
            {["M", "T", "W", "T", "F", "S", "S"].map((d, i) => (
              <div
                key={d + i}
                className={`flex-1 text-center py-[2px] rounded text-[5px] font-medium ${
                  i < 3
                    ? "bg-[#FF6B6B]/20 text-[#FF6B6B]"
                    : i === 3
                      ? "bg-[#1A1A20] text-[#F5F0EB] ring-[0.5px] ring-[#FF6B6B]"
                      : "bg-[#1A1A20] text-[#3D3835]"
                }`}
              >
                {d}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Coach chip */}
      <div
        className="mx-[5%] mt-[2%] rounded-[10px] p-[3%] flex items-center gap-[3%]"
        style={{
          background: "rgba(255,255,255,0.08)",
          border: "0.5px solid rgba(255,255,255,0.12)",
        }}
      >
        <div className="w-4 h-4 rounded-full bg-[#FF6B6B]/15 flex items-center justify-center flex-shrink-0">
          <span className="text-[6px] text-[#FF6B6B]">&#x2726;</span>
        </div>
        <p className="text-[6px] text-[#B0A89E] leading-tight flex-1">
          How was the centering exercise?
        </p>
        <span className="text-[7px] text-[#6B6360]">&#x203A;</span>
      </div>

      {/* Floating glass dock nav */}
      <div className="mx-[10%] mt-auto mb-[4%]">
        <div
          className="flex justify-around items-center py-[3%] rounded-[14px]"
          style={{
            background: "rgba(255,255,255,0.08)",
            border: "0.5px solid rgba(255,255,255,0.12)",
            backdropFilter: "blur(12px)",
          }}
        >
          {/* Home (active) */}
          <div className="w-3 h-[2px] rounded-full bg-[#FF6B6B]" />
          {/* Discover */}
          <div className="w-3 h-[2px] rounded-full bg-[#3D3835]" />
          {/* Profile */}
          <div className="w-3 h-[2px] rounded-full bg-[#3D3835]" />
        </div>
      </div>
    </div>
  );
}

export function Hero() {
  const scrollToNext = () => {
    const el = document.querySelector("#problem");
    el?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      <HeroEnvironment />

      <div className="relative z-10 max-w-7xl mx-auto px-6 py-28 md:py-36 w-full">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Left — Copy */}
          <div className="max-w-xl">
            <motion.p
              {...fadeUp(0.2)}
              className="text-sm font-medium text-text-muted uppercase tracking-[0.2em] mb-6"
            >
              Stop scrolling. Start something.
            </motion.p>

            <StaggeredText
              text="Find a hobby you'll actually stick with."
              as="h1"
              className="text-4xl sm:text-5xl lg:text-6xl font-bold leading-[1.08] tracking-tight"
              highlightWords={["hobby"]}
              delay={0.4}
              stagger={0.07}
            />

            <motion.p
              {...fadeUp(1.2)}
              className="mt-6 text-lg text-text-secondary leading-relaxed max-w-md"
            >
              One hobby matched to your life. Everything you need to start.
              A coach to keep you going for 30 days.
            </motion.p>

            <motion.div
              {...fadeUp(1.5)}
              className="mt-10 flex flex-wrap items-center gap-4"
            >
              <MagneticButton
                variant="primary"
                size="lg"
                breathing
                href="#waitlist"
              >
                Get Early Access
              </MagneticButton>

              <MagneticButton variant="ghost" size="lg" href="#how-it-works">
                See how it works
                <ChevronDown size={16} className="ml-1.5 opacity-60" />
              </MagneticButton>
            </motion.div>

            <motion.p
              {...fadeUp(2.0)}
              className="mt-6 text-xs text-text-whisper"
            >
              Coming soon to iPhone &amp; Android
            </motion.p>
          </div>

          {/* Right — 3D tilted phone */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{
              duration: 1,
              delay: 0.8,
              ease: [0.33, 1, 0.68, 1] as [number, number, number, number],
            }}
            className="flex justify-center lg:justify-end"
            style={{ perspective: "1200px" }}
          >
            <div
              className="relative transition-transform duration-700 ease-out hover:[transform:rotateY(-3deg)_rotateX(2deg)]"
              style={{
                transform: "rotateY(-12deg) rotateX(5deg)",
                transformStyle: "preserve-3d",
              }}
            >
              {/* Ambient glow */}
              <div
                className="absolute -inset-10 -z-10 rounded-[60px] blur-3xl opacity-40"
                style={{
                  background:
                    "radial-gradient(ellipse at center, rgba(255,107,107,0.1), rgba(13,148,136,0.06) 50%, transparent 70%)",
                }}
              />

              <IPhoneMockup3D width={300}>
                <HomeScreenPreview />
              </IPhoneMockup3D>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Scroll indicator */}
      <motion.button
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2.5 }}
        onClick={scrollToNext}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 text-text-whisper hover:text-text-muted transition-colors cursor-pointer"
        aria-label="Scroll down"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
        >
          <ChevronDown size={24} />
        </motion.div>
      </motion.button>
    </section>
  );
}
