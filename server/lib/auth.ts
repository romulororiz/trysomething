import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import type { VercelRequest, VercelResponse } from "@vercel/node";
import { errorResponse } from "./middleware";
import { prisma } from "./db";

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
 * Checks that the user has not been soft-deleted.
 * Returns the userId on success, or null after sending a 401 response.
 */
export async function requireAuth(
  req: VercelRequest,
  res: VercelResponse
): Promise<string | null> {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    errorResponse(res, 401, "Missing or invalid authorization header");
    return null;
  }
  try {
    const { sub } = verifyAccessToken(header.slice(7));

    // Check if user is soft-deleted
    const user = await prisma.user.findUnique({
      where: { id: sub },
      select: { deletedAt: true },
    });
    if (!user || user.deletedAt) {
      errorResponse(res, 401, "Invalid or expired token");
      return null;
    }

    return sub;
  } catch {
    errorResponse(res, 401, "Invalid or expired token");
    return null;
  }
}

// ── Pro tier guard ──────────────────────────────

const PAID_TIERS = ["pro", "trial", "lifetime"];

/**
 * Checks that the user has a paid subscription tier (pro, trial, or lifetime).
 * Returns true if the user is on a paid tier, or false after sending a 403 response.
 */
export async function requirePro(
  userId: string,
  res: VercelResponse
): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { subscriptionTier: true },
  });

  if (!user || !PAID_TIERS.includes(user.subscriptionTier)) {
    errorResponse(res, 403, "Pro subscription required");
    return false;
  }

  return true;
}
