"use client";

import { cn } from "@/lib/utils";
import { DollarSign, Clock, BarChart3 } from "lucide-react";

type SpecType = "cost" | "time" | "difficulty";

interface SpecBadgeProps {
  type: SpecType;
  value: string;
  className?: string;
}

const icons: Record<SpecType, React.ElementType> = {
  cost: DollarSign,
  time: Clock,
  difficulty: BarChart3,
};

/**
 * Frosted glass spec badge matching app's SpecBadge.
 * white 15% bg, white 20% border, pill shape.
 */
export function SpecBadge({ type, value, className }: SpecBadgeProps) {
  const Icon = icons[type];

  return (
    <div
      className={cn(
        "inline-flex items-center gap-1.5 px-3 py-1.5 rounded-badge",
        "bg-white/[0.12] border border-white/[0.15]",
        "backdrop-blur-sm",
        className
      )}
    >
      <Icon size={12} className="text-white/70" />
      <span className="font-mono text-[11px] font-semibold text-white/90">
        {value}
      </span>
    </div>
  );
}
