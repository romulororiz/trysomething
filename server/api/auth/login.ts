import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { comparePassword, generateTokenPair } from "../../lib/auth";
import { mapUserWithPreferences } from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  try {
    const { email, password } = req.body ?? {};

    if (!email || !password) {
      errorResponse(res, 400, "email and password are required");
      return;
    }

    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase().trim() },
      include: { preferences: true },
    });

    if (!user) {
      errorResponse(res, 401, "Invalid email or password");
      return;
    }

    // Google-only users have an empty passwordHash
    if (!user.passwordHash) {
      errorResponse(
        res,
        401,
        "This account uses Google sign-in. Please sign in with Google."
      );
      return;
    }

    const valid = await comparePassword(password, user.passwordHash);
    if (!valid) {
      errorResponse(res, 401, "Invalid email or password");
      return;
    }

    const tokens = generateTokenPair(user.id);

    res.status(200).json({
      user: mapUserWithPreferences(user),
      ...tokens,
    });
  } catch (err) {
    console.error("POST /api/auth/login error:", err);
    errorResponse(res, 500, "Login failed");
  }
}
