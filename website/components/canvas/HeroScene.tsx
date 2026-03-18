"use client";

import { Suspense, useRef, useMemo } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { Float, MeshDistortMaterial } from "@react-three/drei";
import * as THREE from "three";

function Orb({
  position,
  color,
  scale,
  speed,
  distort,
  opacity,
}: {
  position: [number, number, number];
  color: string;
  scale: number;
  speed: number;
  distort: number;
  opacity: number;
}) {
  return (
    <Float speed={speed} rotationIntensity={0.3} floatIntensity={1.2}>
      <mesh position={position} scale={scale}>
        <sphereGeometry args={[1, 48, 48]} />
        <MeshDistortMaterial
          color={color}
          transparent
          opacity={opacity}
          distort={distort}
          speed={1.2}
          roughness={0.3}
          metalness={0.1}
        />
      </mesh>
    </Float>
  );
}

function Particles({ count = 80 }: { count?: number }) {
  const mesh = useRef<THREE.Points>(null);

  const [positions, sizes] = useMemo(() => {
    const pos = new Float32Array(count * 3);
    const sz = new Float32Array(count);
    for (let i = 0; i < count; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 20;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 12;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 10 - 3;
      sz[i] = Math.random() * 2 + 0.5;
    }
    return [pos, sz];
  }, [count]);

  useFrame((state) => {
    if (!mesh.current) return;
    const time = state.clock.elapsedTime * 0.15;
    const posArr = mesh.current.geometry.attributes.position
      .array as Float32Array;
    for (let i = 0; i < count; i++) {
      posArr[i * 3 + 1] += Math.sin(time + i * 0.5) * 0.002;
    }
    mesh.current.geometry.attributes.position.needsUpdate = true;
  });

  return (
    <points ref={mesh}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          args={[positions, 3]}
        />
        <bufferAttribute
          attach="attributes-size"
          args={[sizes, 1]}
        />
      </bufferGeometry>
      <pointsMaterial
        color="#F0EBE3"
        size={0.03}
        transparent
        opacity={0.4}
        sizeAttenuation
        depthWrite={false}
      />
    </points>
  );
}

function Scene() {
  return (
    <>
      <ambientLight intensity={0.3} />
      <pointLight position={[8, 6, 5]} intensity={0.8} color="#F0EBE3" />
      <pointLight position={[-6, -4, 3]} intensity={0.4} color="#0D9488" />

      {/* Teal orb — top left */}
      <Orb
        position={[-4, 2.5, -4]}
        color="#0D9488"
        scale={3}
        speed={0.8}
        distort={0.35}
        opacity={0.12}
      />

      {/* Burgundy orb — bottom right */}
      <Orb
        position={[4, -1.5, -5]}
        color="#9F1239"
        scale={2.5}
        speed={0.6}
        distort={0.3}
        opacity={0.1}
      />

      {/* Coral orb — center back */}
      <Orb
        position={[0, 1, -6]}
        color="#FF6B6B"
        scale={2}
        speed={1}
        distort={0.4}
        opacity={0.08}
      />

      {/* Small accent orb */}
      <Orb
        position={[6, 3, -7]}
        color="#0D9488"
        scale={1.2}
        speed={1.2}
        distort={0.5}
        opacity={0.06}
      />

      <Particles count={60} />
    </>
  );
}

/** WebGL fallback — CSS gradient version */
function FallbackBackground() {
  return (
    <div className="absolute inset-0">
      <div className="absolute top-0 left-0 w-[600px] h-[600px] bloom-teal opacity-60 -translate-x-1/4 -translate-y-1/4" />
      <div className="absolute bottom-0 right-0 w-[500px] h-[500px] bloom-burgundy opacity-50 translate-x-1/4 translate-y-1/4" />
      <div className="absolute top-1/2 left-1/2 w-[400px] h-[400px] bloom-coral opacity-40 -translate-x-1/2 -translate-y-1/2" />
    </div>
  );
}

export function HeroScene() {
  return (
    <div className="absolute inset-0 -z-10">
      <Suspense fallback={<FallbackBackground />}>
        <Canvas
          camera={{ position: [0, 0, 8], fov: 45 }}
          dpr={[1, 1.5]}
          gl={{ antialias: false, alpha: true, powerPreference: "high-performance" }}
          style={{ background: "transparent" }}
        >
          <Scene />
        </Canvas>
      </Suspense>

      {/* Gradient vignette overlay */}
      <div className="absolute inset-0 bg-gradient-to-b from-bg/30 via-transparent to-bg pointer-events-none" />
      <div className="absolute inset-0 bg-gradient-to-r from-bg/20 via-transparent to-bg/20 pointer-events-none" />
    </div>
  );
}
