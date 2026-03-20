# CLAUDE_WHATYOUGET_TASKS.md — "What You Get" Section

## What this section communicates
The concrete value. Not vague promises — real, tangible things the user receives.
This replaces a generic "Features" section with something that has attitude.

## Context
- Read `agent_docs/app-context.md` for the app's identity
- Read `agent_docs/design-brief.md` for visual direction
- This section comes AFTER "The Experience" and BEFORE the final CTA

---

## Creative direction: "Bold claims, hover to prove it"

NO CARDS. NO icon grids. NO three-column feature blocks.

This section is a VERTICAL LIST of bold, large-type statements.
Each statement is a single line that takes up significant horizontal space.
On hover (desktop) or tap (mobile), a detail panel smoothly expands beneath it.

Think: a confident brand making bold claims. Each line is a promise.
The hover/expand reveals the proof.

Inspired by: luxury fashion sites' collection lists, Stripe's feature breakdowns,
Apple's spec pages where each line is a powerful statement.

---

## The content: 6 bold lines

```typescript
const features = [
  {
    number: '01',
    claim: 'AI matching that actually knows you',
    detail: 'Not a quiz that spits out "try yoga." Our AI cross-references your personality, schedule, budget, location, and energy levels to find hobbies with real compatibility scores.',
    accent: 'knows you',  // the words to highlight in gold
  },
  {
    number: '02',
    claim: 'A roadmap for your first 30 days',
    detail: 'Day 1: what to buy (with exact prices). Day 3: your first session. Week 2: your first milestone. No googling "how to start [hobby] for beginners" ever again.',
    accent: 'first 30 days',
  },
  {
    number: '03',
    claim: 'A personal AI coach in your pocket',
    detail: 'Checks in when you need motivation. Adjusts the plan when life gets busy. Celebrates wins you didn\'t know mattered. Like a patient friend who happens to be an expert.',
    accent: 'AI coach',
  },
  {
    number: '04',
    claim: 'Zero overwhelm, by design',
    detail: 'Three hobby matches, not three hundred. One step at a time, not a wall of content. We removed every excuse between you and starting.',
    accent: 'by design',
  },
  {
    number: '05',
    claim: 'Real progress you can feel',
    detail: 'Milestone tracking, streak counts, and a visual journey map. When your brain says "I never stick with anything," your progress page says otherwise.',
    accent: 'you can feel',
  },
  {
    number: '06',
    claim: 'Built for people who are tired of planning',
    detail: 'No research phase. No comparison spreadsheets. No "I\'ll start Monday." Open the app, answer a few questions, and you\'re doing something new today.',
    accent: 'tired of planning',
  },
]
```

---

## Layout: full-width typographic list

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  WHAT YOU GET                                                │
│                                                              │
│  ─────────────────────────────────────────────────────────── │
│  01    AI matching that actually knows you              [+]  │
│  ─────────────────────────────────────────────────────────── │
│  02    A roadmap for your first 30 days                 [+]  │
│  ─────────────────────────────────────────────────────────── │
│  03    A personal AI coach in your pocket               [+]  │
│        ┌──────────────────────────────────────────────┐      │
│        │  Checks in when you need motivation.         │      │
│        │  Adjusts the plan when life gets busy.       │      │
│        │  Like a patient friend who's an expert.      │      │
│        └──────────────────────────────────────────────┘      │
│  ─────────────────────────────────────────────────────────── │
│  04    Zero overwhelm, by design                        [+]  │
│  ─────────────────────────────────────────────────────────── │
│  05    Real progress you can feel                       [+]  │
│  ─────────────────────────────────────────────────────────── │
│  06    Built for people who are tired of planning       [+]  │
│  ─────────────────────────────────────────────────────────── │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

Each row is separated by a thin line (`1px, rgba(255,255,255,0.06)`).
When a row is hovered or clicked, the detail text expands below it.

---

## Implementation tasks

### Task 1: Build the section structure

Create `src/components/sections/WhatYouGet.tsx`:

```tsx
<section className="relative w-full bg-black py-32 md:py-48">
  <div className="max-w-5xl mx-auto px-8">

    {/* Section label */}
    <motion.p className="text-[#6A6A7A] text-sm tracking-[0.2em] uppercase mb-16"
      initial={{ opacity: 0 }} whileInView={{ opacity: 1 }}
      viewport={{ once: true }}>
      WHAT YOU GET
    </motion.p>

    {/* Feature list */}
    <div className="border-t border-white/[0.06]">
      {features.map((feature, i) => (
        <FeatureRow key={i} feature={feature} index={i} />
      ))}
    </div>

  </div>
</section>
```

### Task 2: Build each feature row

Create `src/components/sections/WhatYouGetRow.tsx`:

**Collapsed state (default):**
- Full-width row with `py-6 md:py-8` padding
- Bottom border: `border-b border-white/[0.06]`
- Left: number in muted gold (`#D4A054`, opacity 0.5), small monospaced font
- Center: the claim text, large (`text-xl md:text-2xl lg:text-3xl`), white
- The `accent` words within the claim are in gold (`#D4A054`)
- Right: a small `+` icon in muted text that rotates to `×` when expanded
- On hover (collapsed): the entire row shifts very slightly right (`x: 4px`) and the text brightens — a subtle "I'm interactive" signal
- Cursor: pointer

