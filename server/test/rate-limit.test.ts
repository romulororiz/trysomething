import { describe, it, expect, vi, beforeEach } from "vitest";

// Use vi.hoisted so the mock fn is available in the hoisted vi.mock factory
const { mockCount } = vi.hoisted(() => ({
  mockCount: vi.fn(),
}));

vi.mock("../lib/db", () => ({
  prisma: {
    generationLog: {
      count: mockCount,
    },
  },
}));

import { checkCoachRateLimit } from "../lib/rate_limit";
import {
  COACH_FREE_DAILY_LIMIT,
  COACH_FREE_MONTHLY_LIMIT,
} from "../lib/entitlement_constants";

const DAY_MS = 24 * 60 * 60 * 1000;
const MONTH_MS = 30 * DAY_MS;

/**
 * Mock both count() calls based on which time window they query.
 * Daily filter has gte ~24h ago, monthly has gte ~30d ago — easy to
 * distinguish without depending on Promise.all dispatch order.
 */
function setupCounts(dayCount: number, monthCount: number) {
  mockCount.mockImplementation(
    async (args: { where: { createdAt: { gte: Date } } }) => {
      const windowMs = Date.now() - args.where.createdAt.gte.getTime();
      // Day window is 24h ± skew; treat anything under ~36h as the day query.
      return windowMs < 36 * 60 * 60 * 1000 ? dayCount : monthCount;
    }
  );
}

describe("checkCoachRateLimit (dual-bucket: daily + monthly)", () => {
  beforeEach(() => {
    mockCount.mockReset();
  });

  it("allows pro users without querying the database", async () => {
    const result = await checkCoachRateLimit("user-1", "pro");
    expect(result).toEqual({
      allowed: true,
      count: 0,
      dayCount: 0,
      monthCount: 0,
    });
    expect(mockCount).not.toHaveBeenCalled();
  });

  it("allows free user under both daily and monthly limits", async () => {
    setupCounts(0, 5);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result.allowed).toBe(true);
    expect(result.dayCount).toBe(0);
    expect(result.monthCount).toBe(5);
    expect(result.reason).toBeUndefined();
  });

  it("rejects free user at daily limit with reason='daily'", async () => {
    setupCounts(COACH_FREE_DAILY_LIMIT, 3);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result.allowed).toBe(false);
    expect(result.reason).toBe("daily");
    expect(result.dayCount).toBe(COACH_FREE_DAILY_LIMIT);
  });

  it("rejects free user at monthly limit with reason='monthly'", async () => {
    setupCounts(0, COACH_FREE_MONTHLY_LIMIT);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result.allowed).toBe(false);
    expect(result.reason).toBe("monthly");
    expect(result.monthCount).toBe(COACH_FREE_MONTHLY_LIMIT);
  });

  it("reports daily when both buckets are blocked (actionable: wait until tomorrow)", async () => {
    setupCounts(COACH_FREE_DAILY_LIMIT, COACH_FREE_MONTHLY_LIMIT);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result.allowed).toBe(false);
    expect(result.reason).toBe("daily");
  });

  it("preserves backwards-compat 'count' field as dayCount", async () => {
    setupCounts(0, 7);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result.count).toBe(result.dayCount);
  });

  it("queries GenerationLog with correct filters and time windows", async () => {
    mockCount.mockResolvedValue(0);
    await checkCoachRateLimit("user-42", "free");

    expect(mockCount).toHaveBeenCalledTimes(2);

    // Both calls share user/query/status filters
    for (const call of mockCount.mock.calls) {
      expect(call[0].where).toMatchObject({
        userId: "user-42",
        query: "coach",
        status: "success",
      });
    }

    // One call should be 24h window, the other 30d window
    const windowsMs = mockCount.mock.calls
      .map((c) => Date.now() - c[0].where.createdAt.gte.getTime())
      .sort((a, b) => a - b);
    expect(Math.abs(windowsMs[0] - DAY_MS)).toBeLessThan(5000);
    expect(Math.abs(windowsMs[1] - MONTH_MS)).toBeLessThan(5000);
  });
});
