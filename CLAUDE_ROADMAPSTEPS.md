# CLAUDE_ROADMAPSTEPS.md — Complete Roadmap Steps Redesign

> Read `CLAUDE.md` before starting. This task completely redesigns the roadmap step
> experience on the Home screen and the session completion flow.
> This is a core feature — the roadmap steps are the primary mechanism for getting
> users to DO their hobby, session by session.

---

## What This Changes

### Current State (what exists now)
- `_NextStepCard`: A flat coral-tinted container with "NEXT STEP" overline, title, description. Tappable → starts session.
- `_CompactStepRow`: A flat list of rows with 22px circle indicators (green check / coral fill / gray outline) + step title. Tappable → starts session or toggles completion.
- `SessionCompletePhase`: Minimal — "STEP COMPLETE" overline, step title + checkmark icon, next step preview. Auto-exits after 3 seconds. No celebration, no personality.

### New State (what we're building)
1. **Vertical Journey Roadmap** — connected path with glowing nodes, expanded active step card with inline AI coach tip, smooth animations
2. **Premium Step Completion Screen** — confetti, step-specific coach reaction message, milestone celebration, manual exit (not auto-timer)
3. **Any-step access** — users can start ANY uncompleted step, not just the sequential "next" one
4. **Two new DB fields** — `coachTip` and `completionMessage` on every `RoadmapStep`

---

## Part 1: Schema & Model Changes

### 1A. Prisma Migration

Add two fields to `RoadmapStep` in `server/prisma/schema.prisma`:

```prisma
model RoadmapStep {
  id               String  @id
  hobbyId          String
  title            String
  description      String
  estimatedMinutes Int
  milestone        String?
  coachTip         String?           // ← NEW: practical tip for this step
  completionMessage String?          // ← NEW: coach reaction after completing this step
  sortOrder        Int     @default(0)

  hobby Hobby @relation(fields: [hobbyId], references: [id], onDelete: Cascade)
}
```

Run:
```bash
cd server
npx prisma migrate dev --name add_step_coach_fields
```

### 1B. Flutter Model

Update `lib/models/hobby.dart`:

```dart
const factory RoadmapStep({
  required String id,
  required String title,
  required String description,
  required int estimatedMinutes,
  String? milestone,
  String? coachTip,              // ← NEW
  String? completionMessage,     // ← NEW
  CompletionMode? completionMode,
}) = _RoadmapStep;
```

Run: `dart run build_runner build --delete-conflicting-outputs`

### 1C. Session State Model

Update `lib/models/session.dart` — add `completionMessage` to `SessionState`:

```dart
const factory SessionState({
  // ... existing fields ...
  String? nextStepTitle,
  String? completionMessage,     // ← NEW: shown on the complete phase
}) = _SessionState;
```

Run: `dart run build_runner build --delete-conflicting-outputs`

### 1D. Pass completionMessage Through Session Start

Everywhere a session is started (in the home screen roadmap section), add `completionMessage` to the route extra:

```dart
context.push(
  '/session/${hobby.id}/${step.id}',
  extra: <String, dynamic>{
    'hobbyTitle': hobby.title,
    'hobbyCategory': hobby.category,
    'stepTitle': step.title,
    'stepDescription': step.description,
    'stepInstructions': '',
    'whatYouNeed': '',
    'completionMode': step.effectiveMode,
    'nextStepTitle': followingTitle,
    'completionMessage': step.completionMessage,  // ← NEW
  },
);
```

Update `session_screen.dart` to read it from extras and pass to provider.

### 1E. Server: Update Hobby Create + Mappers

In `server/api/generate/[action].ts`, update the `roadmapSteps.create` block:

```typescript
roadmapSteps: {
  create: (content.roadmapSteps as Record<string, unknown>[]).map(
    (step, i) => ({
      id: `${hobbyId}-step-${i + 1}`,
      title: step.title as string,
      description: step.description as string,
      estimatedMinutes: step.estimatedMinutes as number,
      milestone: (step.milestone as string) ?? null,
      coachTip: (step.coachTip as string) ?? null,                // ← NEW
      completionMessage: (step.completionMessage as string) ?? null, // ← NEW
      sortOrder: i,
    })
  ),
},
```

Update `server/lib/mappers.ts` to include both new fields in the API response.

---

## Part 2: AI Prompt Changes

### 2A. Update TIER1_PROMPT in `server/lib/ai_generator.ts`

Add `coachTip` and `completionMessage` to the roadmapSteps schema in the system prompt:

```
"roadmapSteps": [
  {
    "title": "<string, imperative verb form, e.g. 'Make your first pinch pot'>",
    "description": "<string, 1-2 sentences, what to do and why>",
    "milestone": "<string or null, achievement name if this step is a milestone, null otherwise>",
    "coachTip": "<string, 1-2 sentences max, the single most useful practical tip for THIS step — a concrete technique, common mistake, or insider trick. Must differ from description. No generic motivation.>",
    "completionMessage": "<string, 1-2 sentences, a warm specific reaction to completing THIS step — acknowledge what the user just did, note what they learned, tease why it matters for next steps. Not generic praise.>"
  }
]
```

Add these rules to the prompt:

```
# COACH TIP RULES
- coachTip must differ from description. Description = WHAT to do. coachTip = HOW to do it better.
- Must be specific to this step, not general hobby advice.
- Sound like an experienced practitioner, not a textbook.
- Maximum 2 sentences. Prefer 1.
- GOOD: "Cut the clay in half to check for air bubbles — if you see tiny holes, keep wedging."
- BAD: "Take your time and enjoy the process."

# COMPLETION MESSAGE RULES
- completionMessage is shown AFTER the user finishes a session for this step.
- Acknowledge what they specifically did in this step — reference the technique/activity.
- 1-2 sentences. Warm but not over-the-top. Like a friend who does this hobby saying "nice."
- For final steps: acknowledge journey completion and prompt reflection.
- GOOD: "Your first pinch pot! The shape doesn't matter — what matters is you felt the clay respond."
- BAD: "Great job! You completed this step!"
```

### 2B. Update Validation

In `validateHobbyOutput()` in `ai_generator.ts`, add checks inside the roadmap steps loop:

