"use client";

import { useState, useCallback } from "react";
import { motion } from "framer-motion";
import { useInView } from "@/hooks/useInView";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { MagneticButton } from "@/components/ui/MagneticButton";
import { Check, Smartphone } from "lucide-react";

export function WaitlistCTA() {
  const { ref, inView } = useInView({ threshold: 0.1 });
  const [email, setEmail] = useState("");
  const [platform, setPlatform] = useState<"iphone" | "android" | null>(null);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      if (!email) return;
      // TODO: Wire to actual waitlist API
      setSubmitted(true);
    },
    [email]
  );

  return (
    <section
      id="waitlist"
      ref={ref}
      className="relative min-h-screen flex items-center justify-center overflow-hidden"
    >
      {/* ── Convergence glow layers ── */}
      {/* Outer warm wash */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[900px] h-[900px] opacity-20"
          style={{
            background:
              "radial-gradient(circle, rgba(255,107,107,0.25), rgba(218,165,32,0.10) 40%, transparent 70%)",
          }}
        />
        {/* Secondary coral bloom — slightly offset */}
        <div
          className="absolute top-[40%] left-[45%] -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] opacity-25"
          style={{
            background:
              "radial-gradient(circle, rgba(255,107,107,0.20), transparent 65%)",
          }}
        />
        {/* Gold accent top-left */}
        <div
          className="absolute top-1/4 left-1/4 w-[400px] h-[400px] opacity-15"
          style={{
            background:
              "radial-gradient(ellipse at center, rgba(218,165,32,0.2), transparent 70%)",
          }}
        />
        {/* Sage accent bottom-right */}
        <div
          className="absolute bottom-1/4 right-1/4 w-[350px] h-[350px] opacity-12"
          style={{
            background:
              "radial-gradient(ellipse at center, rgba(125,189,171,0.15), transparent 70%)",
          }}
        />
      </div>

      {/* ── Converging rings (CSS-only particle convergence) ── */}
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
        <div className="w-[1000px] h-[1000px] rounded-full border border-[#DAA520]/8" />
      </motion.div>

      {/* ── Content ── */}
      <div className="relative max-w-3xl mx-auto px-6 text-center py-32">
        {/* Overline */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="mb-6"
        >
          <span className="inline-block px-4 py-1.5 rounded-full bg-coral/8 border border-coral/15 text-coral text-xs font-semibold tracking-wide">
            Launching soon
          </span>
        </motion.div>

        {/* Headline — large, cinematic */}
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
          Join the waitlist. Be first to find the hobby
          you&rsquo;ll actually stick with.
        </motion.p>

        {/* Form / success */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.7 }}
          className="mt-12"
        >
          {!submitted ? (
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Email row */}
              <div className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="your@email.com"
                  required
                  className="flex-1 px-5 py-3.5 rounded-full bg-surface-elevated border border-glass-border text-text-primary placeholder:text-text-whisper text-sm focus:outline-none focus:ring-2 focus:ring-coral/40 transition-shadow"
                />
                <MagneticButton
                  variant="primary"
                  size="lg"
                  breathing
                  onClick={() => {}}
                >
                  Get Early Access
                </MagneticButton>
              </div>

              {/* Platform toggle */}
              <div className="flex items-center justify-center gap-3 mt-6">
                <span className="text-xs text-text-muted">
                  I&apos;ll use it on:
                </span>
                {(["iphone", "android"] as const).map((p) => (
                  <button
                    key={p}
                    type="button"
                    onClick={() => setPlatform(platform === p ? null : p)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all cursor-pointer ${
                      platform === p
                        ? "bg-coral/15 text-coral border border-coral/30"
                        : "bg-glass border border-glass-border text-text-muted hover:text-text-secondary"
                    }`}
                  >
                    <Smartphone size={12} />
                    {p === "iphone" ? "iPhone" : "Android"}
                  </button>
                ))}
              </div>

              <p className="text-[11px] text-text-whisper mt-4">
                No spam. Just a heads-up when we launch.
              </p>
            </form>
          ) : (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="glass-card p-8 max-w-md mx-auto"
            >
              <div className="w-12 h-12 rounded-full bg-coral/15 flex items-center justify-center mx-auto mb-4">
                <Check size={24} className="text-coral" />
              </div>
              <h3 className="text-xl font-bold text-text-primary mb-2">
                You&apos;re in.
              </h3>
              <p className="text-sm text-text-secondary">
                We&apos;ll send you a note when TrySomething is ready.
                {platform &&
                  ` We'll make sure the ${
                    platform === "iphone" ? "iOS" : "Android"
                  } version is waiting for you.`}
              </p>
            </motion.div>
          )}
        </motion.div>

        {/* Platform badges */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 1.0 }}
          className="flex items-center justify-center gap-6 mt-14"
        >
          <div className="flex items-center gap-2 text-text-whisper">
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-current">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
            </svg>
            <span className="text-xs">Coming to iPhone</span>
          </div>
          <div className="w-px h-4 bg-text-whisper" />
          <div className="flex items-center gap-2 text-text-whisper">
            <svg viewBox="0 0 24 24" className="w-5 h-5 fill-current">
              <path d="M17.523 15.341a.5.5 0 00-.471-.665h-.005a.5.5 0 00-.471.334L15.3 18.2h-1.207l1.406-3.547a.5.5 0 00-.28-.648.5.5 0 00-.191-.038H6.972a.5.5 0 00-.191.038.5.5 0 00-.28.648L7.907 18.2H6.7l-1.276-3.19a.5.5 0 00-.471-.334h-.005a.5.5 0 00-.471.665l1.7 4.35a.5.5 0 00.467.32h3.721a.5.5 0 00.465-.315l.934-2.33.934 2.33a.5.5 0 00.465.315h3.721a.5.5 0 00.467-.32zM15.5 7.5L12 2 8.5 7.5H4l8 13 8-13z" />
            </svg>
            <span className="text-xs">Coming to Android</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
