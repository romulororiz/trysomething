import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { generateTokenPair } from "../../lib/auth";
import { mapUserWithPreferences } from "../../lib/mappers";

interface GoogleTokenInfo {
  sub: string;
  email: string;
  name?: string;
  picture?: string;
  aud: string;
}

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  try {
    const { idToken } = req.body ?? {};

    if (!idToken) {
      errorResponse(res, 400, "idToken is required");
      return;
    }

    // Verify the Google ID token
    const tokenInfoUrl = `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`;
    const googleRes = await fetch(tokenInfoUrl);

    if (!googleRes.ok) {
      errorResponse(res, 401, "Invalid Google ID token");
      return;
    }

    const tokenInfo = (await googleRes.json()) as GoogleTokenInfo;

    // Verify audience matches our client ID
    if (
      process.env.GOOGLE_CLIENT_ID &&
      tokenInfo.aud !== process.env.GOOGLE_CLIENT_ID
    ) {
      errorResponse(res, 401, "Google token audience mismatch");
      return;
    }

    const { sub: googleId, email, name, picture } = tokenInfo;

    // Find existing user by googleId or email
    let user = await prisma.user.findFirst({
      where: {
        OR: [{ googleId }, { email: email.toLowerCase() }],
      },
      include: { preferences: true },
    });

    if (user) {
      // Link Google ID if not already set
      if (!user.googleId) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { googleId },
          include: { preferences: true },
        });
      }
    } else {
      // Create new user
      user = await prisma.user.create({
        data: {
          email: email.toLowerCase(),
          passwordHash: "", // Google-only user
          displayName: name || email.split("@")[0],
          avatarUrl: picture || null,
          googleId,
          preferences: { create: {} },
        },
        include: { preferences: true },
      });
    }

    const tokens = generateTokenPair(user.id);

    res.status(200).json({
      user: mapUserWithPreferences(user),
      ...tokens,
    });
  } catch (err) {
    console.error("POST /api/auth/google error:", err);
    errorResponse(res, 500, "Google sign-in failed");
  }
}
