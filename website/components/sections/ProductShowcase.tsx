"use client";

import { useState, useCallback, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  ChevronLeft,
  ChevronRight,
  Compass,
  BookOpen,
  Home,
  MessageCircle,
  Timer,
} from "lucide-react";
import { useInView } from "@/hooks/useInView";
import { showcaseSlides } from "@/lib/data";
import { StaggeredText } from "@/components/ui/StaggeredText";
import { IPhoneMockup3D } from "@/components/ui/IPhoneMockup3D";

/* ─── Constants ──────────────────────────────────────────── */

const SLIDE_ICONS = [Compass, BookOpen, Home, MessageCircle, Timer];
const AUTO_ADVANCE_MS = 5000;

const slideTransition = { duration: 0.5, ease: [0.33, 1, 0.68, 1] as const };

/* ─── Shared inline glass card style (matches app's rgba values) ── */

const gc = {
  background: "rgba(255,255,255,0.08)",
  border: "0.5px solid rgba(255,255,255,0.12)",
  borderRadius: 10,
} as const;

/* ─── Floating glass dock (shared by all screens) ──────────── */

function GlassDock({ active }: { active: 0 | 1 | 2 }) {
  return (
    <div className="mt-auto px-[10%] pb-[4%]">
      <div
        className="flex justify-around items-center py-[3%] rounded-[14px]"
        style={{ ...gc }}
      >
        {[0, 1, 2].map((i) => (
          <div
            key={i}
            className={`w-3 h-[2px] rounded-full ${i === active ? "bg-[#FF6B6B]" : "bg-[#3D3835]"}`}
          />
        ))}
      </div>
    </div>
  );
}

/* ─── Mini app screens matching actual Flutter UI ─────────── */

function DiscoverScreen() {
  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] overflow-hidden">
      {/* Status bar */}
      <div className="pt-[14%] px-[6%] flex items-center justify-between">
        <span className="text-[8px] text-[#6B6360]">9:41</span>
        <div className="flex gap-0.5"><div className="w-2 h-1 rounded-sm bg-[#3D3835]" /><div className="w-1 h-1 rounded-full bg-[#3D3835]" /></div>
      </div>

      {/* Search bar — glass card */}
      <div className="mx-[5%] mt-[2%] px-[4%] py-[3%] rounded-[10px] flex items-center gap-[3%]" style={{ ...gc }}>
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#6B6360" strokeWidth="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>
        <span className="text-[7px] text-[#6B6360]">cheap creative hobby...</span>
      </div>

      {/* Hero card — 55% height, gradient + overlay */}
      <div className="mx-[5%] mt-[2%] flex-1 rounded-[12px] bg-gradient-to-br from-[#0D9488]/25 to-[#1A1A20] relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent" />
        <div className="absolute bottom-[8%] left-[8%] right-[8%]">
          <p className="text-[6px] text-[#6B6360] uppercase tracking-wider">Creative</p>
          <p className="text-[12px] font-bold text-[#F5F0EB] mt-0.5 font-serif">
            <span className="text-[#FF6B6B]">Pot</span>tery
          </p>
          <p className="text-[7px] text-[#B0A89E] mt-0.5 leading-tight">
            Shape something real with your hands
          </p>
          <p className="text-[6px] text-[#6B6360] mt-1 font-mono">
            CHF 45 · 2h/week · Easy
          </p>
        </div>
      </div>

      {/* More For You — 2 small cards */}
      <p className="text-[7px] font-semibold text-[#B0A89E] mx-[5%] mt-[3%] mb-[1%]">More For You</p>
      <div className="flex gap-[2%] mx-[5%]">
        {[
          { cat: "Active", name: "Bouldering", spec: "CHF 60 · 3h" },
          { cat: "Food", name: "Sourdough", spec: "CHF 15 · 2h" },
        ].map((h) => (
          <div key={h.name} className="flex-1 rounded-[8px] p-[4%]" style={{ ...gc }}>
            <p className="text-[5px] text-[#6B6360] uppercase">{h.cat}</p>
            <p className="text-[8px] font-semibold text-[#F5F0EB] mt-0.5 font-serif">{h.name}</p>
            <p className="text-[5px] text-[#6B6360] mt-0.5 font-mono">{h.spec}</p>
          </div>
        ))}
      </div>

      <GlassDock active={1} />
    </div>
  );
}

