"use client";

import { Suspense, useRef, useMemo, useEffect, useCallback, useState } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { Float, useGLTF } from "@react-three/drei";
import * as THREE from "three";

/* ─── Model paths ─────────────────────────────────────────────── */

const MODEL_CONFIGS = [
  { path: "/models/low_poly_guitar..glb", position: [-4.5, 2.0, -2.5] as [number, number, number], scale: 0.9, rotation: [0.1, 0.4, 0.3] as [number, number, number], floatSpeed: 0.5, rotationIntensity: 0.25, color: "#DAA520" },
  { path: "/models/vintage_camera__asahi_pentax_h2.glb", position: [4.5, 1.5, -3] as [number, number, number], scale: 0.7, rotation: [0.15, -0.3, 0.1] as [number, number, number], floatSpeed: 0.45, rotationIntensity: 0.2, color: "#E8D5B7" },
  { path: "/models/low_poly_paint_brush.glb", position: [-4.2, -2.0, -2] as [number, number, number], scale: 0.8, rotation: [0, 0, -0.5] as [number, number, number], floatSpeed: 0.6, rotationIntensity: 0.3, color: "#C8956C" },
  { path: "/models/low_poly_chess_-_knight.glb", position: [5.0, -1.2, -4] as [number, number, number], scale: 0.75, rotation: [0, 0.6, 0] as [number, number, number], floatSpeed: 0.35, rotationIntensity: 0.15, color: "#F0EBE3" },
  { path: "/models/book_stack.glb", position: [-5.5, -0.2, -3.5] as [number, number, number], scale: 0.7, rotation: [0.2, 0.8, 0.1] as [number, number, number], floatSpeed: 0.5, rotationIntensity: 0.2, color: "#D4A574" },
  { path: "/models/indoor_pot_plant_3.glb", position: [5.2, 2.8, -4] as [number, number, number], scale: 0.65, rotation: [0, 0.5, 0] as [number, number, number], floatSpeed: 0.4, rotationIntensity: 0.12, color: "#7DBDAB" },
  { path: "/models/telescope_with_the_tripod.glb", position: [-6.0, 0.5, -5] as [number, number, number], scale: 0.6, rotation: [0.3, 0.2, 0.1] as [number, number, number], floatSpeed: 0.3, rotationIntensity: 0.18, color: "#E8D5B7" },
  { path: "/models/skateboard.glb", position: [3.8, -2.8, -3] as [number, number, number], scale: 0.7, rotation: [0.4, -0.3, 0.2] as [number, number, number], floatSpeed: 0.55, rotationIntensity: 0.28, color: "#D4A574" },
];

const DESKTOP_EXTRA_MODELS = [
  { path: "/models/low-_poly_bicycle__5.glb", position: [7.5, -2.5, -9] as [number, number, number], scale: 0.25, rotation: [0.2, -0.4, 0] as [number, number, number], floatSpeed: 0.25, rotationIntensity: 0.1, color: "#C8956C" },
  { path: "/models/cc0_-_pan_3.glb", position: [-7.5, 3.0, -10] as [number, number, number], scale: 0.2, rotation: [-0.1, 1.0, 0.2] as [number, number, number], floatSpeed: 0.2, rotationIntensity: 0.1, color: "#DAA520" },
  { path: "/models/salomon_outline_gtx_boot.glb", position: [-3.5, -3.8, -8] as [number, number, number], scale: 0.25, rotation: [0.3, 0.5, 0.1] as [number, number, number], floatSpeed: 0.3, rotationIntensity: 0.12, color: "#D4A574" },
];

/* ─── Preload all models ──────────────────────────────────────── */

MODEL_CONFIGS.forEach((m) => useGLTF.preload(m.path));
DESKTOP_EXTRA_MODELS.forEach((m) => useGLTF.preload(m.path));

/* ─── Single hobby model component ───────────────────────────── */

interface HobbyModelProps {
  path: string;
  position: [number, number, number];
  rotation: [number, number, number];
  scale: number;
  floatSpeed: number;
  rotationIntensity: number;
  color: string;
  isMobile: boolean;
}

function HobbyModel({
  path,
  position,
  rotation,
  scale: baseScale,
  floatSpeed,
  rotationIntensity,
  color,
  isMobile,
}: HobbyModelProps) {
  const { scene } = useGLTF(path);
  const clonedScene = useMemo(() => {
    const clone = scene.clone(true);

    // Normalize model: center it and scale to a unit bounding box
    const box = new THREE.Box3().setFromObject(clone);
    const center = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());
    const maxDim = Math.max(size.x, size.y, size.z);
    const normalizeScale = maxDim > 0 ? 1 / maxDim : 1;

    clone.position.sub(center);
    clone.scale.multiplyScalar(normalizeScale);

    // Apply warm-toned material override for consistent premium aesthetic
    clone.traverse((child) => {
      if (child instanceof THREE.Mesh) {
        child.material = new THREE.MeshStandardMaterial({
          color: new THREE.Color(color),
          roughness: 0.4,
          metalness: 0.25,
          transparent: true,
          opacity: 0.85,
          emissive: new THREE.Color(color),
          emissiveIntensity: 0.35,
        });
      }
    });

    return clone;
  }, [scene, color]);

  const s = isMobile ? baseScale * 0.6 : baseScale;

  return (
    <Float speed={floatSpeed} rotationIntensity={rotationIntensity} floatIntensity={0.5}>
      <group position={position} rotation={rotation} scale={s}>
        <primitive object={clonedScene} />
      </group>
    </Float>
  );
}

/* ─── Ambient Dust Particles ─────────────────────────────────── */

function AmbientParticles({ count = 80 }: { count: number }) {
  const pointsRef = useRef<THREE.Points>(null);

  const geometry = useMemo(() => {
    const positions = new Float32Array(count * 3);

    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 24;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 16;
      positions[i * 3 + 2] = -2 - Math.random() * 12;
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
    camera.position.x = smooth.current.x * 0.5;
    camera.position.y = -smooth.current.y * 0.35;
    camera.lookAt(0, 0, -4);
  });

  return null;
}

/* ─── Scene ──────────────────────────────────────────────────── */

function Scene({ isMobile }: { isMobile: boolean }) {
  const groupRef = useRef<THREE.Group>(null);

  useFrame((state) => {
    if (!groupRef.current) return;
    groupRef.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.05) * 0.06;
  });

  return (
    <>
      {/* Warm amber/gold lighting system */}
      <ambientLight intensity={0.3} color="#F0EBE3" />
      <directionalLight position={[6, 5, 4]} intensity={1.2} color="#DAA520" />
      <pointLight position={[-5, -3, 2]} intensity={0.6} color="#C8956C" distance={18} />
      <pointLight position={[0, 2, 6]} intensity={0.4} color="#F0EBE3" distance={14} />
      <pointLight position={[3, -2, 3]} intensity={0.3} color="#DAA520" distance={12} />

      {/* Depth fog for far objects */}
      <fog attach="fog" args={["#0A0A0F", 8, 20]} />

      <group ref={groupRef}>
        {MODEL_CONFIGS.map((config) => (
          <HobbyModel key={config.path} {...config} isMobile={isMobile} />
        ))}

        {!isMobile &&
          DESKTOP_EXTRA_MODELS.map((config) => (
            <HobbyModel key={config.path} {...config} isMobile={false} />
          ))}
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

      {/* Vignette — subtle, lets models show through */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at center, transparent 40%, var(--color-bg) 100%)",
        }}
      />
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-bg/50 pointer-events-none" />
    </div>
  );
}
