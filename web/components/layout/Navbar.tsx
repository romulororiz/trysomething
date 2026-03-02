"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import { cn } from "@/lib/utils";

const navLinks = [
  { label: "Features", href: "#features" },
  { label: "Community", href: "#community" },
];

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [scrollProgress, setScrollProgress] = useState(0);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 80);
      const docHeight =
        document.documentElement.scrollHeight - window.innerHeight;
      setScrollProgress(docHeight > 0 ? window.scrollY / docHeight : 0);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const scrollTo = (href: string) => {
    setMobileOpen(false);
    const el = document.querySelector(href);
    el?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <>
      {/* Scroll progress bar */}
      <div
        className="scroll-progress"
        style={{ transform: `scaleX(${scrollProgress})` }}
      />

      {/* Navbar */}
      <nav
        className={cn(
          "fixed top-4 left-4 right-4 z-20 flex items-center justify-between px-6 py-3 rounded-2xl transition-all",
          scrolled
            ? "bg-cream/95 backdrop-blur-lg border border-stone/40"
            : "bg-transparent"
        )}
        style={{ transitionDuration: "250ms" }}
      >
        {/* Coral accent line at bottom (visible only when scrolled) */}
        <div
          className={cn(
            "absolute bottom-0 left-4 right-4 h-px bg-coral transition-opacity",
            scrolled ? "opacity-100" : "opacity-0"
          )}
          style={{ transitionDuration: "250ms" }}
        />

        {/* Logo */}
        <a
          href="#"
          className="font-serif text-xl font-bold text-near-black hover:text-coral transition-colors cursor-pointer flex items-center"
          style={{ transitionDuration: "200ms" }}
        >
          TrySomething
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-coral ml-1" />
        </a>

        {/* Desktop links */}
        <div className="hidden md:flex items-center gap-8">
          {navLinks.map((link) => (
            <button
              key={link.href}
              onClick={() => scrollTo(link.href)}
              className="group relative font-sans text-sm font-medium text-driftwood hover:text-coral transition-colors cursor-pointer"
              style={{ transitionDuration: "200ms" }}
            >
              {link.label}
              <span
                className="absolute left-1/2 -translate-x-1/2 -bottom-1.5 w-1 h-0.5 rounded-full bg-coral transition-transform origin-center scale-0 group-hover:scale-100"
                style={{ transitionDuration: "200ms" }}
              />
            </button>
          ))}
        </div>

        {/* Desktop CTA */}
        <button
          onClick={() => scrollTo("#download")}
          className={cn(
            "hidden md:block px-5 py-2 rounded-badge font-sans text-sm font-bold text-white cursor-pointer",
            "bg-coral breathing-glow",
            "transition-transform hover:scale-[1.02] active:scale-[0.97]"
          )}
          style={{ transitionDuration: "150ms" }}
        >
          Download
        </button>

        {/* Mobile hamburger */}
        <button
          className="md:hidden p-2 text-near-black cursor-pointer"
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label={mobileOpen ? "Close menu" : "Open menu"}
        >
          {mobileOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </nav>

      {/* Mobile overlay */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.25 }}
            className="fixed inset-0 z-[19] pt-24 px-8 bg-sand/95 backdrop-blur-xl"
          >
            <div className="flex flex-col gap-6">
              {navLinks.map((link) => (
                <button
                  key={link.href}
                  onClick={() => scrollTo(link.href)}
                  className="font-serif text-2xl font-bold text-near-black hover:text-coral transition-colors cursor-pointer text-left"
                  style={{ transitionDuration: "200ms" }}
                >
                  {link.label}
                </button>
              ))}
              <button
                onClick={() => scrollTo("#download")}
                className={cn(
                  "mt-4 px-8 py-4 rounded-badge font-sans text-base font-bold text-white cursor-pointer",
                  "bg-coral breathing-glow w-full"
                )}
              >
                Download
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
