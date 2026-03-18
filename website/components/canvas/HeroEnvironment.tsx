"use client";

import { Suspense, useRef, useMemo, useEffect, useCallback, useState } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { Float, Edges } from "@react-three/drei";
import * as THREE from "three";

/* ─── Hobby Object Components ────────────────────────────────── */

interface HobbyObjectProps {
  position: [number, number, number];
  rotation?: [number, number, number];
  scale?: number;
  color?: string;
  floatSpeed?: number;
  rotationIntensity?: number;
}

/** Guitar — torus body + cylinder neck + small circle headstock */
function Guitar({
  position,
  rotation = [0, 0, 0.3],
  scale = 1,
  color = "#DAA520",
  floatSpeed = 0.6,
  rotationIntensity = 0.3,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.6}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Body */}
        <mesh>
          <torusGeometry args={[0.45, 0.22, 8, 16]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Neck */}
        <mesh position={[0, 0.85, 0]}>
          <boxGeometry args={[0.07, 0.9, 0.04]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Headstock */}
        <mesh position={[0, 1.38, 0]}>
          <boxGeometry args={[0.14, 0.16, 0.04]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
      </group>
    </Float>
  );
}

/** Camera — box body + cylinder lens */
function Camera({
  position,
  rotation = [0.2, 0.3, 0],
  scale = 1,
  color = "#E8D5B7",
  floatSpeed = 0.5,
  rotationIntensity = 0.25,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.7}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Body */}
        <mesh>
          <boxGeometry args={[0.7, 0.5, 0.35]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Lens */}
        <mesh position={[0, 0, 0.3]} rotation={[Math.PI / 2, 0, 0]}>
          <cylinderGeometry args={[0.18, 0.15, 0.25, 12]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Viewfinder */}
        <mesh position={[0, 0.32, -0.05]}>
          <boxGeometry args={[0.15, 0.12, 0.15]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
      </group>
    </Float>
  );
}

/** Paintbrush — thin cylinder handle + cone tip */
function Paintbrush({
  position,
  rotation = [0, 0, -0.6],
  scale = 1,
  color = "#C8956C",
  floatSpeed = 0.7,
  rotationIntensity = 0.35,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.5}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Handle */}
        <mesh position={[0, -0.3, 0]}>
          <cylinderGeometry args={[0.04, 0.05, 1.0, 8]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Ferrule */}
        <mesh position={[0, 0.25, 0]}>
          <cylinderGeometry args={[0.06, 0.04, 0.12, 8]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Bristles */}
        <mesh position={[0, 0.45, 0]}>
          <coneGeometry args={[0.07, 0.3, 8]} />
          <meshStandardMaterial color="#FF6B6B" transparent opacity={0.08} roughness={0.6} />
          <Edges threshold={15} color="#FF6B6B" />
        </mesh>
      </group>
    </Float>
  );
}

/** Chess Pawn — lathe geometry for classic silhouette */
function ChessPawn({
  position,
  rotation = [0, 0, 0],
  scale = 1,
  color = "#F0EBE3",
  floatSpeed = 0.4,
  rotationIntensity = 0.2,
}: HobbyObjectProps) {
  const geometry = useMemo(() => {
    const points = [
      new THREE.Vector2(0, 0),
      new THREE.Vector2(0.25, 0),
      new THREE.Vector2(0.28, 0.02),
      new THREE.Vector2(0.28, 0.06),
      new THREE.Vector2(0.22, 0.08),
      new THREE.Vector2(0.10, 0.25),
      new THREE.Vector2(0.08, 0.35),
      new THREE.Vector2(0.12, 0.38),
      new THREE.Vector2(0.12, 0.42),
      new THREE.Vector2(0.08, 0.44),
      new THREE.Vector2(0.06, 0.50),
      new THREE.Vector2(0.10, 0.55),
      new THREE.Vector2(0.14, 0.58),
      new THREE.Vector2(0.14, 0.62),
      new THREE.Vector2(0.10, 0.65),
      new THREE.Vector2(0.0, 0.68),
    ];
    return new THREE.LatheGeometry(points, 12);
  }, []);

  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.6}>
      <group position={position} rotation={rotation} scale={scale}>
        <mesh geometry={geometry}>
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
      </group>
    </Float>
  );
}

/** Book — two angled planes suggesting an open book */
function Book({
  position,
  rotation = [0.2, 0.5, 0.1],
  scale = 1,
  color = "#D4A574",
  floatSpeed = 0.55,
  rotationIntensity = 0.2,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.5}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Left page */}
        <mesh position={[-0.22, 0, 0]} rotation={[0, 0.2, 0]}>
          <boxGeometry args={[0.4, 0.55, 0.02]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Right page */}
        <mesh position={[0.22, 0, 0]} rotation={[0, -0.2, 0]}>
          <boxGeometry args={[0.4, 0.55, 0.02]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Spine */}
        <mesh position={[0, 0, -0.035]}>
          <boxGeometry args={[0.03, 0.55, 0.04]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
      </group>
    </Float>
  );
}

