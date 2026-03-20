# Code Conventions

## Component structure
- One component per file, PascalCase naming
- Three.js scenes in `src/components/three/`
- UI sections in `src/components/sections/`
- Shared UI primitives in `src/components/ui/`

## Three.js / R3F patterns
- Use React Three Fiber (`@react-three/fiber`) — never raw Three.js in React
- Drei helpers (`@react-three/drei`) for common abstractions
- Post-processing via `@react-three/postprocessing`
- Custom shaders as separate `.glsl` files or inline template literals
- Wrap 3D scenes in `<Suspense>` with a loading fallback
- Use `useFrame` for animation loops, not `requestAnimationFrame`

## Animation patterns
- Framer Motion for DOM element animations (fade, slide, stagger)
- GSAP ScrollTrigger for scroll-driven sequencing
- R3F `useFrame` for Three.js animation loops
- Use `useInView` from Framer Motion for scroll-triggered reveals

## Performance
- Lazy-load Three.js canvas with `next/dynamic` and `ssr: false`
- Use `<Canvas dpr={[1, 2]}>` to cap pixel ratio
- Dispose geometries and materials in cleanup
- Keep draw calls under 100 for the hero scene
- Image optimization: use `next/image` for all images

## Tailwind usage
- Custom theme colors in `tailwind.config.ts`
- Use CSS variables for Three.js-adjacent colors (glow, accent)
- Clamp-based fluid typography: `text-[clamp(2rem,5vw,4rem)]`
