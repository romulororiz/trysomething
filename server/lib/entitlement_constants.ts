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
export const COACH_FREE_DAILY_LIMIT = 3;

/**
 * Free-tier coach messages per rolling 30-day window.
 *
 * Monthly soft cap of a dual-bucket limiter. Caps total API cost and
 * forces conversion for power users while letting the daily ritual
 * play out for normal users.
 */
export const COACH_FREE_MONTHLY_LIMIT = 15;

/** Free-tier max simultaneous active hobbies. */
export const FREE_ACTIVE_HOBBIES = 1;

/** Stage-1 heuristic candidates handed to the match jury. */
export const MATCH_CANDIDATES = 30;

/** Match picks returned to the client. */
export const MATCH_RESULTS = 6;

/**
 * LLM match calls per user per rolling 24-hour window.
 *
 * Cache hits and heuristic fallbacks don't count — only calls that
 * actually reach the jury. Trips fail closed to the heuristic.
 */
export const MATCH_USER_DAILY_LIMIT = 5;

/**
 * Global LLM match ceiling per rolling 24-hour window.
 *
 * Hard cost cap across all users. Trips fail closed to the heuristic —
 * the user always gets matches, never an error.
 */
export const MATCH_GLOBAL_DAILY_LIMIT = 200;

/** MatchCache TTL for AI results (heuristic results cache for 1 day). */
export const MATCH_CACHE_TTL_DAYS = 7;
