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
      // TODO: Wire to actual waitlist API (e.g. Loops, Mailchimp, custom endpoint)
      setSubmitted(true);
    },
    [email]
  );

  return (
    <section
      id="waitlist"
      ref={ref}
      className="relative py-32 md:py-40 overflow-hidden"
    >
      {/* Atmospheric background */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-0 left-1/4 w-[600px] h-[600px] bloom-teal opacity-20" />
        <div className="absolute bottom-0 right-1/4 w-[500px] h-[500px] bloom-burgundy opacity-15" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] bloom-coral opacity-10" />
      </div>

      <div className="relative max-w-3xl mx-auto px-6 text-center">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="mb-4"
        >
          <span className="inline-block px-3 py-1 rounded-full bg-coral/10 text-coral text-xs font-semibold">
            Launching soon
          </span>
        </motion.div>

        <StaggeredText
          text="Ready to try something?"
          as="h2"
          className="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight tracking-tight"
          highlightWords={["something"]}
          stagger={0.08}
        />

        <motion.p
          initial={{ opacity: 0, y: 16 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="mt-6 text-lg text-text-secondary max-w-md mx-auto"
        >
          Join the waitlist. Be first to find your hobby when we launch.
        </motion.p>

        {/* Form or success state */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.6 }}
          className="mt-10"
        >
          {!submitted ? (
            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Email input */}
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
                  size="md"
                  breathing
                  onClick={() => {}}
                >
                  Get Early Access
                </MagneticButton>
              </div>

              {/* Platform preference (optional) */}
              <div className="flex items-center justify-center gap-3 mt-6">
                <span className="text-xs text-text-muted">I&apos;ll use it on:</span>
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
          transition={{ duration: 0.5, delay: 0.9 }}
          className="flex items-center justify-center gap-6 mt-12"
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
