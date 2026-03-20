# CLAUDE_HOWITWORKS_TASKS.md — How It Works Section Rebuild

## What this is
The "How It Works" section for TrySomething's landing page.
This section explains the 4-step journey: **Match → Start → Stay → Grow**.

## Context
Read these before starting:
- `agent_docs/app-context.md` — what the app does
- `agent_docs/design-brief.md` — full creative direction
- `CLAUDE_HERO_TASKS.md` — the hero section (understand the visual language already established)

## Core mechanic: SCROLL-PINNED SCRUB

This is the most important technical requirement. The section is **pinned to the viewport** while the user scrolls. The user scrolls through ~300vh of scroll distance, but the section stays visually fixed at 100vh. Only the **content inside** transitions between steps.

This is NOT a normal scrolling section. It behaves like a presentation slide deck driven by scroll position.

---

## Task 1: Install and configure GSAP ScrollTrigger

- Install `gsap` if not present: `npm install gsap`
- GSAP ScrollTrigger is included in the core package — register it:
```typescript
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
gsap.registerPlugin(ScrollTrigger)
```
- Verify it doesn't conflict with existing scroll libraries (Lenis, etc.)
- If Lenis smooth scroll is active, integrate it with ScrollTrigger:
```typescript
// In your Lenis setup
lenis.on('scroll', ScrollTrigger.update)
gsap.ticker.add((time) => lenis.raf(time * 1000))
gsap.ticker.lagSmoothing(0)
```

## Task 2: Build the scroll-pinned container

Create `src/components/sections/HowItWorks.tsx`:

### Pinning structure
```tsx
const sectionRef = useRef<HTMLDivElement>(null)
const [activeStep, setActiveStep] = useState(0)

useEffect(() => {
  const section = sectionRef.current
  if (!section) return

  const trigger = ScrollTrigger.create({
    trigger: section,
    start: 'top top',
    end: '+=300%',        // 3x viewport height of scroll distance
    pin: true,            // PIN the section
    scrub: 0.5,           // smooth scrub tied to scroll
    onUpdate: (self) => {
      const progress = self.progress  // 0 to 1
      const step = Math.min(3, Math.floor(progress * 4))
      setActiveStep(step)
    }
  })

  return () => trigger.kill()
}, [])
```

### Section layout
```
<section ref={sectionRef} className="relative w-full h-screen bg-black overflow-hidden">
  {/* Section header — stays visible throughout */}
  <SectionHeader />

  <div className="flex h-full items-center max-w-7xl mx-auto px-8">
    {/* Left side: step cards */}
    <StepCards activeStep={activeStep} />

    {/* Right side: visual that transitions per step */}
    <StepVisual activeStep={activeStep} />
  </div>

  {/* Scroll progress indicator */}
  <ScrollProgress activeStep={activeStep} />
</section>
```

## Task 3: Build the step cards (left side)

Create `src/components/sections/HowItWorksCards.tsx`:

### The 4 steps

```typescript
const steps = [
  {
    number: '01',
    label: 'MATCH',
    title: 'Find what fits your life',
    description: 'Answer a few quick questions about your interests, schedule, and budget. Our AI finds hobbies that actually fit — not random suggestions.',
  },
  {
    number: '02',
    label: 'START',
    title: 'Begin in under an hour',
    description: 'Get a starter kit with exact costs, a step-by-step first session, and answers to every beginner question. No research rabbit holes.',
  },
  {
    number: '03',
    label: 'STAY',
    title: 'Keep going for 30 days',
    description: 'Your AI coach checks in, adjusts the plan, and celebrates milestones. The hardest part of any hobby is week two — we get you through it.',
  },
  {
    number: '04',
    label: 'GROW',
    title: 'Make it part of your life',
    description: 'Advanced roadmaps, community connections, and new challenges. What started as "maybe" becomes "this is my thing."',
  },
]
```

### Card behavior

**Active card:**
- Full opacity (1.0)
- Warm gold/amber left border (3px solid, accent color)
- Background: subtle glass effect `rgba(255,255,255,0.03)` with `backdrop-filter: blur(4px)`
- Number in accent color, large
- Title in white, bold
- Description visible, muted text (`#8A8A9A`)
- Slight scale up or left-shift to feel "selected"

**Inactive cards:**
- Low opacity (0.3)
- No border glow
- No background
- Number and title visible but dimmed
- Description HIDDEN (opacity 0, height collapsed or max-height: 0)
- Slightly smaller / receded

### Transitions between states
Use Framer Motion `AnimatePresence` or `motion.div` with `animate` based on `isActive`:

```typescript
<motion.div
  animate={{
    opacity: isActive ? 1 : 0.3,
    x: isActive ? 0 : -8,
    scale: isActive ? 1 : 0.97,
  }}
  transition={{ duration: 0.5, ease: [0.23, 1, 0.32, 1] }}
>
```

