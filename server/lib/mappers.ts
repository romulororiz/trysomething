// ═══════════════════════════════════════════════════
//  Prisma → Flutter JSON mappers
//  Transforms DB field names to match Flutter Freezed models.
// ═══════════════════════════════════════════════════

type PrismaHobby = {
  id: string;
  title: string;
  hook: string;
  categoryId: string;
  imageUrl: string;
  tags: string[];
  costText: string;
  timeText: string;
  difficultyText: string;
  whyLove: string;
  difficultyExplain: string;
  pitfalls: string[];
  sortOrder: number;
  kitItems: PrismaKitItem[];
  roadmapSteps: PrismaRoadmapStep[];
};

type PrismaKitItem = {
  id: string;
  hobbyId: string;
  name: string;
  description: string;
  cost: number;
  isOptional: boolean;
  sortOrder: number;
  imageUrl?: string | null;
  affiliateUrl?: string | null;
  affiliateSource?: string | null;
};

type PrismaRoadmapStep = {
  id: string;
  hobbyId: string;
  title: string;
  description: string;
  estimatedMinutes: number;
  milestone: string | null;
  coachTip: string | null;
  completionMessage: string | null;
  sortOrder: number;
};

type PrismaCategory = {
  id: string;
  name: string;
  imageUrl: string;
  sortOrder: number;
  _count?: { hobbies: number };
};

type PrismaFaqItem = {
  id: string;
  hobbyId: string;
  question: string;
  answer: string;
  upvotes: number;
};

type PrismaCostBreakdown = {
  id: string;
  hobbyId: string;
  starter: number;
  threeMonth: number;
  oneYear: number;
  tips: string[];
};

type PrismaBudgetAlternative = {
  id: string;
  hobbyId: string;
  itemName: string;
  diyOption: string;
  diyCost: number;
  budgetOption: string;
  budgetCost: number;
  premiumOption: string;
  premiumCost: number;
  sortOrder: number;
};

type PrismaHobbyCombo = {
  id: string;
  hobbyId1: string;
  hobbyId2: string;
  reason: string;
  sharedTags: string[];
};

// ── Hobby ────────────────────────────────────────

export function mapHobby(h: PrismaHobby) {
  return {
    id: h.id,
    title: h.title,
    hook: h.hook,
    category: h.categoryId,
    imageUrl: h.imageUrl,
    tags: h.tags,
    costText: h.costText,
    timeText: h.timeText,
    difficultyText: h.difficultyText,
    whyLove: h.whyLove,
    difficultyExplain: h.difficultyExplain,
    starterKit: h.kitItems
      .sort((a, b) => a.sortOrder - b.sortOrder)
      .map(mapKitItem),
    pitfalls: h.pitfalls,
    roadmapSteps: h.roadmapSteps
      .sort((a, b) => a.sortOrder - b.sortOrder)
      .map(mapRoadmapStep),
  };
}

function mapKitItem(k: PrismaKitItem) {
  return {
    name: k.name,
    description: k.description,
    cost: k.cost,
    isOptional: k.isOptional,
    imageUrl: k.imageUrl ?? null,
    affiliateUrl: k.affiliateUrl ?? null,
    affiliateSource: k.affiliateSource ?? null,
  };
}

function mapRoadmapStep(s: PrismaRoadmapStep) {
  return {
    id: s.id,
    title: s.title,
    description: s.description,
    estimatedMinutes: s.estimatedMinutes,
    milestone: s.milestone,
    coachTip: s.coachTip,
    completionMessage: s.completionMessage,
  };
}

// ── Category ─────────────────────────────────────

export function mapCategory(c: PrismaCategory) {
  return {
    id: c.id,
    name: c.name,
    count: c._count?.hobbies ?? 0,
    imageUrl: c.imageUrl,
  };
}

// ── Feature models ───────────────────────────────

export function mapFaqItem(f: PrismaFaqItem) {
  return {
    question: f.question,
    answer: f.answer,
    upvotes: f.upvotes,
  };
}

export function mapCostBreakdown(c: PrismaCostBreakdown) {
  return {
    starter: c.starter,
    threeMonth: c.threeMonth,
    oneYear: c.oneYear,
    tips: c.tips,
  };
}

export function mapBudgetAlternative(b: PrismaBudgetAlternative) {
  return {
    itemName: b.itemName,
    diyOption: b.diyOption,
    diyCost: b.diyCost,
    budgetOption: b.budgetOption,
    budgetCost: b.budgetCost,
    premiumOption: b.premiumOption,
    premiumCost: b.premiumCost,
  };
}

