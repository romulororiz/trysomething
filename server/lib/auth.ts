import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import type { VercelRequest, VercelResponse } from "@vercel/node";
import { errorResponse } from "./middleware";

const SALT_ROUNDS = 12;

// ── Password ─────────────────────────────────────

export async function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, SALT_ROUNDS);
}

export async function comparePassword(
  plain: string,
  hash: string
): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}

// ── JWT ──────────────────────────────────────────

export function generateTokenPair(userId: string) {
  const accessToken = jwt.sign({ sub: userId }, process.env.JWT_SECRET!, {
    expiresIn: "15m",
  });
  const refreshToken = jwt.sign(
    { sub: userId },
    process.env.JWT_REFRESH_SECRET!,
    { expiresIn: "30d" }
  );
  return { accessToken, refreshToken };
}

export function verifyAccessToken(token: string): { sub: string } {
  return jwt.verify(token, process.env.JWT_SECRET!) as { sub: string };
}

export function verifyRefreshToken(token: string): { sub: string } {
  return jwt.verify(token, process.env.JWT_REFRESH_SECRET!) as { sub: string };
}

// ── Auth guard ───────────────────────────────────

/**
 * Extracts and verifies the JWT from the Authorization header.
 * Returns the userId on success, or null after sending a 401 response.
 */
export function requireAuth(
  req: VercelRequest,
  res: VercelResponse
): string | null {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    errorResponse(res, 401, "Missing or invalid authorization header");
    return null;
  }
  try {
    const { sub } = verifyAccessToken(header.slice(7));
    return sub;
  } catch {
    errorResponse(res, 401, "Invalid or expired token");
    return null;
  }
}