**Expanded state (on click/hover):**
- The detail text slides down smoothly below the claim
- Detail text: muted (`#8A8A9A`), smaller (`text-base md:text-lg`), `max-w-2xl`
- Left padding to align with the claim text (past the number)
- The `+` rotates 45° to become `×`
- A very subtle warm glow appears on the left border: `border-left: 2px solid rgba(212,160,84,0.3)`

**Animation:**
```tsx
const [isOpen, setIsOpen] = useState(false)

<motion.div
  className="border-b border-white/[0.06] cursor-pointer"
  onClick={() => setIsOpen(!isOpen)}
  onHoverStart={() => !isMobile && setIsOpen(true)}
  onHoverEnd={() => !isMobile && setIsOpen(false)}
>
  <div className="flex items-center py-6 md:py-8 gap-6 md:gap-10">
    {/* Number */}
    <span className="text-[#D4A054]/50 text-sm font-mono w-8 shrink-0">
      {feature.number}
    </span>

    {/* Claim text */}
    <motion.h3
      className="text-xl md:text-2xl lg:text-3xl text-white flex-1 font-light"
      animate={{ x: isOpen ? 4 : 0 }}
      transition={{ duration: 0.3 }}
    >
      {/* Render with accent words highlighted */}
      {renderWithAccent(feature.claim, feature.accent)}
    </motion.h3>

    {/* Toggle icon */}
    <motion.span
      className="text-[#6A6A7A] text-xl shrink-0"
      animate={{ rotate: isOpen ? 45 : 0 }}
      transition={{ duration: 0.3 }}
    >
      +
    </motion.span>
  </div>

  {/* Expandable detail */}
  <AnimatePresence>
    {isOpen && (
      <motion.div
        initial={{ height: 0, opacity: 0 }}
        animate={{ height: 'auto', opacity: 1 }}
        exit={{ height: 0, opacity: 0 }}
        transition={{ duration: 0.4, ease: [0.23, 1, 0.32, 1] }}
        className="overflow-hidden"
      >
        <p className="text-[#8A8A9A] text-base md:text-lg pl-14 md:pl-[72px] pb-6 max-w-2xl leading-relaxed">
          {feature.detail}
        </p>
      </motion.div>
    )}
  </AnimatePresence>
</motion.div>
```

### Task 3: Build the accent text highlighter

A utility that wraps the accent words in the claim with a gold-colored span:

```tsx
function renderWithAccent(text: string, accent: string) {
  const parts = text.split(accent)
  if (parts.length < 2) return text
  return (
    <>
      {parts[0]}
      <span className="text-[#D4A054] italic">{accent}</span>
      {parts[1]}
    </>
  )
}
```

The accent words are in gold AND italic — this creates a visual rhythm across all 6 rows where the eye catches the gold words: "knows you", "first 30 days", "AI coach", "by design", "you can feel", "tired of planning". These gold fragments tell a micro-story on their own.

### Task 4: Entrance animations

Each row staggers in as the section scrolls into view:

```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: '-50px' }}
  transition={{ duration: 0.6, delay: index * 0.08 }}
>
```

The stagger is FAST (0.08s per row) — they cascade in like a waterfall, not a slow drip.

### Task 5: Mobile behavior

- On mobile, hover doesn't work — use CLICK to toggle expand/collapse
- Detect mobile with a hook or media query
- On mobile: text sizes scale down, `text-lg` for claims
- The `+` icon is larger on mobile (easier tap target): `w-10 h-10`
- Only ONE row can be expanded at a time on mobile (accordion behavior) — expanding one collapses the other
- On desktop, multiple can be open simultaneously (hover-based)

### Task 6: Optional premium touch — a counter

At the bottom of the section, after all 6 rows, add a subtle closing statement:

```
"All of this. One app. Launching soon."
```

- Centered, muted text, small
- The words "One app" in gold
- Adds a sense of closure and anticipation

### Task 7: Verify with Playwright

Screenshot desktop with:
- All rows collapsed: `screenshots/whatyouget-collapsed.png`
- Row 3 expanded: `screenshots/whatyouget-expanded.png`
- Mobile view: `screenshots/whatyouget-mobile.png`

Check:
- Do the thin divider lines create clean horizontal rhythm?
- Are the gold accent words visible but not overpowering?
- Does the expand animation feel smooth and premium?
- Is there enough spacing between rows?
- Does the hover shift feel subtle and intentional?
- Does this look NOTHING like a feature grid?

---

## What NOT to do
- ❌ NO cards, boxes, or containers around features
- ❌ NO icons or illustrations next to features
- ❌ NO multi-column grid layout — this is a SINGLE vertical list
- ❌ NO background colors, gradients, or decorative elements
- ❌ NO scroll-pinning — this section scrolls normally
- ❌ NO Lottie icons in this section
- ❌ NO feature descriptions that are always visible — detail is HIDDEN by default
- ❌ NO generic "Feature 1, Feature 2" numbering — the numbers are part of the premium feel
- ❌ NO heavy borders or dividers — lines should be barely visible (`white/[0.06]`)
- ❌ NO centered text — everything is left-aligned in the row
