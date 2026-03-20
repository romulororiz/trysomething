# CLAUDE_HERO_TASKS.md — Hero Section Rebuild

## What this is
TrySomething is a hobby discovery app. This is the landing page hero section.
The hero must feel like a luxury product launch — dark, cinematic, premium.

## Context
Read these before starting:
- `agent_docs/app-context.md` — what the app does
- `agent_docs/design-brief.md` — full creative direction

## Aesthetic direction: "Quiet luxury constellation"

Full black background. Animated line-art hobby icons floating like constellations in a night sky.
The icons are alive — they play their animations and drift gently.
The text sits on top, large and confident. The icons are atmosphere, not decoration.

Think: a dark room with softly glowing objects suspended in air, gently moving.

---

## Task 1: Clean up and install dependencies

- Install `lottie-react` and `framer-motion` if not already present
- Verify Lottie files exist: run `ls public/lottie/` — you should see: `bicycle.json`, `camera.json`, `pencil.json`, `puzzle.json`, `book.json`, `plant.json`, `bonfire.json`, `skateboard.json`, `music.json`, `stargazing.json`, `cooking.json`
- Remove any existing Three.js hero scene components (the old plasma/orb/particle stuff)
- Remove `@react-three/fiber`, `@react-three/drei`, `@react-three/postprocessing`, and `three` from package.json IF they are only used in the hero — check other sections first
- The hero should be pure DOM + Lottie + Framer Motion — no WebGL

## Task 2: Build the hero background — pure black with depth

Create `src/components/sections/HeroBackground.tsx`:

- Background: `#000000` — true black, not near-black, not dark gray
- Add a single ultra-subtle radial gradient in the center: `radial-gradient(ellipse at 50% 40%, rgba(212,160,84,0.03) 0%, transparent 70%)` — barely visible warm glow, just enough to break the flatness
- Optional: add a noise texture overlay at 2-3% opacity for grain (CSS `filter` or a tiny noise PNG). This prevents the "LCD black" digital feeling.
- The background is full viewport: `100vw × 100vh`, `position: relative`, `overflow: hidden`
- NO gradients that are visible. NO colors. If you can obviously see the gradient, it's too strong. Dial it way back.

## Task 3: Build the floating Lottie icon field

Create `src/components/sections/HeroIcons.tsx`:

### Loading the icons
```
import Lottie from 'lottie-react'
// Import all JSON files from public/lottie/
// Use dynamic imports or static imports — either works
```

### Recoloring
The Lottie JSONs have coral/salmon strokes: `"k":[1,0.42,0.42]` (RGB normalized).
Recolor them to warm gold/amber BEFORE passing to the Lottie component.