```typescript
if (step.coachTip != null) {
  if (typeof step.coachTip !== "string" || step.coachTip.trim().length < 10) {
    errors.push(`roadmapSteps[${i}].coachTip too short`);
  }
}
if (step.completionMessage != null) {
  if (typeof step.completionMessage !== "string" || step.completionMessage.trim().length < 10) {
    errors.push(`roadmapSteps[${i}].completionMessage too short`);
  }
}
```

Also update `content_guard.ts` `validateOutput()` to include both new fields in the blocklist re-scan:

```typescript
...(hobby.roadmapSteps as Record<string, unknown>[]).map(
  (s) => `${s.title} ${s.description} ${s.coachTip ?? ''} ${s.completionMessage ?? ''}`
),
```

---

## Part 3: Backfill Script for 150+ Existing Hobbies

Create `server/scripts/backfill-step-fields.ts`. This generates BOTH `coachTip` and `completionMessage` for every existing roadmap step in one Claude call per hobby.

**Prompt:**

```typescript
const SYSTEM = `You generate a coach tip AND a completion message for each roadmap step of a hobby.

# RULES
1. Return ONLY a raw JSON array. No markdown. No backticks.
2. One entry per step, in the EXACT order provided.
3. Array length MUST equal the number of steps.

Per step:
- "coachTip": 1-2 sentences. Specific technique, common mistake, or insider trick. Must differ from description. No generic motivation.
- "completionMessage": 1-2 sentences. Warm, specific reaction to completing THIS step. Reference what they did. Not "Great job!"

# SCHEMA
[
  { "coachTip": "<string>", "completionMessage": "<string>" }
]`;
```

**Structure:** Same as the `backfill-coach-tips.ts` script from earlier, but writes both fields. Use `pg` directly (matching your `update-kit-images.ts` pattern). Include `--dry-run`, `--hobby=ID`, and `--force` flags.

**Token cost:** ~30-50 tokens per step × 2 fields × ~750 steps = ~45K tokens total ≈ $0.50. One-time cost.

**Run:**
```bash
cd server
npx ts-node scripts/backfill-step-fields.ts --dry-run   # preview
npx ts-node scripts/backfill-step-fields.ts              # write
```

---

## Part 4: Home Screen Roadmap Redesign

### Design: Vertical Journey

Replace `_NextStepCard` + `_CompactStepRow` + the "YOUR STEPS" section with a single `_RoadmapJourney` widget.

**Visual structure:**

```
 ● ── Step 1 title (completed, strikethrough, muted)         12m
 │
 ● ── Step 2 title (completed, strikethrough, muted)         45m
 │
 ┃
 ◉ ── [EXPANDED CARD]                                       
 ┃    UP NEXT
 ┃    Step 3 title (bold, primary)
 ┃    Description text
 ┃    
 ┃    ┌──────────────────────────────────────┐
 ┃    │ ✦  Tap for a coach tip               │
 ┃    └──────────────────────────────────────┘
 ┃    
 ┃    [ ▶ Start session                      ]  ← coral CTA
 │
 ○ ── Step 4 title (muted)                    ✦       60m
 │
 ○ ── Step 5 title (muted)                    ✦       30m
 
```

