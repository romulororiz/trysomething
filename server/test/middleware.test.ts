import { describe, it, expect, vi } from "vitest";
import {
  errorResponse,
  methodNotAllowed,
  handleCors,
} from "../lib/middleware";
import type { VercelRequest, VercelResponse } from "@vercel/node";

/// Create a mock VercelResponse with spies.
function mockRes(): VercelResponse {
  const res = {
    status: vi.fn().mockReturnThis(),
    json: vi.fn().mockReturnThis(),
    end: vi.fn().mockReturnThis(),
    setHeader: vi.fn().mockReturnThis(),
  };
  return res as unknown as VercelResponse;
}

/// Create a mock VercelRequest with the given properties.
function mockReq(overrides: Partial<VercelRequest> = {}): VercelRequest {
  return {
    method: "GET",
    headers: {},
    ...overrides,
  } as unknown as VercelRequest;
}

describe("errorResponse", () => {
  it("sends JSON error with correct status", () => {
    const res = mockRes();
    errorResponse(res, 400, "Bad request");
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ error: "Bad request" });
  });

  it("sends 401 unauthorized", () => {
    const res = mockRes();
    errorResponse(res, 401, "Unauthorized");
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: "Unauthorized" });
  });

  it("sends 500 internal error", () => {
    const res = mockRes();
    errorResponse(res, 500, "Internal error");
    expect(res.status).toHaveBeenCalledWith(500);
  });
});

describe("methodNotAllowed", () => {
  it("returns false for allowed methods", () => {
    const req = mockReq({ method: "GET" });
    const res = mockRes();
    const blocked = methodNotAllowed(req, res, ["GET", "POST"]);
    expect(blocked).toBe(false);
    expect(res.status).not.toHaveBeenCalled();
  });

  it("returns true and sends 405 for disallowed methods", () => {
    const req = mockReq({ method: "DELETE" });
    const res = mockRes();
    const blocked = methodNotAllowed(req, res, ["GET", "POST"]);
    expect(blocked).toBe(true);
    expect(res.status).toHaveBeenCalledWith(405);
    expect(res.setHeader).toHaveBeenCalledWith("Allow", "GET, POST");
  });
});

describe("handleCors", () => {
  it("sets CORS headers on every request", () => {
    const req = mockReq({ method: "GET" });
    const res = mockRes();
    handleCors(req, res);
    expect(res.setHeader).toHaveBeenCalledWith(
      "Access-Control-Allow-Origin",
      "*"
    );
    expect(res.setHeader).toHaveBeenCalledWith(
      "Access-Control-Allow-Methods",
      "GET, POST, PUT, DELETE, OPTIONS"
    );
  });

  it("returns true and ends response for OPTIONS", () => {
    const req = mockReq({ method: "OPTIONS" });
    const res = mockRes();
    const handled = handleCors(req, res);
    expect(handled).toBe(true);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.end).toHaveBeenCalled();
  });

  it("returns false for non-OPTIONS methods", () => {
    const req = mockReq({ method: "POST" });
    const res = mockRes();
    const handled = handleCors(req, res);
    expect(handled).toBe(false);
    expect(res.end).not.toHaveBeenCalled();
  });
});
