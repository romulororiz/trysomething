import { describe, it, expect, vi, beforeEach } from "vitest";
import type { VercelRequest, VercelResponse } from "@vercel/node";

vi.mock("../lib/db", () => ({
  prisma: { $queryRaw: vi.fn() },
}));

vi.mock("../lib/middleware", () => ({
  handleCors: vi.fn().mockReturnValue(false),
  methodNotAllowed: vi.fn().mockReturnValue(false),
}));

// Import mocked modules — Vitest hoists vi.mock() so these receive the mocked versions
import { prisma } from "../lib/db";
import { handleCors, methodNotAllowed } from "../lib/middleware";
import handler from "../api/health";

function mockRes(): VercelResponse {
  const res: any = {};
  res.status = vi.fn().mockReturnValue(res);
  res.json = vi.fn().mockReturnValue(res);
  res.end = vi.fn().mockReturnValue(res);
  res.setHeader = vi.fn().mockReturnValue(res);
  return res as VercelResponse;
}

function mockReq(method = "GET"): VercelRequest {
  return { method, query: {}, body: {} } as unknown as VercelRequest;
}

describe("GET /api/health", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(handleCors).mockReturnValue(false);
    vi.mocked(methodNotAllowed).mockReturnValue(false);
  });

  it("returns 200 with status=ok and version=1.0.0 on DB success", async () => {
    vi.mocked(prisma.$queryRaw).mockResolvedValueOnce([{ "?column?": 1 }] as any);

    const req = mockReq("GET");
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const jsonArg = vi.mocked(res.json).mock.calls[0][0];
    expect(jsonArg.status).toBe("ok");
    expect(jsonArg.version).toBe("1.0.0");
    expect(typeof jsonArg.timestamp).toBe("string");
  });

  it("returns 503 with status=error when DB query throws", async () => {
    vi.mocked(prisma.$queryRaw).mockRejectedValueOnce(new Error("Connection refused"));

    const req = mockReq("GET");
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(503);
    const jsonArg = vi.mocked(res.json).mock.calls[0][0];
    expect(jsonArg.status).toBe("error");
    expect(jsonArg.message).toBe("Database connection failed");
  });

  it("returns early without querying DB when methodNotAllowed blocks the request", async () => {
    vi.mocked(methodNotAllowed).mockReturnValueOnce(true);

    const req = mockReq("POST");
    const res = mockRes();

    await handler(req, res);

    expect(prisma.$queryRaw).not.toHaveBeenCalled();
    expect(res.json).not.toHaveBeenCalled();
  });
});