/** Plant Pot — tapered cylinder pot + sphere leaf clusters */
function PlantPot({
  position,
  rotation = [0, 0, 0],
  scale = 1,
  color = "#7DBDAB",
  floatSpeed = 0.45,
  rotationIntensity = 0.15,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.6}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Pot */}
        <mesh>
          <cylinderGeometry args={[0.22, 0.16, 0.35, 8]} />
          <meshStandardMaterial color="#C8956C" transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color="#C8956C" />
        </mesh>
        {/* Rim */}
        <mesh position={[0, 0.18, 0]}>
          <cylinderGeometry args={[0.24, 0.24, 0.04, 8]} />
          <meshStandardMaterial color="#C8956C" transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color="#C8956C" />
        </mesh>
        {/* Leaves — icosahedron clusters */}
        <mesh position={[0, 0.42, 0]}>
          <icosahedronGeometry args={[0.2, 0]} />
          <meshStandardMaterial color={color} transparent opacity={0.08} roughness={0.6} />
          <Edges threshold={10} color={color} />
        </mesh>
        <mesh position={[0.12, 0.52, 0.05]}>
          <icosahedronGeometry args={[0.13, 0]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={10} color={color} />
        </mesh>
        <mesh position={[-0.1, 0.5, -0.06]}>
          <icosahedronGeometry args={[0.11, 0]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={10} color={color} />
        </mesh>
      </group>
    </Float>
  );
}

/** Bicycle Wheel — torus ring + cross spokes */
function BicycleWheel({
  position,
  rotation = [0.4, 0.2, 0],
  scale = 1,
  color = "#E8D5B7",
  floatSpeed = 0.35,
  rotationIntensity = 0.4,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.5}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Rim */}
        <mesh>
          <torusGeometry args={[0.5, 0.03, 8, 24]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Hub */}
        <mesh>
          <cylinderGeometry args={[0.05, 0.05, 0.06, 8]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Spokes — 6 thin cylinders */}
        {[0, 60, 120].map((angle) => (
          <mesh key={angle} rotation={[0, 0, (angle * Math.PI) / 180]}>
            <cylinderGeometry args={[0.008, 0.008, 1.0, 4]} />
            <meshStandardMaterial color={color} transparent opacity={0.15} roughness={0.6} />
          </mesh>
        ))}
      </group>
    </Float>
  );
}

/** Cooking Pot — cylinder body + torus rim + handle arcs */
function CookingPot({
  position,
  rotation = [0.3, -0.2, 0],
  scale = 1,
  color = "#D4A574",
  floatSpeed = 0.5,
  rotationIntensity = 0.2,
}: HobbyObjectProps) {
  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.6}>
      <group position={position} rotation={rotation} scale={scale}>
        {/* Body */}
        <mesh>
          <cylinderGeometry args={[0.32, 0.28, 0.35, 12]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Rim */}
        <mesh position={[0, 0.18, 0]}>
          <torusGeometry args={[0.32, 0.02, 8, 16]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Handle left */}
        <mesh position={[-0.42, 0.08, 0]} rotation={[0, 0, Math.PI / 2]}>
          <torusGeometry args={[0.08, 0.015, 6, 8, Math.PI]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
        {/* Handle right */}
        <mesh position={[0.42, 0.08, 0]} rotation={[0, 0, -Math.PI / 2]}>
          <torusGeometry args={[0.08, 0.015, 6, 8, Math.PI]} />
          <meshStandardMaterial color={color} transparent opacity={0.06} roughness={0.6} />
          <Edges threshold={15} color={color} />
        </mesh>
      </group>
    </Float>
  );
}

/* ─── Ambient Dust Particles ─────────────────────────────────── */

function AmbientParticles({ count = 80 }: { count: number }) {
  const pointsRef = useRef<THREE.Points>(null);

  const geometry = useMemo(() => {
    const positions = new Float32Array(count * 3);
    const sizes = new Float32Array(count);

    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 24;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 16;
      positions[i * 3 + 2] = -2 - Math.random() * 12;
      sizes[i] = Math.random() * 2 + 0.5;
    }

    const geo = new THREE.BufferGeometry();
    geo.setAttribute("position", new THREE.BufferAttribute(positions, 3));
    return geo;
  }, [count]);

  useFrame((state) => {
    if (!pointsRef.current) return;
    pointsRef.current.rotation.y = state.clock.elapsedTime * 0.008;
  });

  return (
    <points ref={pointsRef} geometry={geometry}>
      <pointsMaterial
        color="#D4A574"
        size={0.02}
        transparent
        opacity={0.3}
        sizeAttenuation
        depthWrite={false}
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
    smooth.current.x += (mouse.current.x - smooth.current.x) * 0.02;
    smooth.current.y += (mouse.current.y - smooth.current.y) * 0.02;
    camera.position.x = smooth.current.x * 0.6;
    camera.position.y = -smooth.current.y * 0.4;
    camera.lookAt(0, 0, -4);
  });

  return null;
}

