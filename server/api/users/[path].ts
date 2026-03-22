import type { VercelRequest, VercelResponse } from "@vercel/node";
import crypto from "crypto";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { requireAuth, comparePassword } from "../../lib/auth";
import {
  mapUserWithPreferences,
  mapUserPreference,
  mapUserHobby,
  mapActivityLog,
  mapJournalEntry,
  mapPersonalNote,
  mapScheduleEvent,
  mapShoppingCheck,
  mapCommunityStory,
  mapBuddyProfile,
  mapBuddyActivity,
  mapBuddyRequest,
  mapSimilarUser,
} from "../../lib/mappers";
import {
  handleChallenges,
  handleAchievements,
  checkChallengeProgress,
} from "../../lib/gamification";

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
    case "stories":
      return handleStories(req, res);
    case "stories-detail":
      return handleStoriesDetail(req, res);
    case "stories-react":
      return handleStoriesReact(req, res);
    case "buddies":
      return handleBuddies(req, res);
    case "buddy-requests":
      return handleBuddyRequests(req, res);
    case "buddy-requests-detail":
      return handleBuddyRequestsDetail(req, res);
    case "similar-users":
      return handleSimilarUsers(req, res);
    case "challenges":
      return handleChallengesRoute(req, res);
    case "achievements":
      return handleAchievementsRoute(req, res);
    case "revenuecat-webhook":
      return handleRevenueCatWebhook(req, res);
    case "export":
      return handleExport(req, res);
    case "purge-deleted-users":
      return handlePurgeDeletedUsers(req, res);
    default:
      errorResponse(res, 404, `Unknown user path '${path}'`);
  }
}

// ── /users/me ────────────────────────────────────

