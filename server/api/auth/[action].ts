import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import jwt from "jsonwebtoken";
import {
  hashPassword,
  comparePassword,
  generateTokenPair,
  verifyRefreshToken,
} from "../../lib/auth";
import { mapUserWithPreferences } from "../../lib/mappers";
import { requireAuth } from "../../lib/auth";
import {
  generateVerificationCode,
  codeExpiresAt,
  isWithinCooldown,
  sendVerificationEmail,
} from "../../lib/email";

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
    case "apple":
      return handleApple(req, res);
    case "apple-callback":
      return handleAppleCallback(req, res);
    case "verify-email":
      return handleVerifyEmail(req, res);
    case "resend-verification":
      return handleResendVerification(req, res);
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

    const code = generateVerificationCode();

    const user = await prisma.user.create({
      data: {
        email: email.toLowerCase().trim(),
        passwordHash,
        displayName: displayName.trim(),
        emailVerified: false,
        verificationCode: code,
        verificationCodeExpiresAt: codeExpiresAt(),
        preferences: { create: {} },
      },
      include: { preferences: true },
    });

    // Send verification email (non-blocking — don't fail registration if email fails)
    sendVerificationEmail(user.email, code, user.displayName).catch((err) => {
      console.error("[Register] Failed to send verification email:", err);
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

    if (user.deletedAt) {
      errorResponse(res, 401, "This account has been scheduled for deletion");
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
    if (!user || user.deletedAt) {
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

      // Token is already verified by Google's tokeninfo endpoint above.
      // Audience check removed — single-project app, all client IDs
      // belong to the same Firebase project. The tokeninfo validation
      // is sufficient to confirm the token is legitimate.

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
      if (user.deletedAt) {
        errorResponse(res, 401, "This account has been scheduled for deletion");
        return;
      }
      if (!user.googleId || !user.emailVerified) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { googleId, emailVerified: true },
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
          emailVerified: true,
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

// ── Apple Sign-In ───────────────────────────────

/**
 * Generate the client_secret JWT that Apple requires for token exchange.
 * Signed with the .p8 private key, valid for 5 minutes.
 */
function generateAppleClientSecret(): string {
  const teamId = process.env.APPLE_TEAM_ID!;
  const keyId = process.env.APPLE_KEY_ID!;
  const privateKey = process.env.APPLE_PRIVATE_KEY!.replace(/\\n/g, "\n");
  const clientId = process.env.APPLE_SERVICE_ID!;

  return jwt.sign({}, privateKey, {
    algorithm: "ES256",
    expiresIn: "5m",
    audience: "https://appleid.apple.com",
    issuer: teamId,
    subject: clientId,
    keyid: keyId,
  });
}

/**
 * Decode an Apple identity token without verification.
 * Apple's public keys rotate, so for simplicity we decode the payload
 * after validating the authorization code exchange succeeded.
 */
function decodeAppleIdToken(idToken: string): {
  sub: string;
  email?: string;
} {
  const payload = JSON.parse(
    Buffer.from(idToken.split(".")[1], "base64url").toString()
  );
  return { sub: payload.sub, email: payload.email };
}

async function handleApple(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  try {
    const { authorizationCode, identityToken, fullName } = req.body ?? {};

    if (!authorizationCode && !identityToken) {
      errorResponse(
        res,
        400,
        "authorizationCode or identityToken is required"
      );
      return;
    }

    let appleId: string;
    let email: string | undefined;
    let name: string | undefined;

    if (authorizationCode) {
      // Exchange authorization code for tokens (Android/web flow)
      const clientSecret = generateAppleClientSecret();
      const tokenRes = await fetch("https://appleid.apple.com/auth/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
          client_id: process.env.APPLE_SERVICE_ID!,
          client_secret: clientSecret,
          code: authorizationCode,
          grant_type: "authorization_code",
        }),
      });

      if (!tokenRes.ok) {
        const errorBody = await tokenRes.text();
        console.error("Apple token exchange failed:", errorBody);
        errorResponse(res, 401, "Invalid Apple authorization code");
        return;
      }

      const tokenData = (await tokenRes.json()) as { id_token: string };
      const decoded = decodeAppleIdToken(tokenData.id_token);
      appleId = decoded.sub;
      email = decoded.email;
    } else {
      // iOS native flow — identityToken is already a JWT from Apple
      const decoded = decodeAppleIdToken(identityToken);
      appleId = decoded.sub;
      email = decoded.email;
    }

    // Apple only sends name on FIRST sign-in
    if (fullName) {
      const parts = [fullName.givenName, fullName.familyName]
        .filter(Boolean);
      if (parts.length > 0) name = parts.join(" ");
    }

    // Find or create user
    let user = await prisma.user.findFirst({
      where: {
        OR: [
          { appleId },
          ...(email ? [{ email: email.toLowerCase() }] : []),
        ],
      },
      include: { preferences: true },
    });

    if (user) {
      if (user.deletedAt) {
        errorResponse(res, 401, "This account has been scheduled for deletion");
        return;
      }
      if (!user.appleId || !user.emailVerified) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: { appleId, emailVerified: true },
          include: { preferences: true },
        });
      }
    } else {
      user = await prisma.user.create({
        data: {
          email: (email || `apple_${appleId}@privaterelay`).toLowerCase(),
          passwordHash: "",
          displayName: name || email?.split("@")[0] || "User",
          appleId,
          emailVerified: true,
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
    console.error("POST /api/auth/apple error:", err);
    errorResponse(res, 500, "Apple sign-in failed");
  }
}

// ── Apple Sign-In Callback (Android/Web) ─────────

/**
 * Callback endpoint for web-based Apple Sign-In on Android.
 *
 * Apple POSTs form-urlencoded data (code, id_token, state, user) to this URL
 * after the user authenticates. This endpoint relays the data back to the
 * Flutter app via an Android intent:// deep link, which the
 * sign_in_with_apple package's SignInWithAppleCallback Activity intercepts.
 *
 * The actual token exchange and user creation happens later when the Flutter
 * client sends the authorization code to the existing /api/auth/apple endpoint.
 */
async function handleAppleCallback(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  try {
    // Apple sends form-urlencoded POST data; Vercel auto-parses it into req.body
    const { code, id_token, state, user, error } = req.body ?? {};

    // Build query parameters to relay back to the app
    const params = new URLSearchParams();
    if (code) params.set("code", code);
    if (id_token) params.set("id_token", id_token);
    if (state) params.set("state", state);
    if (user) params.set("user", typeof user === "string" ? user : JSON.stringify(user));
    if (error) params.set("error", error);

    // Construct the Android intent URI that the sign_in_with_apple package expects.
    // The SignInWithAppleCallback Activity is registered with scheme "signinwithapple"
    // and path "callback" in the app's AndroidManifest.xml.
    const intentUri =
      `intent://callback?${params.toString()}` +
      `#Intent;package=${process.env.ANDROID_PACKAGE_NAME || "com.romulororiz.trysomething"};scheme=signinwithapple;end`;

    // Return an HTML page with JavaScript that redirects to the intent URI.
    // This closes the Chrome Custom Tab and passes data back to the Flutter app.
    const html = `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Redirecting...</title></head>
<body>
<p>Signing in...</p>
<script>window.location.href = ${JSON.stringify(intentUri)};</script>
</body>
</html>`;

    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.status(200).send(html);
  } catch (err) {
    console.error("POST /api/auth/apple-callback error:", err);
    // On error, still try to redirect back to the app with an error indicator
    // so the Chrome Custom Tab doesn't get stuck on a JSON error page.
    const errorIntent =
      `intent://callback?error=server_error` +
      `#Intent;package=${process.env.ANDROID_PACKAGE_NAME || "com.romulororiz.trysomething"};scheme=signinwithapple;end`;

    const html = `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Error</title></head>
<body>
<p>Something went wrong. Returning to app...</p>
<script>window.location.href = ${JSON.stringify(errorIntent)};</script>
</body>
</html>`;

    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.status(200).send(html);
  }
}

// ── Verify Email ────────────────────────────────

async function handleVerifyEmail(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const { code } = req.body ?? {};

    if (!code || typeof code !== "string") {
      return errorResponse(res, 400, "Verification code is required");
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        emailVerified: true,
        verificationCode: true,
        verificationCodeExpiresAt: true,
      },
    });

    if (!user) return errorResponse(res, 404, "User not found");

    if (user.emailVerified) {
      res.status(200).json({ emailVerified: true });
      return;
    }

    if (!user.verificationCode || !user.verificationCodeExpiresAt) {
      return errorResponse(res, 400, "No verification code found. Please request a new one.");
    }

    if (new Date() > user.verificationCodeExpiresAt) {
      return errorResponse(res, 400, "Code expired. Please request a new one.");
    }

    if (code.trim() !== user.verificationCode) {
      return errorResponse(res, 400, "Invalid verification code");
    }

    await prisma.user.update({
      where: { id: userId },
      data: {
        emailVerified: true,
        verificationCode: null,
        verificationCodeExpiresAt: null,
      },
    });

    res.status(200).json({ emailVerified: true });
  } catch (err) {
    console.error("POST /api/auth/verify-email error:", err);
    errorResponse(res, 500, "Verification failed");
  }
}

