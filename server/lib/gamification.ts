// ═══════════════════════════════════════════════════
//  Gamification — Challenge & Achievement Logic
//  Definitions are server-side constants; only user
//  PROGRESS is stored in the database.
// ═══════════════════════════════════════════════════

import { prisma } from "./db";

// ── Challenge Definitions ──────────────────────────

interface ChallengeDefinition {
  type: string;
  title: string;
  description: string;
  targetCount: number;
}

const CHALLENGE_TYPES: ChallengeDefinition[] = [
  {
    type: "try_new_hobby",
    title: "Try Something New",
    description: "Save a new hobby this week",
    targetCount: 1,
  },
  {
    type: "complete_steps",
    title: "Complete Steps",
    description: "Complete 3 roadmap steps this week",
    targetCount: 3,
  },
  {
    type: "journal_entry",
    title: "Journal Your Journey",
    description: "Write a journal entry this week",
    targetCount: 1,
  },
  {
    type: "share_story",
    title: "Share Your Story",
    description: "Share a community story this week",
    targetCount: 1,
  },
];

// ── Achievement Definitions ────────────────────────

export interface AchievementDefinition {
  id: string;
  title: string;
  description: string;
  icon: string;
}

const ACHIEVEMENTS: AchievementDefinition[] = [
  { id: "first_save", title: "First Steps", description: "Saved your first hobby", icon: "🌱" },
  { id: "first_step", title: "Getting Started", description: "Completed your first step", icon: "👣" },
  { id: "explorer", title: "Explorer", description: "Tried 3 different hobbies", icon: "🧭" },
  { id: "dedicated", title: "Dedicated", description: "Completed 10 roadmap steps", icon: "💪" },
  { id: "journaler", title: "Journaler", description: "Wrote 5 journal entries", icon: "📝" },
  { id: "streak_7", title: "On a Roll", description: "Achieved a 7-day streak", icon: "🔥" },
  { id: "social_butterfly", title: "Social Butterfly", description: "Connected with a buddy", icon: "🦋" },
  { id: "storyteller", title: "Storyteller", description: "Shared a community story", icon: "📖" },
  { id: "completionist", title: "Completionist", description: "Finished all steps for a hobby", icon: "🏆" },
];

// ── Helpers ────────────────────────────────────────

/** Returns Monday 00:00 UTC of the given date's week. */
export function getWeekStart(date: Date = new Date()): Date {
  const d = new Date(date);
  d.setUTCHours(0, 0, 0, 0);
  const day = d.getUTCDay(); // 0 = Sunday
  const diff = day === 0 ? 6 : day - 1; // days since Monday
  d.setUTCDate(d.getUTCDate() - diff);
  return d;
}

/** Deterministic rotation: ISO week number mod 4 → challenge type index. */
function getChallengeTypeForWeek(weekStart: Date): ChallengeDefinition {
  // Compute ISO week number from weekStart (which is already a Monday)
  const yearStart = new Date(Date.UTC(weekStart.getUTCFullYear(), 0, 1));
  const daysSinceYearStart = Math.floor(
    (weekStart.getTime() - yearStart.getTime()) / (24 * 60 * 60 * 1000)
  );
  const weekNumber = Math.floor(daysSinceYearStart / 7);
  return CHALLENGE_TYPES[weekNumber % CHALLENGE_TYPES.length];
}

/** Ensure user has a challenge for the current week; create one if not. */
export async function ensureWeeklyChallenge(userId: string): Promise<void> {
  const weekStart = getWeekStart();
  const def = getChallengeTypeForWeek(weekStart);

  await prisma.userChallenge.upsert({
    where: {
      userId_challengeType_weekStart: {
        userId,
        challengeType: def.type,
        weekStart,
      },
    },
    create: {
      userId,
      challengeType: def.type,
      targetCount: def.targetCount,
      weekStart,
    },
    update: {}, // no-op if already exists
  });
}

/**
 * Called after relevant user actions. Maps action types to challenge types:
 * - save_hobby → try_new_hobby
 * - step_complete → complete_steps
 * - journal_entry → journal_entry
 * - share_story → share_story
 */
