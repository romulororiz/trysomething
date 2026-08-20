"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

type Status = "idle" | "loading" | "success" | "error" | "fallback";

/**
 * WaitlistForm — the page's single conversion action while the app
 * is in closed beta. POSTs to /api/waitlist; if the webhook isn't
 * configured (503) it degrades to a mailto fallback instead of
 * silently dropping the email.
 */
export function WaitlistForm() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<Status>("idle");

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (status === "loading") return;
    setStatus("loading");
    try {
      const res = await fetch("/api/waitlist", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
      if (res.ok) {
        setStatus("success");
      } else if (res.status === 503) {
        setStatus("fallback");
      } else {
        setStatus("error");
      }
    } catch {
      setStatus("error");
    }
  };

  if (status === "success") {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.96 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5, ease: [0.33, 1, 0.68, 1] }}
        className="w-full max-w-md mx-auto rounded-2xl border border-coral/30 bg-coral/10 px-6 py-5 text-center"
        role="status"
      >
        <p className="text-base font-semibold text-text-primary">
          You&rsquo;re on the list.
        </p>
        <p className="mt-1 text-sm text-text-secondary">
          Watch your inbox — the first cohort is invited in small waves.
        </p>
      </motion.div>
    );
  }

  return (
    <div className="w-full max-w-md mx-auto">
      <form
        onSubmit={submit}
        className="flex flex-col sm:flex-row gap-3"
        aria-label="Join the TrySomething beta waitlist"
      >
        {/* Honeypot — hidden from humans, tempting for bots */}
        <input
          type="text"
          name="company"
          tabIndex={-1}
          autoComplete="off"
          aria-hidden="true"
          className="hidden"
          onChange={() => {}}
        />

        <label htmlFor="waitlist-email" className="sr-only">
          Email address
        </label>
        <input
          id="waitlist-email"
          type="email"
          required
          value={email}
          onChange={(e) => {
            setEmail(e.target.value);
            if (status === "error") setStatus("idle");
          }}
          placeholder="you@example.com"
          autoComplete="email"
          inputMode="email"
          className="flex-1 h-13 px-5 py-3.5 rounded-full bg-white/[0.06] border border-white/[0.12] text-[15px] text-text-primary placeholder:text-text-muted outline-none focus:border-coral/60 focus:bg-white/[0.08] transition-colors duration-200"
        />
        <button
          type="submit"
          disabled={status === "loading"}
          className="breathing-glow shrink-0 px-7 py-3.5 rounded-full text-[15px] font-semibold text-white bg-coral hover:bg-coral-hover transition-colors duration-200 cursor-pointer active:scale-[0.97] disabled:opacity-60 disabled:cursor-wait"
        >
          {status === "loading" ? "Joining…" : "Join the beta"}
        </button>
      </form>

      <div aria-live="polite">
        <AnimatePresence>
          {status === "error" && (
            <motion.p
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              className="mt-3 text-sm text-coral text-center"
            >
              Something hiccuped. Try again, or email{" "}
              <a href="mailto:support@trysomething.io" className="underline underline-offset-2">
                support@trysomething.io
              </a>
              .
            </motion.p>
          )}
          {status === "fallback" && (
            <motion.p
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              className="mt-3 text-sm text-text-secondary text-center"
            >
              Signups open shortly. Email{" "}
              <a
                href="mailto:support@trysomething.io?subject=TrySomething%20beta"
                className="text-coral underline underline-offset-2"
              >
                support@trysomething.io
              </a>{" "}
              and we&rsquo;ll add you by hand.
            </motion.p>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
