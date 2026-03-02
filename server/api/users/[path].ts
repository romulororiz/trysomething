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
  mapUserHobby,
  mapActivityLog,
  mapJournalEntry,
  mapPersonalNote,
  mapScheduleEvent,
  mapShoppingCheck,
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
    case "hobbies":
      return handleHobbies(req, res);
    case "hobbies-sync":
      return handleHobbiesSync(req, res);
    case "hobbies-detail":
      return handleHobbyDetail(req, res);
    case "activity":
      return handleActivity(req, res);
    case "journal":
      return handleJournal(req, res);
    case "journal-detail":
      return handleJournalDetail(req, res);
    case "notes":
      return handleNotes(req, res);
    case "schedule":
      return handleSchedule(req, res);
    case "schedule-detail":
      return handleScheduleDetail(req, res);
    case "shopping":
      return handleShopping(req, res);
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

// ── /users/hobbies ──────────────────────────────

async function handleHobbies(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "POST"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "GET") {
      const hobbies = await prisma.userHobby.findMany({
        where: { userId },
        include: { completedSteps: { select: { stepId: true } } },
      });
      res.status(200).json(hobbies.map(mapUserHobby));
    } else {
      // POST — save a hobby
      const { hobbyId } = req.body ?? {};
      if (!hobbyId) {
        errorResponse(res, 400, "hobbyId is required");
        return;
      }

      const hobby = await prisma.userHobby.upsert({
        where: { userId_hobbyId: { userId, hobbyId } },
        create: { userId, hobbyId, status: "saved" },
        update: {},
        include: { completedSteps: { select: { stepId: true } } },
      });

      await prisma.userActivityLog.create({
        data: { userId, hobbyId, action: "save" },
      });

      res.status(201).json(mapUserHobby(hobby));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/hobbies error:`, err);
    errorResponse(res, 500, "Failed to process hobbies request");
  }
}

// ── /users/hobbies-sync ─────────────────────────

async function handleHobbiesSync(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["POST"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    const { hobbies } = req.body ?? {};
    if (!Array.isArray(hobbies)) {
      errorResponse(res, 400, "hobbies array is required");
      return;
    }

    // Delete all existing user hobbies, then insert client state
    await prisma.$transaction(async (tx) => {
      await tx.userHobby.deleteMany({ where: { userId } });

      for (const h of hobbies) {
        const userHobby = await tx.userHobby.create({
          data: {
            userId,
            hobbyId: h.hobbyId,
            status: h.status ?? "saved",
            startedAt: h.startedAt ? new Date(h.startedAt) : null,
            completedAt: h.completedAt ? new Date(h.completedAt) : null,
            lastActivityAt: h.lastActivityAt
              ? new Date(h.lastActivityAt)
              : null,
            streakDays: h.streakDays ?? 0,
          },
        });

        // Insert completed steps if provided
        const stepIds: string[] = h.completedStepIds ?? [];
        if (stepIds.length > 0) {
          await tx.userCompletedStep.createMany({
            data: stepIds.map((stepId: string) => ({
              userId,
              hobbyId: h.hobbyId,
              stepId,
            })),
          });
        }
      }
    });

    // Return the synced state
    const result = await prisma.userHobby.findMany({
      where: { userId },
      include: { completedSteps: { select: { stepId: true } } },
    });
    res.status(200).json(result.map(mapUserHobby));
  } catch (err) {
    console.error("POST /api/users/hobbies-sync error:", err);
    errorResponse(res, 500, "Failed to sync hobbies");
  }
}

// ── /users/hobbies/:hobbyId (+ /steps/:stepId) ─

async function handleHobbyDetail(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["PUT", "DELETE", "POST"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  const hobbyId = req.query.hobbyId as string;
  if (!hobbyId) {
    errorResponse(res, 400, "hobbyId is required");
    return;
  }

  try {
    // POST /users/hobbies/:hobbyId/steps/:stepId — toggle step
    const stepId = req.query.stepId as string | undefined;
    if (req.method === "POST" && stepId) {
      const existing = await prisma.userCompletedStep.findUnique({
        where: { userId_hobbyId_stepId: { userId, hobbyId, stepId } },
      });

      if (existing) {
        await prisma.userCompletedStep.delete({
          where: { id: existing.id },
        });
      } else {
        await prisma.userCompletedStep.create({
          data: { userId, hobbyId, stepId },
        });
      }

      // Update lastActivityAt
      await prisma.userHobby.update({
        where: { userId_hobbyId: { userId, hobbyId } },
        data: { lastActivityAt: new Date() },
      });

      await prisma.userActivityLog.create({
        data: {
          userId,
          hobbyId,
          action: existing ? "step_uncomplete" : "step_complete",
        },
      });

      const hobby = await prisma.userHobby.findUnique({
        where: { userId_hobbyId: { userId, hobbyId } },
        include: { completedSteps: { select: { stepId: true } } },
      });
      res.status(200).json(mapUserHobby(hobby!));
      return;
    }

    // PUT /users/hobbies/:hobbyId — update status
    if (req.method === "PUT") {
      const { status, startedAt, completedAt } = req.body ?? {};
      const hobby = await prisma.userHobby.update({
        where: { userId_hobbyId: { userId, hobbyId } },
        data: {
          ...(status !== undefined && { status }),
          ...(startedAt !== undefined && {
            startedAt: startedAt ? new Date(startedAt) : null,
          }),
          ...(completedAt !== undefined && {
            completedAt: completedAt ? new Date(completedAt) : null,
          }),
          lastActivityAt: new Date(),
        },
        include: { completedSteps: { select: { stepId: true } } },
      });

      await prisma.userActivityLog.create({
        data: { userId, hobbyId, action: `status_${status}` },
      });

      res.status(200).json(mapUserHobby(hobby));
      return;
    }

    // DELETE /users/hobbies/:hobbyId — unsave/remove
    if (req.method === "DELETE") {
      await prisma.userHobby.delete({
        where: { userId_hobbyId: { userId, hobbyId } },
      });

      await prisma.userActivityLog.create({
        data: { userId, hobbyId, action: "unsave" },
      });

      res.status(204).end();
      return;
    }
  } catch (err) {
    console.error(
      `${req.method} /api/users/hobbies/${hobbyId} error:`,
      err
    );
    errorResponse(res, 500, "Failed to process hobby request");
  }
}

// ── /users/activity ─────────────────────────────

async function handleActivity(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    const days = parseInt((req.query.days as string) ?? "365", 10);
    const since = new Date();
    since.setDate(since.getDate() - days);

    const logs = await prisma.userActivityLog.findMany({
      where: { userId, createdAt: { gte: since } },
      orderBy: { createdAt: "desc" },
    });
    res.status(200).json(logs.map(mapActivityLog));
  } catch (err) {
    console.error("GET /api/users/activity error:", err);
    errorResponse(res, 500, "Failed to get activity log");
  }
}

// ── /users/journal ─────────────────────────────

async function handleJournal(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "POST"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "GET") {
      const entries = await prisma.journalEntry.findMany({
        where: { userId },
        orderBy: { createdAt: "desc" },
      });
      res.status(200).json(entries.map(mapJournalEntry));
    } else {
      const { hobbyId, text, photoUrl } = req.body ?? {};
      if (!hobbyId || !text) {
        errorResponse(res, 400, "hobbyId and text are required");
        return;
      }

      const entry = await prisma.journalEntry.create({
        data: { userId, hobbyId, text, photoUrl: photoUrl ?? null },
      });
      res.status(201).json(mapJournalEntry(entry));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/journal error:`, err);
    errorResponse(res, 500, "Failed to process journal request");
  }
}