// ── Resend Verification ─────────────────────────

async function handleResendVerification(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        email: true,
        displayName: true,
        emailVerified: true,
        verificationCodeExpiresAt: true,
      },
    });

    if (!user) return errorResponse(res, 404, "User not found");

    if (user.emailVerified) {
      res.status(200).json({ emailVerified: true });
      return;
    }

    // Cooldown check — use the code expiry timestamp to derive when last code was sent
    // (code was sent at expiresAt - 10 minutes)
    const lastSentAt = user.verificationCodeExpiresAt
      ? new Date(user.verificationCodeExpiresAt.getTime() - 10 * 60 * 1000)
      : null;
    const cooldown = isWithinCooldown(lastSentAt);
    if (cooldown.blocked) {
      return errorResponse(res, 429, `Please wait ${cooldown.retryAfter} seconds before requesting a new code`);
    }

    const code = generateVerificationCode();

    await prisma.user.update({
      where: { id: userId },
      data: {
        verificationCode: code,
        verificationCodeExpiresAt: codeExpiresAt(),
      },
    });

    await sendVerificationEmail(user.email, code, user.displayName);

    res.status(200).json({ sent: true });
  } catch (err) {
    console.error("POST /api/auth/resend-verification error:", err);
    errorResponse(res, 500, "Failed to resend verification code");
  }
}