async function handleMe(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "PUT", "DELETE"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "DELETE") {
      const { password } = req.body ?? {};
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { passwordHash: true },
      });

      if (!user) {
        errorResponse(res, 404, "User not found");
        return;
      }

      // Verify password for email/password users; skip for OAuth-only users (empty passwordHash)
      if (user.passwordHash) {
        if (!password) {
          errorResponse(res, 400, "Password is required");
          return;
        }
        const valid = await comparePassword(password, user.passwordHash);
        if (!valid) {
          errorResponse(res, 403, "Invalid password");
          return;
        }
      }

      // Soft-delete: set deletedAt timestamp
      const now = new Date();
      const purgeAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

      await prisma.user.update({
        where: { id: userId },
        data: { deletedAt: now },
      });

      res.status(200).json({
        status: "deleted",
        deletedAt: now.toISOString(),
        purgeAt: purgeAt.toISOString(),
      });
    } else if (req.method === "GET") {
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
      const { displayName, avatarUrl, bio } = req.body ?? {};
      const user = await prisma.user.update({
        where: { id: userId },
        data: {
          ...(displayName !== undefined && {
            displayName: String(displayName).trim(),
          }),
          ...(avatarUrl !== undefined && { avatarUrl }),
          ...(bio !== undefined && { bio: String(bio).trim() }),
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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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
      await checkChallengeProgress(userId, "save_hobby");

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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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
      // Ensure hobby exists first (FK constraint on UserCompletedStep)
      await prisma.userHobby.upsert({
        where: { userId_hobbyId: { userId, hobbyId } },
        create: { userId, hobbyId, status: "trying", lastActivityAt: new Date() },
        update: { lastActivityAt: new Date() },
      });

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

      await prisma.userActivityLog.create({
        data: {
          userId,
          hobbyId,
          action: existing ? "step_uncomplete" : "step_complete",
        },
      });
      if (!existing) {
        await checkChallengeProgress(userId, "step_complete");
      }

      const hobby = await prisma.userHobby.findUnique({
        where: { userId_hobbyId: { userId, hobbyId } },
        include: { completedSteps: { select: { stepId: true } } },
      });
      res.status(200).json(mapUserHobby(hobby!));
      return;
    }

    // PUT /users/hobbies/:hobbyId — update status (upsert to handle race conditions)
    if (req.method === "PUT") {
      const { status, startedAt, completedAt } = req.body ?? {};
      const hobby = await prisma.userHobby.upsert({
        where: { userId_hobbyId: { userId, hobbyId } },
        create: {
          userId,
          hobbyId,
          status: status ?? "trying",
          ...(startedAt && { startedAt: new Date(startedAt) }),
          ...(completedAt && { completedAt: new Date(completedAt) }),
          lastActivityAt: new Date(),
        },
        update: {
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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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
      await checkChallengeProgress(userId, "journal_entry");
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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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

  const userId = await requireAuth(req, res);
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

// ── /users/stories ──────────────────────────────

async function handleStories(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "POST"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "GET") {
      const stories = await prisma.communityStory.findMany({
        orderBy: { createdAt: "desc" },
        include: {
          user: { select: { displayName: true } },
          reactions: { select: { type: true, userId: true } },
        },
      });
      res.status(200).json(stories.map((s) => mapCommunityStory(s, userId)));
    } else {
      const { quote, hobbyId } = req.body ?? {};
      if (!quote || !hobbyId) {
        errorResponse(res, 400, "quote and hobbyId are required");
        return;
      }

      const story = await prisma.communityStory.create({
        data: { userId, quote, hobbyId },
        include: {
          user: { select: { displayName: true } },
          reactions: { select: { type: true, userId: true } },
        },
      });
      await checkChallengeProgress(userId, "share_story");
      res.status(201).json(mapCommunityStory(story, userId));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/stories error:`, err);
    errorResponse(res, 500, "Failed to process stories request");
  }
}

// ── /users/stories/:storyId ─────────────────────

async function handleStoriesDetail(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["DELETE"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  const storyId = req.query.storyId as string;
  if (!storyId) {
    errorResponse(res, 400, "storyId is required");
    return;
  }

  try {
    await prisma.communityStory.deleteMany({
      where: { id: storyId, userId },
    });
    res.status(204).end();
  } catch (err) {
    console.error(`DELETE /api/users/stories/${storyId} error:`, err);
    errorResponse(res, 500, "Failed to delete story");
  }
}

// ── /users/stories/:storyId/react/:type ─────────

async function handleStoriesReact(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["POST", "DELETE"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  const storyId = req.query.storyId as string;
  const type = req.query.type as string;
  if (!storyId || !type) {
    errorResponse(res, 400, "storyId and type are required");
    return;
  }

  try {
    if (req.method === "POST") {
      await prisma.storyReaction.upsert({
        where: { userId_storyId_type: { userId, storyId, type } },
        create: { userId, storyId, type },
        update: {},
      });
      res.status(200).json({ ok: true });
    } else {
      await prisma.storyReaction.deleteMany({
        where: { userId, storyId, type },
      });
      res.status(204).end();
    }
  } catch (err) {
    console.error(`${req.method} /api/users/stories/${storyId}/react/${type} error:`, err);
    errorResponse(res, 500, "Failed to process reaction");
  }
}

// ── /users/buddies ──────────────────────────────

async function handleBuddies(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    // Find active buddy pairs
    const pairs = await prisma.buddyPair.findMany({
      where: {
        status: "active",
        OR: [{ requesterId: userId }, { accepterId: userId }],
      },
      include: {
        requester: { select: { id: true, displayName: true } },
        accepter: { select: { id: true, displayName: true } },
      },
    });

    // Get buddy user IDs
    const buddyUserIds = pairs.map((p) =>
      p.requesterId === userId ? p.accepterId : p.requesterId
    );

    // Get buddy profiles with their most active hobby
    const profiles = [];
    const userNameMap: Record<string, string> = {};
    for (const pair of pairs) {
      const buddyUser =
        pair.requesterId === userId ? pair.accepter : pair.requester;
      userNameMap[buddyUser.id] = buddyUser.displayName;

      const topHobby = await prisma.userHobby.findFirst({
        where: {
          userId: buddyUser.id,
          status: { in: ["trying", "active"] },
        },
        orderBy: { lastActivityAt: "desc" },
        include: { completedSteps: { select: { stepId: true } } },
      });

      profiles.push(mapBuddyProfile(buddyUser, topHobby));
    }

    // Get buddy activities (last 7 days)
    const since = new Date();
    since.setDate(since.getDate() - 7);
    const activityLogs =
      buddyUserIds.length > 0
        ? await prisma.userActivityLog.findMany({
            where: {
              userId: { in: buddyUserIds },
              createdAt: { gte: since },
            },
            orderBy: { createdAt: "desc" },
            take: 20,
          })
        : [];

    const activities = activityLogs.map((log) =>
      mapBuddyActivity(log, userNameMap[log.userId] ?? "Unknown")
    );

    res.status(200).json({ profiles, activities });
  } catch (err) {
    console.error("GET /api/users/buddies error:", err);
    errorResponse(res, 500, "Failed to get buddies");
  }
}

// ── /users/buddy-requests ───────────────────────

async function handleBuddyRequests(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "POST"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "GET") {
      const requests = await prisma.buddyPair.findMany({
        where: {
          status: "pending",
          OR: [{ requesterId: userId }, { accepterId: userId }],
        },
        include: {
          requester: { select: { id: true, displayName: true } },
          accepter: { select: { id: true, displayName: true } },
        },
        orderBy: { createdAt: "desc" },
      });
      res
        .status(200)
        .json(requests.map((r) => mapBuddyRequest(r, userId)));
    } else {
      const { targetUserId, hobbyId } = req.body ?? {};
      if (!targetUserId) {
        errorResponse(res, 400, "targetUserId is required");
        return;
      }

      if (targetUserId === userId) {
        errorResponse(res, 400, "Cannot send buddy request to yourself");
        return;
      }

      // Use ordered IDs for the unique constraint (always smaller ID as requester check)
      const pair = await prisma.buddyPair.upsert({
        where: {
          requesterId_accepterId: {
            requesterId: userId,
            accepterId: targetUserId,
          },
        },
        create: {
          requesterId: userId,
          accepterId: targetUserId,
          hobbyId: hobbyId ?? null,
          status: "pending",
        },
        update: {
          status: "pending",
          hobbyId: hobbyId ?? null,
        },
        include: {
          requester: { select: { id: true, displayName: true } },
          accepter: { select: { id: true, displayName: true } },
        },
      });
      res.status(201).json(mapBuddyRequest(pair, userId));
    }
  } catch (err) {
    console.error(`${req.method} /api/users/buddy-requests error:`, err);
    errorResponse(res, 500, "Failed to process buddy request");
  }
}

// ── /users/buddy-requests/:requestId ────────────

async function handleBuddyRequestsDetail(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["PUT", "DELETE"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  const requestId = req.query.requestId as string;
  if (!requestId) {
    errorResponse(res, 400, "requestId is required");
    return;
  }

  try {
    if (req.method === "PUT") {
      // Accept or reject — only the accepter can do this
      const { status } = req.body ?? {};
      if (status !== "active" && status !== "rejected") {
        errorResponse(res, 400, "status must be 'active' or 'rejected'");
        return;
      }

      const pair = await prisma.buddyPair.findUnique({
        where: { id: requestId },
      });
      if (!pair || pair.accepterId !== userId) {
        errorResponse(res, 403, "Only the request recipient can respond");
        return;
      }

      const updated = await prisma.buddyPair.update({
        where: { id: requestId },
        data: { status },
        include: {
          requester: { select: { id: true, displayName: true } },
          accepter: { select: { id: true, displayName: true } },
        },
      });
      res.status(200).json(mapBuddyRequest(updated, userId));
    } else {
      // DELETE — cancel own request (only the requester)
      const pair = await prisma.buddyPair.findUnique({
        where: { id: requestId },
      });
      if (!pair || pair.requesterId !== userId) {
        errorResponse(res, 403, "Only the request sender can cancel");
        return;
      }

      await prisma.buddyPair.delete({ where: { id: requestId } });
      res.status(204).end();
    }
  } catch (err) {
    console.error(`${req.method} /api/users/buddy-requests/${requestId} error:`, err);
    errorResponse(res, 500, "Failed to process buddy request");
  }
}

// ── /users/similar-users ────────────────────────

async function handleSimilarUsers(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const hobbyIdFilter = req.query.hobbyId as string | undefined;

    // Get current user's active hobby IDs
    const myHobbies = await prisma.userHobby.findMany({
      where: {
        userId,
        status: { in: ["trying", "active"] },
      },
      select: { hobbyId: true },
    });
    const myHobbyIds = myHobbies.map((h) => h.hobbyId);

    if (myHobbyIds.length === 0 && !hobbyIdFilter) {
      res.status(200).json([]);
      return;
    }

    // Get existing buddy/request user IDs to exclude
    const existingPairs = await prisma.buddyPair.findMany({
      where: {
        status: { in: ["pending", "active"] },
        OR: [{ requesterId: userId }, { accepterId: userId }],
      },
      select: { requesterId: true, accepterId: true },
    });
    const excludeIds = new Set([userId]);
    for (const p of existingPairs) {
      excludeIds.add(p.requesterId);
      excludeIds.add(p.accepterId);
    }

    // Find users with overlapping hobbies
    const targetHobbyIds = hobbyIdFilter ? [hobbyIdFilter] : myHobbyIds;
    const similarHobbies = await prisma.userHobby.findMany({
      where: {
        hobbyId: { in: targetHobbyIds },
        status: { in: ["trying", "active"] },
        userId: { notIn: Array.from(excludeIds) },
      },
      include: {
        user: { select: { id: true, displayName: true } },
      },
      take: 20,
    });

    // Deduplicate by user (one entry per user, pick first hobby)
    const seen = new Set<string>();
    const results = [];
    for (const uh of similarHobbies) {
      if (seen.has(uh.userId)) continue;
      seen.add(uh.userId);
      results.push(
        mapSimilarUser(uh.user, {
          hobbyId: uh.hobbyId,
          startedAt: uh.startedAt,
        })
      );
    }

    res.status(200).json(results);
  } catch (err) {
    console.error("GET /api/users/similar-users error:", err);
    errorResponse(res, 500, "Failed to get similar users");
  }
}

// ── /users/challenges ──────────────────────────────

async function handleChallengesRoute(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const data = await handleChallenges(userId);
    res.status(200).json(data);
  } catch (err) {
    console.error("GET /api/users/challenges error:", err);
    errorResponse(res, 500, "Failed to get challenges");
  }
}

// ── /users/achievements ────────────────────────────

async function handleAchievementsRoute(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const data = await handleAchievements(userId);
    res.status(200).json(data);
  } catch (err) {
    console.error("GET /api/users/achievements error:", err);
    errorResponse(res, 500, "Failed to get achievements");
  }
}

// ── /webhooks/revenuecat (merged to stay within 12-function limit) ──

async function handleRevenueCatWebhook(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  // D-03: Skip verification in development for local testing
  if (process.env.NODE_ENV !== "development") {
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET;

    // D-01: Fail closed — 503 signals misconfiguration, RevenueCat will retry
    if (!secret) {
      console.warn("[RC Webhook] REVENUECAT_WEBHOOK_SECRET not configured");
      return errorResponse(res, 503, "Webhook not configured");
    }

    // D-02: Reject silently when Authorization header is wrong/missing
    const auth = req.headers.authorization;
    if (!auth) {
      return errorResponse(res, 401, "Unauthorized");
    }

    // Timing-safe comparison to prevent timing attacks
    const expected = `Bearer ${secret}`;
    const incomingBuf = Buffer.from(auth);
    const expectedBuf = Buffer.from(expected);
    if (
      incomingBuf.length !== expectedBuf.length ||
      !crypto.timingSafeEqual(incomingBuf, expectedBuf)
    ) {
      return errorResponse(res, 401, "Unauthorized");
    }
  }

  try {
    const event = req.body?.event;
    if (!event) {
      res.status(400).json({ error: "Missing event data" });
      return;
    }

    const eventType: string = event.type;
    const appUserId: string | undefined = event.app_user_id;
    const expirationAtMs: number | undefined = event.expiration_at_ms;
    const productId: string | undefined = event.product_id;

    if (!appUserId || appUserId.startsWith("$RCAnonymousID")) {
      res.status(200).json({ status: "skipped", reason: "anonymous_user" });
      return;
    }

    let user = await prisma.user.findUnique({ where: { id: appUserId } });
    if (!user) {
      user = await prisma.user.findUnique({ where: { revenuecatId: appUserId } });
      if (!user) {
        res.status(200).json({ status: "skipped", reason: "user_not_found" });
        return;
      }
    }

    const userId = user.id;
    const expiresAt = expirationAtMs ? new Date(expirationAtMs) : undefined;
    const isLifetimeProduct = productId?.includes("lifetime") ?? false;

    switch (eventType) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION":
      case "PRODUCT_CHANGE":
        await prisma.user.update({
          where: { id: userId },
          data: {
            subscriptionTier: isLifetimeProduct ? "lifetime" : "pro",
            proSince: user.proSince ?? new Date(),
            proExpiresAt: isLifetimeProduct ? null : expiresAt,
            isLifetime: isLifetimeProduct,
            revenuecatId: appUserId,
          },
        });
        break;
      case "NON_RENEWING_PURCHASE":
        await prisma.user.update({
          where: { id: userId },
          data: {
            subscriptionTier: "lifetime",
            proSince: user.proSince ?? new Date(),
            proExpiresAt: null,
            isLifetime: true,
            revenuecatId: appUserId,
          },
        });
        break;
      case "CANCELLATION":
      case "EXPIRATION":
        if (!user.isLifetime) {
          await prisma.user.update({
            where: { id: userId },
            data: { subscriptionTier: "free", proExpiresAt: expiresAt },
          });
        }
        break;
      case "BILLING_ISSUE":
        console.log(`[RC Webhook] Billing issue for user ${userId}, product: ${productId}`);
        break;
      default:
        console.log(`[RC Webhook] Unhandled event type: ${eventType}`);
    }

    res.status(200).json({ status: "ok", event: eventType, userId });
  } catch (error) {
    console.error("[RC Webhook] Error:", error);
    res.status(200).json({ status: "error", message: "Internal error logged" });
  }
}

// ── /users/export ────────────────────────────────

async function handleExport(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        preferences: true,
        hobbies: { include: { completedSteps: true } },
        activityLogs: { orderBy: { createdAt: "desc" } },
        journalEntries: { orderBy: { createdAt: "desc" } },
        personalNotes: true,
        scheduleEvents: true,
        shoppingChecks: true,
        communityStories: { include: { reactions: true } },
        storyReactions: true,
        buddyRequestsSent: true,
        buddyRequestsRcvd: true,
        challenges: true,
        achievements: true,
      },
    });

    if (!user) {
      errorResponse(res, 404, "User not found");
      return;
    }

    const exportData = {
      account: {
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        bio: user.bio,
        avatarUrl: user.avatarUrl,
        subscriptionTier: user.subscriptionTier,
        proSince: user.proSince?.toISOString() ?? null,
        proExpiresAt: user.proExpiresAt?.toISOString() ?? null,
        isLifetime: user.isLifetime,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      },
      preferences: user.preferences
        ? {
            hoursPerWeek: user.preferences.hoursPerWeek,
            budgetLevel: user.preferences.budgetLevel,
            preferSocial: user.preferences.preferSocial,
            vibes: user.preferences.vibes,
          }
        : null,
      hobbies: user.hobbies.map((h) => ({
        hobbyId: h.hobbyId,
        status: h.status,
        startedAt: h.startedAt?.toISOString() ?? null,
        completedAt: h.completedAt?.toISOString() ?? null,
        lastActivityAt: h.lastActivityAt?.toISOString() ?? null,
        streakDays: h.streakDays,
        createdAt: h.createdAt.toISOString(),
        completedSteps: h.completedSteps.map((s) => ({
          stepId: s.stepId,
          completedAt: s.completedAt.toISOString(),
        })),
      })),
      activityLogs: user.activityLogs.map((a) => ({
        hobbyId: a.hobbyId,
        action: a.action,
        createdAt: a.createdAt.toISOString(),
      })),
      journalEntries: user.journalEntries.map((j) => ({
        hobbyId: j.hobbyId,
        text: j.text,
        photoUrl: j.photoUrl,
        createdAt: j.createdAt.toISOString(),
      })),
      personalNotes: user.personalNotes.map((n) => ({
        hobbyId: n.hobbyId,
        stepId: n.stepId,
        text: n.text,
      })),
      scheduleEvents: user.scheduleEvents.map((e) => ({
        hobbyId: e.hobbyId,
        dayOfWeek: e.dayOfWeek,
        startTime: e.startTime,
        durationMinutes: e.durationMinutes,
      })),
      shoppingChecks: user.shoppingChecks.map((s) => ({
        hobbyId: s.hobbyId,
        itemName: s.itemName,
        checked: s.checked,
      })),
      communityStories: user.communityStories.map((cs) => ({
        quote: cs.quote,
        hobbyId: cs.hobbyId,
        createdAt: cs.createdAt.toISOString(),
        reactions: cs.reactions.map((r) => ({
          type: r.type,
          userId: r.userId,
        })),
      })),
      storyReactions: user.storyReactions.map((r) => ({
        storyId: r.storyId,
        type: r.type,
      })),
      buddyConnections: [
        ...user.buddyRequestsSent.map((b) => ({
          partnerId: b.accepterId,
          hobbyId: b.hobbyId,
          status: b.status,
          role: "requester" as const,
          createdAt: b.createdAt.toISOString(),
        })),
        ...user.buddyRequestsRcvd.map((b) => ({
          partnerId: b.requesterId,
          hobbyId: b.hobbyId,
          status: b.status,
          role: "accepter" as const,
          createdAt: b.createdAt.toISOString(),
        })),
      ],
      challenges: user.challenges.map((c) => ({
        challengeType: c.challengeType,
        currentCount: c.currentCount,
        targetCount: c.targetCount,
        isCompleted: c.isCompleted,
        weekStart: c.weekStart.toISOString(),
        completedAt: c.completedAt?.toISOString() ?? null,
      })),
      achievements: user.achievements.map((a) => ({
        achievementId: a.achievementId,
        unlockedAt: a.unlockedAt.toISOString(),
      })),
      exportedAt: new Date().toISOString(),
    };

    res.setHeader("Content-Type", "application/json");
    res.setHeader(
      "Content-Disposition",
      "attachment; filename=trysomething-export.json"
    );
    res.status(200).json(exportData);
  } catch (err) {
    console.error("GET /api/users/me/export error:", err);
    errorResponse(res, 500, "Failed to export user data");
  }
}

// ── /cron/purge-deleted-users (merged to stay within 12-function limit) ──

async function handlePurgeDeletedUsers(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  // Vercel Cron sends GET requests
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  // Verify CRON_SECRET
  const authHeader = req.headers.authorization;
  if (
    !process.env.CRON_SECRET ||
    authHeader !== `Bearer ${process.env.CRON_SECRET}`
  ) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  try {
    const cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const usersToDelete = await prisma.user.findMany({
      where: { deletedAt: { lte: cutoff } },
      select: { id: true },
    });

    if (usersToDelete.length === 0) {
      res.status(200).json({ purged: 0 });
      return;
    }

    const userIds = usersToDelete.map((u) => u.id);

    // Hard delete: GenerationLog first (no FK cascade), then User (cascades the rest)
    await prisma.$transaction([
      prisma.generationLog.deleteMany({ where: { userId: { in: userIds } } }),
      prisma.user.deleteMany({ where: { id: { in: userIds } } }),
    ]);

    res.status(200).json({ purged: userIds.length });
  } catch (err) {
    console.error("Cron purge-deleted-users error:", err);
    res.status(500).json({ error: "Purge failed" });
  }
}