export function mapCombo(c: PrismaHobbyCombo) {
  return {
    hobbyId1: c.hobbyId1,
    hobbyId2: c.hobbyId2,
    reason: c.reason,
    sharedTags: c.sharedTags,
  };
}

// ── User ────────────────────────────────────────

type PrismaUser = {
  id: string;
  email: string;
  displayName: string;
  bio: string;
  avatarUrl: string | null;
  createdAt: Date;
  updatedAt: Date;
  preferences?: PrismaUserPreference | null;
};

type PrismaUserPreference = {
  id: string;
  userId: string;
  hoursPerWeek: number;
  budgetLevel: number;
  preferSocial: boolean;
  vibes: string[];
};

export function mapUser(u: PrismaUser) {
  return {
    id: u.id,
    email: u.email,
    displayName: u.displayName,
    bio: u.bio,
    avatarUrl: u.avatarUrl,
    createdAt: u.createdAt.toISOString(),
  };
}

export function mapUserWithPreferences(u: PrismaUser) {
  return {
    ...mapUser(u),
    preferences: u.preferences ? mapUserPreference(u.preferences) : null,
  };
}

export function mapUserPreference(p: PrismaUserPreference) {
  return {
    hoursPerWeek: p.hoursPerWeek,
    budgetLevel: p.budgetLevel,
    preferSocial: p.preferSocial,
    vibes: p.vibes,
  };
}

// ── User Progress ───────────────────────────────

type PrismaUserHobby = {
  userId: string;
  hobbyId: string;
  status: string;
  startedAt: Date | null;
  completedAt: Date | null;
  lastActivityAt: Date | null;
  streakDays: number;
  completedSteps: { stepId: string }[];
};

type PrismaActivityLog = {
  id: string;
  hobbyId: string | null;
  action: string;
  createdAt: Date;
};

export function mapUserHobby(uh: PrismaUserHobby) {
  return {
    hobbyId: uh.hobbyId,
    status: uh.status,
    completedStepIds: uh.completedSteps.map((s) => s.stepId),
    startedAt: uh.startedAt?.toISOString() ?? null,
    lastActivityAt: uh.lastActivityAt?.toISOString() ?? null,
    streakDays: uh.streakDays,
  };
}

export function mapActivityLog(a: PrismaActivityLog) {
  return {
    id: a.id,
    hobbyId: a.hobbyId,
    action: a.action,
    createdAt: a.createdAt.toISOString(),
  };
}

// ── Personal Tools ─────────────────────────────

type PrismaJournalEntry = {
  id: string;
  userId: string;
  hobbyId: string;
  text: string;
  photoUrl: string | null;
  createdAt: Date;
};

type PrismaPersonalNote = {
  id: string;
  userId: string;
  hobbyId: string;
  stepId: string;
  text: string;
};

type PrismaScheduleEvent = {
  id: string;
  userId: string;
  hobbyId: string;
  dayOfWeek: number;
  startTime: string;
  durationMinutes: number;
};

type PrismaShoppingCheck = {
  id: string;
  userId: string;
  hobbyId: string;
  itemName: string;
  checked: boolean;
};

export function mapJournalEntry(e: PrismaJournalEntry) {
  return {
    id: e.id,
    hobbyId: e.hobbyId,
    text: e.text,
    photoUrl: e.photoUrl,
    createdAt: e.createdAt.toISOString(),
  };
}

export function mapPersonalNote(n: PrismaPersonalNote) {
  return {
    stepId: n.stepId,
    text: n.text,
  };
}

export function mapScheduleEvent(e: PrismaScheduleEvent) {
  return {
    id: e.id,
    hobbyId: e.hobbyId,
    dayOfWeek: e.dayOfWeek,
    startTime: e.startTime,
    durationMinutes: e.durationMinutes,
  };
}

export function mapShoppingCheck(s: PrismaShoppingCheck) {
  return {
    hobbyId: s.hobbyId,
    itemName: s.itemName,
    checked: s.checked,
  };
}

// ── Social ──────────────────────────────────────

type PrismaCommunityStory = {
  id: string;
  userId: string;
  quote: string;
  hobbyId: string;
  createdAt: Date;
  user: { displayName: string };
  reactions: { type: string; userId: string }[];
};

