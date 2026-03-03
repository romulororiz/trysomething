import { describe, it, expect, beforeAll } from "vitest";
import {
  hashPassword,
  comparePassword,
  generateTokenPair,
  verifyAccessToken,
  verifyRefreshToken,
} from "../lib/auth";

// Set up JWT secrets for testing
beforeAll(() => {
  process.env.JWT_SECRET = "test-jwt-secret-for-unit-tests";
  process.env.JWT_REFRESH_SECRET = "test-jwt-refresh-secret-for-unit-tests";
});

describe("hashPassword / comparePassword", () => {
  it("hashes a password and verifies it", async () => {
    const plain = "mySecret123";
    const hashed = await hashPassword(plain);
    expect(hashed).not.toBe(plain);
    expect(hashed.length).toBeGreaterThan(20);
    const match = await comparePassword(plain, hashed);
    expect(match).toBe(true);
  });

  it("rejects wrong password", async () => {
    const hashed = await hashPassword("correct");
    const match = await comparePassword("wrong", hashed);
    expect(match).toBe(false);
  });

  it("produces different hashes for same input (salted)", async () => {
    const h1 = await hashPassword("same");
    const h2 = await hashPassword("same");
    expect(h1).not.toBe(h2);
  });
});

describe("generateTokenPair", () => {
  it("returns accessToken and refreshToken", () => {
    const { accessToken, refreshToken } = generateTokenPair("user_123");
    expect(accessToken).toBeDefined();
    expect(refreshToken).toBeDefined();
    expect(typeof accessToken).toBe("string");
    expect(typeof refreshToken).toBe("string");
    expect(accessToken).not.toBe(refreshToken);
  });

  it("embeds userId as sub claim", () => {
    const { accessToken } = generateTokenPair("user_456");
    const decoded = verifyAccessToken(accessToken);
    expect(decoded.sub).toBe("user_456");
  });
});

describe("verifyAccessToken", () => {
  it("verifies a valid access token", () => {
    const { accessToken } = generateTokenPair("user_789");
    const { sub } = verifyAccessToken(accessToken);
    expect(sub).toBe("user_789");
  });

  it("throws on invalid token", () => {
    expect(() => verifyAccessToken("garbage.token.here")).toThrow();
  });

  it("throws on refresh token (wrong secret)", () => {
    const { refreshToken } = generateTokenPair("user_789");
    expect(() => verifyAccessToken(refreshToken)).toThrow();
  });
});

describe("verifyRefreshToken", () => {
  it("verifies a valid refresh token", () => {
    const { refreshToken } = generateTokenPair("user_abc");
    const { sub } = verifyRefreshToken(refreshToken);
    expect(sub).toBe("user_abc");
  });

  it("throws on invalid token", () => {
    expect(() => verifyRefreshToken("not.a.token")).toThrow();
  });

  it("throws on access token (wrong secret)", () => {
    const { accessToken } = generateTokenPair("user_abc");
    expect(() => verifyRefreshToken(accessToken)).toThrow();
  });
});