Description expands/collapses smoothly:
```typescript
<motion.p
  animate={{
    opacity: isActive ? 1 : 0,
    height: isActive ? 'auto' : 0,
    marginTop: isActive ? 12 : 0,
  }}
  transition={{ duration: 0.4, ease: 'easeInOut' }}
>
```

### Layout
- Left side takes ~45% of the width
- Cards stacked vertically with ~24px gap
- All 4 cards are ALWAYS visible (stacked list) — only the active state changes
- This is NOT a carousel or slider — it's a vertical list where one card is highlighted

## Task 4: Build the step visual (right side)

Create `src/components/sections/HowItWorksVisual.tsx`:

### Concept: "Journey of the hobby icons"

Reuse the same Lottie hobby icons from the hero (loaded from `public/lottie/`), but tell a STORY with their arrangement that maps to each step. The icons transition between formations as the active step changes.

**Pick 6 icons** for this section (subset of the hero icons):
```typescript
const visualIcons = [bicycle, camera, music, plant, cooking, book]
```

### The 4 formations (one per step):

**Step 0 — MATCH (scattered/searching):**
Icons are spread randomly across the visual area, slowly drifting in different directions. Some are dimmer than others. The feeling: "so many options, where do I start?"
```typescript
const matchPositions = [
  { x: '15%', y: '20%', opacity: 0.25, size: 50 },
  { x: '70%', y: '15%', opacity: 0.35, size: 45 },
  { x: '40%', y: '70%', opacity: 0.20, size: 55 },
  { x: '80%', y: '60%', opacity: 0.30, size: 40 },
  { x: '25%', y: '50%', opacity: 0.28, size: 48 },
  { x: '60%', y: '40%', opacity: 0.22, size: 42 },
]
```

**Step 1 — START (one highlighted, others recede):**
ONE icon moves to center and grows larger + brighter (the "matched" hobby). The others dim and pull to the edges. The feeling: "found it — this one's for you."
```typescript
const startPositions = [
  { x: '5%',  y: '15%', opacity: 0.10, size: 35 },  // receded
  { x: '85%', y: '10%', opacity: 0.10, size: 30 },  // receded
  { x: '45%', y: '45%', opacity: 0.60, size: 80 },  // CENTER — the match!
  { x: '90%', y: '75%', opacity: 0.10, size: 30 },  // receded
  { x: '10%', y: '80%', opacity: 0.10, size: 32 },  // receded
  { x: '75%', y: '50%', opacity: 0.10, size: 28 },  // receded
]
```

**Step 2 — STAY (forming a path/line):**
Icons arrange into a diagonal line or gentle curve — a visual roadmap. Each icon is evenly spaced, similar size, building brightness from left to right. The feeling: "here's your journey, step by step."
```typescript
const stayPositions = [
  { x: '10%', y: '70%', opacity: 0.45, size: 44 },
  { x: '25%', y: '58%', opacity: 0.48, size: 46 },
  { x: '40%', y: '46%', opacity: 0.50, size: 48 },
  { x: '55%', y: '38%', opacity: 0.52, size: 50 },
  { x: '70%', y: '30%', opacity: 0.55, size: 52 },
  { x: '85%', y: '22%', opacity: 0.58, size: 54 },
]
```

**Step 3 — GROW (bloom/expansion):**
Icons spread outward from center in a radial burst, all now bright and alive. Each icon is confident, well-lit, fully animated. The feeling: "this is your life now — full of things you love."
```typescript
const growPositions = [
  { x: '50%', y: '10%', opacity: 0.55, size: 55 },
  { x: '85%', y: '30%', opacity: 0.50, size: 52 },
  { x: '80%', y: '70%', opacity: 0.48, size: 50 },
  { x: '50%', y: '85%', opacity: 0.52, size: 53 },
  { x: '15%', y: '65%', opacity: 0.50, size: 51 },
  { x: '18%', y: '25%', opacity: 0.48, size: 49 },
]
```

### Transitioning between formations

When `activeStep` changes, each icon animates from its current position to the new one using Framer Motion:

```typescript
{visualIcons.map((icon, i) => {
  const pos = formations[activeStep][i]
  return (
    <motion.div
      key={i}
      animate={{
        left: pos.x,
        top: pos.y,
        opacity: pos.opacity,
        width: pos.size,
        height: pos.size,
      }}
      transition={{
        duration: 0.8,
        delay: i * 0.06,  // staggered — icons don't all move at once
        ease: [0.23, 1, 0.32, 1],
      }}
      style={{ position: 'absolute', pointerEvents: 'none' }}
    >
      <Lottie animationData={recolor(icon)} loop autoplay />
    </motion.div>
  )
})}
```

**Important:** Use the same `recolor()` utility from the hero to make icons warm gold/amber on black.

### Add connecting lines (optional but premium)

Between the icons in the **STAY** step (the path formation), draw subtle SVG lines connecting them:

