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
