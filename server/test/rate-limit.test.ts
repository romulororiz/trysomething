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

describe("checkCoachRateLimit", () => {
  beforeEach(() => {
    mockCount.mockReset();
  });

  it("allows pro users without querying the database", async () => {
    const result = await checkCoachRateLimit("user-1", "pro");
    expect(result).toEqual({ allowed: true, count: 0 });
    expect(mockCount).not.toHaveBeenCalled();
  });

  it("allows lifetime users without querying the database", async () => {
    const result = await checkCoachRateLimit("user-1", "lifetime");
    expect(result).toEqual({ allowed: true, count: 0 });
    expect(mockCount).not.toHaveBeenCalled();
  });

  it("allows free user with fewer than 3 messages in 30 days", async () => {
    mockCount.mockResolvedValue(2);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result).toEqual({ allowed: true, count: 2 });
  });

  it("rejects free user with 3 or more messages in 30 days", async () => {
    mockCount.mockResolvedValue(3);
    const result = await checkCoachRateLimit("user-1", "free");
    expect(result).toEqual({ allowed: false, count: 3 });
  });

  it("queries GenerationLog with correct filters for free users", async () => {
    mockCount.mockResolvedValue(0);
    await checkCoachRateLimit("user-42", "free");
    expect(mockCount).toHaveBeenCalledWith({
      where: expect.objectContaining({
        userId: "user-42",
        query: "coach",
        status: "success",
        createdAt: { gte: expect.any(Date) },
      }),
    });
    // Verify the date is approximately 30 days ago (within 5 seconds tolerance)
    const callArg = mockCount.mock.calls[0][0];
    const windowStart = callArg.where.createdAt.gte.getTime();
    const expected30DaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;
    expect(Math.abs(windowStart - expected30DaysAgo)).toBeLessThan(5000);
  });
});