```tsx
{activeStep === 2 && (
  <svg className="absolute inset-0 w-full h-full pointer-events-none">
    <motion.path
      d="M 10% 70% Q 30% 55% 50% 42% Q 70% 32% 90% 20%"
      stroke="rgba(212,160,84,0.15)"
      strokeWidth="1"
      fill="none"
      strokeDasharray="4 6"
      initial={{ pathLength: 0 }}
      animate={{ pathLength: 1 }}
      transition={{ duration: 1.2, ease: 'easeOut' }}
    />
  </svg>
)}
```

This dashed golden line connecting the icons makes the "roadmap" metaphor concrete. It appears only during the STAY step and animates in with a drawing effect.

### Subtle glow behind center icon in START step

When one icon is highlighted (step 1), add a radial glow behind it:
```tsx
{activeStep === 1 && (
  <motion.div
    className="absolute rounded-full"
    style={{
      left: '45%', top: '45%',
      width: 120, height: 120,
      transform: 'translate(-50%, -50%)',
      background: 'radial-gradient(circle, rgba(212,160,84,0.12) 0%, transparent 70%)',
    }}
    initial={{ opacity: 0, scale: 0.5 }}
    animate={{ opacity: 1, scale: 1 }}
    transition={{ duration: 0.6 }}
  />
)}
```

## Task 5: Build the scroll progress indicator

A minimal indicator showing which step is active. Sits at the bottom of the section or along the right edge.

**Option A — Bottom dots:**
```
○ ● ○ ○
```
4 dots, active one is filled with accent color, others are outline/dim.

**Option B — Vertical progress bar (right edge):**
A thin vertical line on the right side. A warm golden dot/marker moves down the line as the user scrolls. Step labels (`01`, `02`, `03`, `04`) sit alongside at even intervals.

Pick whichever feels more premium. The indicator must be subtle — it's a helper, not a feature.

## Task 6: Section header

A small header at the top of the pinned section:

- Small uppercase tracking-wide label: "HOW IT WORKS" in muted text (`#6A6A7A`)
- OR a larger section title if the design calls for it
- Keep it minimal — the cards and visual tell the story
- Positioned at the top of the section with generous top padding (80-100px)

## Task 7: Mobile adaptation

On screens < 768px:

- The visual (right side) moves ABOVE the cards, taking ~40% of the viewport height
- Cards stack below, taking the remaining space
- Only the active card shows its description — others show just number + title
- Icons in the visual are smaller (30-40px)
- The connecting lines in STAY step can be hidden on mobile
- Scroll pin still works — test this thoroughly
- If scroll pin causes jank on mobile, consider disabling pin and using a simpler scroll-triggered animation instead (intersection observer based)

## Task 8: Compose and verify

- Wire HowItWorks into the main page, positioned AFTER the hero and problem sections
- Ensure smooth transition from the previous section into the pinned area
- Ensure smooth transition OUT of the pinned area when all steps are scrolled through
- The unpinning should feel natural — not a jarring snap

### Screenshot verification
Use Playwright MCP:
1. Navigate to `http://localhost:3000`
2. Scroll to the How It Works section
3. Screenshot at each step:
   - `screenshots/hiw-step0-match.png` (icons scattered)
   - `screenshots/hiw-step1-start.png` (one icon centered, others dimmed)
   - `screenshots/hiw-step2-stay.png` (icons in path formation with connecting line)
   - `screenshots/hiw-step3-grow.png` (icons bloomed outward)
4. Mobile screenshots at 390px width for steps 0 and 2
5. STUDY the screenshots:
   - Does the pinning work? (section stays fixed while scrolling)
   - Do the card transitions look smooth?
   - Do the icon formations clearly tell the story of each step?
   - Is the STAY step's path/line visible and meaningful?
   - Does active card clearly stand out from inactive ones?
   - Is the overall feel premium and intentional?

---

## Visual summary of the 4 formations

```
STEP 0 — MATCH (scattered)         STEP 1 — START (one found)

    ◇       ◇                              ·           ·
        ◇                                      ◆◆
  ◇         ◇                                ◆ ★ ◆     (★ = the match)
      ◇                                        ◆◆
                                          ·           ·

STEP 2 — STAY (roadmap path)        STEP 3 — GROW (bloom)

                        ◆                     ◆
                    ◆                     ◆       ◆
                ◆                       
            ◆                             ◆       ◆
        ◆                                     ◆
    ◆
    ╌╌╌╌ dashed line ╌╌╌╌
```

---

## What NOT to do — HARD RULES
- ❌ NO Three.js, WebGL, or Canvas — pure DOM + Lottie + Framer Motion + GSAP
- ❌ NO plasma, orbs, blobs, or abstract generative effects
- ❌ NO carousel/slider behavior — all 4 cards are ALWAYS visible in a vertical list
- ❌ NO horizontal scrolling
- ❌ NO click-to-advance — scroll position drives everything
- ❌ NO icons that aren't from `public/lottie/` — use ONLY the existing Lottie files
- ❌ NO full-opacity icons — they must stay ghostly/atmospheric (max 0.6)
- ❌ NO background colors other than black
- ❌ NO generic fonts or purple/blue accents
- ❌ The section must NOT scroll normally — it MUST be pinned with GSAP ScrollTrigger
