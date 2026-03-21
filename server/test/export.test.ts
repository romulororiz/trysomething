import { describe, it, expect, vi, beforeAll, beforeEach } from "vitest";

vi.mock("../lib/db", () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
    },
  },
}));

import { prisma } from "../lib/db";
import type { VercelRequest, VercelResponse } from "@vercel/node";

beforeAll(() => {
  process.env.JWT_SECRET = "test-jwt-secret";
  process.env.JWT_REFRESH_SECRET = "test-jwt-refresh-secret";
});

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

import { generateTokenPair } from "../lib/auth";

function authHeader(userId: string): string {
  const { accessToken } = generateTokenPair(userId);
  return `Bearer ${accessToken}`;
}

const FULL_USER = {
  id: "user-export",
  email: "test@example.com",
  passwordHash: "$2a$12$shouldnotappear",
  displayName: "Test User",
  bio: "Hello",
  avatarUrl: "https://example.com/avatar.jpg",
  googleId: "google-id-secret",
  appleId: "apple-id-secret",
  revenuecatId: "rc-id-secret",
  deletedAt: null,
  subscriptionTier: "free",
  proSince: null,
  proExpiresAt: null,
  isLifetime: false,
  createdAt: new Date("2025-01-01"),
  updatedAt: new Date("2025-06-01"),
  preferences: {
    hoursPerWeek: 5,
    budgetLevel: 2,
    preferSocial: false,
    vibes: ["creative", "relaxing"],
  },
  hobbies: [
    {
      hobbyId: "pottery",
      status: "active",
      startedAt: new Date("2025-02-01"),
      completedAt: null,
      lastActivityAt: new Date("2025-06-01"),
      streakDays: 10,
      createdAt: new Date("2025-02-01"),
      completedSteps: [
        { stepId: "step1", completedAt: new Date("2025-02-05") },
      ],
    },
  ],
  activityLogs: [
    { hobbyId: "pottery", action: "session_complete", createdAt: new Date("2025-06-01") },
  ],
  journalEntries: [
    { hobbyId: "pottery", text: "Great session", photoUrl: null, createdAt: new Date("2025-06-01") },
  ],
  personalNotes: [
    { hobbyId: "pottery", stepId: "step1", text: "Use more water" },
  ],
  scheduleEvents: [
    { hobbyId: "pottery", dayOfWeek: 1, startTime: "18:00", durationMinutes: 60 },
  ],
  shoppingChecks: [
    { hobbyId: "pottery", itemName: "Clay 2kg", checked: true },
  ],
  communityStories: [
    {
      quote: "Pottery changed my life",
      hobbyId: "pottery",
      createdAt: new Date("2025-05-01"),
      reactions: [{ type: "heart", userId: "other-user" }],
    },
  ],
  storyReactions: [
    { storyId: "story-1", type: "fire" },
  ],
  buddyRequestsSent: [
    { accepterId: "buddy-1", hobbyId: "pottery", status: "active", requesterId: "user-export", createdAt: new Date("2025-04-01") },
  ],
  buddyRequestsRcvd: [],
  challenges: [
    {
      challengeType: "complete_steps",
      currentCount: 3,
      targetCount: 5,
      isCompleted: false,
      weekStart: new Date("2025-05-26"),
      completedAt: null,
    },
  ],
  achievements: [
    { achievementId: "first_session", unlockedAt: new Date("2025-02-01") },
  ],
};

describe("GET /api/users/me/export", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns JSON with correct Content-Disposition header", async () => {
    const userId = "user-export";
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null }) // requireAuth check
      .mockResolvedValueOnce(FULL_USER); // export query

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: authHeader(userId) },
      query: { path: "export" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.setHeader).toHaveBeenCalledWith("Content-Type", "application/json");
    expect(res.setHeader).toHaveBeenCalledWith(
      "Content-Disposition",
      "attachment; filename=trysomething-export.json"
    );
    expect(res.status).toHaveBeenCalledWith(200);
  });

  it("includes all personal data categories in export", async () => {
    const userId = "user-export";
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null })
      .mockResolvedValueOnce(FULL_USER);

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: authHeader(userId) },
      query: { path: "export" },
    });
    const res = mockRes();

    await handler(req, res);

    const exportData = (res.json as any).mock.calls[0][0];

    // Verify all sections exist
    expect(exportData).toHaveProperty("account");
    expect(exportData).toHaveProperty("preferences");
    expect(exportData).toHaveProperty("hobbies");
    expect(exportData).toHaveProperty("activityLogs");
    expect(exportData).toHaveProperty("journalEntries");
    expect(exportData).toHaveProperty("personalNotes");
    expect(exportData).toHaveProperty("scheduleEvents");
    expect(exportData).toHaveProperty("shoppingChecks");
    expect(exportData).toHaveProperty("communityStories");
    expect(exportData).toHaveProperty("storyReactions");
    expect(exportData).toHaveProperty("buddyConnections");
    expect(exportData).toHaveProperty("challenges");
    expect(exportData).toHaveProperty("achievements");
    expect(exportData).toHaveProperty("exportedAt");

    // Verify data content
    expect(exportData.hobbies).toHaveLength(1);
    expect(exportData.hobbies[0].hobbyId).toBe("pottery");
    expect(exportData.hobbies[0].completedSteps).toHaveLength(1);
    expect(exportData.journalEntries).toHaveLength(1);
    expect(exportData.achievements).toHaveLength(1);
  });

  it("excludes passwordHash, revenuecatId, googleId, appleId from export", async () => {
    const userId = "user-export";
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null })
      .mockResolvedValueOnce(FULL_USER);

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: authHeader(userId) },
      query: { path: "export" },
    });
    const res = mockRes();

    await handler(req, res);

    const exportData = (res.json as any).mock.calls[0][0];
    const jsonString = JSON.stringify(exportData);

    // These fields must NOT appear anywhere in the export
    expect(jsonString).not.toContain("passwordHash");
    expect(jsonString).not.toContain("$2a$12$shouldnotappear");
    expect(jsonString).not.toContain("revenuecatId");
    expect(jsonString).not.toContain("rc-id-secret");
    expect(jsonString).not.toContain("googleId");
    expect(jsonString).not.toContain("google-id-secret");
    expect(jsonString).not.toContain("appleId");
    expect(jsonString).not.toContain("apple-id-secret");
    expect(jsonString).not.toContain("generationLog");
    expect(jsonString).not.toContain("GenerationLog");
  });
});
