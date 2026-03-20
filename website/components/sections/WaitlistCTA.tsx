"use client";

import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { StoreBadges } from "@/components/ui/StoreBadges";

export function WaitlistCTA() {
  const { ref, inView } = useInView({ threshold: 0.1 });

  return (
    <section
      id="download"
      ref={ref}
      className="relative min-h-screen flex items-center justify-center overflow-hidden"
    >
      {/* ── Convergence glow layers ── */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[900px] h-[900px] opacity-20"
          style={{
            background:
              "radial-gradient(circle, rgba(255,107,107,0.25), rgba(218,165,32,0.10) 40%, transparent 70%)",
          }}
        />
        <div
          className="absolute top-[40%] left-[45%] -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] opacity-25"
          style={{
            background:
              "radial-gradient(circle, rgba(255,107,107,0.20), transparent 65%)",
          }}
        />
      </div>

      {/* ── Converging rings ── */}
      <motion.div
        initial={{ opacity: 0, scale: 1.3 }}
        animate={inView ? { opacity: 0.06, scale: 1 } : {}}
        transition={{ duration: 2, ease: [0.33, 1, 0.68, 1] }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none"
      >
        <div className="w-[700px] h-[700px] rounded-full border border-coral/10" />
      </motion.div>
      <motion.div
        initial={{ opacity: 0, scale: 1.5 }}
        animate={inView ? { opacity: 0.04, scale: 1 } : {}}
        transition={{ duration: 2.5, delay: 0.3, ease: [0.33, 1, 0.68, 1] }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none"
      >
        <div className="w-[1000px] h-[1000px] rounded-full border border-coral/8" />
      </motion.div>

      {/* ── Content ── */}
      <div className="relative max-w-3xl mx-auto px-6 text-center py-32">
        {/* Headline */}
        <StaggeredText
          text="Your next chapter starts now."
          as="h2"
          className="text-[clamp(2rem,5vw,4rem)] font-bold leading-[1.1] tracking-tight"
          highlightWords={["chapter"]}
          stagger={0.09}
        />

        {/* Subtext */}
        <motion.p
          initial={{ opacity: 0, y: 16 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.5 }}
          className="mt-6 text-lg md:text-xl text-text-secondary max-w-lg mx-auto leading-relaxed"
        >
          Download TrySomething. Find the hobby you&rsquo;ll actually stick
          with.
        </motion.p>

        {/* Store badges */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.7 }}
          className="mt-10 flex justify-center"
        >
          <StoreBadges />
        </motion.div>

        {/* Reassurance */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 1.0 }}
          className="mt-6 text-[11px] text-text-whisper"
        >
          Free to download. No credit card required.
        </motion.p>
      </div>
    </section>
  );
}
