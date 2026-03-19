"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { LetterSwap } from "@/components/ui/LetterSwap";
import { useSmoothScroll } from "@/components/layout/SmoothScroll";

const navLinks = [
  { label: "The Problem", href: "#solution" },
  { label: "How It Works", href: "#how-it-works" },
  { label: "Experience", href: "#experience" },
  { label: "What You Get", href: "#what-you-get" },
  { label: "Testimonials", href: "#testimonials" },
];

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [scrollProgress, setScrollProgress] = useState(0);
  const [mobileOpen, setMobileOpen] = useState(false);
  const { scrollTo: lenisScrollTo } = useSmoothScroll();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 60);
      const docHeight =
        document.documentElement.scrollHeight - window.innerHeight;
      setScrollProgress(docHeight > 0 ? window.scrollY / docHeight : 0);
    };
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const scrollTo = useCallback(
    (href: string) => {
      setMobileOpen(false);
      lenisScrollTo(href);
    },
    [lenisScrollTo]
  );

  const scrollToTop = useCallback(() => {
    lenisScrollTo(0);
  }, [lenisScrollTo]);

  return (
    <>
      {/* Scroll progress */}
      <div
        className="scroll-progress"
        style={{ transform: `scaleX(${scrollProgress})` }}
      />

      <nav
        className={cn(
          "fixed top-4 left-4 right-4 z-40 flex items-center justify-between px-6 py-3 rounded-2xl transition-all duration-300",
          scrolled
            ? "bg-surface/90 backdrop-blur-xl border border-glass-border shadow-[0_4px_30px_rgba(0,0,0,0.3)]"
            : "bg-transparent"
        )}
      >
        {/* Logo */}
        <button
          onClick={scrollToTop}
          className="flex items-center gap-0.5 cursor-pointer"
        >
          <span className="text-xl font-bold text-text-primary tracking-tight">
            Try
          </span>
          <span className="text-xl font-bold text-coral tracking-tight">
            Something
          </span>
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-coral ml-0.5 mb-3" />
        </button>

        {/* Desktop nav */}
        <div className="hidden md:flex items-center gap-10">
          {navLinks.map((link) => (
            <button
              key={link.href}
              onClick={() => scrollTo(link.href)}
              className="text-sm font-medium text-text-secondary hover:text-text-primary transition-colors duration-200 cursor-pointer"
            >
              <LetterSwap text={link.label} stagger={0.02} />
            </button>
          ))}
        </div>

        {/* Desktop CTA */}
        <button
          onClick={() => scrollTo("#waitlist")}
          className={cn(
            "hidden md:block px-5 py-2.5 rounded-full text-sm font-semibold cursor-pointer",
            "bg-coral text-white hover:bg-coral-hover transition-colors duration-200",
            "active:scale-[0.97] transition-transform"
          )}
        >
          Get Early Access
        </button>

        {/* Mobile hamburger */}
        <button
          className="md:hidden p-2 text-text-primary cursor-pointer"
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
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
            className="fixed inset-0 z-[39] pt-24 px-8 bg-bg/95 backdrop-blur-2xl"
          >
            <div className="flex flex-col gap-8">
              {navLinks.map((link, i) => (
                <motion.button
                  key={link.href}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.1 }}
                  onClick={() => scrollTo(link.href)}
                  className="text-3xl font-bold text-text-primary text-left cursor-pointer"
                >
                  {link.label}
                </motion.button>
              ))}
              <motion.button
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                onClick={() => scrollTo("#waitlist")}
                className="mt-6 px-8 py-4 rounded-full text-lg font-bold text-white bg-coral w-full cursor-pointer breathing-glow"
              >
                Get Early Access
              </motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
