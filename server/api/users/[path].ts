import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { requireAuth } from "../../lib/auth";
import {
  mapUserWithPreferences,
  mapUserPreference,
} from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;

  const { path } = req.query;

  switch (path) {
    case "me":
      return handleMe(req, res);
    case "preferences":
      return handlePreferences(req, res);
    default:
      errorResponse(res, 404, `Unknown user path '${path}'`);
  }
}

// ── /users/me ────────────────────────────────────

async function handleMe(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "PUT"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "GET") {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: { preferences: true },
      });
      if (!user) {
        errorResponse(res, 404, "User not found");
        return;
      }
      res.status(200).json(mapUserWithPreferences(user));
    } else {
      const { displayName, avatarUrl } = req.body ?? {};
      const user = await prisma.user.update({
        where: { id: userId },
        data: {
          ...(displayName !== undefined && {
            displayName: String(displayName).trim(),
          }),
          ...(avatarUrl !== undefined && { avatarUrl }),
        },
        include: { preferences: true },
      });
      res.status(200).json(mapUserWithPreferences(user));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/me error:`, err);
    errorResponse(res, 500, "Failed to process user request");
  }
}

// ── /users/preferences ──────────────────────────

async function handlePreferences(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["PUT"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    const { hoursPerWeek, budgetLevel, preferSocial, vibes } = req.body ?? {};

    const preference = await prisma.userPreference.upsert({
      where: { userId },
      create: {
        userId,
        ...(hoursPerWeek !== undefined && { hoursPerWeek }),
        ...(budgetLevel !== undefined && { budgetLevel }),
        ...(preferSocial !== undefined && { preferSocial }),
        ...(vibes !== undefined && { vibes }),
      },
      update: {
        ...(hoursPerWeek !== undefined && { hoursPerWeek }),
        ...(budgetLevel !== undefined && { budgetLevel }),
        ...(preferSocial !== undefined && { preferSocial }),
        ...(vibes !== undefined && { vibes }),
      },
    });

    res.status(200).json(mapUserPreference(preference));
  } catch (err) {
    console.error("PUT /api/users/preferences error:", err);
    errorResponse(res, 500, "Failed to update preferences");
  }
}
