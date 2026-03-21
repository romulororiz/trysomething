import { describe, it, expect, vi, beforeEach } from "vitest";

vi.mock("../lib/db", () => ({
  prisma: {
    user: {
      findMany: vi.fn(),
      deleteMany: vi.fn(),
    },
    generationLog: {
      deleteMany: vi.fn(),
    },
    $transaction: vi.fn(),
  },
}));

import { prisma } from "../lib/db";
import type { VercelRequest, VercelResponse } from "@vercel/node";

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

describe("cron: purge-deleted-users", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    process.env.CRON_SECRET = "test-cron-secret";
  });

  it("rejects requests without valid CRON_SECRET", async () => {
    const handler = (await import("../api/cron/purge-deleted-users")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: "Bearer wrong-secret" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: "Unauthorized" })
    );
  });

  it("rejects non-GET requests with 405", async () => {
    const handler = (await import("../api/cron/purge-deleted-users")).default;
    const req = mockReq({
      method: "POST",
      headers: { authorization: "Bearer test-cron-secret" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(405);
  });

  it("returns purged: 0 when no users to purge", async () => {
    (prisma.user.findMany as any).mockResolvedValue([]);

    const handler = (await import("../api/cron/purge-deleted-users")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: "Bearer test-cron-secret" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ purged: 0 });
  });

  it("hard-deletes users older than 30 days with transaction", async () => {
    const oldUsers = [{ id: "old-user-1" }, { id: "old-user-2" }];
    (prisma.user.findMany as any).mockResolvedValue(oldUsers);
    (prisma.$transaction as any).mockResolvedValue([]);

    const handler = (await import("../api/cron/purge-deleted-users")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: "Bearer test-cron-secret" },
    });
    const res = mockRes();

    await handler(req, res);

    expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ purged: 2 });
  });

  it("queries users with deletedAt older than 30-day cutoff", async () => {
    (prisma.user.findMany as any).mockResolvedValue([]);

    const handler = (await import("../api/cron/purge-deleted-users")).default;
    const req = mockReq({
      method: "GET",
      headers: { authorization: "Bearer test-cron-secret" },
    });
    const res = mockRes();

    const before = Date.now();
    await handler(req, res);

    // Verify the cutoff date was approximately 30 days ago
    const findManyCall = (prisma.user.findMany as any).mock.calls[0][0];
    const cutoffDate = findManyCall.where.deletedAt.lte;
    const thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;
    const expectedCutoff = before - thirtyDaysMs;

    // Allow 5 seconds of tolerance
    expect(cutoffDate.getTime()).toBeGreaterThan(expectedCutoff - 5000);
    expect(cutoffDate.getTime()).toBeLessThan(expectedCutoff + 5000);
  });
});
