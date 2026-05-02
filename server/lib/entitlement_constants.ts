/**
 * Single source of truth for all free/pro entitlement limits.
 *
 * Every rate limit check, error message, and copy string must reference
 * these constants — never hardcode numbers.
 */

/**
 * Free-tier coach messages per rolling 24-hour window.
 *
 * Daily bucket of a dual-bucket limiter. Prevents bursting while keeping
 * a daily ritual for the user (1 message per day, ~30/month upper bound
 * but capped sooner by COACH_FREE_MONTHLY_LIMIT).
 */
export const COACH_FREE_DAILY_LIMIT = 1;

/**
 * Free-tier coach messages per rolling 30-day window.
 *
 * Monthly soft cap of a dual-bucket limiter. Caps total API cost and
 * forces conversion for power users while letting the daily ritual
 * play out for normal users.
 */
export const COACH_FREE_MONTHLY_LIMIT = 10;

/** Pro-tier hobby generations per 24-hour window. */
export const GENERATION_LIMIT_PRO = 10;

/** Free-tier max simultaneous active hobbies. */
export const FREE_ACTIVE_HOBBIES = 1;
