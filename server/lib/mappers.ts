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
};

type PrismaRoadmapStep = {
  id: string;
  hobbyId: string;
  title: string;
  description: string;
  estimatedMinutes: number;
  milestone: string | null;
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
  };
}

function mapRoadmapStep(s: PrismaRoadmapStep) {
  return {
    id: s.id,
    title: s.title,
    description: s.description,
    estimatedMinutes: s.estimatedMinutes,
    milestone: s.milestone,
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