export async function checkChallengeProgress(
  userId: string,
  actionType: string
): Promise<void> {
  const challengeTypeMap: Record<string, string> = {
    save_hobby: "try_new_hobby",
    step_complete: "complete_steps",
    journal_entry: "journal_entry",
    share_story: "share_story",
  };

  const challengeType = challengeTypeMap[actionType];
  if (!challengeType) return;

  const weekStart = getWeekStart();

  try {
    // Find active (non-completed) challenge for this week and type
    const challenge = await prisma.userChallenge.findUnique({
      where: {
        userId_challengeType_weekStart: {
          userId,
          challengeType,
          weekStart,
        },
      },
    });

    if (!challenge || challenge.isCompleted) return;

    const newCount = challenge.currentCount + 1;
    const completed = newCount >= challenge.targetCount;

    await prisma.userChallenge.update({
      where: { id: challenge.id },
      data: {
        currentCount: newCount,
        isCompleted: completed,
        ...(completed && { completedAt: new Date() }),
      },
    });
  } catch (err) {
    // Non-critical — log but don't fail the parent request
    console.error("checkChallengeProgress error:", err);
  }
}

/** Map a challenge DB row to the API response format. */
function mapChallengeResponse(challenge: {
  id: string;
  challengeType: string;
  currentCount: number;
  targetCount: number;
  isCompleted: boolean;
  weekStart: Date;
  completedAt: Date | null;
}) {
  const def = CHALLENGE_TYPES.find((c) => c.type === challenge.challengeType);
  const weekEnd = new Date(challenge.weekStart);
  weekEnd.setUTCDate(weekEnd.getUTCDate() + 7);

  return {
    id: challenge.id,
    title: def?.title ?? challenge.challengeType,
    description: def?.description ?? "",
    targetCount: challenge.targetCount,
    currentCount: challenge.currentCount,
    isCompleted: challenge.isCompleted,
    startDate: challenge.weekStart.toISOString(),
    endDate: weekEnd.toISOString(),
    completedAt: challenge.completedAt?.toISOString() ?? null,
  };
}

/** GET /users/challenges — returns all challenges for the user. */
export async function handleChallenges(userId: string) {
  await ensureWeeklyChallenge(userId);

  const challenges = await prisma.userChallenge.findMany({
    where: { userId },
    orderBy: { weekStart: "desc" },
  });

  return challenges.map(mapChallengeResponse);
}

/**
 * GET /users/achievements — computes achievements, upserts new unlocks,
 * returns all definitions with unlockedAt.
 */
export async function handleAchievements(userId: string) {
  // Run all aggregate queries in parallel
  const [
    hobbyCount,
    stepCount,
    journalCount,
    storyCount,
    activeBuddyCount,
    maxStreak,
    doneHobbyCount,
  ] = await Promise.all([
    prisma.userHobby.count({ where: { userId } }),
    prisma.userCompletedStep.count({ where: { userId } }),
    prisma.journalEntry.count({ where: { userId } }),
    prisma.communityStory.count({ where: { userId } }),
    prisma.buddyPair.count({
      where: {
        status: "active",
        OR: [{ requesterId: userId }, { accepterId: userId }],
      },
    }),
    prisma.userHobby
      .aggregate({ where: { userId }, _max: { streakDays: true } })
      .then((r) => r._max.streakDays ?? 0),
    prisma.userHobby.count({ where: { userId, status: "done" } }),
  ]);

  // Check each achievement criteria
  const criteria: Record<string, boolean> = {
    first_save: hobbyCount >= 1,
    first_step: stepCount >= 1,
    explorer: hobbyCount >= 3,
    dedicated: stepCount >= 10,
    journaler: journalCount >= 5,
    streak_7: maxStreak >= 7,
    social_butterfly: activeBuddyCount >= 1,
    storyteller: storyCount >= 1,
    completionist: doneHobbyCount >= 1,
  };

  // Upsert newly earned achievements
  const newlyEarned = ACHIEVEMENTS.filter((a) => criteria[a.id]);
  for (const a of newlyEarned) {
    await prisma.userAchievement.upsert({
      where: { userId_achievementId: { userId, achievementId: a.id } },
      create: { userId, achievementId: a.id },
      update: {}, // no-op
    });
  }

  // Fetch all user achievements
  const userAchievements = await prisma.userAchievement.findMany({
    where: { userId },
  });
  const unlockedMap = new Map(
    userAchievements.map((ua) => [ua.achievementId, ua.unlockedAt])
  );

  // Return all definitions with unlock status
  return ACHIEVEMENTS.map((a) => ({
    id: a.id,
    title: a.title,
    description: a.description,
    icon: a.icon,
    unlockedAt: unlockedMap.get(a.id)?.toISOString() ?? null,
  }));
}
