# Design Brief — TrySomething Landing Page

## Creative direction: "Quiet luxury meets digital wonder"

Think Apple keynote elegance crossed with the wonder of discovering something new.
NOT flashy. NOT loud. NOT crowded. PREMIUM. Every element earns its place.
The Three.js isn't decoration — it's the storytelling medium.

## Design references (the feeling, not the layout)

- **Linear.app** — Dark, refined, beautiful motion, every pixel intentional
- **Vercel.com** — Typography-forward, sophisticated gradients, confident whitespace
- **Stripe.com** — Premium product feel, smooth scroll animations, trust-building
- **Apple keynotes** — Dramatic reveals, cinematic pacing, "one more thing" moments
- **Lusion.co** — Artistic 3D that serves the narrative, not just decoration

## Color palette

Dark-mode dominant. Light is cheap — darkness is premium.

- Background: Near-black with subtle depth (`#0A0A0F` → `#12121A`)
- Primary accent: A warm, unexpected gold or amber — NOT startup blue/purple
- Text: Crisp white (`#FAFAFA`) with a softer secondary (`#8A8A9A`)
- Accent glow: Subtle warm luminance — think candlelight, not neon
- Gradients: Ultra-subtle, noise-textured, multi-stop — never flat or obvious

## Typography

Premium typography is the #1 signal of quality.

- Display/headlines: A distinctive serif or elegant sans — consider: Playfair Display, Cormorant Garamond, PP Neue Montreal, General Sans, Cabinet Grotesk, Satoshi. Pick ONE that feels luxurious.
- Body: Clean, highly legible sans — consider: General Sans, Satoshi, Plus Jakarta Sans. NOT Inter, NOT Roboto, NOT system fonts.
- Sizing: Dramatically large headlines (clamp-based fluid), generous line heights, tight letter-spacing on headings.
- The typography alone should make someone think "this is premium."

---

## Three.js / 3D vision

### What NOT to do — ABSOLUTE RULES
- ❌ NO abstract plasma, orbs, blobs, or generic particle clouds
- ❌ NO glowing spheres or aura effects
- ❌ NO code-generated SVG hobby icons — they look amateur
- ❌ NOTHING that looks like a screensaver or tech demo
- ❌ NO random shapes that have nothing to do with hobbies
- The 3D must be MEANINGFUL — directly connected to hobby discovery

### 3D models — use REAL .glb files

The project has real low-poly 3D models in `public/models/`. 
Load them using `useGLTF` from `@react-three/drei`.

**BEFORE implementing any 3D, run `ls public/models/` to see which .glb files are available.**
Use ONLY the models that exist. Do NOT generate placeholder geometry or SVG paths as substitutes.

If `public/models/` is empty or missing, fall back to simple geometric primitives (icosahedrons, torus knots, octahedrons) arranged artfully — but NEVER random blobs or plasma.

### Hero section — "A universe of hobbies"

A full-viewport 3D scene with the real hobby models floating gently in space.

- Load 6-8 .glb models from `public/models/`
- Position them scattered across the scene at varying depths (z = -2 to -10)
- Each object rotates slowly on its own axis (different speeds, different axes)
- Gentle floating motion — subtle sine-wave Y oscillation, each with different phase
- Warm amber/gold directional light from above-right, soft fill light from below-left
- On mouse move, the camera subtly shifts perspective (parallax effect, max ±0.5 units)
- Objects further from camera are slightly more transparent/dimmed — depth fog
- The feeling: "look at all these possibilities waiting for you"
- Scale: objects should be SMALL — they're floating in the background, not dominating the frame. Text is the hero, 3D is atmosphere.
- Subtle bloom post-processing — VERY subtle, just enough to make the warm light feel alive
- Canvas sits BEHIND the hero text (position absolute, z-index behind)

### How It Works section — SCROLL-PINNED (sticky scrub)

**This is the most important technical requirement. Read carefully.**

This section uses GSAP ScrollTrigger with `pin: true`:
- The ENTIRE section is pinned to the viewport while the user scrolls
- The section occupies ~300vh of scroll space but visually stays fixed at 100vh
- There are 3-4 step cards (e.g. Match → Start → Stay → Grow)
- As the user scrolls, ONLY the active card transitions — the section itself does NOT move
- Inactive cards: dimmed, slightly smaller or faded out
- Active card: full opacity, highlighted border or glow, expanded with description text
- The transition between cards is driven by scroll position, not click

