# CLAUDE_SOLUTION_TASKS.md — "The Solution" Section

## What this section communicates
The emotional pivot: from the PAIN of not having a hobby → to the RELIEF of TrySomething solving it.
This is NOT a feature list. It's a feeling. Before vs After.

## Context
- Read `agent_docs/app-context.md` for the app's identity
- Read `agent_docs/design-brief.md` for visual direction
- This section comes AFTER the hero and BEFORE "How It Works"

---

## Creative direction: "The before and after"

NO CARDS. This is an editorial, full-bleed, typographic section.

Think magazine spread. Think Apple's "This changes everything" moments.
Two halves of a story told through scroll. The first half is the pain. The second half is the answer.

---

## Layout concept: Horizontal split that transforms

The section is ONE continuous scroll experience:

### Phase 1 — "The problem" (top half as user scrolls in)

A full-width area with large, emotionally resonant text that fades in line by line.
Each line appears as the user scrolls into view. Cinematic pacing.

**The copy (adjust wording as needed but keep the emotional arc):**

```
You've been meaning to start something new.

A hobby. A passion. Anything that isn't
scrolling, working, or waiting for the weekend.

But every time you try to figure out what,
you end up lost in a sea of listicles,
YouTube rabbit holes, and abandoned shopping carts.

So you do nothing.

Again.
```

**How it looks:**
- Text is LEFT-aligned, NOT centered (editorial feel, like reading a book)
- Font: the project's display/serif font, large (`clamp(1.5rem, 3.5vw, 2.8rem)`)
- Color: starts as muted (`#5A5A6A`) and as lines reveal, they shift to slightly brighter
- The last two lines ("So you do nothing." / "Again.") are smaller, isolated, and hit hard — extra spacing above them, maybe even the accent color or white
- Each line uses Framer Motion `useInView` with staggered delays
- Background: black, no decoration, just TEXT. The emptiness IS the design. Represents the void of "doing nothing."
- Generous padding: `py-40` or more. This section breathes.
- Max text width: `max-w-3xl` — text should never stretch across the full screen

### Phase 2 — "The shift" (a visual break)

A single horizontal line or gradient wipe that marks the transition.
As the user scrolls past the problem text, a warm golden line draws itself across the viewport:

```tsx
<motion.div
  className="w-full h-px my-24"
  style={{ background: 'linear-gradient(90deg, transparent 0%, #D4A054 50%, transparent 100%)' }}
  initial={{ scaleX: 0 }}
  whileInView={{ scaleX: 1 }}
  viewport={{ once: true, margin: '-100px' }}
  transition={{ duration: 1.2, ease: [0.23, 1, 0.32, 1] }}
/>
```

This golden line is the "moment of change." Subtle but meaningful.

### Phase 3 — "The answer" (bottom half)

After the golden line, the tone shifts. Brighter. Warmer. Confident.

**Layout: a two-column asymmetric grid**
- Left column (~55%): bold statement text
- Right column (~45%): 3 short value props stacked vertically (NOT cards — just text with accent markers)

**Left side — the bold statement:**
```
What if someone just told you
exactly what to try — and
exactly how to start?
```
- Large display font, WHITE text (contrast with the muted problem text above)
- The word "exactly" in accent gold, both times
- Fade-up entrance animation

**Right side — three value anchors (NOT cards, just typographic blocks):**

Each one is:
- A thin golden accent line on the left (3px, 40px tall)
- A short bold title in white
- A one-line description in muted text

```
│ AI that knows you
  Not random suggestions. Personalized to your life.

│ A roadmap, not a reading list
  Step one. Step two. Your first win in a week.

│ A coach that stays with you
  Encouragement, adjustments, momentum.
```

- Staggered entrance: each block fades in 0.2s after the previous
- No backgrounds, no borders, no shadows — just text + the gold accent line
- The vertical gold lines create a visual rhythm without needing boxes

**Mobile layout:**
- Stacks to single column
- Problem text → golden line → statement → value anchors below
- All text sizes scale down fluidly

---

## Implementation tasks

### Task 1: Build the Problem narrative
Create `src/components/sections/Solution.tsx`:

- Full-width section, `bg-black`, generous vertical padding (`py-32 md:py-48`)
- Problem text block: left-aligned, `max-w-3xl`, `mx-auto` with left padding
- Each line wrapped in its own `<motion.div>`:
  ```tsx
  <motion.p
    initial={{ opacity: 0, y: 16 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true, margin: '-50px' }}
    transition={{ duration: 0.7, delay: index * 0.12 }}
  >
  ```
- The last two lines have extra `mt-12` spacing and use white or accent color
- NO decorations, NO icons, NO images — the emptiness is intentional

### Task 2: Build the golden divider
- A horizontal gradient line: transparent → gold → transparent
- Animates `scaleX` from 0 to 1 when scrolled into view
- Sits between problem and answer with `my-20 md:my-32` spacing

### Task 3: Build the Answer section
- Two-column grid: `grid grid-cols-1 md:grid-cols-[1.2fr_1fr] gap-16`
- Left: large statement text with gold "exactly" highlights
- Right: three text blocks with gold left-border accent lines
- All elements fade up on scroll with stagger
- `max-w-6xl mx-auto px-8`

### Task 4: Mobile and polish
- Test at 390px: everything single-column, text scales down
- Verify the golden line animates smoothly
- Verify the emotional arc reads correctly (pain → shift → answer)
- Screenshot desktop and mobile with Playwright

---

## What NOT to do
- ❌ NO cards, boxes, containers, or bordered elements in the problem section
- ❌ NO icons or illustrations — this section is pure typography
- ❌ NO background colors other than black
- ❌ NO centered text in the problem section (left-align for editorial feel)
- ❌ NO feature lists — this is emotional, not informational
- ❌ NO generic copy like "Our solution" or "Why choose us"
- ❌ NO Lottie icons here — save those for hero and how-it-works
- ❌ NO images or screenshots — text IS the content
