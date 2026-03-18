# Activity Log

> Auto-populated by each Ralph iteration. Do not edit manually.

---

## 2026-03-18T15:05 — Hero Particle Scene Upgrade (Tasks 1–3)

**Task:** Build the Three.js hero particle scene — the centerpiece (PRD task 3)
**Also verified:** Tasks 1 (install deps) and 2 (dark theme) were already complete.

### Changes
- **`components/canvas/HeroEnvironment.tsx`** — Complete rewrite of particle system:
  - 500 shader-based particles (up from 150 basic instanced spheres)
  - Custom GLSL vertex + fragment shaders with soft glow effect
  - Warm gold/amber color palette (cream, gold, amber, goldenrod)
  - Additive blending for bokeh-like glow halos
  - Spherical distribution with denser center
  - Organic drift animation (Y, X, Z oscillation per particle)
  - Breathing/pulsing size variation
  - Depth-based alpha fading
  - Camera parallax on mouse movement (smooth lerp)
  - CSS fallback with animated dots for no-WebGL
  - Warm atmospheric color washes (gold tones instead of teal/burgundy)
  - Vignette overlay to contain the scene

### Screenshots
- `screenshots/hero-particles-upgraded-desktop.png` — Desktop 1280x800
- `screenshots/hero-particles-upgraded-mobile.png` — Mobile 390x844

### Visual Notes
- Particles create a warm, atmospheric "constellation" effect
- Gold/amber tones match the "quiet luxury" design brief
- Text remains fully readable over the particle field
- Mobile renders well with contained particle density
- No console errors, build passes clean

### Tasks Marked Passing
- Task 1: Install Three.js ecosystem ✅
- Task 2: Dark premium theme foundation ✅
- Task 3: Three.js hero particle scene ✅

---

## 2026-03-18T15:15 — Hero Section Verification (Task 4)

**Task:** Build the Hero section — headline, subtext, CTA overlaying the 3D scene (PRD task 4)

### Findings
Hero section (`components/sections/Hero.tsx`) was already fully implemented by a previous iteration. Verified all PRD requirements:

- **Three.js canvas** positioned as full-viewport background behind text via `HeroEnvironment`
- **Headline** uses Instrument Serif italic for "hobby" highlight in coral, clamp-based fluid sizing `clamp(2.5rem,6vw,5rem)`
- **Subtitle** is 2 lines max, warm secondary text color, max-w-2xl constrained
- **Single CTA** "Get Early Access" with `MagneticButton` (magnetic pull on hover + breathing coral glow)
- **Staggered entrance** via `StaggeredText` component (word-by-word fade-up with blur, 0.07s stagger)
- **Text readability** ensured by radial gradient overlay (dark center → darker edges)
- **Eyebrow text** "Stop scrolling. Start something." in uppercase tracking
- **Scroll indicator** animated chevron at bottom
- **Mobile** text resizes fluidly, CTA is full-width-friendly, layout stacks cleanly

### Screenshots
- `screenshots/hero-desktop.png` — Desktop 1280x800
- `screenshots/hero-mobile.png` — Mobile 390x844

### Visual Notes
- Warm gold particles create atmospheric depth behind text
- Serif italic "hobby" in coral is the distinctive typographic moment
- Breathing glow on CTA draws the eye naturally
- Generous whitespace — section breathes, no crowding
- Mobile: text scales down elegantly, particles visible but subtle
- Build passes clean, no errors

### Tasks Marked Passing
- Task 4: Hero section ✅

---

## 2026-03-18T15:30 — Problem Section Redesign (Task 5)

**Task:** Build the Problem section — emotional scroll-triggered text reveals (PRD task 5)