export function mapCommunityStory(
  s: PrismaCommunityStory,
  currentUserId: string
) {
  const reactionCounts: Record<string, number> = {};
  const userReactions: string[] = [];
  for (const r of s.reactions) {
    reactionCounts[r.type] = (reactionCounts[r.type] ?? 0) + 1;
    if (r.userId === currentUserId) {
      userReactions.push(r.type);
    }
  }

  return {
    id: s.id,
    authorName: s.user.displayName,
    authorInitial: s.user.displayName.charAt(0).toUpperCase(),
    quote: s.quote,
    hobbyId: s.hobbyId,
    reactions: reactionCounts,
    userReactions,
    createdAt: s.createdAt.toISOString(),
  };
}

export function mapBuddyProfile(
  user: { id: string; displayName: string },
  hobby: { hobbyId: string; completedSteps: { stepId: string }[] } | null
) {
  return {
    id: user.id,
    name: user.displayName,
    avatarInitial: user.displayName.charAt(0).toUpperCase(),
    currentHobbyId: hobby?.hobbyId ?? "",
    progress: hobby ? Math.min(hobby.completedSteps.length / 10, 1.0) : 0,
  };
}

export function mapBuddyActivity(
  log: { id: string; userId: string; hobbyId: string | null; action: string; createdAt: Date },
  userName: string
) {
  const actionText = formatActionText(log.action, log.hobbyId);
  return {
    userId: log.userId,
    userName,
    text: `${userName} ${actionText}`,
    timestamp: log.createdAt.toISOString(),
  };
}

function formatActionText(action: string, hobbyId: string | null): string {
  const hobby = hobbyId ?? "a hobby";
  switch (action) {
    case "save":
      return `saved ${hobby}`;
    case "unsave":
      return `removed ${hobby}`;
    case "step_complete":
      return `completed a step in ${hobby}`;
    case "step_uncomplete":
      return `unchecked a step in ${hobby}`;
    default:
      if (action.startsWith("status_")) {
        const status = action.replace("status_", "");
        return `is now ${status} with ${hobby}`;
      }
      return `did something with ${hobby}`;
  }
}

type PrismaBuddyPair = {
  id: string;
  requesterId: string;
  accepterId: string;
  hobbyId: string | null;
  status: string;
  createdAt: Date;
  requester: { id: string; displayName: string };
  accepter: { id: string; displayName: string };
};

export function mapBuddyRequest(
  pair: PrismaBuddyPair,
  currentUserId: string
) {
  const isSender = pair.requesterId === currentUserId;
  const otherUser = isSender ? pair.accepter : pair.requester;
  return {
    id: pair.id,
    userId: otherUser.id,
    name: otherUser.displayName,
    avatarInitial: otherUser.displayName.charAt(0).toUpperCase(),
    hobbyId: pair.hobbyId,
    status: pair.status,
    direction: isSender ? "sent" : "received",
    createdAt: pair.createdAt.toISOString(),
  };
}

export function mapSimilarUser(
  user: { id: string; displayName: string },
  hobby: { hobbyId: string; startedAt: Date | null }
) {
  const startedText = hobby.startedAt
    ? formatStartedText(hobby.startedAt)
    : "Recently started";
  return {
    id: user.id,
    name: user.displayName,
    avatarInitial: user.displayName.charAt(0).toUpperCase(),
    hobbyId: hobby.hobbyId,
    distance: "",
    startedText,
  };
}

function formatStartedText(startedAt: Date): string {
  const diff = Date.now() - startedAt.getTime();
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  if (days < 1) return "Started today";
  if (days === 1) return "Started yesterday";
  if (days < 7) return `Started ${days} days ago`;
  const weeks = Math.floor(days / 7);
  if (weeks === 1) return "Started this week";
  if (weeks < 5) return `${weeks} weeks in`;
  const months = Math.floor(days / 30);
  if (months === 1) return "1 month in";
  return `${months} months in`;
}

// ── Aggregation helpers ──────────────────────────

export function groupByField<T extends Record<string, unknown>>(
  rows: T[],
  keyField: keyof T,
  valueField: keyof T
): Record<string, string[]> {
  const result: Record<string, string[]> = {};
  for (const row of rows) {
    const key = row[keyField] as string;
    const value = row[valueField] as string;
    if (!result[key]) result[key] = [];
    result[key].push(value);
  }
  return result;
}