function DetailScreen() {
  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] overflow-hidden">
      {/* Hero image area */}
      <div className="h-[35%] bg-gradient-to-br from-[#0D9488]/20 to-[#1A1A20] relative">
        <div className="absolute inset-0 bg-gradient-to-t from-[#0A0A0F] via-transparent to-transparent" />
        {/* Back button */}
        <div className="absolute top-[16%] left-[5%] w-5 h-5 rounded-full bg-black/40 flex items-center justify-center">
          <span className="text-[8px] text-white">&#x2190;</span>
        </div>
        <div className="absolute bottom-[8%] left-[6%] right-[6%]">
          <p className="text-[6px] text-[#6B6360] uppercase tracking-wider">Creative</p>
          <p className="text-[13px] font-bold text-[#F5F0EB] font-serif">
            <span className="text-[#FF6B6B]">Pot</span>tery
          </p>
          <p className="text-[7px] text-[#B0A89E] mt-0.5">Shape something real with your hands</p>
          {/* Spec badge — plain mono text, no pills */}
          <p className="text-[6px] text-[#6B6360] mt-1 font-mono">CHF 45 · 2h/week · Easy</p>
        </div>
      </div>

      {/* Glass cards below hero */}
      <div className="flex-1 flex flex-col gap-[2%] px-[5%] mt-[2%] overflow-hidden">
        {/* Why this fits you */}
        <div className="rounded-[10px] p-[4%]" style={{ ...gc }}>
          <p className="text-[7px] font-bold text-[#F5F0EB] mb-1">Why this fits you</p>
          {["Fits your budget", "Works in 2h/week", "Solo sessions at home"].map((r) => (
            <div key={r} className="flex items-center gap-1 py-[1px]">
              <span className="text-[6px] text-[#06D6A0]">&#x2713;</span>
              <span className="text-[6px] text-[#B0A89E]">{r}</span>
            </div>
          ))}
        </div>

        {/* 4-week roadmap */}
        <div className="rounded-[10px] p-[4%] flex-1" style={{ ...gc }}>
          <p className="text-[7px] font-bold text-[#F5F0EB] mb-1.5">What to expect</p>
          {[
            { wk: "Week 1", label: "Try it", done: true },
            { wk: "Week 2", label: "Repeat it", current: true },
            { wk: "Week 3", label: "Reduce friction" },
            { wk: "Week 4", label: "Decide" },
          ].map((s, i) => (
            <div key={s.wk} className="flex items-center gap-1.5 py-[2px]">
              <div
                className={`w-3 h-3 rounded-full flex items-center justify-center text-[5px] font-bold ${
                  s.done
                    ? "bg-[#FF6B6B] text-white"
                    : s.current
                      ? "border border-[#FF6B6B] text-[#FF6B6B]"
                      : "border border-[#3D3835] text-[#3D3835]"
                }`}
              >
                {s.done ? "✓" : i + 1}
              </div>
              <div>
                <span className={`text-[6px] font-semibold ${s.current ? "text-[#F5F0EB]" : s.done ? "text-[#6B6360]" : "text-[#B0A89E]"}`}>{s.wk}</span>
                <span className="text-[6px] text-[#6B6360]"> — {s.label}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Start hobby CTA */}
      <div className="mx-[5%] mb-[4%] mt-[2%] py-[3%] rounded-full bg-[#FF6B6B] text-center">
        <p className="text-[8px] font-bold text-white">Start hobby</p>
      </div>
    </div>
  );
}