**JSX for reference**
```
import { useState, useEffect, useCallback } from "react";

const C = {
  bg: "#0A0A0F", surface: "#111116", elevated: "#1A1A20",
  text: "#F5F0EB", textSec: "#B0A89E", textMut: "#6B6360",
  textW: "#3D3835", accent: "#FF6B6B", accentDeep: "#E55555",
  accentM: "rgba(255,107,107,0.2)", success: "#06D6A0",
  successM: "rgba(6,214,160,0.15)", glass: "rgba(255,255,255,0.08)",
  border: "rgba(255,255,255,0.12)",
  coachBg: "rgba(6,139,168,0.08)", coachBorder: "rgba(6,139,168,0.2)",
  coachText: "#5CB8C9", coachGlow: "rgba(6,139,168,0.25)",
};

const INITIAL_STEPS = [
  { id: 1, title: "Make your first pinch pot", desc: "Start with a ball of clay and shape it using just your thumbs and fingers. Don't aim for perfect.", mins: 30, milestone: "First Creation", completed: false, mode: "timer",
    tip: "Start with a ball slightly bigger than your fist — too small and the walls collapse before you can shape them.",
    coachReact: "Your first pinch pot! The shape doesn't matter — what matters is you felt the clay respond to your hands. That tactile connection is what hooks people on pottery." },
  { id: 2, title: "Try a coil-built bowl", desc: "Roll long clay coils and stack them to build walls. Smooth the inside with your thumb.", mins: 45, milestone: null, completed: false, mode: "timer",
    tip: "Score and slip every coil junction — just pressing them together will crack when drying.",
    coachReact: "Coil building is ancient technique — literally thousands of years old. If your coils cracked a bit, that's normal. The scoring and slipping gets intuitive after 2-3 tries." },
  { id: 3, title: "Practice wedging clay", desc: "Learn the kneading technique that removes air bubbles. Essential before any project.", mins: 20, milestone: null, completed: false, mode: "timer",
    tip: "Cut the clay in half after 30 pushes to check for air bubbles. If you see tiny holes, keep going. Aim for a clean cross-section.",
    coachReact: "Wedging feels tedious but it's the foundation of everything else. Most cracked pots trace back to skipped wedging. Your arms will thank you once the rhythm clicks." },
  { id: 4, title: "Build a simple mug", desc: "Combine coil and pinch techniques to make a cylinder with a pulled handle.", mins: 60, milestone: "First Mug", completed: false, mode: "photoProof",
    tip: "Pull the handle from a thick cylinder attached to the mug rather than making it separately — it bonds better and is more forgiving.",
    coachReact: "A mug you made yourself! This is the step where pottery stops being an experiment and starts being a skill. The handle is always the hardest part — everyone's first handle is wonky." },
  { id: 5, title: "Experiment with textures", desc: "Use found objects to press patterns into wet clay surfaces.", mins: 30, milestone: "Texture Explorer", completed: false, mode: "timer",
    tip: "Press gently and remove straight back — dragging sideways distorts the pattern. Old lace doilies create surprisingly professional results.",
    coachReact: "You've completed all 5 steps — that's the full beginner roadmap done! You now have real pottery fundamentals. Time to decide: keep going deeper, or try something new?" },
];

const F = "'Manrope', sans-serif";
const M = "'IBM Plex Mono', monospace";

function Sparkle({ size = 16, color = C.coachText, glow = false }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", justifyContent: "center",
      filter: glow ? `drop-shadow(0 0 6px ${C.coachGlow})` : "none",
      transition: "filter 0.3s ease",
    }}>
      <svg width={size} height={size} viewBox="0 0 20 20" fill="none">
        <path d="M10 2l2 5.5L18 10l-6 2.5L10 18l-2-5.5L2 10l6-2.5L10 2z" fill={color} />
      </svg>
    </div>
  );
}

function PlayIcon({ size = 13, color = "#fff" }) {
  return <svg width={size} height={size} viewBox="0 0 16 16"><polygon points="5,3 13,8 5,13" fill={color} /></svg>;
}
function CheckIcon({ size = 12 }) {
  return <svg width={size} height={size} viewBox="0 0 16 16"><path d="M3 8l3.5 3.5L13 5" stroke="#fff" strokeWidth="2.5" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>;
}

function Confetti({ active }) {
  if (!active) return null;
  const particles = Array.from({ length: 12 }, (_, i) => {
    const angle = (i / 12) * 360;
    const dist = 30 + Math.random() * 40;
    const x = Math.cos(angle * Math.PI / 180) * dist;
    const y = Math.sin(angle * Math.PI / 180) * dist;
    const colors = [C.accent, C.success, C.coachText, C.text, "#FFD700"];
    return { x, y, color: colors[i % colors.length], size: 3 + Math.random() * 3, delay: i * 20 };
  });
  return (
    <div style={{ position: "absolute", inset: 0, pointerEvents: "none", zIndex: 10 }}>
      {particles.map((p, i) => (
        <div key={i} style={{
          position: "absolute", left: "50%", top: "50%",
          width: p.size, height: p.size, borderRadius: "50%", background: p.color,
          animation: `confettiBurst 0.6s ease-out ${p.delay}ms forwards`,
          "--tx": `${p.x}px`, "--ty": `${p.y}px`,
        }} />
      ))}
    </div>
  );
}

function Toast({ message, visible, type = "success" }) {
  const bg = type === "success" ? C.successM : C.coachBg;
  const borderColor = type === "success" ? "rgba(6,214,160,0.3)" : C.coachBorder;
  const iconColor = type === "success" ? C.success : C.coachText;
  return (
    <div style={{
      position: "fixed", top: 20, left: "50%",
      transform: `translateX(-50%) translateY(${visible ? 0 : -60}px)`,
      padding: "10px 20px", borderRadius: 14,
      background: bg, border: `1px solid ${borderColor}`,
      backdropFilter: "blur(16px)",
      display: "flex", alignItems: "center", gap: 8,
      transition: "transform 0.4s cubic-bezier(0.33,1,0.68,1)",
      zIndex: 100, maxWidth: 360, boxShadow: "0 8px 32px rgba(0,0,0,0.4)",
    }}>
      <span style={{ fontSize: 14, color: iconColor }}>{type === "success" ? "✓" : "✦"}</span>
      <span style={{ fontFamily: F, fontSize: 12, fontWeight: 600, color: C.text }}>{message}</span>
    </div>
  );
}

function SessionOverlay({ step, onComplete, onCancel }) {
  const [progress, setProgress] = useState(0);
  const [phase, setPhase] = useState("ready");

  useEffect(() => {
    if (phase !== "running") return;
    const interval = setInterval(() => {
      setProgress(p => {
        if (p >= 100) { clearInterval(interval); setPhase("done"); return 100; }
        return p + 2;
      });
    }, 40);
    return () => clearInterval(interval);
  }, [phase]);

  return (
    <div style={{
      position: "fixed", inset: 0, zIndex: 50,
      background: "rgba(10,10,15,0.95)",
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
      animation: "fadeIn 0.3s ease",
    }}>
      <button onClick={onCancel} style={{
        position: "absolute", top: 20, right: 20,
        width: 36, height: 36, borderRadius: "50%",
        background: C.glass, border: `1px solid ${C.border}`,
        color: C.textMut, fontSize: 18, cursor: "pointer",
        display: "flex", alignItems: "center", justifyContent: "center",
      }}>×</button>

      {phase === "ready" && (
        <div style={{ textAlign: "center", padding: "0 40px", animation: "fadeIn 0.3s ease" }}>
          <div style={{ width: 64, height: 64, borderRadius: "50%", margin: "0 auto 24px", background: C.accentM, border: `2px solid rgba(255,107,107,0.3)`, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <PlayIcon size={24} color={C.accent} />
          </div>
          <h2 style={{ fontFamily: F, fontSize: 22, fontWeight: 800, color: C.text, margin: "0 0 8px" }}>{step.title}</h2>
          <p style={{ fontFamily: F, fontSize: 14, color: C.textSec, margin: "0 0 6px", lineHeight: 1.5 }}>{step.desc}</p>
          <p style={{ fontFamily: M, fontSize: 12, color: C.textMut, margin: "0 0 32px" }}>{step.mins} minutes</p>
          <button onClick={() => setPhase("running")} style={{
            padding: "14px 48px", border: "none", borderRadius: 16,
            background: `linear-gradient(135deg, ${C.accent}, ${C.accentDeep})`,
            color: "#fff", fontSize: 16, fontWeight: 700, cursor: "pointer", fontFamily: F,
            boxShadow: "0 6px 24px rgba(255,107,107,0.35)",
          }}>Begin session</button>
        </div>
      )}

      {phase === "running" && (
        <div style={{ textAlign: "center", animation: "fadeIn 0.3s ease" }}>
          <div style={{ position: "relative", width: 160, height: 160, margin: "0 auto 28px" }}>
            <svg width={160} height={160} style={{ transform: "rotate(-90deg)" }}>
              <circle cx={80} cy={80} r={70} fill="none" stroke={C.textW} strokeWidth={4} />
              <circle cx={80} cy={80} r={70} fill="none" stroke={C.accent} strokeWidth={4}
                strokeDasharray={Math.PI * 140} strokeDashoffset={Math.PI * 140 * (1 - progress / 100)}
                strokeLinecap="round" style={{ transition: "stroke-dashoffset 0.1s linear" }} />
            </svg>
            <span style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: M, fontSize: 36, fontWeight: 300, color: C.text }}>{Math.round(progress)}%</span>
          </div>
          <p style={{ fontFamily: F, fontSize: 14, fontWeight: 600, color: C.textSec }}>{step.title}</p>
          <p style={{ fontFamily: F, fontSize: 12, color: C.textMut, marginTop: 4 }}>Session in progress...</p>
        </div>
      )}

      {phase === "done" && (
        <div style={{ textAlign: "center", padding: "0 40px", animation: "fadeIn 0.3s ease", position: "relative" }}>
          <Confetti active={true} />
          <div style={{ width: 72, height: 72, borderRadius: "50%", margin: "0 auto 20px", background: C.successM, border: `2px solid rgba(6,214,160,0.4)`, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: `0 0 30px rgba(6,214,160,0.2)` }}>
            <CheckIcon size={28} />
          </div>
          <h2 style={{ fontFamily: F, fontSize: 24, fontWeight: 800, color: C.text, margin: "0 0 6px" }}>Step complete!</h2>
          {step.milestone && (
            <div style={{ display: "inline-flex", alignItems: "center", gap: 6, padding: "6px 14px", borderRadius: 100, margin: "8px 0 16px", background: C.accentM, border: "1px solid rgba(255,107,107,0.25)" }}>
              <span style={{ fontSize: 14 }}>🏆</span>
              <span style={{ fontFamily: F, fontSize: 12, fontWeight: 700, color: C.accent }}>{step.milestone}</span>
            </div>
          )}
          <p style={{ fontFamily: F, fontSize: 13, color: C.textSec, margin: "0 0 28px", lineHeight: 1.5 }}>{step.coachReact}</p>
          <button onClick={onComplete} style={{
            padding: "14px 48px", border: "none", borderRadius: 16,
            background: `linear-gradient(135deg, ${C.success}, #05B88A)`,
            color: "#fff", fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: F,
            boxShadow: "0 6px 20px rgba(6,214,160,0.3)",
          }}>Continue</button>
        </div>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════════════

