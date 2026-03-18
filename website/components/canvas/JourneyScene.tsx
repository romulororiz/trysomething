"use client";

import { Suspense, useRef, useMemo, useEffect, useState } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import * as THREE from "three";

/* ─── Config ─────────────────────────────────────────────────── */

const PARTICLE_COUNT = 200;

/* Step shapes: each step morphs particles into a different form */
const SHAPES = {
  // Step 1: Match — scattered expanding ring (discovery/search)
  match: (i: number, total: number) => {
    const angle = (i / total) * Math.PI * 2;
    const ringJitter = Math.sin(i * 1.7) * 0.3;
    const radius = 1.6 + ringJitter;
    const y = Math.sin(angle * 3) * 0.25;
    return new THREE.Vector3(
      Math.cos(angle) * radius,
      y,
      Math.sin(angle) * radius * 0.4
    );
  },
  // Step 2: Start — converging upward helix (beginning a journey)
  start: (i: number, total: number) => {
    const t = i / total;
    const angle = t * Math.PI * 5;
    const radius = 1.2 * (1 - t * 0.4);
    return new THREE.Vector3(
      Math.cos(angle) * radius,
      t * 2.8 - 1.4,
      Math.sin(angle) * radius * 0.4
    );
  },
  // Step 3: Stay — stable warm sphere (momentum/consistency)
  stay: (i: number, total: number) => {
    const phi = Math.acos(2 * (i / total) - 1);
    const theta = Math.sqrt(total * Math.PI) * phi;
    const r = 1.5;
    return new THREE.Vector3(
      r * Math.sin(phi) * Math.cos(theta),
      r * Math.sin(phi) * Math.sin(theta),
      r * Math.cos(phi) * 0.35
    );
  },
};

const SHAPE_KEYS = ["match", "start", "stay"] as const;

/* ─── Shaders ────────────────────────────────────────────────── */

const vertexShader = /* glsl */ `
  attribute float aSize;
  attribute vec3 aColor;
  attribute float aPhase;
  attribute vec3 aTarget;

  varying vec3 vColor;
  varying float vAlpha;

  uniform float uTime;
  uniform float uPixelRatio;
  uniform float uTransition;

  void main() {
    // Lerp toward target position
    vec3 pos = mix(position, aTarget, uTransition);

    // Organic drift
    float t = uTime * 0.25;
    pos.y += sin(t + aPhase * 6.28) * 0.06;
    pos.x += cos(t * 0.6 + aPhase * 4.0) * 0.04;
    pos.z += sin(t * 0.4 + aPhase * 3.0) * 0.03;

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);

    float breathe = 1.0 + sin(t * 1.2 + aPhase * 6.28) * 0.2;
    float size = aSize * breathe * uPixelRatio;
    gl_PointSize = size * (100.0 / -mvPosition.z);

    gl_Position = projectionMatrix * mvPosition;

    vColor = aColor;
    float depthFade = smoothstep(-14.0, -1.0, mvPosition.z);
    float pulse = 0.5 + sin(t * 1.0 + aPhase * 6.28) * 0.15;
    vAlpha = depthFade * pulse;
  }
`;

const fragmentShader = /* glsl */ `
  varying vec3 vColor;
  varying float vAlpha;

  void main() {
    vec2 uv = gl_PointCoord - vec2(0.5);
    float d = length(uv);
    if (d > 0.5) discard;

    // Soft glow with warm core
    float glow = exp(-d * 5.0);
    float core = smoothstep(0.1, 0.0, d) * 0.5;
    float alpha = (glow * 0.6 + core) * vAlpha;

    gl_FragColor = vec4(vColor, alpha);
  }
`;

/* ─── Step palettes (warm gold/amber tones per step) ─────────── */

const STEP_PALETTES = [
  // Match: warm teal/sage (discovery)
  [
    new THREE.Color("#7DBDAB"),
    new THREE.Color("#5A9E8F"),
    new THREE.Color("#A8D4C8"),
    new THREE.Color("#D4C9B0"),
  ],
  // Start: coral/warm (action)
  [
    new THREE.Color("#E88B7A"),
    new THREE.Color("#D4756E"),
    new THREE.Color("#F0A899"),
    new THREE.Color("#D4C9B0"),
  ],
  // Stay: gold/amber (momentum)
  [
    new THREE.Color("#DAA520"),
    new THREE.Color("#C8A045"),
    new THREE.Color("#E8C870"),
    new THREE.Color("#D4C9B0"),
  ],
];

/* ─── Journey Particles ──────────────────────────────────────── */

interface JourneyParticlesProps {
  activeStep: number;
}