### Changes
- **`components/sections/Problem.tsx`** — Complete redesign from card-based layout to cinematic text reveals:
  - Removed `ProblemCard` component and grid layout entirely
  - New `RevealLine` component — scroll-triggered fade-up with blur using `useInView`
  - Emotional narrative flow: 4 text beats building to a turn
  - Clamp-based fluid typography `clamp(1.75rem, 4vw, 3.25rem)` for impact lines
  - Accent-colored keywords ("something", "started.") in serif italic coral
  - "The turn" — softer secondary text leading to bold insight block
  - Third line "And nobody shows you how." in `text-text-muted` for contrast fade
  - Closing bridge "Until now." centered in muted text
  - Gradient transition from hero (no hard line)
  - Atmospheric blooms (burgundy + coral) for warmth
  - Generous padding: `py-40 md:py-56` — section breathes
  - No cards, no grids — pure typography-driven storytelling

### Screenshots
- `screenshots/problem-section-desktop.png` — Desktop 1280x800 (top)
- `screenshots/problem-section-desktop-bottom.png` — Desktop 1280x800 (bottom)
- `screenshots/problem-section-mobile.png` — Mobile 390x844 (top)
- `screenshots/problem-section-mobile-bottom.png` — Mobile 390x844 (bottom)

### Visual Notes
- Typography creates a cinematic reading experience — each line a beat
- Coral serif italic highlights ("something", "started.") are the distinctive moments
- Generous whitespace between reveals creates dramatic pacing
- The "turn" (from emotional hook to insight) lands well visually
- "Until now." as a quiet bridge to the Solution section
- Mobile: text scales fluidly, maintains impact at smaller sizes
- Build passes clean, no errors

### Tasks Marked Passing
- Task 5: Problem section ✅

---

## 2026-03-18T15:38 — How It Works Section Redesign (Task 6)

**Task:** Build the How It Works section with Three.js journey visualization (PRD task 6)

### Changes
- **`components/canvas/JourneyScene.tsx`** — Complete redesign of particle system:
  - 200 shader-based particles (up from 150)
  - Warm color palettes per step: sage/teal (Match), coral (Start), gold/amber (Stay)
  - Improved particle shapes: ring (discovery), helix (journey upward), sphere (momentum)
  - Softer glow with warmer core in fragment shader
  - More organic drift animation (Y, X, Z oscillation)
  - Slower, more elegant rotation and transition timing
  - Warm gold fallback gradient (was teal)
  - Warm gold glow wash behind particles

- **`components/sections/HowItWorks.tsx`** — Polished step card design:
  - Step accent colors: sage (#7DBDAB), coral (#FF6B6B), gold (#DAA520)
  - Active card: gradient background with accent border glow
  - Inactive cards: 50% opacity with hover to 70% (was hard 40%)
  - Clickable step cards and indicator dots for direct navigation
  - Larger step numbers (text-2xl) for better visual hierarchy
  - "momentum." keyword highlighted in coral italic via StaggeredText
  - Active step label below the 3D scene on desktop
  - Mobile step indicator dots (visible on small screens)
  - Warm atmospheric blooms (gold + coral radial gradients)
  - More generous padding: py-32 md:py-48

### Approach
Chose Option C (morphing particle system) — particles transform between ring → helix → sphere as user scrolls through steps. This creates the most premium, achievable result while clearly differentiating each step visually.

### Screenshots
- `screenshots/howitworks-desktop-final.png` — Desktop 1280x800 (header + start of steps)
- `screenshots/howitworks-desktop-step1-active.png` — Desktop with Step 2 active (coral helix)
- `screenshots/howitworks-v2-mobile-header.png` — Mobile 390x844 (header + Step 1)
- `screenshots/howitworks-v2-mobile-steps.png` — Mobile (Step 3 active, gold accent)

### Visual Notes
- Warm coral helix for "Start" step is the visual highlight — reads as an upward journey
- Gold sphere for "Stay" step conveys stability and momentum
- Step cards have clean active/inactive states with color-coded accents
- "momentum." in coral serif italic is the distinctive typographic moment in the headline
- Particles morph smoothly between shapes with eased transitions
- Mobile: cards stack cleanly, no 3D (too small), step dots provide navigation
- Build passes clean, no errors

### Tasks Marked Passing
- Task 6: How It Works section ✅
