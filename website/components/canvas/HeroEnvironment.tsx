"use client";

import { Suspense, useRef, useMemo, useEffect, useCallback } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import * as THREE from "three";

/* ─── Config ─────────────────────────────────────────────────── */

const PARTICLE_COUNT = 500;

/* ─── Shaders ────────────────────────────────────────────────── */

const vertexShader = /* glsl */ `
  attribute float aSize;
  attribute vec3 aColor;
  attribute float aPhase;

  varying vec3 vColor;
  varying float vAlpha;

  uniform float uTime;
  uniform float uPixelRatio;

  void main() {
    vec3 pos = position;

    // Organic drift
    float t = uTime * 0.25;
    pos.y += sin(t + aPhase * 6.28) * 0.18;
    pos.x += cos(t * 0.6 + aPhase * 4.0) * 0.1;
    pos.z += sin(t * 0.4 + aPhase * 3.0) * 0.06;

    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);

    // Size: larger when closer, breathing effect
    float breathe = 1.0 + sin(t * 1.8 + aPhase * 6.28) * 0.25;
    float size = aSize * breathe * uPixelRatio;
    gl_PointSize = size * (280.0 / -mvPosition.z);

    gl_Position = projectionMatrix * mvPosition;

    vColor = aColor;
    // Depth-based fade: closer = more visible
    float depthFade = smoothstep(-18.0, -2.0, mvPosition.z);
    float pulse = 0.6 + sin(t * 1.5 + aPhase * 6.28) * 0.15;
    vAlpha = depthFade * pulse;
  }
`;

const fragmentShader = /* glsl */ `
  varying vec3 vColor;
  varying float vAlpha;

  void main() {
    // Distance from center of point sprite
    vec2 uv = gl_PointCoord - vec2(0.5);
    float d = length(uv);
    if (d > 0.5) discard;

    // Soft glow: bright core fading to soft halo
    float glow = exp(-d * 6.0);
    float core = smoothstep(0.12, 0.0, d) * 0.5;
    float alpha = (glow * 0.7 + core) * vAlpha;

    gl_FragColor = vec4(vColor, alpha);
  }
`;

/* ─── Shader Particle Field ──────────────────────────────────── */

function GlowParticles() {
  const pointsRef = useRef<THREE.Points>(null);

  const uniforms = useMemo(
    () => ({
      uTime: { value: 0 },
      uPixelRatio: { value: 1.5 },
    }),
    [],
  );

  const geometry = useMemo(() => {
    const positions = new Float32Array(PARTICLE_COUNT * 3);
    const sizes = new Float32Array(PARTICLE_COUNT);
    const colors = new Float32Array(PARTICLE_COUNT * 3);
    const phases = new Float32Array(PARTICLE_COUNT);

    // Warm palette: golds, ambers, soft creams
    const palette = [
      new THREE.Color("#F0EBE3"), // Warm cream
      new THREE.Color("#F0EBE3"), // Warm cream (weighted)
      new THREE.Color("#D4A574"), // Warm gold
      new THREE.Color("#C8956C"), // Amber
      new THREE.Color("#E8D5B7"), // Light gold
      new THREE.Color("#F5E6D3"), // Pale amber
      new THREE.Color("#DAA520"), // Goldenrod accent
    ];

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      // Spherical distribution with denser center
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(2 * Math.random() - 1);
      const r = Math.pow(Math.random(), 0.5) * 13;

      positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
      positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta) * 0.65;
      positions[i * 3 + 2] = -2 - r * Math.cos(phi) * 0.4;

      // Varying sizes — some tiny stars, some larger glows
      const sizeRand = Math.random();
      sizes[i] = sizeRand < 0.7 ? 1.5 + Math.random() * 3 : 4 + Math.random() * 6;

      phases[i] = Math.random();

      const color = palette[Math.floor(Math.random() * palette.length)];
      colors[i * 3] = color.r;
      colors[i * 3 + 1] = color.g;
      colors[i * 3 + 2] = color.b;
    }

    const geo = new THREE.BufferGeometry();
    geo.setAttribute("position", new THREE.BufferAttribute(positions, 3));
    geo.setAttribute("aSize", new THREE.BufferAttribute(sizes, 1));
    geo.setAttribute("aColor", new THREE.BufferAttribute(colors, 3));
    geo.setAttribute("aPhase", new THREE.BufferAttribute(phases, 1));
    return geo;
  }, []);

  useFrame((state) => {
    if (!pointsRef.current) return;
    const material = pointsRef.current.material as THREE.ShaderMaterial;
    material.uniforms.uTime.value = state.clock.elapsedTime;
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

/* ─── Mouse-driven camera parallax ──────────────────────────── */

function CameraRig() {
  const { camera } = useThree();
  const mouse = useRef({ x: 0, y: 0 });
  const smooth = useRef({ x: 0, y: 0 });

  const onMove = useCallback((e: MouseEvent) => {
    mouse.current.x = (e.clientX / window.innerWidth - 0.5) * 2;
    mouse.current.y = (e.clientY / window.innerHeight - 0.5) * 2;
  }, []);

  useEffect(() => {
    window.addEventListener("mousemove", onMove, { passive: true });
    return () => window.removeEventListener("mousemove", onMove);
  }, [onMove]);

  useFrame(() => {
    smooth.current.x += (mouse.current.x - smooth.current.x) * 0.025;
    smooth.current.y += (mouse.current.y - smooth.current.y) * 0.025;
    camera.position.x = smooth.current.x * 0.5;
    camera.position.y = -smooth.current.y * 0.35;
    camera.lookAt(0, 0, -5);
  });

  return null;
}

/* ─── Scene ──────────────────────────────────────────────────── */

function Scene() {
  return (
    <>
      <GlowParticles />
      <CameraRig />
    </>
  );
}

/* ─── CSS Fallback (no WebGL) ────────────────────────────────── */

function FallbackBackground() {
  return (
    <div className="absolute inset-0">
      {Array.from({ length: 50 }).map((_, i) => {
        const size = 1 + Math.random() * 3;
        return (
          <div
            key={i}
            className="absolute rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              width: `${size}px`,
              height: `${size}px`,
              background: `rgba(212, 165, 116, ${0.15 + Math.random() * 0.3})`,
              filter: "blur(1px)",
              animation: `breathe ${3 + Math.random() * 4}s ease-in-out infinite`,
              animationDelay: `${Math.random() * 3}s`,
            }}
          />
        );
      })}
    </div>
  );
}

/* ─── Export ──────────────────────────────────────────────────── */

export function HeroEnvironment() {
  return (
    <div className="absolute inset-0 -z-10">
      <Suspense fallback={<FallbackBackground />}>
        <Canvas
          camera={{ position: [0, 0, 8], fov: 50 }}
          dpr={[1, 1.5]}
          gl={{
            antialias: false,
            alpha: true,
            powerPreference: "high-performance",
          }}
          style={{ background: "transparent" }}
        >
          <Scene />
        </Canvas>
      </Suspense>

      {/* Warm atmospheric washes */}
      <div
        className="absolute top-[-10%] left-[-5%] w-[600px] h-[600px] pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(212,165,116,0.06), transparent 70%)",
        }}
      />
      <div
        className="absolute bottom-[-10%] right-[-5%] w-[500px] h-[500px] pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(200,149,108,0.04), transparent 70%)",
        }}
      />

      {/* Vignette */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, transparent 25%, var(--color-bg) 100%)",
        }}
      />
      <div className="absolute inset-0 bg-gradient-to-b from-bg/10 via-transparent to-bg/70 pointer-events-none" />
    </div>
  );
}