function JourneyParticles({ activeStep }: JourneyParticlesProps) {
  const pointsRef = useRef<THREE.Points>(null);
  const transitionRef = useRef(1);

  const uniforms = useMemo(
    () => ({
      uTime: { value: 0 },
      uPixelRatio: { value: 1.5 },
      uTransition: { value: 1 },
    }),
    []
  );

  // Build initial geometry for step 0
  const geometry = useMemo(() => {
    const positions = new Float32Array(PARTICLE_COUNT * 3);
    const targets = new Float32Array(PARTICLE_COUNT * 3);
    const sizes = new Float32Array(PARTICLE_COUNT);
    const colors = new Float32Array(PARTICLE_COUNT * 3);
    const phases = new Float32Array(PARTICLE_COUNT);

    const shapeFn = SHAPES[SHAPE_KEYS[0]];
    const palette = STEP_PALETTES[0];

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      const pos = shapeFn(i, PARTICLE_COUNT);

      // Start scattered
      positions[i * 3] = (Math.random() - 0.5) * 5;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 4;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 2;

      targets[i * 3] = pos.x;
      targets[i * 3 + 1] = pos.y;
      targets[i * 3 + 2] = pos.z;

      const sizeRand = Math.random();
      sizes[i] =
        sizeRand < 0.6
          ? 1.5 + Math.random() * 2
          : sizeRand < 0.9
            ? 3 + Math.random() * 2.5
            : 5 + Math.random() * 2;

      phases[i] = Math.random();

      const color = palette[Math.floor(Math.random() * palette.length)];
      colors[i * 3] = color.r;
      colors[i * 3 + 1] = color.g;
      colors[i * 3 + 2] = color.b;
    }

    const geo = new THREE.BufferGeometry();
    geo.setAttribute("position", new THREE.BufferAttribute(positions, 3));
    geo.setAttribute("aTarget", new THREE.BufferAttribute(targets, 3));
    geo.setAttribute("aSize", new THREE.BufferAttribute(sizes, 1));
    geo.setAttribute("aColor", new THREE.BufferAttribute(colors, 3));
    geo.setAttribute("aPhase", new THREE.BufferAttribute(phases, 1));
    return geo;
  }, []);

  // When activeStep changes, update target positions and colors
  useEffect(() => {
    if (!pointsRef.current) return;
    const geo = pointsRef.current.geometry;
    const posAttr = geo.getAttribute("position") as THREE.BufferAttribute;
    const targetAttr = geo.getAttribute("aTarget") as THREE.BufferAttribute;
    const colorAttr = geo.getAttribute("aColor") as THREE.BufferAttribute;

    const clampedStep = Math.min(activeStep, SHAPE_KEYS.length - 1);
    const shapeFn = SHAPES[SHAPE_KEYS[clampedStep]];
    const palette = STEP_PALETTES[clampedStep];

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      // Current target becomes new start position
      posAttr.setXYZ(
        i,
        targetAttr.getX(i),
        targetAttr.getY(i),
        targetAttr.getZ(i)
      );

      // Set new target
      const target = shapeFn(i, PARTICLE_COUNT);
      targetAttr.setXYZ(i, target.x, target.y, target.z);

      // Update colors with smooth palette transition
      const color = palette[Math.floor(Math.random() * palette.length)];
      colorAttr.setXYZ(i, color.r, color.g, color.b);
    }

    posAttr.needsUpdate = true;
    targetAttr.needsUpdate = true;
    colorAttr.needsUpdate = true;

    // Reset transition
    transitionRef.current = 0;
  }, [activeStep, geometry]);

  useFrame((state) => {
    if (!pointsRef.current) return;
    const mat = pointsRef.current.material as THREE.ShaderMaterial;
    mat.uniforms.uTime.value = state.clock.elapsedTime;

    // Smooth transition
    transitionRef.current = Math.min(transitionRef.current + 0.012, 1);
    mat.uniforms.uTransition.value = easeOutCubic(transitionRef.current);

    // Gentle rotation
    pointsRef.current.rotation.y += 0.0008;
  });

  return (
    <points ref={pointsRef} geometry={geometry}>
      <shaderMaterial
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={uniforms}
        transparent
        depthWrite={false}
        blending={THREE.AdditiveBlending}
      />
    </points>
  );
}

function easeOutCubic(t: number): number {
  return 1 - Math.pow(1 - t, 3);
}

/* ─── CSS Fallback ───────────────────────────────────────────── */

function FallbackVisual() {
  return (
    <div className="absolute inset-0 flex items-center justify-center">
      <div
        className="w-48 h-48 rounded-full opacity-20"
        style={{
          background:
            "radial-gradient(circle, rgba(218,165,32,0.3), transparent 70%)",
          filter: "blur(40px)",
        }}
      />
    </div>
  );
}

/* ─── Export ──────────────────────────────────────────────────── */

interface JourneySceneProps {
  activeStep: number;
}

export function JourneyScene({ activeStep }: JourneySceneProps) {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return <FallbackVisual />;

  return (
    <div className="w-full h-full relative">
      <Suspense fallback={<FallbackVisual />}>
        <Canvas
          camera={{ position: [0, 0, 5], fov: 45 }}
          dpr={[1, 1.5]}
          gl={{
            antialias: false,
            alpha: true,
            powerPreference: "high-performance",
          }}
          style={{ background: "transparent" }}
        >
          <JourneyParticles activeStep={activeStep} />
        </Canvas>
      </Suspense>

      {/* Warm glow wash behind particles */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(218,165,32,0.04), transparent 70%)",
        }}
      />
    </div>
  );
}
