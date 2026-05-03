import { prisma } from './db';
import {
  COACH_FREE_DAILY_LIMIT,
  COACH_FREE_MONTHLY_LIMIT,
} from './entitlement_constants';

const DAY_MS = 24 * 60 * 60 * 1000;
const MONTH_MS = 30 * DAY_MS;

export type CoachRateLimitReason = 'daily' | 'monthly';

export interface CoachRateLimitResult {
  allowed: boolean;
  /** Daily count — preserved as `count` for backwards compatibility. */
  count: number;
  dayCount: number;
  monthCount: number;
  /** Which bucket blocked the request (only set when allowed=false). */
  reason?: CoachRateLimitReason;
}

/**
 * Dual-bucket rate limiter for free-tier coach messages.
 *
 * Free users are limited to:
 *   - {@link COACH_FREE_DAILY_LIMIT} messages per rolling 24h window
 *   - {@link COACH_FREE_MONTHLY_LIMIT} messages per rolling 30-day window
 *
 * Both must be satisfied for the request to be allowed. Daily bucket
 * prevents bursting; monthly bucket caps total cost. Pro users are
 * unlimited.
 */
export async function checkCoachRateLimit(
  userId: string,
  subscriptionTier: string
): Promise<CoachRateLimitResult> {
  // D-05: Only explicitly-unlimited tiers bypass the rate limit.
  // Positive whitelist (not negative !== 'free') so unknown / null /
  // legacy / future tier values default to rate-limited rather than
  // silently bypassed. Schema enum: "free", "trial", "pro".
  const UNLIMITED_TIERS = new Set(['pro', 'trial']);
  if (UNLIMITED_TIERS.has(subscriptionTier)) {
    return { allowed: true, count: 0, dayCount: 0, monthCount: 0 };
  }

  const now = Date.now();
  const dayStart = new Date(now - DAY_MS);
  const monthStart = new Date(now - MONTH_MS);

  // Two parallel count queries — adds ~5ms over the single-bucket version.
  const [dayCount, monthCount] = await Promise.all([
    prisma.generationLog.count({
      where: {
        userId,
        query: 'coach',
        status: 'success',
        createdAt: { gte: dayStart },
      },
    }),
    prisma.generationLog.count({
      where: {
        userId,
        query: 'coach',
        status: 'success',
        createdAt: { gte: monthStart },
      },
    }),
  ]);

  const dayBlocked = dayCount >= COACH_FREE_DAILY_LIMIT;
  const monthBlocked = monthCount >= COACH_FREE_MONTHLY_LIMIT;
  const allowed = !dayBlocked && !monthBlocked;

  return {
    allowed,
    count: dayCount, // backwards compat with single-bucket callers
    dayCount,
    monthCount,
    // Daily bucket reported first when both are blocked — it's the
    // limit the user can act on (wait until tomorrow vs wait weeks).
    reason: !allowed ? (dayBlocked ? 'daily' : 'monthly') : undefined,
  };
}