Write a utility function that deep-clones the JSON and replaces all instances of `[1,0.42,0.42]` with a warm gold: `[0.83,0.63,0.33]` (≈ #D4A054). Search for the pattern in `ef` arrays and `c.k` properties.

Alternatively, apply a CSS filter on each Lottie wrapper div:
```css
filter: sepia(1) saturate(2) hue-rotate(-10deg) brightness(0.9);
```
Test both approaches — use whichever produces a cleaner warm gold on black.

### Layout — scattered constellation
Pick 8-9 icons (not all 11 — too crowded). Define an array of icon configs:

```typescript
const icons = [
  { file: bicycle,    x: '8%',  y: '15%', size: 70, opacity: 0.35, depth: 1.2, delay: 0 },
  { file: camera,     x: '85%', y: '20%', size: 55, opacity: 0.25, depth: 0.8, delay: 0.4 },
  { file: music,      x: '75%', y: '70%', size: 65, opacity: 0.30, depth: 1.0, delay: 0.8 },
  { file: book,       x: '15%', y: '75%', size: 50, opacity: 0.20, depth: 0.6, delay: 1.2 },
  { file: plant,      x: '90%', y: '50%', size: 45, opacity: 0.25, depth: 0.7, delay: 0.6 },
  { file: skateboard, x: '5%',  y: '45%', size: 60, opacity: 0.30, depth: 1.1, delay: 1.0 },
  { file: bonfire,    x: '60%', y: '85%', size: 50, opacity: 0.20, depth: 0.5, delay: 1.4 },
  { file: cooking,    x: '30%', y: '10%', size: 55, opacity: 0.28, depth: 0.9, delay: 0.2 },
  { file: stargazing, x: '45%', y: '80%', size: 48, opacity: 0.22, depth: 0.6, delay: 1.6 },
]
```

**Position each icon with:**
- `position: absolute`
- `left` and `top` from the config
- `width` from the `size` value (px)
- `opacity` from the config — they should be GHOSTLY, not prominent
- `pointer-events: none` — they're background, not interactive

**CLEAR ZONES — no icons here:**
- Center area roughly `25%-75%` horizontal × `25%-65%` vertical — this is where the headline and CTA sit
- Move any icon that overlaps text to the edges/corners

### Floating animation — Framer Motion
Each icon wrapper gets a Framer Motion `animate` with infinite repeat:

```typescript
<motion.div
  animate={{
    y: [0, -12, 0, 8, 0],        // gentle bob
    rotate: [0, 1.5, 0, -1, 0],  // subtle tilt
  }}
  transition={{
    duration: 5 + icon.delay,     // different speeds
    repeat: Infinity,
    ease: "easeInOut",
    delay: icon.delay,            // staggered start
  }}
>
  <Lottie animationData={icon.file} loop autoplay style={{ width: icon.size, height: icon.size }} />
</motion.div>
```

Vary the animation values per icon — NOT all the same bob distance. Some icons float more, some barely move. This creates organic, non-mechanical motion.

### Mouse parallax
Track mouse position with `onMouseMove` on the hero container.
Each icon shifts slightly based on mouse position × its `depth` multiplier:

```typescript
const handleMouseMove = (e: MouseEvent) => {
  const x = (e.clientX / window.innerWidth - 0.5) * 2   // -1 to 1
  const y = (e.clientY / window.innerHeight - 0.5) * 2   // -1 to 1
  setMouse({ x, y })
}

// Per icon: transform: translate(mouse.x * depth * 15px, mouse.y * depth * 10px)
```

Higher `depth` = more movement = feels closer. Lower = less movement = feels further away.
Use `transform` only — no layout-triggering properties. Apply with a slight CSS `transition: transform 0.3s ease-out` for smoothness.

### Entrance animation
On page load, icons should NOT all appear at once. Stagger them:

```typescript
<motion.div
  initial={{ opacity: 0, scale: 0.5 }}
  animate={{ opacity: icon.opacity, scale: 1 }}
  transition={{ duration: 1.2, delay: 0.3 + icon.delay * 0.3, ease: [0.23, 1, 0.32, 1] }}
>
```

This creates a "constellation lighting up" effect on load.

## Task 4: Build the hero text content

Create or update `src/components/sections/HeroContent.tsx`:

### Typography
- Pre-heading: small tracking-widest uppercase text, muted color (`#6A6A7A`), something like "STOP SCROLLING. START SOMETHING."
- Headline: MASSIVE. Fluid sizing: `clamp(2.5rem, 6vw, 5rem)`. A premium display font (Playfair Display, Cormorant Garamond, or whatever the project already uses). White (`#FAFAFA`).
- The word "hobby" in the headline should be in the accent color (warm gold/amber) and italic — a visual anchor.
- Example: `Discover the *hobby* you were made for.`
- Subtext: 1-2 lines max, muted (`#8A8A9A`), `max-width: 600px`, centered.
- CTA button: warm gold background, dark text, generous padding (`16px 48px`), subtle border-radius (`8-10px`, NOT fully rounded pill), letter-spacing. On hover: subtle glow (`box-shadow: 0 0 30px rgba(212,160,84,0.3)`), slight scale (`1.02`).
- Below CTA: very small muted text "Coming soon to iPhone & Android"

### Text entrance animation
Staggered Framer Motion reveals, cinematic pacing:

```typescript
// Pre-heading: fade up first
initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
transition={{ duration: 0.8, delay: 0.2 }}

// Headline: fade up second, slightly slower
transition={{ duration: 1.0, delay: 0.5 }}

// Subtext: fade up third
transition={{ duration: 0.8, delay: 0.9 }}

// CTA: fade up last, with a slight scale
initial={{ opacity: 0, y: 20, scale: 0.95 }}
transition={{ duration: 0.8, delay: 1.3 }}
```

### Layout
- Everything centered horizontally
- Vertically centered in viewport (flexbox or grid)
- Text is `position: relative` with `z-index: 10` — above the icons
- Icons are `z-index: 1` — behind everything

## Task 5: Compose the hero section

Create or update `src/components/sections/Hero.tsx`:

```
<section className="relative w-full h-screen overflow-hidden bg-black">
  <HeroBackground />     {/* Subtle gradient + noise */}
  <HeroIcons />           {/* Floating Lottie icons, z-1 */}
  <HeroContent />         {/* Text + CTA, z-10 */}
</section>
```

### Final checks
- Full viewport height (`100vh` or `100dvh` for mobile)
- No scrollbar within the hero
- Icons don't make the page wider than viewport (overflow: hidden on section)
- Text is readable over every icon — if any icon peeks behind text, lower its opacity further
- Mobile: icons are even smaller (40-60px) and fewer visible (hide 2-3 via media query or just reduce opacity to near-zero on mobile). The text is the star on mobile.
- Performance: Lottie animations are lightweight but 9 running simultaneously should be tested. If janky, reduce to 6 icons.

### Screenshot verification
After implementing, use Playwright MCP:
1. Navigate to `http://localhost:3000`
2. Wait 3 seconds for animations to initialize
3. Screenshot desktop (1280×800) → `screenshots/hero-desktop.png`
4. Resize to 390×844 → `screenshots/hero-mobile.png`
5. STUDY the screenshots:
   - Is the background truly black?
   - Are the icons subtle/ghostly (not loud)?
   - Are the icons gold/amber (not coral/salmon)?
   - Is there a clear text zone in the center with no icon overlap?
   - Does it feel like a premium product page, not a template?
   - Is the headline typography distinctive and large?
   - Does the mobile version look clean with text as the star?

---

## What NOT to do — HARD RULES
- ❌ NO Three.js, WebGL, or Canvas — pure DOM + Lottie + CSS/Framer Motion
- ❌ NO plasma, orbs, blobs, particles, or abstract generative art
- ❌ NO background colors other than black (no dark gray, no navy, no near-black)
- ❌ NO icons larger than 90px — they're atmosphere
- ❌ NO icons at full opacity — max 40%, most should be 20-35%
- ❌ NO icons in the center text zone
- ❌ NO generic fonts (Inter, Roboto, Arial, system-ui)
- ❌ NO purple or blue accent colors — warm gold/amber only
- ❌ NO pill-shaped buttons (fully rounded) — use subtle border-radius (8-10px)
- ❌ NO "AI slop" aesthetics — if it looks like every other landing page, redo it
