import { describe, it, expect, vi } from "vitest";
import {
  errorResponse,
  methodNotAllowed,
  handleCors,
  setCorsHeaders,
} from "../lib/middleware";
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

describe("middleware utilities", () => {
  describe("handleCors", () => {
    it("returns true and ends the response for OPTIONS preflight", () => {
      const req = mockReq({ method: "OPTIONS" });
      const res = mockRes();
      const result = handleCors(req, res);
      expect(result).toBe(true);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.end).toHaveBeenCalled();
    });

    it("returns false and does not end the response for non-OPTIONS requests", () => {
      const req = mockReq({ method: "GET" });
      const res = mockRes();
      const result = handleCors(req, res);
      expect(result).toBe(false);
      expect(res.end).not.toHaveBeenCalled();
    });

    it("sets Access-Control-Allow-Origin header on every request", () => {
      const req = mockReq({ method: "POST" });
      const res = mockRes();
      handleCors(req, res);
      expect(res.setHeader).toHaveBeenCalledWith(
        "Access-Control-Allow-Origin",
        "*"
      );
    });
  });

  describe("methodNotAllowed", () => {
    it("returns false when the request method is in the allowed list", () => {
      const req = mockReq({ method: "GET" });
      const res = mockRes();
      const result = methodNotAllowed(req, res, ["GET", "POST"]);
      expect(result).toBe(false);
      expect(res.status).not.toHaveBeenCalled();
    });

    it("returns true and sends 405 when the method is not allowed", () => {
      const req = mockReq({ method: "DELETE" });
      const res = mockRes();
      const result = methodNotAllowed(req, res, ["GET", "POST"]);
      expect(result).toBe(true);
      expect(res.status).toHaveBeenCalledWith(405);
      expect(res.setHeader).toHaveBeenCalledWith("Allow", "GET, POST");
    });

    it("includes the disallowed method name in the error body", () => {
      const req = mockReq({ method: "PUT" });
      const res = mockRes();
      methodNotAllowed(req, res, ["GET"]);
      expect(res.json).toHaveBeenCalledWith({ error: "Method PUT not allowed" });
    });
  });

  describe("errorResponse", () => {
    it("sends the correct HTTP status code", () => {
      const res = mockRes();
      errorResponse(res, 404, "Not found");
      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("sends JSON body with an error field matching the message", () => {
      const res = mockRes();
      errorResponse(res, 422, "Validation failed");
      expect(res.json).toHaveBeenCalledWith({ error: "Validation failed" });
    });

    it("handles 500 internal server errors", () => {
      const res = mockRes();
      errorResponse(res, 500, "Unexpected failure");
      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: "Unexpected failure" });
    });
  });
});
