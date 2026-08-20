import type { NextConfig } from "next";

// Standard Vercel output (serverless). Static export was dropped so the
// /api/waitlist route handler and generated OG image can run — deploying
// on Vercel this changes nothing about how pages are served.
const nextConfig: NextConfig = {};

export default nextConfig;
