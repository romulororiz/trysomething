# CLAUDE_EXPERIENCE_TASKS.md — "The Experience" Section

## What this section communicates
What it FEELS like to use TrySomething. Not features — the experience.
The user should think: "I can already feel myself using this."

## Context
- Read `agent_docs/app-context.md` for the app's identity and user journey
- Read `agent_docs/design-brief.md` for visual direction
- This section comes AFTER "How It Works" and BEFORE "What You Get"

---

## Creative direction: "A window into the app"

NO CARDS. NO feature grids. NO icon + title + description blocks.

This section shows a SIMULATED app experience using a phone mockup frame
with animated UI inside it. As the user scrolls, the phone screen transitions
through the key moments of using TrySomething.

Think: Apple product pages where the iPhone screen shows the product in action.
Think: Stripe's payment flow demos. Linear's interface reveals.

The phone is the centerpiece. Text flanks it with context.

---

## Layout concept: Centered phone with flanking narrative

```
                    "Tell us about you"
                           |
              ┌─────────────────────┐
              │    ┌───────────┐    │
              │    │           │    │
  Left text   │    │  PHONE    │    │   Right text
  context     │    │  SCREEN   │    │   context
              │    │           │    │
              │    └───────────┘    │
              └─────────────────────┘
```

The phone mockup sits in the center. As the user scrolls through this section,
the "screen" inside the phone transitions between 4 app states:

### Screen 1 — "The Quiz"
A simplified mock of the onboarding quiz:
- A question: "What excites you?"
- A few pill-shaped options: "Creating things", "Being outdoors", "Learning skills", "Moving my body"
- Two are "selected" (highlighted in gold)
- Flanking text (left): "2 minutes. That's all it takes."
- Flanking text (right): "No signup walls. No credit card. Just honest questions."

### Screen 2 — "Your Matches"
A simplified mock of the matched hobbies screen:
- 3 hobby "cards" stacked: "Pottery" (92% match), "Urban Sketching" (87% match), "Bouldering" (84% match)
- Each has a small Lottie icon (reuse from `public/lottie/`) and a match percentage
- The top one has a warm glow around it
- Flanking text (left): "AI that actually gets you."
- Flanking text (right): "Not '100 hobbies to try.' Three that fit your life."

### Screen 3 — "Your Roadmap"
A simplified mock of a hobby roadmap:
- Title: "Pottery — Week 1"
- A checklist with 3 items: "✓ Find a local studio" / "✓ Book intro class ($25)" / "○ Attend first session"
- Progress bar at 66%
- Flanking text (left): "Every step spelled out."
- Flanking text (right): "What to buy. Where to go. What to expect. Done."

### Screen 4 — "Your Coach"
A simplified mock of an AI coach message:
- Chat bubble from coach: "Nice work finishing your first session! Here's what to focus on next week..."
- A "tip" card below: "Start with the centering technique — it builds muscle memory fastest."
- Flanking text (left): "A coach that never judges."
- Flanking text (right): "Adapts to your pace. Celebrates your wins."

---

## Implementation tasks

### Task 1: Build the phone mockup frame

Create `src/components/sections/ExperiencePhone.tsx`:

**The phone frame:**
- A CSS-only phone mockup (NOT an image)
- Rounded rectangle: `w-[280px] h-[580px]` with `border-radius: 40px`
- Border: `2px solid rgba(255,255,255,0.08)` — subtle, barely visible
- Background: `#111111` (slightly lighter than page black to create depth)
- Top notch: a small rounded rectangle at the top center (the "dynamic island")
- Inner screen area: `overflow: hidden`, `border-radius: 32px` (inset from frame)
- Subtle shadow: `box-shadow: 0 0 80px rgba(212,160,84,0.06)` — warm ambient glow
- The frame itself should feel like a real device floating in space

**DO NOT use an image of a phone. Build it with CSS.**

### Task 2: Build the 4 screen states

Create `src/components/sections/ExperienceScreens.tsx`:

Each screen is a React component that renders a simplified, BEAUTIFUL mock UI:

**Design rules for the mock screens:**
- Background: `#0A0A0F` (matches app dark theme)
- Text: white and muted gray
- Accent: warm gold (`#D4A054`) for highlights, selections, progress bars
- Typography: the project's sans font, appropriately sized for the phone scale
- Keep it SIMPLE — this is a suggestion of UI, not a pixel-perfect replica
- Rounded corners on all inner elements (`8-12px`)
- Generous padding inside the phone screen

