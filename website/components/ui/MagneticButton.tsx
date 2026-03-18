"use client";

import { useRef, useState, useCallback } from "react";
import { motion } from "framer-motion";
import { cn } from "@/lib/utils";

interface MagneticButtonProps {
  children: React.ReactNode;
  className?: string;
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
  /** Magnetic pull strength (0-1) */
  strength?: number;
  /** Magnetic pull radius in px */
  radius?: number;
  breathing?: boolean;
  onClick?: () => void;
  href?: string;
}

const variants = {
  primary:
    "bg-coral text-white hover:bg-coral-hover active:scale-[0.97]",
  secondary:
    "glass text-text-primary hover:border-glass-hover active:scale-[0.97]",
  ghost:
    "bg-transparent text-text-secondary hover:text-text-primary active:scale-[0.97]",
};

const sizes = {
  sm: "px-5 py-2.5 text-sm rounded-full",
  md: "px-7 py-3.5 text-base rounded-full",
  lg: "px-10 py-4.5 text-lg rounded-full",
};

export function MagneticButton({
  children,
  className = "",
  variant = "primary",
  size = "md",
  strength = 0.3,
  radius = 150,
  breathing = false,
  onClick,
  href,
}: MagneticButtonProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouseMove = useCallback(
    (e: React.MouseEvent) => {
      if (!ref.current) return;
      const rect = ref.current.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      const distX = e.clientX - centerX;
      const distY = e.clientY - centerY;
      const dist = Math.sqrt(distX * distX + distY * distY);

      if (dist < radius) {
        const pull = (1 - dist / radius) * strength;
        setPosition({ x: distX * pull, y: distY * pull });
      }
    },
    [strength, radius]
  );

  const handleMouseLeave = useCallback(() => {
    setPosition({ x: 0, y: 0 });
  }, []);

  const buttonClasses = cn(
    "inline-flex items-center justify-center font-semibold transition-all cursor-pointer",
    "focus-visible:outline-2 focus-visible:outline-coral focus-visible:outline-offset-2",
    variants[variant],
    sizes[size],
    breathing && variant === "primary" && "breathing-glow",
    className
  );

  const Tag = href ? "a" : "button";
  const linkProps = href ? { href } : {};

  return (
    <motion.div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      animate={{
        x: position.x,
        y: position.y,
      }}
      transition={{
        type: "spring",
        stiffness: 200,
        damping: 20,
        mass: 0.5,
      }}
      className="inline-block"
    >
      <Tag
        className={buttonClasses}
        onClick={onClick}
        {...linkProps}
      >
        {children}
      </Tag>
    </motion.div>
  );
}