export default function RoadmapInteractive() {
  const [steps, setSteps] = useState(INITIAL_STEPS);
  const [openTip, setOpenTip] = useState(null);
  const [activeSession, setActiveSession] = useState(null);
  const [toast, setToast] = useState({ visible: false, message: "", type: "success" });
  const [vis, setVis] = useState(false);
  const [justCompleted, setJustCompleted] = useState(null);

  useEffect(() => { setTimeout(() => setVis(true), 200); }, []);

  const completedCount = steps.filter(s => s.completed).length;
  const allDone = completedCount === steps.length;
  const currentIdx = steps.findIndex(s => !s.completed);
  const currentStep = currentIdx >= 0 ? steps[currentIdx] : null;

  const showToast = useCallback((message, type = "success") => {
    setToast({ visible: true, message, type });
    setTimeout(() => setToast(t => ({ ...t, visible: false })), 2500);
  }, []);

  const startSession = (step) => { setOpenTip(null); setActiveSession(step); };

  const completeStep = (stepId) => {
    setActiveSession(null);
    setJustCompleted(stepId);
    setTimeout(() => {
      setSteps(prev => prev.map(s => s.id === stepId ? { ...s, completed: true } : s));
      const step = steps.find(s => s.id === stepId);
      showToast(step?.milestone ? `🏆 Milestone: ${step.milestone}` : "Step completed!", "success");
      setTimeout(() => setJustCompleted(null), 600);
    }, 100);
  };

  const resetAll = () => {
    setSteps(INITIAL_STEPS);
    setOpenTip(null);
    setJustCompleted(null);
    showToast("Reset — start fresh", "coach");
  };

  const toggleTip = (stepId) => setOpenTip(openTip === stepId ? null : stepId);

  return (
    <div style={{ width: "100%", maxWidth: 430, margin: "0 auto", minHeight: "100vh", fontFamily: F }}>
      <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@300;500;600;700&display=swap" rel="stylesheet" />
      <style>{`
        * { box-sizing: border-box; margin: 0; padding: 0; }
        ::-webkit-scrollbar { display: none; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes completePop { 0% { transform: scale(1); } 40% { transform: scale(1.15); } 100% { transform: scale(1); } }
        @keyframes confettiBurst { 0% { transform: translate(0,0) scale(1); opacity: 1; } 100% { transform: translate(var(--tx), var(--ty)) scale(0); opacity: 0; } }
        @keyframes nodePulse { 0%, 100% { box-shadow: 0 0 12px rgba(255,107,107,0.3); } 50% { box-shadow: 0 0 22px rgba(255,107,107,0.5); } }
        @keyframes tipFadeIn { from { opacity: 0; transform: translateX(6px); } to { opacity: 1; transform: translateX(0); } }
      `}</style>

      <div style={{ position: "fixed", inset: 0, background: "linear-gradient(to bottom, #10121C 0%, #0B0B12 35%, #09090F 65%, #07070C 100%)", zIndex: 0 }} />
      <div style={{ position: "fixed", inset: 0, background: "linear-gradient(to bottom right, rgba(6,139,168,0.24) 0%, transparent 50%)", zIndex: 0 }} />
      <div style={{ position: "fixed", inset: 0, background: "linear-gradient(to top left, rgba(122,48,80,0.24) 0%, transparent 50%)", zIndex: 0 }} />

      <Toast {...toast} />
      {activeSession && <SessionOverlay step={activeSession} onComplete={() => completeStep(activeSession.id)} onCancel={() => setActiveSession(null)} />}

      <div style={{ position: "relative", zIndex: 1, padding: "0 24px 40px" }}>
        {/* Header */}
        <div style={{ paddingTop: 52, marginBottom: 20 }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <span style={{ fontSize: 10, fontWeight: 600, letterSpacing: 1.4, color: C.textMut }}>
              {allDone ? "ROADMAP COMPLETE" : `WEEK ${Math.ceil((completedCount + 1) / 2)} OF POTTERY`}
            </span>
            <button onClick={resetAll} style={{ padding: "4px 10px", border: "none", borderRadius: 6, background: C.glass, color: C.textMut, fontSize: 10, fontWeight: 600, cursor: "pointer", fontFamily: F }}>Reset</button>
          </div>
          <h1 style={{ fontSize: 28, fontWeight: 800, color: C.text, letterSpacing: -0.5, margin: "6px 0 4px" }}>
            {allDone ? "Journey complete ✦" : "Your journey"}
          </h1>
          <p style={{ fontSize: 12, color: C.textMut, marginBottom: 10 }}>
            {allDone ? "All 5 steps done — you have real pottery fundamentals now" : "Tap the play button to simulate a session"}
          </p>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <div style={{ flex: 1, height: 3, borderRadius: 2, background: C.textW, overflow: "hidden" }}>
              <div style={{ height: "100%", borderRadius: 2, background: allDone ? C.success : `linear-gradient(90deg, ${C.success}, ${C.accent})`, width: `${(completedCount / steps.length) * 100}%`, transition: "width 0.6s cubic-bezier(0.33,1,0.68,1)" }} />
            </div>
            <span style={{ fontFamily: M, fontSize: 11, fontWeight: 600, color: allDone ? C.success : C.textSec }}>{completedCount}/{steps.length}</span>
          </div>
        </div>

        {/* All done */}
        {allDone && (
          <div style={{ padding: 20, borderRadius: 20, marginBottom: 16, background: C.successM, border: "1px solid rgba(6,214,160,0.25)", animation: "fadeIn 0.5s ease" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 10 }}>
              <Sparkle size={18} color={C.success} glow />
              <span style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.2, color: C.success }}>COACH</span>
            </div>
            <p style={{ fontSize: 14, color: C.textSec, lineHeight: 1.6, margin: 0 }}>
              You've completed the full beginner pottery roadmap! You now know pinch pots, coil building, wedging, mug construction, and texturing. What's next?
            </p>
            <div style={{ display: "flex", gap: 8, marginTop: 14 }}>
              <button style={{ flex: 1, padding: "10px 0", border: "none", borderRadius: 12, background: `linear-gradient(135deg, ${C.success}, #05B88A)`, color: "#fff", fontSize: 12, fontWeight: 700, cursor: "pointer", fontFamily: F }}>Keep going</button>
              <button style={{ flex: 1, padding: "10px 0", border: `1px solid ${C.border}`, borderRadius: 12, background: "transparent", color: C.textSec, fontSize: 12, fontWeight: 600, cursor: "pointer", fontFamily: F }}>Try something new</button>
            </div>
          </div>
        )}

        {/* ── STEPS ── */}
        {steps.map((step, i) => {
          const isLast = i === steps.length - 1;
          const delay = `${0.1 + i * 0.08}s`;
          const isTipOpen = openTip === step.id;
          const isCurrent = currentStep?.id === step.id;
          const wasJustCompleted = justCompleted === step.id;

          return (
            <div key={step.id} style={{
              display: "flex",
              opacity: vis ? 1 : 0,
              transform: vis ? "translateX(0)" : "translateX(-12px)",
              transition: `all 0.5s cubic-bezier(0.33,1,0.68,1) ${delay}`,
            }}>
              {/* Line + node */}
              <div style={{ display: "flex", flexDirection: "column", alignItems: "center", width: 38, flexShrink: 0 }}>
                <div style={{
                  width: isCurrent ? 36 : step.completed ? 26 : 22,
                  height: isCurrent ? 36 : step.completed ? 26 : 22,
                  borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center",
                  background: step.completed ? C.success : isCurrent ? C.accent : "transparent",
                  border: !step.completed && !isCurrent ? `1.5px solid ${C.textW}` : "none",
                  boxShadow: isCurrent ? `0 0 20px rgba(255,107,107,0.4)` : step.completed ? `0 0 10px rgba(6,214,160,0.25)` : "none",
                  animation: isCurrent ? "nodePulse 2.5s ease-in-out infinite" : wasJustCompleted ? "completePop 0.4s ease" : "none",
                  marginTop: isCurrent ? 16 : 8, zIndex: 2,
                  transition: "all 0.4s cubic-bezier(0.33,1,0.68,1)",
                }}>
                  {step.completed ? <CheckIcon size={12} /> : isCurrent ? <PlayIcon size={12} /> : (
                    <span style={{ fontSize: 10, fontWeight: 700, color: C.textMut }}>{step.id}</span>
                  )}
                </div>
                {!isLast && (
                  <div style={{
                    flex: 1, width: 2,
                    minHeight: isCurrent ? 110 : 32,
                    transition: "all 0.4s ease",
                    background: step.completed && steps[i + 1]?.completed ? C.success
                      : step.completed ? `linear-gradient(to bottom, ${C.success}, ${C.textW})` : C.textW,
                  }} />
                )}
              </div>

              {/* Content */}
              <div style={{ flex: 1, paddingLeft: 14, paddingBottom: isLast ? 0 : isCurrent ? 14 : 6, paddingTop: isCurrent ? 8 : 2 }}>
                {isCurrent ? (
                  // ═══ EXPANDED CURRENT STEP — single card, tip INSIDE ═══
                  <div style={{
                    padding: "18px 18px 16px", borderRadius: 18,
                    background: "linear-gradient(145deg, rgba(255,107,107,0.08), rgba(255,107,107,0.02))",
                    border: "1px solid rgba(255,107,107,0.2)",
                    position: "relative", overflow: "hidden",
                  }}>
                    <div style={{ position: "absolute", top: -25, right: -25, width: 90, height: 90, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,107,107,0.1), transparent 70%)" }} />

                    <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 6 }}>
                      <span style={{ fontSize: 10, fontWeight: 700, letterSpacing: 1.4, color: C.accent }}>UP NEXT</span>
                      {step.milestone && (
                        <span style={{ fontSize: 9, fontWeight: 600, padding: "2px 7px", background: C.accentM, borderRadius: 100, color: C.accent }}>🏆 {step.milestone}</span>
                      )}
                    </div>

                    <h3 style={{ fontSize: 17, fontWeight: 700, color: C.text, margin: "0 0 5px", lineHeight: 1.3 }}>{step.title}</h3>
                    <p style={{ fontSize: 13, color: C.textSec, margin: "0 0 14px", lineHeight: 1.5 }}>{step.desc}</p>

                    {/* ── Coach tip: unified sparkle + tip block ── */}
                    <div
                      onClick={() => toggleTip(step.id)}
                      style={{
                        display: "flex", alignItems: "flex-start", gap: 10,
                        padding: isTipOpen ? "10px 12px" : "8px 12px",
                        borderRadius: 12,
                        background: isTipOpen ? "rgba(6,139,168,0.08)" : "rgba(6,139,168,0.04)",
                        border: `1px solid ${isTipOpen ? "rgba(6,139,168,0.2)" : "rgba(6,139,168,0.08)"}`,
                        cursor: "pointer",
                        transition: "all 0.3s cubic-bezier(0.33,1,0.68,1)",
                        marginBottom: 0,
                      }}
                    >
                      {/* Sparkle + optional vertical bar */}
                      <div style={{
                        display: "flex", flexDirection: "column", alignItems: "center",
                        gap: 4, flexShrink: 0, paddingTop: 1,
                      }}>
                        <Sparkle size={15} color={isTipOpen ? C.coachText : "rgba(92,184,201,0.55)"} glow={isTipOpen} />
                        {/* Vertical bar grows below the sparkle when tip is open */}
                        <div style={{
                          width: 2.5, borderRadius: 2,
                          background: `linear-gradient(to bottom, ${C.coachText}, rgba(6,139,168,0.1))`,
                          maxHeight: isTipOpen ? 80 : 0,
                          opacity: isTipOpen ? 1 : 0,
                          transition: "max-height 0.35s cubic-bezier(0.33,1,0.68,1), opacity 0.25s ease",
                          flexShrink: 0,
                        }} />
                      </div>

                      {/* Text: hint when closed, tip when open */}
                      <div style={{ flex: 1, minHeight: 20, display: "flex", flexDirection: "column", justifyContent: "center" }}>
                        {/* Hint text — fades out */}
                        <p style={{
                          fontSize: 11, fontWeight: 500, margin: 0, lineHeight: 1.4,
                          color: "rgba(92,184,201,0.5)",
                          maxHeight: isTipOpen ? 0 : 20,
                          opacity: isTipOpen ? 0 : 1,
                          overflow: "hidden",
                          transition: "max-height 0.25s ease, opacity 0.2s ease",
                        }}>
                          Tap for a coach tip
                        </p>
                        {/* Tip text — fades in */}
                        <p style={{
                          fontSize: 12, fontWeight: 400, margin: 0, lineHeight: 1.55,
                          color: C.textSec,
                          maxHeight: isTipOpen ? 120 : 0,
                          opacity: isTipOpen ? 1 : 0,
                          overflow: "hidden",
                          transition: "max-height 0.35s cubic-bezier(0.33,1,0.68,1) 0.05s, opacity 0.3s ease 0.08s",
                        }}>
                          {step.tip}
                        </p>
                      </div>
                    </div>

                    {/* ── CTAs: vertically stacked, left-aligned ── */}
                    <div style={{
                      display: "flex", flexDirection: "column", gap: 8,
                      marginTop: 14,
                      transition: "margin-top 0.35s cubic-bezier(0.33,1,0.68,1)",
                    }}>
                      <button onClick={(e) => { e.stopPropagation(); startSession(step); }} style={{
                        width: "100%", height: 44, border: "none", borderRadius: 13,
                        background: `linear-gradient(135deg, ${C.accent}, ${C.accentDeep})`,
                        color: "#fff", fontSize: 13, fontWeight: 700, cursor: "pointer", fontFamily: F,
                        boxShadow: "0 4px 16px rgba(255,107,107,0.3)",
                        display: "flex", alignItems: "center", justifyContent: "center", gap: 7,
                      }}>
                        <PlayIcon size={12} /> Start session
                      </button>

                      {/* Ask more CTA: smooth height */}
                      <div style={{
                        maxHeight: isTipOpen ? 46 : 0,
                        opacity: isTipOpen ? 1 : 0,
                        overflow: "hidden",
                        transition: "max-height 0.35s cubic-bezier(0.33,1,0.68,1) 0.05s, opacity 0.3s ease 0.1s",
                      }}>
                        <button onClick={(e) => e.stopPropagation()} style={{
                          width: "100%", height: 38, border: "none", borderRadius: 10,
                          background: "rgba(6,139,168,0.1)",
                          color: C.coachText, fontSize: 12, fontWeight: 600, cursor: "pointer", fontFamily: F,
                          display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
                        }}>
                          <Sparkle size={11} color={C.coachText} /> Ask more about this step
                        </button>
                      </div>
                    </div>
                  </div>
                ) : (
                  // ═══ COMPACT ROW ═══
                  <div>
                    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "5px 0" }}>
                      <div style={{ flex: 1, display: "flex", alignItems: "center", gap: 6 }}>
                        <span style={{
                          fontSize: 13, fontWeight: step.completed ? 400 : 500,
                          color: step.completed ? C.textMut : C.textSec,
                          textDecoration: step.completed ? "line-through" : "none",
                          textDecorationColor: C.textW, transition: "all 0.3s ease",
                        }}>{step.title}</span>
                        {step.milestone && !step.completed && (
                          <span style={{ fontSize: 9, padding: "1px 6px", background: "rgba(255,255,255,0.04)", border: `1px solid ${C.textW}`, borderRadius: 100, color: C.textMut }}>🏆</span>
                        )}
                      </div>
                      <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
                        {!step.completed && step.tip && (
                          <div onClick={() => toggleTip(step.id)} style={{ cursor: "pointer", padding: 2 }}>
                            <Sparkle size={13} color={isTipOpen ? C.coachText : "rgba(92,184,201,0.4)"} glow={isTipOpen} />
                          </div>
                        )}
                        <span style={{ fontFamily: M, fontSize: 10, color: C.textW, minWidth: 24, textAlign: "right" }}>{step.mins}m</span>
                      </div>
                    </div>

                    {/* Inline tip for compact rows */}
                    {isTipOpen && step.tip && !step.completed && (
                      <div style={{
                        display: "flex", gap: 8, padding: "8px 0 4px 0",
                        animation: "tipFadeIn 0.25s ease forwards",
                      }}>
                        <div style={{ width: 3, borderRadius: 2, flexShrink: 0, background: `linear-gradient(to bottom, ${C.coachText}, rgba(6,139,168,0.15))` }} />
                        <p style={{ fontSize: 12, color: C.textSec, margin: 0, lineHeight: 1.55 }}>{step.tip}</p>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

### Node States

| State | Size | Color | Content | Glow |
|-------|------|-------|---------|------|
| Completed | 26px | `AppColors.success` (#06D6A0) | Check icon (white) | Subtle green |
| Active | 36px | `AppColors.accent` (#FF6B6B) | Step number (white, bold) | Coral pulse animation |
| Future | 22px | Transparent | Step number (textMuted) | None |
| Border (future) | — | `AppColors.textWhisper` | 1.5px stroke | — |

**IMPORTANT:** Active step shows the step NUMBER, not a play icon. Filled coral with the number in white.

### Connecting Line

| Segment | Color |
|---------|-------|
| Between two completed steps | `AppColors.success` solid |
| Completed → active | Gradient: `success` → `textWhisper` |
| Active → future | `AppColors.textWhisper` solid |
| Between two future steps | `AppColors.textWhisper` solid |

### Progress Bar

Above the journey, show a thin progress bar:

```dart
// Coral only, NOT gradient
LinearProgressIndicator(
  value: completedCount / totalSteps,
  backgroundColor: AppColors.textWhisper,
  valueColor: AlwaysStoppedAnimation(AppColors.accent),
)
```

**Coral color only.** No green-to-coral gradient.

### Active Step Card (Expanded)

Inside the journey, the active step expands into a card:

- Background: `AppColors.accent.withOpacity(0.07)` with gradient
- Border: `AppColors.accent.withOpacity(0.18)`, 1px, 18px radius
- Subtle radial glow in top-right corner
- "UP NEXT" overline in coral
- Step title: 17pt, weight 700, textPrimary
- Description: 13pt, textSecondary
- Milestone badge if present: coral pill with 🏆
- Coach tip block (see below)
- "Start session" CTA: full-width coral gradient button, 44px height, 13px radius
- "Ask more about this step" CTA: appears below Start session only when tip is open

### Coach Tip Block (Inside Active Card)

A single tappable row that transforms:

**Closed state:**
- Subtle teal container: `rgba(6,139,168,0.04)` bg, `rgba(6,139,168,0.08)` border, 12px radius
- Sparkle icon (✦) 15px + "Tap for a coach tip" hint text in `rgba(92,184,201,0.5)`
- Entire row is tappable

**Open state (smooth transition):**
- Container tint increases: `rgba(6,139,168,0.08)` bg, `rgba(6,139,168,0.2)` border
- Sparkle stays at top-left, teal vertical bar (2.5px wide) grows below it
- Tip text fades in beside the vertical bar
- Hint text fades out, tip text fades in — `max-height` transition on both, 350ms easeOutCubic
- "Start session" CTA slides down smoothly (NOT flicker — use `AnimatedContainer` or `AnimatedSize` with curve)
- "Ask more about this step" CTA fades in below Start session with 50ms delay

**Animation specs:**
- Tip container: `max-height` 0→120, opacity 0→1, 350ms `Curves.easeOutCubic`
- Vertical bar: `max-height` 0→80, 350ms same curve
- Hint text: opacity 1→0, 200ms ease
- Ask more CTA: `max-height` 0→46, opacity 0→1, 350ms with 50ms delay

### Compact Future Steps

Each future step is a single row:
- Step number in gray circle (22px, `textWhisper` border)
- Title in `textSecondary`, 13pt, weight 500
- Sparkle icon (✦) on the right, 13px, in muted teal `rgba(92,184,201,0.4)` — tappable
- Estimated time in mono, 10pt, `textWhisper`
- Tapping sparkle: tip text fades in below the row with teal vertical bar (same pattern but simpler, no container)
- Tapping the row itself: starts a session for that step (see Part 6)
- Milestone badge (🏆) as small pill if present

### Compact Completed Steps

- Green check circle (26px, `success` fill)
- Title in `textMuted`, strikethrough with `textWhisper` decorationColor
- Time in mono
- No sparkle icon (tip not needed for completed steps)
- Tapping: toggles step completion (uncompletes it)

### Entry Animation

Use `flutter_animate` for staggered entrance:
- Each step fades in + slides from left: 500ms, `Curves.easeOutCubic`
- Stagger: 80ms per step
- Progress bar animates width: 600ms, same curve

---

## Part 5: Premium Step Completion Screen

### Current Problem
The `SessionCompletePhase` is bare: "STEP COMPLETE" text, title + checkmark, next step preview, auto-exit 3 seconds. No celebration, no personality, no emotional reward.

### New Design

Replace `session_complete_phase.dart` entirely. The new completion screen:

**Layout (top to bottom, centered):**

1. **Celebration burst** — Custom confetti/particle animation (see below)
2. **Success circle** — 72px green circle with animated checkmark (draws on with stroke animation)
3. **"Step complete!"** — 24pt, weight 800, textPrimary, fades in at 300ms
4. **Milestone badge** — If step has a milestone: coral pill with 🏆 + milestone name, scale-bounce in at 500ms
5. **Coach reaction** — `completionMessage` text, 13pt, textSecondary, centered, max 2 lines, fades in at 600ms. If null, skip this element.
6. **Next step preview** — "Next: [step title]" in muted text, fades in at 800ms. Only if there IS a next step.
7. **Continue button** — Green gradient CTA, "Continue" text, fades in at 1000ms. No auto-exit timer. User must tap.

**Celebration animation (pick ONE):**

Option A — **Burst particles**: 16 circles burst outward from the success circle center. Mix of colors: coral, success, coachText, textPrimary, gold. Each travels to a random point on an arc, fades out. Duration: 600ms. Use `CustomPainter` with `AnimationController`.

Option B — **Falling confetti**: Small rectangles fall from above the success circle, rotating. Same color mix. Slower, more ambient. Duration: 1.5s. Could use the `confetti` package (add `confetti: ^0.7.0` to pubspec) or custom painter.

**Recommend Option A** — burst is faster, punchier, more premium. Matches the session timer's particle aesthetic.

**Checkmark animation**: The check inside the success circle should draw on stroke-by-stroke using a `Path` + `PathMetric` animation (same technique as the particle timer). Duration: 400ms, starting at 200ms delay.

**No auto-exit.** The current 3-second timer is removed. The user taps "Continue" to return to Home. This gives them time to read the coach reaction message and feel the accomplishment.

### Audio/Haptic

- `HapticFeedback.heavyImpact()` when the completion screen appears
- Optional: a subtle success sound if `session_sound` preference is enabled (check SharedPreferences `session_sound` bool)

---

## Part 6: Any-Step Access (Non-Sequential)

### Current Behavior
The current code ALREADY allows tapping any uncompleted step to start a session — `_CompactStepRow.onTap` pushes to `/session/:hobbyId/:stepId` for any non-completed step. This is correct.

### What to Keep
- Any uncompleted step is tappable → starts a session
- The "active" step (first non-completed) gets the expanded card treatment
- Completed steps can be un-completed by tapping (toggleStep)

### What to Add
- **Visual distinction for skipped steps**: If a user completes step 3 without completing step 2, step 2 should have a slightly different state: not "future" (it's been skipped), not "completed" (it hasn't been done). Show it as: same gray circle but with a subtle dashed border instead of solid. Title stays in `textSecondary` (not muted like future steps that are truly ahead).
- **No blocking**: Never prevent a user from starting any step. The roadmap is a guide, not a gate.
- **"Active" step logic change**: Currently `nextStep` is the first uncompleted step in order. Keep this — it determines which step gets the expanded card. But if a user taps a future step directly, it starts a session for that step without changing which one is "active" in the UI.

### Why This Is the Right Call
Hobbies aren't linear. Someone doing pottery might want to try textures (step 5) before building a mug (step 4) because they're curious. Blocking them would feel like a course, not a hobby app. The expanded "UP NEXT" card still guides them to the suggested next step, but they're free to explore.

---

## Part 7: Files to Create / Modify

### New Files
| File | Purpose |
|------|---------|
| `server/scripts/backfill-step-fields.ts` | One-time script: generate coachTip + completionMessage for all existing steps |

### Modified Files
| File | Changes |
|------|---------|
| `server/prisma/schema.prisma` | Add `coachTip String?` and `completionMessage String?` to RoadmapStep |
| `server/lib/ai_generator.ts` | Add coachTip + completionMessage to TIER1_PROMPT schema + validation |
| `server/lib/content_guard.ts` | Include new fields in blocklist re-scan |
| `server/lib/mappers.ts` | Include new fields in API response |
| `server/api/generate/[action].ts` | Save new fields in hobby create block |
| `lib/models/hobby.dart` | Add `coachTip` and `completionMessage` to RoadmapStep model |
| `lib/models/session.dart` | Add `completionMessage` to SessionState |
| `lib/screens/home/home_screen.dart` | Replace `_NextStepCard` + `_CompactStepRow` + YOUR STEPS section with `_RoadmapJourney` widget |
| `lib/screens/session/session_screen.dart` | Pass `completionMessage` from route extras to session state |
| `lib/screens/session/session_complete_phase.dart` | Complete rewrite: premium completion screen |
| `lib/providers/session_provider.dart` | Accept and store `completionMessage` |

### No New Packages Required
Everything uses existing dependencies:
- `flutter_animate` (already in pubspec) — staggered entrance animations
- `CustomPainter` (Flutter SDK) — confetti burst, checkmark draw
- `AnimatedContainer` / `AnimatedSize` (Flutter SDK) — smooth tip expansion
- `HapticFeedback` (Flutter SDK) — completion haptic

If you prefer a ready-made confetti widget, optionally add `confetti: ^0.7.0` to pubspec. But custom painter is more premium and consistent with the session timer aesthetic.

---

## Part 8: Testing Checklist

### Roadmap UI
- [ ] Completed steps show green check nodes + strikethrough title
- [ ] Active step shows coral-filled node with step NUMBER (not play icon)
- [ ] Active step expands into card with title, description, tip block, CTA
- [ ] Future steps show gray outline nodes with step number
- [ ] Connecting lines: green between completed, gradient to whisper at active, whisper for future
- [ ] Progress bar is coral-only, not gradient
- [ ] Sparkle tap on active step: tip fades in smoothly, CTA slides down (no flicker), "Ask more" appears
- [ ] Sparkle tap on future step: inline tip fades in below row
- [ ] Tapping any uncompleted step starts a session
- [ ] Tapping completed step un-completes it
- [ ] Staggered entrance animation on screen load

### Session Completion
- [ ] Completion screen shows confetti burst + animated checkmark
- [ ] "Step complete!" title appears
- [ ] Milestone badge appears with scale-bounce if step has milestone
- [ ] Coach reaction message (`completionMessage`) displays, specific to the step
- [ ] If completionMessage is null, that section is skipped gracefully
- [ ] "Next: [title]" shows if there's a next step
- [ ] "Continue" button — no auto-exit timer
- [ ] Haptic feedback fires on completion
- [ ] After tapping Continue: returns to Home, step is marked complete, next step becomes active

### Any-Step Access
- [ ] User can tap step 4 without completing step 3 → session starts
- [ ] After completing step 4 (skipping 3), step 3 shows "skipped" visual (dashed border)
- [ ] The "active" expanded card still shows the first uncompleted step in order
- [ ] No errors when completing steps out of order

### Backfill
- [ ] `--dry-run` previews tips without writing
- [ ] Full run generates coachTip + completionMessage for all ~750 steps
- [ ] Tips differ from descriptions
- [ ] Completion messages are step-specific, not generic
- [ ] Script handles API errors gracefully with retry

### Edge Cases
- [ ] Hobby with 3 steps (minimum) renders correctly
- [ ] Hobby with 7 steps (maximum) doesn't overflow
- [ ] All steps completed: progress bar full, "Journey complete" state
- [ ] 0 steps completed: first step is active, no completed section
- [ ] Step with null coachTip: sparkle icon still appears but shows "No tip available" or hides
- [ ] Step with null completionMessage: completion screen skips that section
