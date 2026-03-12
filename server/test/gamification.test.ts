import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  getWeekStart,
  checkChallengeProgress,
  handleChallenges,
  handleAchievements,
} from "../lib/gamification";
import { prisma } from "../lib/db";

// ── Mock prisma ────────────────────────────────────────
vi.mock("../lib/db", () => ({
  prisma: {
    userChallenge: {
      findUnique: vi.fn(),
      update: vi.fn(),
      upsert: vi.fn(),
      findMany: vi.fn(),
    },
    userHobby: {
      count: vi.fn(),
      aggregate: vi.fn(),
    },
    userCompletedStep: { count: vi.fn() },
    journalEntry: { count: vi.fn() },
    communityStory: { count: vi.fn() },
    buddyPair: { count: vi.fn() },
    userAchievement: {
      upsert: vi.fn(),
      findMany: vi.fn(),
    },
  },
}));

// ── Helpers ────────────────────────────────────────────

const USER_ID = "user-123";

/** Build a minimal userChallenge-like object for mocking. */
function makeChallenge(overrides: Partial<{
  id: string;
  challengeType: string;
  currentCount: number;
  targetCount: number;
  isCompleted: boolean;
  weekStart: Date;
  completedAt: Date | null;
}> = {}) {
  return {
    id: "challenge-1",
    challengeType: "try_new_hobby",
    currentCount: 0,
    targetCount: 1,
    isCompleted: false,
    weekStart: getWeekStart(),
    completedAt: null,
    ...overrides,
  };
}

// ── getWeekStart ───────────────────────────────────────

describe("getWeekStart", () => {
  it("Wednesday 2024-01-10 → returns Monday 2024-01-08", () => {
    const result = getWeekStart(new Date("2024-01-10T12:00:00Z"));
    expect(result.toISOString()).toBe("2024-01-08T00:00:00.000Z");
  });

  it("Monday 2024-01-08 → returns same day (2024-01-08)", () => {
    const result = getWeekStart(new Date("2024-01-08T09:30:00Z"));
    expect(result.toISOString()).toBe("2024-01-08T00:00:00.000Z");
  });

  it("Sunday 2024-01-14 → returns Monday 2024-01-08", () => {
    const result = getWeekStart(new Date("2024-01-14T23:59:00Z"));
    expect(result.toISOString()).toBe("2024-01-08T00:00:00.000Z");
  });

  it("Saturday 2024-01-13 → returns Monday 2024-01-08", () => {
    const result = getWeekStart(new Date("2024-01-13T06:00:00Z"));
    expect(result.toISOString()).toBe("2024-01-08T00:00:00.000Z");
  });
});

// ── checkChallengeProgress ─────────────────────────────

describe("checkChallengeProgress", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("unknown actionType → no prisma call (findUnique not called)", async () => {
    await checkChallengeProgress(USER_ID, "unknown_action");
    expect(prisma.userChallenge.findUnique).not.toHaveBeenCalled();
  });

  it("save_hobby maps to try_new_hobby challenge (findUnique called with correct type)", async () => {
    vi.mocked(prisma.userChallenge.findUnique).mockResolvedValue(null);

    await checkChallengeProgress(USER_ID, "save_hobby");

    expect(prisma.userChallenge.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          userId_challengeType_weekStart: expect.objectContaining({
            userId: USER_ID,
            challengeType: "try_new_hobby",
          }),
        }),
      })
    );
  });

  it("step_complete maps to complete_steps challenge (findUnique called with correct type)", async () => {
    vi.mocked(prisma.userChallenge.findUnique).mockResolvedValue(null);

    await checkChallengeProgress(USER_ID, "step_complete");

    expect(prisma.userChallenge.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          userId_challengeType_weekStart: expect.objectContaining({
            userId: USER_ID,
            challengeType: "complete_steps",
          }),
        }),
      })
    );
  });

  it("challenge not found (findUnique returns null) → no update", async () => {
    vi.mocked(prisma.userChallenge.findUnique).mockResolvedValue(null);

    await checkChallengeProgress(USER_ID, "save_hobby");

    expect(prisma.userChallenge.update).not.toHaveBeenCalled();
  });

  it("already completed challenge → no update", async () => {
    vi.mocked(prisma.userChallenge.findUnique).mockResolvedValue(
      makeChallenge({ isCompleted: true, currentCount: 1, targetCount: 1 }) as any
    );

    await checkChallengeProgress(USER_ID, "save_hobby");

    expect(prisma.userChallenge.update).not.toHaveBeenCalled();
  });

  it("increments count from 1 to 2 (targetCount=3, not completed yet)", async () => {
    vi.mocked(prisma.userChallenge.findUnique).mockResolvedValue(
      makeChallenge({
        id: "challenge-steps",
        challengeType: "complete_steps",
        currentCount: 1,
        targetCount: 3,
        isCompleted: false,
      }) as any
    );
    vi.mocked(prisma.userChallenge.update).mockResolvedValue({} as any);

    await checkChallengeProgress(USER_ID, "step_complete");

    expect(prisma.userChallenge.update).toHaveBeenCalledWith({
      where: { id: "challenge-steps" },
      data: {
        currentCount: 2,
        isCompleted: false,
      },
    });
  });

  it("completes challenge when count reaches targetCount → isCompleted: true + completedAt set", async () => {
    vi.mocked(prisma.userChallenge.findUnique).mockResolvedValue(
      makeChallenge({
        id: "challenge-journal",
        challengeType: "journal_entry",
        currentCount: 0,
        targetCount: 1,
        isCompleted: false,
      }) as any
    );
    vi.mocked(prisma.userChallenge.update).mockResolvedValue({} as any);

    await checkChallengeProgress(USER_ID, "journal_entry");

    const updateCall = vi.mocked(prisma.userChallenge.update).mock.calls[0][0];
    expect(updateCall.where).toEqual({ id: "challenge-journal" });
    expect(updateCall.data.currentCount).toBe(1);
    expect(updateCall.data.isCompleted).toBe(true);
    expect(updateCall.data.completedAt).toBeInstanceOf(Date);
  });
});

