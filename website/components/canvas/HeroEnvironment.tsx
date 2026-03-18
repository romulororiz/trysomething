"use client";

import { Suspense, useRef, useMemo, useCallback } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import * as THREE from "three";

/* ─── Instanced Particle Field ───────────────────────────────── */

const PARTICLE_COUNT = 150;

function ParticleField() {
  const meshRef = useRef<THREE.InstancedMesh>(null);
  const dummy = useMemo(() => new THREE.Object3D(), []);

  const particles = useMemo(() => {
    const data: {
      x: number; y: number; z: number;
      baseY: number;
      speed: number;
      phase: number;
      size: number;
      brightness: number;
    }[] = [];

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      const x = (Math.random() - 0.5) * 24;
      const y = (Math.random() - 0.5) * 14;
      const z = -2 - Math.random() * 12;

      data.push({
        x, y, z,
        baseY: y,
        speed: 0.08 + Math.random() * 0.15,
        phase: Math.random() * Math.PI * 2,
        size: 0.01 + Math.random() * 0.025,
        brightness: 0.3 + Math.random() * 0.7,
      });
    }
    return data;
  }, []);

  useFrame((state) => {
    if (!meshRef.current) return;
    const t = state.clock.elapsedTime;

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      const p = particles[i];
      const y = p.baseY + Math.sin(t * p.speed + p.phase) * 0.2;
      const x = p.x + Math.sin(t * 0.02 + p.phase) * 0.1;

      dummy.position.set(x, y, p.z);
      dummy.scale.setScalar(p.size);
      dummy.updateMatrix();
      meshRef.current.setMatrixAt(i, dummy.matrix);
    }
    meshRef.current.instanceMatrix.needsUpdate = true;
  });

  return (
    <instancedMesh ref={meshRef} args={[undefined, undefined, PARTICLE_COUNT]}>
      <sphereGeometry args={[1, 6, 6]} />
      <meshBasicMaterial color="#F0EBE3" transparent opacity={0.5} />
    </instancedMesh>
  );
}

/* ─── Subtle mouse parallax ──────────────────────────────────── */

function CameraRig() {
  const { camera } = useThree();
  const mouse = useRef({ x: 0, y: 0 });
  const smooth = useRef({ x: 0, y: 0 });
  const attached = useRef(false);

  const onMove = useCallback((e: MouseEvent) => {
    mouse.current.x = (e.clientX / window.innerWidth - 0.5) * 2;
    mouse.current.y = (e.clientY / window.innerHeight - 0.5) * 2;
  }, []);

  if (typeof window !== "undefined" && !attached.current) {
    window.addEventListener("mousemove", onMove, { passive: true });
    attached.current = true;
  }

  useFrame(() => {
    smooth.current.x += (mouse.current.x - smooth.current.x) * 0.02;
    smooth.current.y += (mouse.current.y - smooth.current.y) * 0.02;
    camera.position.x = smooth.current.x * 0.3;
    camera.position.y = -smooth.current.y * 0.2;
    camera.lookAt(0, 0, -5);
  });

  return null;
}

/* ─── Scene ──────────────────────────────────────────────────── */

function Scene() {
  return (
    <>
      <ambientLight intensity={0.2} />
      <pointLight position={[8, 6, 4]} intensity={0.4} color="#F0EBE3" />
      <pointLight position={[-6, -3, 2]} intensity={0.2} color="#0D9488" />
      <ParticleField />
      <CameraRig />
    </>
  );
}

/* ─── Fallback ───────────────────────────────────────────────── */

function FallbackBackground() {
  return (
    <div className="absolute inset-0">
      {Array.from({ length: 30 }).map((_, i) => (
        <div
          key={i}
          className="absolute w-px h-px bg-text-primary/40 rounded-full"
          style={{
            left: `${Math.random() * 100}%`,
            top: `${Math.random() * 100}%`,
          }}
        />
      ))}
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
          gl={{ antialias: true, alpha: true, powerPreference: "high-performance" }}
          style={{ background: "transparent" }}
        >
          <Scene />
        </Canvas>
      </Suspense>

      {/* Atmospheric color washes — CSS only, subtle */}
      <div className="absolute top-0 left-0 w-[500px] h-[500px] -translate-x-1/4 -translate-y-1/4 pointer-events-none" style={{ background: "radial-gradient(ellipse at center, rgba(13,148,136,0.07), transparent 70%)" }} />
      <div className="absolute bottom-0 right-0 w-[500px] h-[500px] translate-x-1/4 translate-y-1/4 pointer-events-none" style={{ background: "radial-gradient(ellipse at center, rgba(159,18,57,0.05), transparent 70%)" }} />

      {/* Vignette */}
      <div className="absolute inset-0 pointer-events-none" style={{
        background: "radial-gradient(ellipse at center, transparent 30%, var(--color-bg) 100%)",
      }} />
      <div className="absolute inset-0 bg-gradient-to-b from-bg/20 via-transparent to-bg/60 pointer-events-none" />
    </div>
  );
}
