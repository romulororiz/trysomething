"use client";

import { cn } from "@/lib/utils";
import { categoryColors, type CategoryId } from "@/lib/tokens";

interface CategoryChipProps {
  category: CategoryId;
  label: string;
  active?: boolean;
  onClick?: () => void;
  className?: string;
}

/**
 * Category pill matching app's category chip style.
 * Colored bg, pill radius, white text + uppercase label.
 */
export function CategoryChip({
  category,
  label,
  active = false,
  onClick,
  className,
}: CategoryChipProps) {
  const color = categoryColors[category];

  return (
    <button
      onClick={onClick}
      className={cn(
        "inline-flex items-center gap-1.5 px-3 py-1.5 rounded-badge",
        "font-sans text-[10px] font-bold uppercase tracking-[1.5px]",
        "transition-all cursor-pointer",
        active ? "ring-2 ring-white/30" : "ring-0",
        className
      )}
      style={{
        backgroundColor: active ? color : `${color}33`,
        color: active ? "#fff" : color,
        transitionDuration: "200ms",
      }}
    >
      {label}
    </button>
  );
}
