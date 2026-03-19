"use client";

/**
 * 4 simplified mock app screens for the Experience section.
 *
 * Design rules:
 * - Background: #0A0A0F (app dark theme)
 * - Text: #F5F0EB (warm cream) + #6B6360 (muted)
 * - Accent: coral #FF6B6B
 * - Glass surfaces: rgba(255,255,255,0.08) bg, 0.12 border
 * - Keep simple — suggestive, not pixel-perfect
 */

const CORAL = "#FF6B6B";
const CREAM = "#F5F0EB";
const MUTED = "#6B6360";
const GLASS_BG = "rgba(255,255,255,0.08)";
const GLASS_BORDER = "rgba(255,255,255,0.12)";

const gc = {
  background: GLASS_BG,
  border: `0.5px solid ${GLASS_BORDER}`,
  borderRadius: 12,
};

/* ─── Screen 1: The Quiz ──────────────────────────────────── */

export function QuizScreen() {
  const pills = [
    { label: "Creating things", selected: true },
    { label: "Being outdoors", selected: false },
    { label: "Learning skills", selected: true },
    { label: "Moving my body", selected: false },
    { label: "Relaxing alone", selected: false },
    { label: "Meeting people", selected: false },
  ];

  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] px-[7%] pt-[18%] pb-[6%]">
      {/* Progress bar */}
      <div className="h-[3px] rounded-full bg-[#1A1A20] mb-6 overflow-hidden">
        <div
          className="h-full rounded-full"
          style={{ width: "35%", background: CORAL }}
        />
      </div>

      {/* Question */}
      <p
        className="text-[11px] font-semibold mb-1"
        style={{ color: MUTED }}
      >
        Question 2 of 5
      </p>
      <h3
        className="text-[16px] font-bold leading-snug mb-6"
        style={{ color: CREAM }}
      >
        What excites you?
      </h3>
      <p className="text-[9px] mb-5" style={{ color: MUTED }}>
        Pick as many as you like.
      </p>

      {/* Pill options */}
      <div className="flex flex-wrap gap-2">
        {pills.map((p) => (
          <div
            key={p.label}
            className="px-3 py-[7px] rounded-full text-[9px] font-medium transition-colors"
            style={{
              background: p.selected ? `${CORAL}18` : GLASS_BG,
              border: p.selected
                ? `1px solid ${CORAL}40`
                : `0.5px solid ${GLASS_BORDER}`,
              color: p.selected ? CORAL : CREAM,
            }}
          >
            {p.selected && (
              <span className="mr-1 text-[8px]">&#x2713;</span>
            )}
            {p.label}
          </div>
        ))}
      </div>

      <div className="flex-1" />

      {/* Continue CTA */}
      <div
        className="py-[10px] rounded-full text-center text-[10px] font-bold"
        style={{ background: CORAL, color: "#fff" }}
      >
        Continue
      </div>
    </div>
  );
}

/* ─── Screen 2: Your Matches ──────────────────────────────── */

export function MatchesScreen() {
  const matches = [
    { name: "Pottery", match: 92, emoji: "🏺", top: true },
    { name: "Urban Sketching", match: 87, emoji: "✏️", top: false },
    { name: "Bouldering", match: 84, emoji: "🧗", top: false },
  ];

  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] px-[7%] pt-[18%] pb-[6%]">
      <p className="text-[9px] font-semibold mb-1" style={{ color: MUTED }}>
        Your matches
      </p>
      <h3
        className="text-[15px] font-bold leading-snug mb-1"
        style={{ color: CREAM }}
      >
        We found your hobbies.
      </h3>
      <p className="text-[8px] mb-5" style={{ color: MUTED }}>
        Ranked by how well they fit your life.
      </p>

      <div className="flex flex-col gap-[10px]">
        {matches.map((m) => (
          <div
            key={m.name}
            className="rounded-[12px] px-4 py-3 flex items-center gap-3 relative overflow-hidden"
            style={{
              ...gc,
              border: m.top ? `1px solid ${CORAL}30` : gc.border,
            }}
          >
            {/* Top match warm glow */}
            {m.top && (
              <div
                className="absolute inset-0 pointer-events-none"
                style={{
                  background: `radial-gradient(ellipse at 30% 50%, ${CORAL}08, transparent 70%)`,
                }}
              />
            )}

            {/* Emoji */}
            <span className="text-[18px] relative z-10">{m.emoji}</span>

            {/* Info */}
            <div className="flex-1 relative z-10">
              <p
                className="text-[11px] font-bold"
                style={{ color: CREAM }}
              >
                {m.name}
              </p>
              <p className="text-[8px] mt-0.5" style={{ color: MUTED }}>
                {m.match}% match
              </p>
            </div>

            {/* Match bar */}
            <div className="relative z-10 w-10 h-[4px] rounded-full bg-[#1A1A20] overflow-hidden">
              <div
                className="h-full rounded-full"
                style={{
                  width: `${m.match}%`,
                  background: m.top ? CORAL : `${CORAL}60`,
                }}
              />
            </div>
          </div>
        ))}
      </div>

      <div className="flex-1" />

      {/* CTA */}
      <div
        className="py-[10px] rounded-full text-center text-[10px] font-bold"
        style={{ background: CORAL, color: "#fff" }}
      >
        Start with Pottery
      </div>
    </div>
  );
}

/* ─── Screen 3: Your Roadmap ──────────────────────────────── */

