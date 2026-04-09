/**
 * Single source of truth for all free/pro entitlement limits.
 *
 * Every rate limit check, error message, and copy string must reference
 * these constants — never hardcode numbers.
 */

/** Free-tier coach messages per rolling 30-day window. */
export const COACH_FREE_LIMIT = 5;

/** Pro-tier hobby generations per 24-hour window. */
export const GENERATION_LIMIT_PRO = 10;

/** Free-tier max simultaneous active hobbies. */
export const FREE_ACTIVE_HOBBIES = 1;
