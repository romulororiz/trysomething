import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { hashPassword, generateTokenPair } from "../../lib/auth";
import { mapUserWithPreferences } from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  try {
    const { email, password, displayName } = req.body ?? {};

    if (!email || !password || !displayName) {
      errorResponse(res, 400, "email, password, and displayName are required");
      return;
    }
    if (typeof password !== "string" || password.length < 8) {
      errorResponse(res, 400, "Password must be at least 8 characters");
      return;
    }
    if (typeof email !== "string" || !email.includes("@")) {
      errorResponse(res, 400, "Invalid email address");
      return;
    }

    const existing = await prisma.user.findUnique({
      where: { email: email.toLowerCase().trim() },
    });
    if (existing) {
      errorResponse(res, 409, "Email already registered");
      return;
    }

    const passwordHash = await hashPassword(password);

    const user = await prisma.user.create({
      data: {
        email: email.toLowerCase().trim(),
        passwordHash,
        displayName: displayName.trim(),
        preferences: { create: {} },
      },
      include: { preferences: true },
    });

    const tokens = generateTokenPair(user.id);

    res.status(201).json({
      user: mapUserWithPreferences(user),
      ...tokens,
    });
  } catch (err) {
    console.error("POST /api/auth/register error:", err);
    errorResponse(res, 500, "Registration failed");
  }
}
