import { describe, it, expect, vi, beforeEach } from "vitest";

// Mock all dependencies of [path].ts to prevent Prisma engine loading
vi.mock("../../lib/db", () => ({ prisma: {} }));
vi.mock("../lib/db", () => ({ prisma: {} }));
vi.mock("../lib/middleware", () => ({
  handleCors: vi.fn(),
  methodNotAllowed: vi.fn(),
  errorResponse: vi.fn(),
}));
vi.mock("../lib/auth", () => ({
  requireAuth: vi.fn(),
  comparePassword: vi.fn(),
}));
vi.mock("../lib/mappers", () => ({
  mapUserWithPreferences: vi.fn((x: unknown) => x),
  mapUserPreference: vi.fn((x: unknown) => x),
  mapUserHobby: vi.fn((x: unknown) => x),
  mapActivityLog: vi.fn((x: unknown) => x),
  mapJournalEntry: vi.fn((x: unknown) => x),
  mapPersonalNote: vi.fn((x: unknown) => x),
  mapScheduleEvent: vi.fn((x: unknown) => x),
  mapShoppingCheck: vi.fn((x: unknown) => x),
  mapCommunityStory: vi.fn((x: unknown) => x),
  mapBuddyProfile: vi.fn((x: unknown) => x),
  mapBuddyActivity: vi.fn((x: unknown) => x),
  mapBuddyRequest: vi.fn((x: unknown) => x),
  mapSimilarUser: vi.fn((x: unknown) => x),
}));
vi.mock("../lib/gamification", () => ({
  handleChallenges: vi.fn(),
  handleAchievements: vi.fn(),
  checkChallengeProgress: vi.fn(),
}));

import { toggleStepCompletion } from "../api/users/[path]";

// ── Mock transaction client ─────────────────────────────

function makeTxClient(overrides: {
  existingStep?: { id: string } | null;
  completedCount?: number;
  totalSteps?: number;
  hobbyAfter?: Record<string, unknown>;
}) {
  const {
    existingStep = null,
    completedCount = 0,
    totalSteps = 4,
    hobbyAfter = {},
  } = overrides;

  return {
    userHobby: {
      upsert: vi.fn().mockResolvedValue({}),
      findUnique: vi.fn().mockResolvedValue({
        userId: "user-1",
        hobbyId: "hobby-1",
        status: "active",
        startedAt: new Date("2026-03-01T00:00:00Z"),
        completedAt: null,
        lastActivityAt: new Date(),
        streakDays: 3,
        pausedAt: null,
        pausedDurationDays: 0,
        completedSteps: [{ stepId: "s1" }],
        ...hobbyAfter,
      }),
      update: vi.fn().mockResolvedValue({}),
    },
    userCompletedStep: {
      findUnique: vi.fn().mockResolvedValue(existingStep),
      delete: vi.fn().mockResolvedValue({}),
      create: vi.fn().mockResolvedValue({}),
      count: vi.fn().mockResolvedValue(completedCount),
    },
    roadmapStep: {
      count: vi.fn().mockResolvedValue(totalSteps),
    },
  };
}

function makePrismaWithTx(txClient: ReturnType<typeof makeTxClient>) {
  return {
    $transaction: vi.fn(async (fn: (tx: unknown) => Promise<unknown>) => {
      return fn(txClient);
    }),
  } as any;
}

// ── Tests ────────────────────────────────────────────────

describe("step completion - hobbyCompleted flag", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns hobbyCompleted: true when last step is completed", async () => {
    // 4 total steps, completing the 4th (count returns 4 after create)
    const tx = makeTxClient({
      existingStep: null, // step is new (being added)
      completedCount: 4,
      totalSteps: 4,
      hobbyAfter: {
        status: "done",
        completedAt: new Date("2026-03-20T12:00:00Z"),
        completedSteps: [
          { stepId: "s1" },
          { stepId: "s2" },
          { stepId: "s3" },
          { stepId: "s4" },
        ],
      },
    });
    const db = makePrismaWithTx(tx);

    const result = await toggleStepCompletion(db, "user-1", "hobby-1", "s4");

    expect(result.hobbyCompleted).toBe(true);
    expect(result.wasNew).toBe(true);

    // Verify hobby was updated to done
    expect(tx.userHobby.update).toHaveBeenCalledWith({
      where: { userId_hobbyId: { userId: "user-1", hobbyId: "hobby-1" } },
      data: { status: "done", completedAt: expect.any(Date) },
    });

    // Verify completion detection counts were queried
    expect(tx.userCompletedStep.count).toHaveBeenCalledWith({
      where: { userId: "user-1", hobbyId: "hobby-1" },
    });
    expect(tx.roadmapStep.count).toHaveBeenCalledWith({
      where: { hobbyId: "hobby-1" },
    });
  });

  it("returns hobbyCompleted: false when steps remain incomplete", async () => {
    // 4 total steps, only 2 completed after adding this one
    const tx = makeTxClient({
      existingStep: null, // step is new
      completedCount: 2,
      totalSteps: 4,
    });
    const db = makePrismaWithTx(tx);

    const result = await toggleStepCompletion(db, "user-1", "hobby-1", "s2");

    expect(result.hobbyCompleted).toBe(false);
    expect(result.wasNew).toBe(true);

    // Verify hobby was NOT updated to done
    expect(tx.userHobby.update).not.toHaveBeenCalled();
  });

  it("returns hobbyCompleted: false on un-toggle and does NOT revert done status", async () => {
    // Step already exists (being un-toggled/removed)
    // Hobby is already in "done" status with all steps previously complete
    const tx = makeTxClient({
      existingStep: { id: "step-record-1" }, // existing = un-toggle
      hobbyAfter: {
        status: "done",
        completedAt: new Date("2026-03-19T10:00:00Z"),
        completedSteps: [{ stepId: "s1" }, { stepId: "s2" }, { stepId: "s3" }],
      },
    });
    const db = makePrismaWithTx(tx);

    const result = await toggleStepCompletion(db, "user-1", "hobby-1", "s4");

    expect(result.hobbyCompleted).toBe(false);
    expect(result.wasNew).toBe(false);

    // Verify step was deleted (un-toggled)
    expect(tx.userCompletedStep.delete).toHaveBeenCalledWith({
      where: { id: "step-record-1" },
    });

    // Verify hobby status was NOT reverted (no update call to change status)
    expect(tx.userHobby.update).not.toHaveBeenCalled();

    // Verify completion detection was NOT run (only runs on step addition)
    expect(tx.userCompletedStep.count).not.toHaveBeenCalled();
    expect(tx.roadmapStep.count).not.toHaveBeenCalled();

    // Verify the returned hobby still shows "done" status
    expect(result.hobby.status).toBe("done");
    expect(result.hobby.completedAt).not.toBeNull();
  });

  it("wraps all operations inside a prisma.$transaction", async () => {
    const tx = makeTxClient({ existingStep: null, completedCount: 1, totalSteps: 4 });
    const db = makePrismaWithTx(tx);

    await toggleStepCompletion(db, "user-1", "hobby-1", "s1");

    // $transaction was called exactly once
    expect(db.$transaction).toHaveBeenCalledTimes(1);

    // Operations happened on tx (transaction client), not on db directly
    expect(tx.userHobby.upsert).toHaveBeenCalled();
    expect(tx.userCompletedStep.findUnique).toHaveBeenCalled();
    expect(tx.userHobby.findUnique).toHaveBeenCalled();
  });
});