/* ─── Scene ──────────────────────────────────────────────────── */

function Scene({ isMobile }: { isMobile: boolean }) {
  const groupRef = useRef<THREE.Group>(null);

  useFrame((state) => {
    if (!groupRef.current) return;
    // Very slow global rotation for life
    groupRef.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.05) * 0.08;
  });

  return (
    <>
      {/* Warm amber key light */}
      <ambientLight intensity={0.15} color="#F0EBE3" />
      <pointLight position={[6, 5, 4]} intensity={0.8} color="#DAA520" distance={20} />
      <pointLight position={[-5, -3, 2]} intensity={0.3} color="#C8956C" distance={15} />
      <pointLight position={[0, 2, 6]} intensity={0.2} color="#F0EBE3" distance={12} />

      <group ref={groupRef}>
        {/* Hobby objects scattered at the periphery — away from center text */}
        <Guitar position={[-5.5, 2.5, -3]} rotation={[0.1, 0.3, 0.4]} scale={isMobile ? 0.7 : 0.95} color="#DAA520" />
        <Camera position={[5.5, 2.0, -4]} rotation={[0.15, -0.4, 0.1]} scale={isMobile ? 0.5 : 0.7} color="#E8D5B7" />
        <Paintbrush position={[-5.0, -2.5, -2]} rotation={[0, 0, -0.5]} scale={isMobile ? 0.6 : 0.85} color="#C8956C" />
        <ChessPawn position={[5.8, -1.8, -5]} scale={isMobile ? 0.55 : 0.8} color="#F0EBE3" />
        <Book position={[-6.5, -0.5, -5]} rotation={[0.3, 0.8, 0.15]} scale={isMobile ? 0.5 : 0.75} color="#D4A574" />
        <PlantPot position={[6.2, 3.2, -5]} rotation={[0, 0.5, 0]} scale={isMobile ? 0.45 : 0.65} color="#7DBDAB" />
        <BicycleWheel position={[-7, 0.5, -6]} rotation={[0.3, 0.1, 0.15]} scale={isMobile ? 0.45 : 0.7} color="#E8D5B7" />
        <CookingPot position={[5.0, -3.5, -4]} rotation={[0.2, -0.3, 0.05]} scale={isMobile ? 0.45 : 0.65} color="#D4A574" />

        {/* Additional objects at far depths for layering */}
        {!isMobile && (
          <>
            <Guitar position={[8, -3, -9]} rotation={[0.5, -0.2, -0.3]} scale={0.45} color="#C8956C" floatSpeed={0.3} />
            <Book position={[-8, 3.5, -10]} rotation={[-0.2, 1.2, 0.3]} scale={0.4} color="#DAA520" floatSpeed={0.25} />
            <ChessPawn position={[-3, -4, -8]} scale={0.5} color="#D4A574" floatSpeed={0.35} />
          </>
        )}
      </group>

      <AmbientParticles count={isMobile ? 40 : 80} />
      <CameraRig />
    </>
  );
}

/* ─── CSS Fallback (no WebGL) ────────────────────────────────── */

function FallbackBackground() {
  return (
    <div className="absolute inset-0">
      {/* Floating geometric shapes suggesting hobbies */}
      {[
        { shape: "◆", x: 15, y: 20, size: 28, delay: 0, color: "rgba(218,165,32,0.2)" },
        { shape: "○", x: 75, y: 30, size: 36, delay: 1, color: "rgba(232,213,183,0.15)" },
        { shape: "△", x: 40, y: 65, size: 24, delay: 2, color: "rgba(200,149,108,0.18)" },
        { shape: "□", x: 85, y: 70, size: 20, delay: 0.5, color: "rgba(240,235,227,0.12)" },
        { shape: "◇", x: 25, y: 80, size: 22, delay: 1.5, color: "rgba(125,189,171,0.15)" },
        { shape: "○", x: 60, y: 15, size: 18, delay: 2.5, color: "rgba(212,165,116,0.12)" },
      ].map((item, i) => (
        <div
          key={i}
          className="absolute select-none pointer-events-none"
          style={{
            left: `${item.x}%`,
            top: `${item.y}%`,
            fontSize: `${item.size}px`,
            color: item.color,
            animation: `breathe ${4 + i * 0.5}s ease-in-out infinite`,
            animationDelay: `${item.delay}s`,
          }}
        >
          {item.shape}
        </div>
      ))}
    </div>
  );
}

/* ─── Export ──────────────────────────────────────────────────── */

export function HeroEnvironment() {
  const [isMobile, setIsMobile] = useState(true);

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
  }, []);

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
          <Scene isMobile={isMobile} />
        </Canvas>
      </Suspense>

      {/* Warm atmospheric washes */}
      <div
        className="absolute top-[-10%] left-[-5%] w-[600px] h-[600px] pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(218,165,32,0.05), transparent 70%)",
        }}
      />
      <div
        className="absolute bottom-[-10%] right-[-5%] w-[500px] h-[500px] pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(200,149,108,0.035), transparent 70%)",
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