**Layout:**
- Left side: stacked step cards (vertical list), active one highlighted
- Right side: a 3D visualization area that transitions between states per step
  - Step 1 (Match): hobby models scattered randomly, slowly drifting
  - Step 2 (Start): models begin clustering into a loose group (finding your match)
  - Step 3 (Stay): models form a clear line/path (your roadmap taking shape)
  - Step 4 (Grow): models spread outward in a bloom pattern (growth, expansion)
- OR if the multi-state 3D is too complex: a single rotating model that changes per step, or an abstract geometric shape that morphs
- The 3D transitions are interpolated based on scroll progress (0 to 1)

**Technical implementation:**
```
- GSAP ScrollTrigger: pin the section, scrub: true
- Track scroll progress (0 to 1) and map to active step index
- React state for activeStep, driven by ScrollTrigger onUpdate
- Cards use Framer Motion for enter/exit transitions
- 3D scene reads activeStep and interpolates object positions with lerp
```

### Feature cards / Social proof — NO 3D

Clean 2D glassmorphic cards with subtle hover effects. 
Not everything needs to be 3D — restraint is premium.
Subtle backdrop-blur, thin warm border, gentle lift on hover.

### Final CTA section

One or two hobby models from the hero drift gently into view, slightly larger now, warmly lit — a visual callback. A subtle radial gradient glow behind the CTA button area. The feeling: "your hobby is right here, waiting."

NO plasma, NO orbs, NO particle convergence effects.

---

## Animation principles

- **Cinematic pacing** — Not everything moves at once. Orchestrated reveals.
- **Scroll-driven** — The page is a JOURNEY. The How It Works section SCRUBS with scroll.
- **Ease curves** — Custom cubic-bezier, never linear. Elastic for playful, smooth for premium.
- **Entrance animations** — Elements fade-up with slight Y translation. Staggered. Never instant.
- **Parallax** — Subtle depth layers. Background moves slower than foreground.
- **Micro-interactions** — Buttons glow on hover. Cards lift. CTAs pulse subtly.
- **Performance** — Use `will-change`, `transform` only, GPU-accelerated. No layout thrashing.

## Layout principles

- **Breathing room** — Massive padding between sections. Let content breathe.
- **Vertical rhythm** — Consistent spacing scale (8px base, 16, 24, 32, 48, 64, 96, 128).
- **Full-viewport sections** — Each major section is roughly 100vh, creating a cinematic feel.
- **Asymmetric grids** — Not everything centered. Offset text with 3D elements.
- **Max-width for text** — Headlines max ~800px, body max ~600px. Never wall-to-wall text.

## What NOT to do

- ❌ Crowded layouts with too many elements
- ❌ Stock photos or generic illustrations
- ❌ Startup clichés ("revolutionize", "disrupt", blue/purple gradient hero)
- ❌ Too many CTAs — one primary CTA, repeated strategically
- ❌ Feature grids that look like every other SaaS page
- ❌ Animations that are flashy but don't serve the story
- ❌ Light mode — this page is dark, confident, premium
- ❌ Generic AI aesthetics — no Inter font, no rounded-everything, no pastel cards
- ❌ Code-generated SVG icons for hobbies — they always look cheap
- ❌ Abstract plasma, orbs, blobs, or particle effects

## Sections (in order)

1. **Hero** — Three.js scene with real .glb hobby models floating + headline + single CTA. "Discover the hobby you were made for." Max 2 sentences. 3D is background atmosphere, text is the star.
2. **The problem** — Brief emotional hook. "You've been meaning to start something new..." Scroll-triggered text reveals.
3. **How it works** — SCROLL-PINNED section using GSAP ScrollTrigger pin:true. Section stays fixed in viewport. 3-4 step cards on left, only active one highlighted. 3D visualization on right transitions per step. User scrolls THROUGH this section but it stays pinned.
4. **Features** — 3 key features with glassmorphic cards. AI matching, step-by-step roadmaps, personal coaching. NO 3D here — restraint.
5. **Social proof** — Testimonials or stats as minimal glass cards. Short and punchy.
6. **CTA** — Closing moment with 1-2 hobby models drifting back as callback. Warm glow. "Your next chapter starts now."
7. **Footer** — Minimal, elegant, dark.

## The "amazement" moments

- The hero scene with REAL 3D hobby objects floating weightlessly
- The scroll-pinned How It Works that scrubs smoothly as you scroll — feels like controlling a presentation
- Text reveals with cinematic timing
- The warm ambient glow building toward the CTA
- The feeling that this isn't a template — it's a crafted experience