// ── /users/journal/:entryId ────────────────────

async function handleJournalDetail(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["DELETE"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  const entryId = req.query.entryId as string;
  if (!entryId) {
    errorResponse(res, 400, "entryId is required");
    return;
  }

  try {
    await prisma.journalEntry.deleteMany({
      where: { id: entryId, userId },
    });
    res.status(204).end();
  } catch (err) {
    console.error(`DELETE /api/users/journal/${entryId} error:`, err);
    errorResponse(res, 500, "Failed to delete journal entry");
  }
}

// ── /users/notes/:hobbyId ─────────────────────

async function handleNotes(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "PUT", "DELETE"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  const hobbyId = req.query.hobbyId as string;
  if (!hobbyId) {
    errorResponse(res, 400, "hobbyId is required");
    return;
  }

  try {
    if (req.method === "GET") {
      const notes = await prisma.personalNote.findMany({
        where: { userId, hobbyId },
      });
      res.status(200).json(notes.map(mapPersonalNote));
    } else if (req.method === "PUT") {
      const { stepId, text } = req.body ?? {};
      if (!stepId || text === undefined) {
        errorResponse(res, 400, "stepId and text are required");
        return;
      }

      const note = await prisma.personalNote.upsert({
        where: { userId_hobbyId_stepId: { userId, hobbyId, stepId } },
        create: { userId, hobbyId, stepId, text },
        update: { text },
      });
      res.status(200).json(mapPersonalNote(note));
    } else {
      // DELETE
      const stepId = req.query.stepId as string;
      if (!stepId) {
        errorResponse(res, 400, "stepId is required");
        return;
      }

      await prisma.personalNote.deleteMany({
        where: { userId, hobbyId, stepId },
      });
      res.status(204).end();
    }
  } catch (err) {
    console.error(`${req.method} /api/users/notes/${hobbyId} error:`, err);
    errorResponse(res, 500, "Failed to process notes request");
  }
}

// ── /users/schedule ───────────────────────────

async function handleSchedule(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "POST"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "GET") {
      const events = await prisma.scheduleEvent.findMany({
        where: { userId },
      });
      res.status(200).json(events.map(mapScheduleEvent));
    } else {
      const { hobbyId, dayOfWeek, startTime, durationMinutes } =
        req.body ?? {};
      if (!hobbyId || dayOfWeek === undefined || !startTime || !durationMinutes) {
        errorResponse(
          res,
          400,
          "hobbyId, dayOfWeek, startTime, and durationMinutes are required"
        );
        return;
      }

      const event = await prisma.scheduleEvent.create({
        data: { userId, hobbyId, dayOfWeek, startTime, durationMinutes },
      });
      res.status(201).json(mapScheduleEvent(event));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/schedule error:`, err);
    errorResponse(res, 500, "Failed to process schedule request");
  }
}

// ── /users/schedule/:eventId ──────────────────

async function handleScheduleDetail(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["DELETE"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  const eventId = req.query.eventId as string;
  if (!eventId) {
    errorResponse(res, 400, "eventId is required");
    return;
  }

  try {
    await prisma.scheduleEvent.deleteMany({
      where: { id: eventId, userId },
    });
    res.status(204).end();
  } catch (err) {
    console.error(`DELETE /api/users/schedule/${eventId} error:`, err);
    errorResponse(res, 500, "Failed to delete schedule event");
  }
}

// ── /users/shopping/:hobbyId ──────────────────

async function handleShopping(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "PUT"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  const hobbyId = req.query.hobbyId as string;
  if (!hobbyId) {
    errorResponse(res, 400, "hobbyId is required");
    return;
  }

  try {
    if (req.method === "GET") {
      const checks = await prisma.shoppingCheck.findMany({
        where: { userId, hobbyId },
      });
      res.status(200).json(checks.map(mapShoppingCheck));
    } else {
      const { itemName, checked } = req.body ?? {};
      if (!itemName || checked === undefined) {
        errorResponse(res, 400, "itemName and checked are required");
        return;
      }

      const check = await prisma.shoppingCheck.upsert({
        where: {
          userId_hobbyId_itemName: { userId, hobbyId, itemName },
        },
        create: { userId, hobbyId, itemName, checked },
        update: { checked },
      });
      res.status(200).json(mapShoppingCheck(check));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/shopping/${hobbyId} error:`, err);
    errorResponse(res, 500, "Failed to process shopping request");
  }
}
