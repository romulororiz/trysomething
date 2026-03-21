import { describe, it, expect, vi, beforeAll, beforeEach } from "vitest";

// Mock prisma before importing modules that use it
vi.mock("../lib/db", () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
      update: vi.fn(),
    },
  },
}));

// Mock bcryptjs for comparePassword
vi.mock("bcryptjs", () => ({
  default: {
    hash: vi.fn(),
    compare: vi.fn(),
  },
}));

import { prisma } from "../lib/db";
import bcrypt from "bcryptjs";
import type { VercelRequest, VercelResponse } from "@vercel/node";

// Set JWT secrets for token generation
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

// Generate a valid JWT for testing
import { generateTokenPair } from "../lib/auth";

function authHeader(userId: string): string {
  const { accessToken } = generateTokenPair(userId);
  return `Bearer ${accessToken}`;
}

describe("DELETE /api/users/me", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("soft-deletes user with valid password", async () => {
    const userId = "user-123";
    // requireAuth's findUnique call (deletedAt check)
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null }) // requireAuth check
      .mockResolvedValueOnce({ passwordHash: "$2a$12$hash" }); // handleMe password lookup
    (bcrypt.compare as any).mockResolvedValue(true);
    (prisma.user.update as any).mockResolvedValue({});

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "DELETE",
      headers: { authorization: authHeader(userId) },
      query: { path: "me" },
      body: { password: "correct-password" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        status: "deleted",
        deletedAt: expect.any(String),
        purgeAt: expect.any(String),
      })
    );
    expect(prisma.user.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: userId },
        data: { deletedAt: expect.any(Date) },
      })
    );
  });

  it("rejects invalid password with 403", async () => {
    const userId = "user-456";
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null })
      .mockResolvedValueOnce({ passwordHash: "$2a$12$hash" });
    (bcrypt.compare as any).mockResolvedValue(false);

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "DELETE",
      headers: { authorization: authHeader(userId) },
      query: { path: "me" },
      body: { password: "wrong-password" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: "Invalid password" })
    );
  });

  it("allows OAuth user deletion without password check", async () => {
    const userId = "oauth-user-789";
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null })
      .mockResolvedValueOnce({ passwordHash: "" }); // OAuth user
    (prisma.user.update as any).mockResolvedValue({});

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "DELETE",
      headers: { authorization: authHeader(userId) },
      query: { path: "me" },
      body: {},
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(bcrypt.compare).not.toHaveBeenCalled();
  });

  it("returns 400 when password user omits password", async () => {
    const userId = "user-needs-pw";
    (prisma.user.findUnique as any)
      .mockResolvedValueOnce({ deletedAt: null })
      .mockResolvedValueOnce({ passwordHash: "$2a$12$somehash" });

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "DELETE",
      headers: { authorization: authHeader(userId) },
      query: { path: "me" },
      body: {},
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: "Password is required" })
    );
  });
});

describe("requireAuth rejects soft-deleted user", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns 401 for soft-deleted user", async () => {
    const userId = "deleted-user";
    (prisma.user.findUnique as any).mockResolvedValueOnce({
      deletedAt: new Date("2025-01-01"),
    });

    const handler = (await import("../api/users/[path]")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: authHeader(userId) },
      query: { path: "me" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });
});
