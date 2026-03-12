import { describe, it, expect, vi, beforeEach } from "vitest";
import type { VercelRequest, VercelResponse } from "@vercel/node";

// Vitest resolves vi.mock paths relative to the test file.
// api/hobbies/index.ts imports from "../../lib/..." — both resolve to server/lib/...
// From test/ we reach server/lib/... via "../lib/..."
vi.mock("../lib/db", () => ({
  prisma: { hobby: { findMany: vi.fn() } },
}));

vi.mock("../lib/middleware", () => ({
  handleCors: vi.fn().mockReturnValue(false),
  methodNotAllowed: vi.fn().mockReturnValue(false),
  errorResponse: vi.fn(),
}));

vi.mock("../lib/mappers", () => ({
  mapHobby: vi.fn((h) => h),
}));

import { prisma } from "../lib/db";
import { handleCors, methodNotAllowed, errorResponse } from "../lib/middleware";
import handler from "../api/hobbies/index";

function mockRes(): VercelResponse {
  const res: any = {};
  res.status = vi.fn().mockReturnValue(res);
  res.json = vi.fn().mockReturnValue(res);
  res.end = vi.fn().mockReturnValue(res);
  res.setHeader = vi.fn().mockReturnValue(res);
  return res as VercelResponse;
}

function mockReq(method = "GET", query: Record<string, string> = {}): VercelRequest {
  return { method, query, body: {} } as unknown as VercelRequest;
}

describe("GET /api/hobbies", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(handleCors).mockReturnValue(false);
    vi.mocked(methodNotAllowed).mockReturnValue(false);
  });

  it("returns mapped hobbies array for a default GET", async () => {
    vi.mocked(prisma.hobby.findMany).mockResolvedValueOnce([
      { id: "1", title: "Knitting" } as any,
    ]);

    const req = mockReq("GET");
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith([{ id: "1", title: "Knitting" }]);
  });

  it("returns 3 curated packs with correct ids when packs=true", async () => {
    vi.mocked(prisma.hobby.findMany).mockResolvedValue([] as any);

    const req = mockReq("GET", { packs: "true" });
    const res = mockRes();

    await handler(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const jsonArg: any[] = vi.mocked(res.json).mock.calls[0][0];
    expect(jsonArg).toHaveLength(3);
    const ids = jsonArg.map((p: any) => p.id);
    expect(ids).toContain("introverts");
    expect(ids).toContain("budget");
    expect(ids).toContain("community");
  });

  it("returns early without querying DB when methodNotAllowed blocks the request", async () => {
    vi.mocked(methodNotAllowed).mockReturnValueOnce(true);

    const req = mockReq("POST");
    const res = mockRes();

    await handler(req, res);

    expect(prisma.hobby.findMany).not.toHaveBeenCalled();
    expect(res.json).not.toHaveBeenCalled();
  });

  it("calls errorResponse with 500 when findMany throws", async () => {
    vi.mocked(prisma.hobby.findMany).mockRejectedValueOnce(new Error("DB error"));

    const req = mockReq("GET");
    const res = mockRes();

    await handler(req, res);

    expect(errorResponse).toHaveBeenCalledWith(res, 500, "Failed to fetch hobbies");
  });
});