function HomeScreen() {
  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] overflow-hidden">
      <div className="pt-[14%] px-[6%] flex items-center justify-between">
        <span className="text-[8px] text-[#6B6360]">9:41</span>
        <div className="flex gap-0.5"><div className="w-2 h-1 rounded-sm bg-[#3D3835]" /><div className="w-1 h-1 rounded-full bg-[#3D3835]" /></div>
      </div>

      <div className="px-[6%] mt-[2%]">
        <p className="text-[7px] text-[#6B6360]">Good evening, Mara</p>
        <p className="text-[12px] font-bold text-[#F5F0EB] mt-0.5 font-serif">Your next step</p>
      </div>

      {/* Next step card */}
      <div className="mx-[5%] mt-[3%] rounded-[10px] p-[4%] flex-1 flex flex-col" style={{ ...gc }}>
        <div className="flex items-start justify-between">
          <div>
            <p className="text-[6px] text-[#6B6360] uppercase tracking-wider">Week 2 of Pottery</p>
            <p className="text-[10px] font-bold text-[#F5F0EB] mt-0.5 font-serif">Center your first bowl</p>
          </div>
          <div className="w-5 h-5 rounded-md bg-[#0D9488]/20 flex items-center justify-center flex-shrink-0">
            <span className="text-[8px]">&#x1F3FA;</span>
          </div>
        </div>
        <div className="mt-[5%] h-[2px] rounded-full bg-[#1A1A20] overflow-hidden">
          <div className="h-full w-[42%] rounded-full bg-gradient-to-r from-[#FF6B6B] to-[#FF8585]" />
        </div>
        <p className="text-[6px] text-[#6B6360] mt-0.5">Step 5 of 12</p>
        <div className="mt-[4%] py-[4%] rounded-full bg-[#FF6B6B] text-center">
          <p className="text-[8px] font-bold text-white">Start session</p>
        </div>
        <div className="flex-1" />
        {/* Weekly calendar */}
        <div className="mt-[3%]">
          <p className="text-[5px] text-[#6B6360] uppercase tracking-wider font-semibold mb-1">This week</p>
          <div className="flex gap-[2px]">
            {["M","T","W","T","F","S","S"].map((d, i) => (
              <div key={d+i} className={`flex-1 text-center py-[2px] rounded text-[5px] font-medium ${
                i < 3 ? "bg-[#FF6B6B]/20 text-[#FF6B6B]" : i === 3 ? "bg-[#1A1A20] text-[#F5F0EB] ring-[0.5px] ring-[#FF6B6B]" : "bg-[#1A1A20] text-[#3D3835]"
              }`}>{d}</div>
            ))}
          </div>
        </div>
      </div>

      {/* Coach chip */}
      <div className="mx-[5%] mt-[2%] rounded-[10px] p-[3%] flex items-center gap-[3%]" style={{ ...gc }}>
        <div className="w-4 h-4 rounded-full bg-[#FF6B6B]/15 flex items-center justify-center flex-shrink-0">
          <span className="text-[6px] text-[#FF6B6B]">&#x2726;</span>
        </div>
        <p className="text-[6px] text-[#B0A89E] leading-tight flex-1">Plan your first session</p>
        <span className="text-[7px] text-[#6B6360]">&#x203A;</span>
      </div>

      <GlassDock active={0} />
    </div>
  );
}

