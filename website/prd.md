# TrySomething — Premium Landing Page PRD

## Vision
A dark, cinematic, Three.js-powered landing page that feels like a luxury product experience.
Every element earns its place. The 3D isn't decoration — it's the storytelling medium.

## Tasks

```json
[
  {
    "category": "setup",
    "description": "Install Three.js ecosystem and animation dependencies",
    "steps": [
      "Install @react-three/fiber @react-three/drei @react-three/postprocessing three",
      "Install framer-motion and gsap",
      "Install @studio-freight/lenis for smooth scrolling",
      "Verify dev server starts with no errors",
      "Verify build passes"
    ],
    "passes": true
  },
  {
    "category": "setup",
    "description": "Set up dark premium theme foundation — typography, colors, global styles",
    "steps": [
      "Import premium Google Fonts (a distinctive display serif + clean sans body) via next/font",
      "Configure tailwind.config.ts with dark color palette: near-black backgrounds (#0A0A0F), warm gold/amber accent, crisp white text, muted secondary text",
      "Set up CSS variables for glow colors and Three.js-adjacent effects",
      "Apply global dark background, smooth font rendering (antialiased), selection color",
      "Set up Lenis smooth scroll provider wrapping the app",
      "Screenshot and verify: dark background, premium fonts loaded, smooth scrolling works"
    ],
    "passes": true
  },
  {
    "category": "feature",
    "description": "Build the Three.js hero particle scene — the centerpiece",
    "steps": [
      "Create src/components/three/HeroScene.tsx with React Three Fiber Canvas",
      "Lazy-load the Canvas with next/dynamic ssr:false and a beautiful loading state",
      "Build a shader-based particle system: thousands of softly glowing particles floating in 3D space",
      "Particles should respond to mouse movement (subtle displacement/attraction)",
      "Use warm color palette for particles (golds, ambers, soft whites) against the dark background",
      "Add subtle post-processing: light bloom and very subtle film grain",
      "Target 60fps — use instanced mesh or buffer geometry for performance",
      "Screenshot and verify: particles render, glow is visible, dark background, feels premium not cheap"
    ],
    "passes": true
  },
  {
    "category": "feature",
    "description": "Build the Hero section — headline, subtext, CTA overlaying the 3D scene",
    "steps": [
      "Create src/components/sections/Hero.tsx",
      "Position the Three.js canvas as full-viewport background behind the text",
      "Add the headline using the display font — large, cinematic, distinctive",
      "Add a short compelling subtitle (max 2 lines)",
      "Add a single primary CTA button with a premium hover effect (subtle glow, scale)",
      "Use Framer Motion for staggered text entrance animation (fade up with delay)",
      "Ensure text is readable over the particle background (consider subtle text shadow or gradient overlay)",
      "Check mobile layout — text should resize fluidly, CTA should be thumb-friendly",
      "Screenshot desktop and mobile — verify it looks like a luxury product launch, not a SaaS template"
    ],
    "passes": true
  },
  {
    "category": "feature",
    "description": "Build the Problem section — emotional scroll-triggered text reveals",
    "steps": [
      "Create src/components/sections/Problem.tsx",
      "Short emotional copy: address the pain point of wanting something new but never starting",
      "Use scroll-triggered text reveals — lines or words that fade in as user scrolls into view",
      "Use Framer Motion useInView + staggered children animations",
      "Generous vertical padding — this section breathes",
      "Typography: large, impactful text, possibly with accent-colored keywords",
      "Subtle separator or transition from the hero (gradient fade, not a hard line)",
      "Screenshot and verify: text reveals smoothly on scroll, spacing is generous, feels cinematic"
    ],
    "passes": true
  },
  {
    "category": "feature",
    "description": "Build the How It Works section with Three.js journey visualization",
    "steps": [
      "Create src/components/sections/HowItWorks.tsx",
      "Create a Three.js scene showing the 4-step journey: Discover → Match → Roadmap → Grow",
      "Option A: A 3D path/ribbon that the camera follows as user scrolls, with waypoints",
      "Option B: Floating 3D icons/abstract shapes for each step that animate in sequence",
      "Option C: A morphing particle system that transforms shape for each step",
      "Pick whichever approach creates the most premium, achievable result",
      "Each step has: a number, a short title, a one-line description",
      "Text and 3D should coexist — asymmetric layout, text on one side, 3D on the other",
      "Scroll-driven progression — each step reveals as user scrolls through",
      "Screenshot and verify: clear storytelling, premium feel, 3D adds value not noise"
    ],
    "passes": true
  },
  {
    "category": "feature",
    "description": "Build the Features section — three key features with subtle 3D accents",
    "steps": [
      "Create src/components/sections/Features.tsx",
      "Three features: AI Matching, Step-by-Step Roadmaps, Personal AI Coach",
      "Each feature gets: an icon or abstract 3D element, a headline, 2-3 lines of description",
      "Layout: NOT a grid of 3 cards. Use an asymmetric or stacked layout with staggered reveals",
      "Subtle glassmorphism or border-glow effect on feature containers",
      "Scroll-triggered entrance animations per feature",
      "Keep it minimal — 3 features, not 12. Quality over quantity.",
      "Screenshot and verify: features are scannable, the layout breaks from generic, feels designed"
    ],
    "passes": true
  },
  {
    "category": "feature",
    "description": "Build the Social Proof section — minimal testimonials or stats",
    "steps": [
      "Create src/components/sections/SocialProof.tsx",
      "Option A: 2-3 short testimonial quotes with attribution",
      "Option B: 3 impressive stats (users matched, hobbies started, satisfaction %)",
      "Floating glass-card aesthetic — subtle backdrop blur, warm border glow",
      "Gentle 3D tilt on hover using CSS perspective transforms",
      "Staggered scroll-reveal entrance",
      "This section is short and punchy — not a wall of testimonials",
      "Screenshot and verify: elegant, trustworthy, premium card design"
    ],
    "passes": false
  },
  {
    "category": "feature",
    "description": "Build the final CTA section — the grand convergence moment",
    "steps": [
      "Create src/components/sections/FinalCTA.tsx",
      "A full-viewport section with a powerful closing message",
      "Optional: subtle Three.js effect — particles or light converging to a warm focal point",
      "Large headline: something like 'Your next chapter starts now'",
      "Same CTA button style as hero, but larger and more prominent here",
      "Warm ambient glow effect behind the CTA area",
      "This is the climax of the page — it should feel like everything has built to this moment",
      "Screenshot and verify: compelling, warm, inviting, clear call to action"
    ],
    "passes": false
  },
  {
    "category": "feature",
    "description": "Build the Footer — minimal, elegant, dark",
    "steps": [
      "Create src/components/sections/Footer.tsx",
      "Keep it extremely minimal: logo/name, a few links, copyright",
      "Very subtle divider line or gradient separator from the CTA section",
      "Muted text colors — the footer fades out, it doesn't compete",
      "Screenshot and verify: clean, minimal, doesn't distract from the CTA above"
    ],
    "passes": false
  },
  {
    "category": "polish",
    "description": "Compose all sections into the main page with smooth scroll transitions",
    "steps": [
      "Wire all sections into the main page component in the correct order",
      "Ensure Lenis smooth scrolling works across the entire page",
      "Add smooth transitions between sections (gradient fades, no hard lines)",
      "Verify the complete scroll experience from hero to footer feels like a journey",
      "Test full-page performance: should maintain smooth scrolling, no jank",
      "Screenshot the full page at multiple scroll positions",
      "Verify on mobile: all sections stack properly, 3D degrades gracefully"
    ],
    "passes": false
  },
  {
    "category": "polish",
    "description": "Performance optimization and WebGL fallback",
    "steps": [
      "Verify Lighthouse performance score is decent (aim for 70+)",
      "Ensure Three.js Canvas is lazy-loaded (no SSR)",
      "Add a fallback for devices without WebGL: a CSS gradient + subtle CSS animation",
      "Ensure fonts are preloaded and don't cause layout shift",
      "Verify images use next/image with proper sizing",
      "Test mobile performance — reduce particle count on mobile if needed",
      "Screenshot and verify everything still looks premium after optimizations"
    ],
    "passes": false
  },
  {
    "category": "polish",
    "description": "Final review — scroll through entire page, screenshot everything, fix any issues",
    "steps": [
      "Navigate through the entire page slowly with Playwright",
      "Screenshot every section (desktop): hero, problem, how-it-works, features, social-proof, cta, footer",
      "Screenshot every section (mobile 390px): same sections",
      "Review ALL screenshots critically for: typography consistency, spacing, color, alignment, premium feel",
      "Fix any visual issues found in the review",
      "Ensure build passes with no warnings",
      "Final screenshot of hero section — this is the money shot"
    ],
    "passes": false
  }
]
```