// ── handleChallenges ───────────────────────────────────

describe("handleChallenges", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calls ensureWeeklyChallenge (upsert) and returns mapped challenges from findMany", async () => {
    const weekStart = getWeekStart();
    const weekEnd = new Date(weekStart);
    weekEnd.setUTCDate(weekEnd.getUTCDate() + 7);

    const fakeChallenge = makeChallenge({
      id: "c-1",
      challengeType: "try_new_hobby",
      currentCount: 0,
      targetCount: 1,
      isCompleted: false,
      weekStart,
      completedAt: null,
    });

    vi.mocked(prisma.userChallenge.upsert).mockResolvedValue({} as any);
    vi.mocked(prisma.userChallenge.findMany).mockResolvedValue([fakeChallenge] as any);

    const result = await handleChallenges(USER_ID);

    // ensureWeeklyChallenge calls upsert
    expect(prisma.userChallenge.upsert).toHaveBeenCalledOnce();

    // findMany fetches all user challenges
    expect(prisma.userChallenge.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: { userId: USER_ID } })
    );

    // Returns mapped response
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe("c-1");
    expect(result[0].title).toBe("Try Something New");
    expect(result[0].currentCount).toBe(0);
    expect(result[0].isCompleted).toBe(false);
    expect(result[0].startDate).toBe(weekStart.toISOString());
    expect(result[0].endDate).toBe(weekEnd.toISOString());
    expect(result[0].completedAt).toBeNull();
  });
});

// ── handleAchievements ─────────────────────────────────

describe("handleAchievements", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("user with 0 everything → no achievements unlocked (upsert not called)", async () => {
    vi.mocked(prisma.userHobby.count).mockResolvedValue(0);
    vi.mocked(prisma.userCompletedStep.count).mockResolvedValue(0);
    vi.mocked(prisma.journalEntry.count).mockResolvedValue(0);
    vi.mocked(prisma.communityStory.count).mockResolvedValue(0);
    vi.mocked(prisma.buddyPair.count).mockResolvedValue(0);
    vi.mocked(prisma.userHobby.aggregate).mockResolvedValue({
      _max: { streakDays: null },
    } as any);
    vi.mocked(prisma.userAchievement.findMany).mockResolvedValue([]);

    await handleAchievements(USER_ID);

    expect(prisma.userAchievement.upsert).not.toHaveBeenCalled();
  });

  it("user with hobbyCount >= 1 → first_save achievement upserted", async () => {
    // hobbyCount = 1 triggers first_save; everything else stays 0
    vi.mocked(prisma.userHobby.count)
      .mockResolvedValueOnce(1)  // hobbyCount
      .mockResolvedValueOnce(0); // doneHobbyCount
    vi.mocked(prisma.userCompletedStep.count).mockResolvedValue(0);
    vi.mocked(prisma.journalEntry.count).mockResolvedValue(0);
    vi.mocked(prisma.communityStory.count).mockResolvedValue(0);
    vi.mocked(prisma.buddyPair.count).mockResolvedValue(0);
    vi.mocked(prisma.userHobby.aggregate).mockResolvedValue({
      _max: { streakDays: null },
    } as any);
    vi.mocked(prisma.userAchievement.upsert).mockResolvedValue({} as any);
    vi.mocked(prisma.userAchievement.findMany).mockResolvedValue([
      { achievementId: "first_save", unlockedAt: new Date("2024-01-10T00:00:00Z") },
    ] as any);

    const result = await handleAchievements(USER_ID);

    expect(prisma.userAchievement.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          userId_achievementId: { userId: USER_ID, achievementId: "first_save" },
        },
        create: { userId: USER_ID, achievementId: "first_save" },
        update: {},
      })
    );

    const firstSave = result.find((a) => a.id === "first_save");
    expect(firstSave).toBeDefined();
    expect(firstSave!.unlockedAt).toBe("2024-01-10T00:00:00.000Z");
  });
});
