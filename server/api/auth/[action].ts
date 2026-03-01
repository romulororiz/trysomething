import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import {
  hashPassword,
  comparePassword,
  generateTokenPair,
  verifyRefreshToken,
} from "../../lib/auth";
import { mapUserWithPreferences } from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const { action } = req.query;

  switch (action) {
    case "register":
      return handleRegister(req, res);
    case "login":
      return handleLogin(req, res);
    case "refresh":
      return handleRefresh(req, res);
    case "google":
      return handleGoogle(req, res);
    default:
      errorResponse(res, 404, `Unknown auth action '${action}'`);
  }
}

// ── Register ─────────────────────────────────────

async function handleRegister(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
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

// ── Login ────────────────────────────────────────

async function handleLogin(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
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

// ── Refresh ──────────────────────────────────────

async function handleRefresh(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  try {
    const { refreshToken } = req.body ?? {};

    if (!refreshToken) {
      errorResponse(res, 400, "refreshToken is required");
      return;
    }

    let sub: string;
    try {
      ({ sub } = verifyRefreshToken(refreshToken));
    } catch {
      errorResponse(res, 401, "Invalid or expired refresh token");
      return;
    }

    const user = await prisma.user.findUnique({ where: { id: sub } });
    if (!user) {
      errorResponse(res, 401, "User not found");
      return;
    }

    const tokens = generateTokenPair(user.id);

    res.status(200).json(tokens);
  } catch (err) {
    console.error("POST /api/auth/refresh error:", err);
    errorResponse(res, 500, "Token refresh failed");
  }
}

// ── Google Sign-In ───────────────────────────────

interface GoogleTokenInfo {
  sub: string;
  email: string;
  name?: string;
  picture?: string;
  aud: string;
}

async function handleGoogle(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  try {
    const { idToken, accessToken } = req.body ?? {};

    if (!idToken && !accessToken) {
      errorResponse(res, 400, "idToken or accessToken is required");
      return;
    }

    let googleId: string;
    let email: string;
    let name: string | undefined;
    let picture: string | undefined;

    if (idToken) {
      // Verify ID token via Google's tokeninfo endpoint
      const tokenInfoUrl = `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`;
      const googleRes = await fetch(tokenInfoUrl);

      if (!googleRes.ok) {
        errorResponse(res, 401, "Invalid Google ID token");
        return;
      }

      const tokenInfo = (await googleRes.json()) as GoogleTokenInfo;

      // Accept tokens from any client ID in our Google Cloud project.
      const allowedAudiences = (process.env.GOOGLE_CLIENT_IDS ?? process.env.GOOGLE_CLIENT_ID ?? "")
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean);

      if (allowedAudiences.length > 0 && !allowedAudiences.includes(tokenInfo.aud)) {
        errorResponse(res, 401, "Google token audience mismatch");
        return;
      }

      googleId = tokenInfo.sub;
      email = tokenInfo.email;
      name = tokenInfo.name;
      picture = tokenInfo.picture;
    } else {
      // Fallback: verify access token via Google's userinfo endpoint
      // (used on platforms where idToken is unavailable, e.g. Windows)
      const userinfoRes = await fetch("https://www.googleapis.com/oauth2/v3/userinfo", {
        headers: { Authorization: `Bearer ${accessToken}` },
      });

      if (!userinfoRes.ok) {
        errorResponse(res, 401, "Invalid Google access token");
        return;
      }

      const userinfo = (await userinfoRes.json()) as {
        sub: string;
        email: string;
        name?: string;
        picture?: string;
      };

      googleId = userinfo.sub;
      email = userinfo.email;
      name = userinfo.name;
      picture = userinfo.picture;
    }

    let user = await prisma.user.findFirst({
      where: {
        OR: [{ googleId }, { email: email.toLowerCase() }],
      },
      include: { preferences: true },
    });

    if (user) {
      if (!user.googleId) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { googleId },
          include: { preferences: true },
        });
      }
    } else {
      user = await prisma.user.create({
        data: {
          email: email.toLowerCase(),
          passwordHash: "",
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
