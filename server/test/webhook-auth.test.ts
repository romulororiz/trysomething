import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import type { VercelRequest, VercelResponse } from "@vercel/node";

// Mock Prisma before importing handler
vi.mock("../../lib/db", () => ({
  prisma: {
    user: { findUnique: vi.fn(), update: vi.fn() },
    userHobby: { findMany: vi.fn(), update: vi.fn() },
  },
}));

// Mock auth — webhook path does not use requireAuth, but other paths do
vi.mock("../../lib/auth", () => ({
  requireAuth: vi.fn().mockReturnValue(null),
}));

// Mock gamification
vi.mock("../../lib/gamification", () => ({
  handleChallenges: vi.fn(),
  handleAchievements: vi.fn(),
  checkChallengeProgress: vi.fn(),
}));

// Mock mappers
vi.mock("../../lib/mappers", () => ({
  mapUserWithPreferences: vi.fn(),
  mapUserPreference: vi.fn(),
  mapUserHobby: vi.fn(),
  mapActivityLog: vi.fn(),
  mapJournalEntry: vi.fn(),
  mapPersonalNote: vi.fn(),
  mapScheduleEvent: vi.fn(),
  mapShoppingCheck: vi.fn(),
  mapCommunityStory: vi.fn(),
  mapBuddyProfile: vi.fn(),
  mapBuddyActivity: vi.fn(),
  mapBuddyRequest: vi.fn(),
  mapSimilarUser: vi.fn(),
}));

function mockRes(): VercelResponse {
  const res: any = {};
  res.status = vi.fn().mockReturnValue(res);
  res.json = vi.fn().mockReturnValue(res);
  res.end = vi.fn().mockReturnValue(res);
  res.setHeader = vi.fn().mockReturnValue(res);
  return res as VercelResponse;
}

function mockReq(overrides: Partial<VercelRequest> = {}): VercelRequest {
  return {
    method: "GET",
    headers: {},
    query: {},
    body: {},
    ...overrides,
  } as unknown as VercelRequest;
}

describe("RevenueCat webhook auth guard", () => {
  const originalEnv = { ...process.env };

  beforeEach(() => {
    // Reset env to a clean state for each test
    process.env = { ...originalEnv };
    // Default to production to test auth guard behavior
    process.env.NODE_ENV = "production";
    // Ensure secret is not set by default
    delete process.env.REVENUECAT_WEBHOOK_SECRET;
    // Reset module cache so env changes take effect
    vi.resetModules();
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it("returns 503 when REVENUECAT_WEBHOOK_SECRET is not set (SEC-01a)", async () => {
    delete process.env.REVENUECAT_WEBHOOK_SECRET;
    process.env.NODE_ENV = "production";

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "POST",
      query: { path: "revenuecat-webhook" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(503);
    expect(res.json).toHaveBeenCalledWith({ error: "Webhook not configured" });
  });

  it("returns 401 when Authorization header is missing (SEC-01c)", async () => {
    process.env.REVENUECAT_WEBHOOK_SECRET = "test-secret";
    process.env.NODE_ENV = "production";

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "POST",
      query: { path: "revenuecat-webhook" },
      headers: {},
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: "Unauthorized" });
  });

  it("returns 401 when Authorization header has wrong value (SEC-01b)", async () => {
    process.env.REVENUECAT_WEBHOOK_SECRET = "test-secret";
    process.env.NODE_ENV = "production";

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "POST",
      query: { path: "revenuecat-webhook" },
      headers: { authorization: "Bearer wrong-secret" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: "Unauthorized" });
  });

  it("passes through when correct Authorization header is provided (SEC-01d)", async () => {
    process.env.REVENUECAT_WEBHOOK_SECRET = "test-secret";
    process.env.NODE_ENV = "production";

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "POST",
      query: { path: "revenuecat-webhook" },
      headers: { authorization: "Bearer test-secret" },
      body: { event: { type: "TEST", app_user_id: "$RCAnonymousID:skip" } },
    });
    const res = mockRes();

    await handler(req, res);

    // Should NOT return 401 or 503 — should reach business logic
    // With an anonymous user ID, handler returns 200 with "skipped"
    expect(res.status).not.toHaveBeenCalledWith(401);
    expect(res.status).not.toHaveBeenCalledWith(503);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      status: "skipped",
      reason: "anonymous_user",
    });
  });

  it("skips verification when NODE_ENV is development (SEC-01e)", async () => {
    process.env.NODE_ENV = "development";
    delete process.env.REVENUECAT_WEBHOOK_SECRET;

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "POST",
      query: { path: "revenuecat-webhook" },
      headers: {},
      body: { event: { type: "TEST", app_user_id: "$RCAnonymousID:skip" } },
    });
    const res = mockRes();

    await handler(req, res);

    // Should NOT return 503 or 401 — should skip verification entirely
    expect(res.status).not.toHaveBeenCalledWith(503);
    expect(res.status).not.toHaveBeenCalledWith(401);
    // Should reach business logic and return 200 with skipped
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      status: "skipped",
      reason: "anonymous_user",
    });
  });

  it("auto-resumes paused hobbies on EXPIRATION event (LIFE-06)", async () => {
    process.env.REVENUECAT_WEBHOOK_SECRET = "test-secret";
    process.env.NODE_ENV = "production";

    const { prisma } = await import("../../lib/db");
    // Mock user lookup
    (prisma.user.findUnique as any).mockResolvedValue({
      id: "user-1",
      isLifetime: false,
    });
    // Mock user update (subscription downgrade)
    (prisma.user.update as any).mockResolvedValue({});
    // Mock finding paused hobbies
    (prisma.userHobby.findMany as any).mockResolvedValue([
      { hobbyId: "hobby-a", pausedAt: new Date("2026-03-01"), pausedDurationDays: 2 },
    ]);
    // Mock hobby update (auto-resume)
    (prisma.userHobby.update as any).mockResolvedValue({});

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "POST",
      query: { path: "revenuecat-webhook" },
      headers: { authorization: "Bearer test-secret" },
      body: {
        event: {
          type: "EXPIRATION",
          app_user_id: "user-1",
          expiration_at_ms: Date.now(),
        },
      },
    });
    const res = mockRes();

    await handler(req, res);

    // Verify paused hobbies were queried
    expect(prisma.userHobby.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { userId: "user-1", status: "paused" },
      })
    );
    // Verify auto-resume was called
    expect(prisma.userHobby.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { userId_hobbyId: { userId: "user-1", hobbyId: "hobby-a" } },
        data: expect.objectContaining({
          status: "active",
          pausedAt: null,
        }),
      })
    );
  });
});