function CoachScreen() {
  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] overflow-hidden">
      <div className="pt-[14%] px-[6%] flex items-center gap-[3%]">
        <span className="text-[8px] text-[#6B6360]">&#x2190;</span>
        <p className="text-[10px] font-bold text-[#F5F0EB] flex-1">Pottery Coach</p>
        <div className="px-1.5 py-0.5 rounded-full bg-[#FF6B6B]/15">
          <span className="text-[5px] text-[#FF6B6B] font-bold">AI</span>
        </div>
      </div>

      {/* Chat area */}
      <div className="flex-1 flex flex-col gap-[2%] px-[5%] mt-[3%] overflow-hidden">
        {/* AI message — glass card */}
        <div className="self-start max-w-[82%] rounded-[10px] p-[3%]" style={{ ...gc }}>
          <p className="text-[7px] text-[#B0A89E] leading-relaxed">
            I noticed you haven&apos;t logged a session in 3 days. Want to try a simpler hand-building exercise instead?
          </p>
        </div>
        {/* User message — coral tint */}
        <div className="self-end max-w-[75%] rounded-[10px] p-[3%]" style={{ background: "rgba(255,107,107,0.12)", border: "0.5px solid rgba(255,107,107,0.2)", borderRadius: 10 }}>
          <p className="text-[7px] text-[#F5F0EB] leading-relaxed">
            Yes please, I keep failing at centering
          </p>
        </div>
        {/* AI response */}
        <div className="self-start max-w-[82%] rounded-[10px] p-[3%]" style={{ ...gc }}>
          <p className="text-[7px] text-[#B0A89E] leading-relaxed">
            I&apos;ve swapped your next step to &ldquo;Pinch pot with texture&rdquo; — just your hands and clay, no wheel needed.
          </p>
        </div>
      </div>

      {/* Starter chips */}
      <div className="flex gap-1 px-[5%] mt-[2%] mb-[1%] overflow-hidden">
        {["How do I start?", "I'm stuck", "Motivate me"].map((c) => (
          <div key={c} className="px-1.5 py-[3px] rounded-full flex-shrink-0" style={{ ...gc }}>
            <p className="text-[5px] text-[#B0A89E]">{c}</p>
          </div>
        ))}
      </div>

      {/* Input bar */}
      <div className="mx-[5%] mb-[4%] rounded-[10px] px-[4%] py-[3%] flex items-center" style={{ ...gc }}>
        <p className="text-[6px] text-[#3D3835] flex-1">Ask about your hobby...</p>
        <div className="w-4 h-4 rounded-full bg-[#FF6B6B] flex items-center justify-center">
          <span className="text-[6px] text-white font-bold">&#x2191;</span>
        </div>
      </div>
    </div>
  );
}

function SessionScreen() {
  return (
    <div className="w-full h-full flex flex-col items-center justify-center bg-[#0A0A0F] relative overflow-hidden">
      {/* Subtle ambient glow */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,_rgba(255,107,107,0.04)_0%,_transparent_70%)]" />

      {/* Overline */}
      <p className="text-[6px] text-[#6B6360] uppercase tracking-[0.2em] mb-1 relative z-10">
        Pottery · Centering practice
      </p>

      {/* Timer — large monospace digits */}
      <div className="relative w-[55%] aspect-square flex items-center justify-center">
        <svg className="absolute inset-0 w-full h-full -rotate-90" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="44" fill="none" stroke="#1E1E24" strokeWidth="1" />
          <circle
            cx="50" cy="50" r="44" fill="none"
            stroke="url(#timer-g)" strokeWidth="2"
            strokeDasharray="276.5" strokeDashoffset="83"
            strokeLinecap="round"
          />
          <defs>
            <linearGradient id="timer-g" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor="#FF6B6B" />
              <stop offset="100%" stopColor="#FF8E8E" />
            </linearGradient>
          </defs>
        </svg>
        <div className="text-center relative z-10">
          <p className="text-[22px] font-light text-[#F5E6D8] tracking-tight font-mono">
            10:24
          </p>
          <p className="text-[6px] text-[#6B6360] mt-0.5">remaining</p>
        </div>
      </div>

      {/* Step info */}
      <p className="text-[9px] font-semibold text-[#F5F0EB] mt-[5%] relative z-10">
        Center your first bowl
      </p>
      <p className="text-[7px] text-[#6B6360] mt-0.5 relative z-10">
        Keep your hands steady and wet
      </p>

      {/* Pause button */}
      <div className="mt-[6%] w-7 h-7 rounded-full flex items-center justify-center relative z-10" style={{ ...gc }}>
        <div className="flex gap-[1.5px]">
          <div className="w-[2px] h-2.5 rounded-sm bg-[#B0A89E]" />
          <div className="w-[2px] h-2.5 rounded-sm bg-[#B0A89E]" />
        </div>
      </div>
    </div>
  );
}

