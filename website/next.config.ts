import type { NextConfig } from "next";

// Standard Vercel output. Static export was dropped so the generated OG
// image renders without extra force-static wiring and next/image can
// optimize the app screenshots — every page still prerenders as static.
const nextConfig: NextConfig = {};

export default nextConfig;