export function RoadmapScreen() {
  const steps = [
    { label: "Find a local studio", done: true },
    { label: "Book intro class (CHF 25)", done: true },
    { label: "Attend first session", done: false, current: true },
    { label: "Try centering technique", done: false },
  ];

  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] px-[7%] pt-[18%] pb-[6%]">
      <p className="text-[9px] font-semibold mb-1" style={{ color: MUTED }}>
        Pottery — Week 1
      </p>
      <h3
        className="text-[15px] font-bold leading-snug mb-2"
        style={{ color: CREAM }}
      >
        Your roadmap
      </h3>

      {/* Progress bar */}
      <div className="h-[4px] rounded-full bg-[#1A1A20] mb-5 overflow-hidden">
        <div
          className="h-full rounded-full transition-all"
          style={{ width: "50%", background: CORAL }}
        />
      </div>

      {/* Steps */}
      <div className="flex flex-col gap-[2px]">
        {steps.map((s, i) => (
          <div
            key={s.label}
            className="flex items-start gap-3 py-[8px]"
          >
            {/* Connector + circle */}
            <div className="flex flex-col items-center flex-shrink-0 w-5">
              <div
                className="w-[18px] h-[18px] rounded-full flex items-center justify-center text-[8px] font-bold"
                style={{
                  background: s.done
                    ? CORAL
                    : s.current
                      ? "transparent"
                      : "#1A1A20",
                  border: s.current
                    ? `1.5px solid ${CORAL}`
                    : s.done
                      ? "none"
                      : "1px solid #3D3835",
                  color: s.done ? "#fff" : s.current ? CORAL : "#3D3835",
                }}
              >
                {s.done ? "✓" : i + 1}
              </div>
              {i < steps.length - 1 && (
                <div
                  className="w-px flex-1 min-h-[12px]"
                  style={{
                    background: s.done
                      ? `${CORAL}40`
                      : "#1E1E24",
                  }}
                />
              )}
            </div>

            {/* Text */}
            <p
              className="text-[10px] leading-snug pt-[2px]"
              style={{
                color: s.done
                  ? MUTED
                  : s.current
                    ? CREAM
                    : "#5A5A6A",
                textDecoration: s.done ? "line-through" : "none",
                fontWeight: s.current ? 600 : 400,
              }}
            >
              {s.label}
            </p>
          </div>
        ))}
      </div>

      <div className="flex-1" />

      {/* Time estimate */}
      <div
        className="rounded-[10px] px-4 py-3 flex items-center gap-2"
        style={{ ...gc }}
      >
        <span className="text-[12px]">⏱</span>
        <p className="text-[9px]" style={{ color: MUTED }}>
          Estimated time: <span style={{ color: CREAM }}>45 min this week</span>
        </p>
      </div>
    </div>
  );
}

/* ─── Screen 4: Your Coach ────────────────────────────────── */

export function CoachScreen() {
  return (
    <div className="w-full h-full flex flex-col bg-[#0A0A0F] px-[7%] pt-[18%] pb-[6%]">
      <div className="flex items-center gap-2 mb-4">
        <div
          className="w-5 h-5 rounded-full flex items-center justify-center text-[8px]"
          style={{ background: `${CORAL}20`, color: CORAL }}
        >
          ✦
        </div>
        <p className="text-[10px] font-bold" style={{ color: CREAM }}>
          Your Coach
        </p>
        <div
          className="ml-auto px-2 py-0.5 rounded-full text-[7px] font-bold"
          style={{ background: `${CORAL}15`, color: CORAL }}
        >
          AI
        </div>
      </div>

      {/* Coach message bubble */}
      <div
        className="rounded-[12px] px-4 py-3 mb-3"
        style={{ ...gc }}
      >
        <p
          className="text-[9px] leading-relaxed"
          style={{ color: "#B0A89E" }}
        >
          Nice work finishing your first session! The centering was tricky but
          you stuck with it. Here&apos;s what to focus on next week...
        </p>
      </div>

      {/* Tip card */}
      <div
        className="rounded-[12px] px-4 py-3 mb-3"
        style={{
          background: `${CORAL}08`,
          border: `0.5px solid ${CORAL}20`,
          borderRadius: 12,
        }}
      >
        <p
          className="text-[8px] font-semibold mb-1"
          style={{ color: CORAL }}
        >
          Tip for next session
        </p>
        <p
          className="text-[9px] leading-relaxed"
          style={{ color: CREAM }}
        >
          Start with the centering technique — it builds muscle memory fastest.
          Keep your hands wet and elbows braced.
        </p>
      </div>

      {/* User reply bubble */}
      <div
        className="self-end max-w-[80%] rounded-[12px] px-4 py-3 mb-3"
        style={{
          background: `${CORAL}12`,
          border: `0.5px solid ${CORAL}20`,
          borderRadius: 12,
        }}
      >
        <p className="text-[9px] leading-relaxed" style={{ color: CREAM }}>
          Thanks! Should I buy my own clay?
        </p>
      </div>

      {/* Coach response */}
      <div
        className="rounded-[12px] px-4 py-3"
        style={{ ...gc }}
      >
        <p
          className="text-[9px] leading-relaxed"
          style={{ color: "#B0A89E" }}
        >
          Not yet! The studio provides everything for week 1. Focus on the
          experience first — gear comes later.
        </p>
      </div>

      <div className="flex-1" />

      {/* Input bar */}
      <div
        className="rounded-[12px] px-4 py-[10px] flex items-center"
        style={{ ...gc }}
      >
        <p className="text-[8px] flex-1" style={{ color: "#3D3835" }}>
          Ask your coach anything...
        </p>
        <div
          className="w-5 h-5 rounded-full flex items-center justify-center text-[8px] font-bold"
          style={{ background: CORAL, color: "#fff" }}
        >
          ↑
        </div>
      </div>
    </div>
  );
}
