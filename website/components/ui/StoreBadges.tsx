"use client";

/**
 * App Store + Play Store download badges.
 * Placeholder links for now — replace href values when live.
 */

const APP_STORE_URL = "#";
const PLAY_STORE_URL = "#";

export function StoreBadges({
  className = "",
  size = "default",
}: {
  className?: string;
  size?: "default" | "sm";
}) {
  const h = size === "sm" ? "h-10" : "h-12";

  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <a
        href={APP_STORE_URL}
        target="_blank"
        rel="noopener noreferrer"
        className={`inline-flex items-center gap-2 px-4 ${h} rounded-lg bg-white/[0.06] border border-white/[0.1] hover:bg-white/[0.1] transition-colors duration-200 cursor-pointer`}
      >
        <svg viewBox="0 0 24 24" className="w-5 h-5 fill-white flex-shrink-0">
          <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
        </svg>
        <div className="flex flex-col leading-none">
          <span className="text-[9px] text-white/60">Download on the</span>
          <span className="text-[13px] font-semibold text-white -mt-px">App Store</span>
        </div>
      </a>

      <a
        href={PLAY_STORE_URL}
        target="_blank"
        rel="noopener noreferrer"
        className={`inline-flex items-center gap-2 px-4 ${h} rounded-lg bg-white/[0.06] border border-white/[0.1] hover:bg-white/[0.1] transition-colors duration-200 cursor-pointer`}
      >
        <svg viewBox="0 0 24 24" className="w-5 h-5 flex-shrink-0">
          <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 01-.61-.92V2.734a1 1 0 01.609-.92z" fill="#4285F4" />
          <path d="M17.556 8.445l-3.764 3.556 3.764 3.555 4.218-2.371a1.01 1.01 0 000-1.77l-4.218-2.37z" fill="#FBBC04" />
          <path d="M3.609 22.186L14.794 12l-1.002-1L3.609 1.814l-.024.014A1.002 1.002 0 003 2.734v18.532c0 .36.193.694.585.906l.024.014z" fill="#EA4335" />
          <path d="M3.609 1.814L13.792 12l3.764-3.555L4.196.892A1.01 1.01 0 003.61 1.814z" fill="#34A853" />
        </svg>
        <div className="flex flex-col leading-none">
          <span className="text-[9px] text-white/60">Get it on</span>
          <span className="text-[13px] font-semibold text-white -mt-px">Google Play</span>
        </div>
      </a>
    </div>
  );
}
