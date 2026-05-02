// In-memory rate limiter for unauthenticated auth endpoints.
//
// State lives in module scope on each Vercel Function instance. Vercel
// Fluid Compute reuses warm instances across many requests, so the
// counters persist across the hot path. Cold starts wipe the state —
// the trade-off is a slightly leakier ceiling in exchange for zero DB
// schema changes and zero per-request DB calls on the auth fast path.
//
// Each handler calls checkAuthRateLimit twice when both an IP and
// an email exist (IP-based protection for one-account brute force, plus
// email-based protection for password spray across rotating IPs).

import type { VercelRequest } from "@vercel/node";

interface Bucket {
  count: number;
  resetAt: number;
}

const buckets = new Map<string, Bucket>();

let opCount = 0;
function maybeCleanup(): void {
  if (++opCount % 200 !== 0) return;
  const now = Date.now();
  for (const [key, bucket] of buckets) {
    if (now >= bucket.resetAt) buckets.delete(key);
  }
}

export interface RateLimitOptions {
  max: number;
  windowMs: number;
}

export interface RateLimitResult {
  allowed: boolean;
  retryAfter: number;
  count: number;
}

export function checkAuthRateLimit(
  key: string,
  options: RateLimitOptions
): RateLimitResult {
  maybeCleanup();

  const now = Date.now();
  const bucket = buckets.get(key);

  if (!bucket || now >= bucket.resetAt) {
    buckets.set(key, { count: 1, resetAt: now + options.windowMs });
    return { allowed: true, retryAfter: 0, count: 1 };
  }

  bucket.count++;
  if (bucket.count > options.max) {
    return {
      allowed: false,
      retryAfter: Math.ceil((bucket.resetAt - now) / 1000),
      count: bucket.count,
    };
  }

  return { allowed: true, retryAfter: 0, count: bucket.count };
}

export function getClientIp(req: VercelRequest): string {
  const xff = req.headers["x-forwarded-for"];
  if (typeof xff === "string") {
    const first = xff.split(",")[0]?.trim();
    if (first) return first;
  } else if (Array.isArray(xff) && xff[0]) {
    return xff[0];
  }
  const realIp = req.headers["x-real-ip"];
  if (typeof realIp === "string") return realIp;
  return "unknown";
}