const SCREEN_COMPONENTS: Record<string, React.FC> = {
  discover: DiscoverScreen,
  detail: DetailScreen,
  home: HomeScreen,
  coach: CoachScreen,
  session: SessionScreen,
};

/* ─── Phone content wrapper with AnimatePresence ─────────── */

function PhoneSlideContent({ slideId }: { slideId: string }) {
  const Screen = SCREEN_COMPONENTS[slideId] ?? DiscoverScreen;
  return <Screen />;
}

/* ─── Main ProductShowcase component ─────────────────────── */

export function ProductShowcase() {
  const [activeIndex, setActiveIndex] = useState(0);
  const [isHovering, setIsHovering] = useState(false);
  const { ref, inView } = useInView({ threshold: 0.1 });
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const slide = showcaseSlides[activeIndex];

  const next = useCallback(() => {
    setActiveIndex((i) => (i + 1) % showcaseSlides.length);
  }, []);

  const prev = useCallback(() => {
    setActiveIndex(
      (i) => (i - 1 + showcaseSlides.length) % showcaseSlides.length
    );
  }, []);

  /* Auto-advance timer: pauses on hover */
  useEffect(() => {
    if (isHovering || !inView) {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
      return;
    }
    intervalRef.current = setInterval(next, AUTO_ADVANCE_MS);
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [isHovering, inView, next]);

  return (
    <section
      id="product"
      ref={ref}
      className="relative py-32 md:py-40 overflow-hidden"
      onMouseEnter={() => setIsHovering(true)}
      onMouseLeave={() => setIsHovering(false)}
    >
      {/* ── Atmospheric bloom background ── */}
      <AnimatePresence mode="wait">
        <motion.div
          key={`bg-${slide.id}`}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.8 }}
          className="absolute inset-0 pointer-events-none"
        >
          <div
            className={`absolute inset-0 bg-gradient-to-br ${slide.gradient}`}
          />
          <div className="absolute top-1/3 left-1/4 w-96 h-96 bg-coral/[0.03] rounded-full blur-[120px]" />
          <div className="absolute bottom-1/4 right-1/3 w-80 h-80 bg-teal-500/[0.03] rounded-full blur-[100px]" />
        </motion.div>
      </AnimatePresence>

      <div className="relative max-w-6xl mx-auto px-6">
        {/* ── Section header ── */}
        <div className="max-w-2xl mb-20">
          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-xs font-semibold text-text-muted uppercase tracking-[0.2em] mb-4"
          >
            The experience
          </motion.p>

          <StaggeredText
            text="See it in action."
            as="h2"
            className="text-3xl md:text-4xl lg:text-5xl font-bold leading-tight tracking-tight"
            highlightWords={["action."]}
            stagger={0.07}
          />
        </div>

        {/* ── Carousel: phone left, metadata right ── */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-center">
          {/* Left: IPhoneMockup3D */}
          <div className="flex justify-center lg:justify-end">
            <div className="relative">
              <IPhoneMockup3D width={280}>
                <AnimatePresence mode="wait">
                  <motion.div
                    key={slide.id}
                    initial={{ opacity: 0, scale: 0.97 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.97 }}
                    transition={{ duration: 0.4, ease: [0.33, 1, 0.68, 1] }}
                    className="w-full h-full"
                  >
                    <PhoneSlideContent slideId={slide.id} />
                  </motion.div>
                </AnimatePresence>
              </IPhoneMockup3D>
            </div>
          </div>

          {/* Right: Slide metadata */}
          <div className="flex flex-col">
            <AnimatePresence mode="wait">
              <motion.div
                key={`meta-${slide.id}`}
                initial={{ opacity: 0, y: 24 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -16 }}
                transition={slideTransition}
                className="min-h-[280px]"
              >
                {/* Label pill */}
                <span className="inline-block px-3.5 py-1 rounded-full bg-coral/10 text-coral text-xs font-semibold mb-5 tracking-wide">
                  {slide.label}
                </span>

                {/* Title */}
                <h3 className="text-2xl md:text-3xl font-bold text-text-primary mb-4 leading-snug">
                  {slide.title}
                </h3>

                {/* Description */}
                <p className="text-text-secondary leading-relaxed mb-8 max-w-md">
                  {slide.description}
                </p>

                {/* Feature chips */}
                <div className="flex flex-wrap gap-2">
                  {slide.features.map((f, i) => (
                    <motion.span
                      key={f}
                      initial={{ opacity: 0, y: 8 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{
                        duration: 0.35,
                        delay: 0.15 + i * 0.06,
                        ease: [0.33, 1, 0.68, 1],
                      }}
                      className="px-3 py-1.5 rounded-full bg-glass border border-glass-border text-xs text-text-secondary"
                    >
                      {f}
                    </motion.span>
                  ))}
                </div>
              </motion.div>
            </AnimatePresence>

            {/* ── Navigation controls ── */}
            <div className="flex items-center gap-4 mt-10">
              {/* Prev button */}
              <button
                onClick={prev}
                className="w-10 h-10 rounded-full bg-glass border border-glass-border flex items-center justify-center text-text-secondary hover:text-text-primary hover:border-text-muted transition-all duration-200 cursor-pointer"
                aria-label="Previous slide"
              >
                <ChevronLeft size={18} />
              </button>

              {/* Icon dots */}
              <div className="flex gap-2">
                {showcaseSlides.map((s, i) => {
                  const Icon = SLIDE_ICONS[i];
                  const isActive = i === activeIndex;
                  return (
                    <button
                      key={s.id}
                      onClick={() => setActiveIndex(i)}
                      className="relative cursor-pointer"
                      aria-label={`Go to ${s.label}`}
                    >
                      <motion.div
                        animate={{
                          scale: isActive ? 1.15 : 1,
                          backgroundColor: isActive
                            ? "rgba(255, 107, 107, 1)"
                            : "rgba(255, 255, 255, 0.08)",
                        }}
                        transition={{ duration: 0.3, ease: [0.33, 1, 0.68, 1] }}
                        className="w-9 h-9 rounded-full flex items-center justify-center"
                      >
                        <Icon
                          size={14}
                          className={
                            isActive
                              ? "text-white"
                              : "text-text-muted hover:text-text-secondary transition-colors"
                          }
                        />
                      </motion.div>
                      {/* Active indicator ring */}
                      {isActive && (
                        <motion.div
                          layoutId="slide-indicator"
                          className="absolute -inset-0.5 rounded-full border border-coral/30"
                          transition={{
                            type: "spring",
                            stiffness: 350,
                            damping: 30,
                          }}
                        />
                      )}
                    </button>
                  );
                })}
              </div>

              {/* Next button */}
              <button
                onClick={next}
                className="w-10 h-10 rounded-full bg-glass border border-glass-border flex items-center justify-center text-text-secondary hover:text-text-primary hover:border-text-muted transition-all duration-200 cursor-pointer"
                aria-label="Next slide"
              >
                <ChevronRight size={18} />
              </button>
            </div>

            {/* Auto-advance progress bar */}
            <div className="mt-4 ml-14 mr-14">
              <div className="h-px bg-glass-border rounded-full overflow-hidden">
                <motion.div
                  key={`progress-${activeIndex}-${isHovering}`}
                  initial={{ scaleX: 0 }}
                  animate={{ scaleX: isHovering ? 0 : 1 }}
                  transition={{
                    duration: isHovering ? 0 : AUTO_ADVANCE_MS / 1000,
                    ease: "linear",
                  }}
                  className="h-full bg-coral/40 origin-left"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