**Screen transitions:**
- Use Framer Motion `AnimatePresence` to transition between screens
- Exit: fade out + slight scale down (0.95)
- Enter: fade in + slight scale up from 0.95 to 1
- Transition duration: 0.5s

### Task 3: Build the scroll-driven state machine

Create `src/components/sections/Experience.tsx`:

**Section is scroll-pinned** (like How It Works):
```tsx
useEffect(() => {
  const trigger = ScrollTrigger.create({
    trigger: sectionRef.current,
    start: 'top top',
    end: '+=250%',
    pin: true,
    scrub: 0.5,
    onUpdate: (self) => {
      const screen = Math.min(3, Math.floor(self.progress * 4))
      setActiveScreen(screen)
    }
  })
  return () => trigger.kill()
}, [])
```

**Layout:**
```tsx
<section ref={sectionRef} className="relative w-full h-screen bg-black overflow-hidden">
  <div className="flex items-center justify-center h-full max-w-6xl mx-auto px-8">

    {/* Left flanking text */}
    <div className="flex-1 text-right pr-12">
      <AnimatePresence mode="wait">
        <motion.div key={activeScreen}>
          <p className="text-2xl text-white font-display">{screens[activeScreen].leftText}</p>
        </motion.div>
      </AnimatePresence>
    </div>

    {/* Phone mockup */}
    <PhoneMockup>
      <AnimatePresence mode="wait">
        <ScreenComponent key={activeScreen} />
      </AnimatePresence>
    </PhoneMockup>

    {/* Right flanking text */}
    <div className="flex-1 pl-12">
      <AnimatePresence mode="wait">
        <motion.div key={activeScreen}>
          <p className="text-lg text-[#8A8A9A]">{screens[activeScreen].rightText}</p>
        </motion.div>
      </AnimatePresence>
    </div>

  </div>

  {/* Screen indicator dots at bottom */}
  <div className="absolute bottom-12 left-1/2 -translate-x-1/2 flex gap-2">
    {[0,1,2,3].map(i => (
      <div key={i} className={`w-2 h-2 rounded-full transition-colors duration-300 ${
        i === activeScreen ? 'bg-[#D4A054]' : 'bg-white/15'
      }`} />
    ))}
  </div>
</section>
```

### Task 4: Section header

Above the phone area (inside the pinned section):
- Small label: "THE EXPERIENCE" in muted uppercase tracking-wide text
- Optional headline: "See it in action" or "Feel it before you try it" — keep it short
- Positioned at the top of the section

### Task 5: Mobile adaptation

On screens < 768px:
- Phone mockup scales down to `w-[240px] h-[500px]`
- Flanking text moves BELOW the phone instead of beside it
- Only show left text (the punchy line), hide the right text on mobile
- Stack vertically: header → phone → text → dots
- Scroll pin still works but with `end: '+=200%'` (less scroll distance)

### Task 6: Polish and verify

- Transitions between screens should feel SMOOTH and intentional
- The flanking text should swap in sync with the screen change
- The phone should feel like it's floating (the warm glow shadow helps)
- Test the full scroll-through: is it clear what each screen represents?
- Screenshot all 4 states with Playwright:
  - `screenshots/experience-quiz.png`
  - `screenshots/experience-matches.png`
  - `screenshots/experience-roadmap.png`
  - `screenshots/experience-coach.png`
- Mobile screenshot at state 2 (matches): `screenshots/experience-mobile.png`

---

## What NOT to do
- ❌ NO cards or feature grids — this section has ONE phone, not multiple boxes
- ❌ NO real app screenshots — build simplified mock UIs in React
- ❌ NO image of a phone — build the frame with CSS
- ❌ NO horizontal scrolling or carousels
- ❌ NO click-to-advance — scroll drives the transitions
- ❌ NO complex animations inside the phone screens — keep the mock UI static/simple, the TRANSITION between screens is the animation
- ❌ NO light-mode screens inside the phone — everything is dark theme
- ❌ NO generic stock UI — the mock screens should feel like THIS specific app
- ❌ NO plasma, orbs, or abstract effects anywhere in this section
