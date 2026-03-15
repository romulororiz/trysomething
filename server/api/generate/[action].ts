// ═══════════════════════════════════════════════════
//  AI Hobby Generation — Consolidated handler
//  POST /api/generate/hobby  → Generate new hobby
//  POST /api/generate/faq    → Generate FAQ (tier 2)
//  POST /api/generate/cost   → Generate cost breakdown (tier 2)
//  POST /api/generate/budget → Generate budget alternatives (tier 2)
//  POST /api/generate/coach  → AI hobby coach (Sonnet)
//
//  Model: claude-sonnet-4-20250514 (all endpoints)
// ═══════════════════════════════════════════════════

import type { VercelRequest, VercelResponse } from "@vercel/node";
import { PrismaClient } from "@prisma/client";
import Anthropic from "@anthropic-ai/sdk";
import { requireAuth } from "../../lib/auth";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { validateInput, validateOutput } from "../../lib/content_guard";
import { fetchHobbyImage } from "../../lib/unsplash";
import {
  generateHobbyContent,
  generateFaqContent,
  generateCostContent,
  generateBudgetContent,
} from "../../lib/ai_generator";
import {
  mapHobby,
  mapFaqItem,
  mapCostBreakdown,
  mapBudgetAlternative,
} from "../../lib/mappers";

const prisma = new PrismaClient();

// ── Shared Anthropic client (coach uses this directly) ──
const COACH_MODEL = "claude-sonnet-4-6";
const COACH_MAX_TOKENS = 512;

let _anthropic: Anthropic | null = null;
function getAnthropicClient(): Anthropic {
  if (!_anthropic) {
    _anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _anthropic;
}

// Rate limit: 20 generations per user per 24 hours
const RATE_LIMIT = 20;

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const action = req.query.action as string;

  switch (action) {
    case "hobby":
      return handleGenerateHobby(req, res);
    case "faq":
      return handleGenerateFaq(req, res);
    case "cost":
      return handleGenerateCost(req, res);
    case "budget":
      return handleGenerateBudget(req, res);
    case "coach":
      return handleCoachChat(req, res);
    default:
      return errorResponse(res, 404, `Unknown action: ${action}`);
  }
}

// ═══════════════════════════════════════════════════
//  Generate hobby (Tier 1)
// ═══════════════════════════════════════════════════

async function handleGenerateHobby(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { query } = req.body ?? {};
  if (!query || typeof query !== "string") {
    return errorResponse(res, 400, "Query is required");
  }

  const trimmed = query.trim();

  // Layer 1: Input validation
  const inputCheck = validateInput(trimmed);
  if (!inputCheck.ok) {
    await logGeneration(userId, trimmed, "rejected", inputCheck.reason);
    return errorResponse(res, 400, inputCheck.reason);
  }

  // Rate limit check
  const recentCount = await prisma.generationLog.count({
    where: {
      userId,
      createdAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
      status: "success",
    },
  });

  if (recentCount >= RATE_LIMIT) {
    await logGeneration(userId, trimmed, "rejected", "Rate limit exceeded");
    return errorResponse(res, 429, "Generation limit reached (5 per day). Try again tomorrow.");
  }

  // Duplicate check — case-insensitive title match
  const existing = await prisma.hobby.findFirst({
    where: { title: { equals: trimmed, mode: "insensitive" } },
    include: {
      kitItems: { orderBy: { sortOrder: "asc" } },
      roadmapSteps: { orderBy: { sortOrder: "asc" } },
    },
  });

  if (existing) {
    return res.status(200).json({ hobby: mapHobby(existing), existed: true });
  }

  try {
    // Parallel: Claude + Unsplash
    const [content, defaultImage] = await Promise.all([
      generateHobbyContent(trimmed),
      fetchHobbyImage(trimmed),
    ]);
    const imageUrl = defaultImage;

    // Layer 3: Output validation
    const outputCheck = validateOutput(content);
    if (!outputCheck.ok) {
      await logGeneration(userId, trimmed, "rejected", `Output: ${outputCheck.reason}`);
      return errorResponse(res, 500, "Generated content failed validation. Please try a different query.");
    }

    // Post-generation duplicate check
    const generatedTitle = content.title as string;
    const postGenDupe = await prisma.hobby.findFirst({
      where: { title: { equals: generatedTitle, mode: "insensitive" } },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" } },
        roadmapSteps: { orderBy: { sortOrder: "asc" } },
      },
    });

    if (postGenDupe) {
      await logGeneration(userId, trimmed, "success", "Returned existing (post-gen match)", postGenDupe.id);
      return res.status(200).json({ hobby: mapHobby(postGenDupe), existed: true });
    }

    // Generate slug ID from title
    const slug = generatedTitle
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");

    const slugExists = await prisma.hobby.findUnique({ where: { id: slug } });
    const hobbyId = slugExists ? `${slug}-${Date.now().toString(36)}` : slug;

    // Create hobby with nested relations
    const hobby = await prisma.hobby.create({
      data: {
        id: hobbyId,
        title: content.title as string,
        hook: content.hook as string,
        categoryId: content.categoryId as string,
        imageUrl,
        tags: content.tags as string[],
        costText: content.costText as string,
        timeText: content.timeText as string,
        difficultyText: content.difficultyText as string,
        whyLove: content.whyLove as string,
        difficultyExplain: content.difficultyExplain as string,
        pitfalls: content.pitfalls as string[],
        isAiGenerated: true,
        generatedBy: userId,
        sortOrder: 999,
        kitItems: {
          create: (content.kitItems as Record<string, unknown>[]).map(
            (item, i) => ({
              name: item.name as string,
              description: item.description as string,
              cost: item.cost as number,
              isOptional: (item.isOptional as boolean) ?? false,
              sortOrder: i,
            })
          ),
        },
        roadmapSteps: {
          create: (content.roadmapSteps as Record<string, unknown>[]).map(
            (step, i) => ({
              id: `${hobbyId}-step-${i + 1}`,
              title: step.title as string,
              description: step.description as string,
              estimatedMinutes: step.estimatedMinutes as number,
              milestone: (step.milestone as string) ?? null,
              coachTip: (step.coachTip as string) ?? null,
              completionMessage: (step.completionMessage as string) ?? null,
              sortOrder: i,
            })
          ),
        },
      },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" } },
        roadmapSteps: { orderBy: { sortOrder: "asc" } },
      },
    });

    await logGeneration(userId, trimmed, "success", null, hobbyId);

    return res.status(201).json({  hobby: mapHobby(hobby), existed: false });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    await logGeneration(userId, trimmed, "error", message).catch(() => {});
    console.error("Generation error:", message);
    return errorResponse(res, 500, "Failed to generate hobby. Please try again.");
  }
}

// ═══════════════════════════════════════════════════
//  Generate FAQ (Tier 2)
// ═══════════════════════════════════════════════════

async function handleGenerateFaq(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }

  const existing = await prisma.faqItem.findMany({ where: { hobbyId } });
  if (existing.length > 0) {
    return res.status(200).json(existing.map(mapFaqItem));
  }

  const hobby = await prisma.hobby.findUnique({
    where: { id: hobbyId },
    select: { title: true, categoryId: true },
  });

  if (!hobby) {
    return errorResponse(res, 404, "Hobby not found");
  }

  try {
    const faqData = await generateFaqContent(hobby.title, hobby.categoryId);

    const created = await Promise.all(
      faqData.map((item) =>
        prisma.faqItem.create({
          data: { hobbyId, question: item.question, answer: item.answer },
        })
      )
    );

    return res.status(201).json(created.map(mapFaqItem));
  } catch (err) {
    console.error("FAQ generation error:", err);
    return errorResponse(res, 500, "Failed to generate FAQ");
  }
}

// ═══════════════════════════════════════════════════
//  Generate cost breakdown (Tier 2)
// ═══════════════════════════════════════════════════

async function handleGenerateCost(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }

  const existing = await prisma.costBreakdown.findUnique({ where: { hobbyId } });
  if (existing) {
    return res.status(200).json(mapCostBreakdown(existing));
  }

  const hobby = await prisma.hobby.findUnique({
    where: { id: hobbyId },
    include: { kitItems: { select: { name: true, cost: true } } },
  });

  if (!hobby) {
    return errorResponse(res, 404, "Hobby not found");
  }

  try {
    const costData = await generateCostContent(hobby.title, hobby.kitItems);

    const created = await prisma.costBreakdown.create({
      data: {
        hobbyId,
        starter: costData.starter,
        threeMonth: costData.threeMonth,
        oneYear: costData.oneYear,
        tips: costData.tips,
      },
    });

    return res.status(201).json(mapCostBreakdown(created));
  } catch (err) {
    console.error("Cost generation error:", err);
    return errorResponse(res, 500, "Failed to generate cost breakdown");
  }
}

// ═══════════════════════════════════════════════════
//  Generate budget alternatives (Tier 2)
// ═══════════════════════════════════════════════════

async function handleGenerateBudget(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }

  const existing = await prisma.budgetAlternative.findMany({ where: { hobbyId } });
  if (existing.length > 0) {
    return res.status(200).json(existing.map(mapBudgetAlternative));
  }

  const hobby = await prisma.hobby.findUnique({
    where: { id: hobbyId },
    include: { kitItems: { select: { name: true, cost: true } } },
  });

  if (!hobby) {
    return errorResponse(res, 404, "Hobby not found");
  }

  try {
    const budgetData = await generateBudgetContent(hobby.title, hobby.kitItems);

    const created = await Promise.all(
      budgetData.map((item, i) =>
        prisma.budgetAlternative.create({
          data: {
            hobbyId,
            itemName: item.itemName,
            diyOption: item.diyOption,
            diyCost: item.diyCost,
            budgetOption: item.budgetOption,
            budgetCost: item.budgetCost,
            premiumOption: item.premiumOption,
            premiumCost: item.premiumCost,
            sortOrder: i,
          },
        })
      )
    );

    return res.status(201).json(created.map(mapBudgetAlternative));
  } catch (err) {
    console.error("Budget generation error:", err);
    return errorResponse(res, 500, "Failed to generate budget alternatives");
  }
}

// ═══════════════════════════════════════════════════
//  AI Hobby Coach — Sonnet, hardened prompt
// ═══════════════════════════════════════════════════

type CoachMode = "START" | "MOMENTUM" | "RESCUE";

interface CoachChatMessage {
  role: "user" | "assistant";
  content: string;
}

async function handleCoachChat(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId, message, conversationHistory, modeOverride } = req.body ?? {};

  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }
  if (!message || typeof message !== "string") {
    return errorResponse(res, 400, "message is required");
  }

  try {
    const hobby = await prisma.hobby.findUnique({
      where: { id: hobbyId },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" } },
        roadmapSteps: { orderBy: { sortOrder: "asc" } },
      },
    });

    if (!hobby) {
      return errorResponse(res, 404, "Hobby not found");
    }

    const userHobby = await prisma.userHobby.findUnique({
      where: { userId_hobbyId: { userId, hobbyId } },
    });

    const recentJournal = await prisma.journalEntry.findMany({
      where: { userId, hobbyId },
      orderBy: { createdAt: "desc" },
      take: 5,
    });

// ── Derive user state + coach mode ──

    let userState: "BROWSING" | "SAVED" | "ACTIVE" = "BROWSING";
    let currentStep = -1;
    let daysSinceLastSession: number | null = null;

    if (userHobby) {
      if (userHobby.status === "trying" || userHobby.status === "active") {
        userState = "ACTIVE";

        // Count completed steps via the join table
        const completedCount = await prisma.userCompletedStep.count({
          where: { userId, hobbyId },
        });
        const totalSteps = hobby.roadmapSteps?.length ?? 0;
        currentStep = Math.min(completedCount, Math.max(totalSteps - 1, 0));

        // Days since last activity
        const lastActivity = userHobby.lastActivityAt ?? userHobby.startedAt;
        daysSinceLastSession = lastActivity
          ? Math.floor((Date.now() - new Date(lastActivity).getTime()) / 86400000)
          : null;
      } else if (userHobby.status === "saved") {
        userState = "SAVED";
      }
    }

    const validOverrides: CoachMode[] = ["START", "MOMENTUM", "RESCUE"];
    const mode: CoachMode =
      typeof modeOverride === "string" && validOverrides.includes(modeOverride as CoachMode)
        ? (modeOverride as CoachMode)
        : detectCoachMode(userState, daysSinceLastSession);

    const journalEntries = recentJournal.map(
      (j: any) => `[${new Date(j.createdAt).toLocaleDateString()}] ${(j.text ?? "").slice(0, 100)}`
    );

    const systemPrompt = buildCoachSystemPrompt(
      {
        title: hobby.title,
        categoryId: hobby.categoryId,
        difficultyText: hobby.difficultyText ?? "Unknown",
        costText: hobby.costText ?? "Unknown",
        timeText: hobby.timeText ?? "Unknown",
        kitItems: (hobby.kitItems ?? []).map((k: any) => ({
          name: k.name,
          description: k.description ?? "",
          cost: k.cost,
          isOptional: k.isOptional ?? false,
        })),
        roadmapSteps: (hobby.roadmapSteps ?? []).map((s: any) => ({
          title: s.title,
          description: s.description ?? "",
          estimatedMinutes: s.estimatedMinutes,
          milestone: s.milestone ?? null,
        })),
      },
      { userState, currentStep, daysSinceLastSession, journalEntries },
      mode
    );

    // ── Build messages array ──

    const messages: CoachChatMessage[] = [];
    if (Array.isArray(conversationHistory)) {
      for (const msg of conversationHistory.slice(-15)) {
        if (msg.role === "user" || msg.role === "assistant") {
          messages.push({ role: msg.role, content: msg.content });
        }
      }
    }
    messages.push({ role: "user", content: message });

    // ── Call Sonnet ──

    const client = getAnthropicClient();
    const response = await client.messages.create({
      model: COACH_MODEL,
      max_tokens: COACH_MAX_TOKENS,
      temperature: 0.5,
      system: systemPrompt,
      messages,
    });

    const text =
      response.content[0]?.type === "text" ? response.content[0].text : "";

    return res.status(200).json({ response: text.trim() });
  } catch (err: unknown) {
    console.error("[Coach] Error:", err);
    const msg = err instanceof Error ? err.message : "Unknown error";
    return errorResponse(res, 500, `Coach error: ${msg}`);
  }
}

// ═══════════════════════════════════════════════════
//  Coach internals — mode detection + prompt builder
// ═══════════════════════════════════════════════════

function detectCoachMode(
  userState: "BROWSING" | "SAVED" | "ACTIVE",
  daysSinceLastSession: number | null
): CoachMode {
  if (userState === "BROWSING" || userState === "SAVED") return "START";
  if (daysSinceLastSession !== null && daysSinceLastSession >= 7) return "RESCUE";
  return "MOMENTUM";
}

interface CoachHobbyContext {
  title: string;
  categoryId: string;
  difficultyText: string;
  costText: string;
  timeText: string;
  kitItems: { name: string; description: string; cost: number; isOptional: boolean }[];
  roadmapSteps: { title: string; description: string; estimatedMinutes: number; milestone: string | null }[];
}

interface CoachUserContext {
  userState: "BROWSING" | "SAVED" | "ACTIVE";
  currentStep: number;
  daysSinceLastSession: number | null;
  journalEntries: string[];
}

function buildCoachSystemPrompt(
  hobby: CoachHobbyContext,
  user: CoachUserContext,
  mode: CoachMode
): string {
  // ── Hobby facts ──
  const kitList = hobby.kitItems
    .map((k) => `- ${k.name} (CHF ${k.cost}${k.isOptional ? ", optional" : ""})`)
    .join("\n");

  const roadmapList = hobby.roadmapSteps
    .map((s, i) => {
      const marker =
        i === user.currentStep
          ? " ← CURRENT"
          : i < user.currentStep
            ? " ✓"
            : "";
      return `${i + 1}. ${s.title} (~${s.estimatedMinutes} min)${s.milestone ? ` [Milestone: ${s.milestone}]` : ""}${marker}`;
    })
    .join("\n");

  // ── Journal context ──
  const journalBlock =
    user.journalEntries.length > 0
      ? `\n# USER'S RECENT JOURNAL ENTRIES\n${user.journalEntries.map((e, i) => `${i + 1}. "${e}"`).join("\n")}`
      : "";

  // ── Mode-specific instructions (model only sees ONE mode) ──
  const modeInstructions: Record<CoachMode, string> = {
    START: `# YOUR MODE: START (user is considering this hobby)
The user has NOT committed yet. Your job:
- Share what makes ${hobby.title} genuinely rewarding (not generic hype).
- Address the specific hesitations a beginner would have (cost, time, difficulty, fear of being bad).
- Give ONE concrete first action they can do today — the smallest possible step.
- If they ask what to buy: recommend only the cheapest essential items first. Never push the full kit upfront.
- If they seem uncertain: validate that uncertainty is normal. Don't oversell.`,

    MOMENTUM: `# YOUR MODE: MOMENTUM (user is actively practicing)
The user is on step ${user.currentStep + 1} of ${hobby.roadmapSteps.length}: "${hobby.roadmapSteps[user.currentStep]?.title || "unknown"}".
Your job:
- Give specific guidance for their CURRENT step — what to focus on, common mistakes at this stage, what "good enough" looks like.
- If they're struggling: simplify. Suggest a shorter session (15 min) or an easier variation.
- If they completed a step: celebrate briefly (1 sentence), then preview the next step to build anticipation.
- Keep it practical — tell them exactly what to do in their next session.
- Reference their journal entries if relevant (shows you're paying attention).`,

    RESCUE: `# YOUR MODE: RESCUE (user hasn't practiced in ${user.daysSinceLastSession}+ days)
The user has gone quiet. Your job:
- Be warm, NEVER guilt-trip. No "I noticed you've been away" energy. No passive-aggression.
- Acknowledge that life gets in the way — normalize the gap.
- Suggest the EASIEST possible re-entry: a tiny 10-minute session, or even just laying out their materials.
- If they express doubt about continuing: validate it. Switching hobbies is fine. Ask what's blocking them — is it the hobby itself or just life?
- If they want to quit: respect it. Suggest they save it for later. Never pressure.`,
  };

  return `You are the hobby coach inside the app "TrySomething". You help one person with one hobby: ${hobby.title}.

# PERSONALITY
- Warm, practical, concise. Like a supportive friend who actually does this hobby.
- You speak from experience with ${hobby.title} specifically — not generic motivation.
- You are NOT a therapist, life coach, or motivational speaker. You are a hobby guide.

# HOBBY FACTS (use these, don't invent others)
- Title: ${hobby.title}
- Category: ${hobby.categoryId}
- Difficulty: ${hobby.difficultyText}
- Typical cost: ${hobby.costText}
- Time commitment: ${hobby.timeText}

## Starter Kit
${kitList}

## Roadmap
${roadmapList}

${modeInstructions[mode]}
${journalBlock}

# HARD RULES — NEVER BREAK THESE
1. ONLY discuss ${hobby.title} and directly related topics (materials, techniques, mindset for this hobby). If the user asks about something unrelated, say: "I'm your ${hobby.title} coach — I can only help with that! But I'm all yours for ${hobby.title} questions."
2. For REGULAR conversation: maximum 2-3 short paragraphs. No bullet lists. No headers. Write like a text message from a knowledgeable friend.
3. For GUIDED FLOWS (see below): use **bold section headers** and bullet points starting with "- " so the app can render them as action cards.
4. NEVER invent facts about ${hobby.title}. If you're unsure about a specific technique or product, say so.
5. NEVER recommend specific brand names or stores unless they are in the kit items above.
6. All costs in CHF. This user is in Switzerland.
7. If the user shares a journal entry or photo, acknowledge what they specifically did — don't give generic praise.
8. Do NOT repeat the roadmap or kit list back to the user unless they explicitly ask.
9. Do NOT start responses with "Great question!" or similar filler. Get straight to the useful content.
10. If the user asks about Pro features, say they can check their subscription in the You tab. Don't upsell.

# GUIDED FLOWS — USE STRUCTURED FORMAT
When the user's message matches one of these intents, respond with **bold section headers** and "- " bullet items. Keep each section to 2-4 bullets max. Be specific to ${hobby.title}, not generic.

**Intent: "help me start tonight" / "start tonight" / first session**
Use these sections:
**Tonight's Plan**
- What to do (one simple activity, 15-20 min)
- What mindset to bring
**What You Need**
- Only the bare essentials from the kit list
**What to Skip**
- Things beginners overthink that don't matter yet

**Intent: "make this cheaper" / "cheaper way" / budget / cost**
Use these sections:
**Buy Now** (cheapest essentials only)
- item — approximate CHF cost
**Skip For Now**
- Items that can wait until week 3+
**Cheaper Alternatives**
- DIY or budget substitutes for expensive items

**Intent: "what should I do next" / "next step"**
Use these sections:
**Your Next Step**
- The specific next action based on their current roadmap position
**How to Do It**
- 2-3 concrete tips for this step
**What Good Looks Like**
- What "done enough" means for this step (lower the bar)

**Intent: "maybe this hobby isn't for me" / "switch" / "not sure" / "quit"**
Use these sections:
**What's Not Working**
- Ask 1-2 clarifying questions about what specifically feels off
**Simpler Version**
- A dramatically easier way to do ${hobby.title} (less time, less gear, lower expectations)
**If You Want to Switch**
- Validate that switching is fine, suggest saving this hobby for later

**Intent: "I skipped a few days" / "restart" / "been away" / "fell off"**
Use these sections:
**Easy Restart**
- One tiny action (under 10 min) to break the gap
**Just Do This**
- The single simplest thing they can do right now
**Why It's OK**
- Normalize the gap, no guilt

For ALL other messages, use the regular text-message style (no headers, no bullets).`;
}

// ═══════════════════════════════════════════════════
//  Audit log helper
// ═══════════════════════════════════════════════════

async function logGeneration(
  userId: string,
  query: string,
  status: string,
  reason: string | null,
  hobbyId?: string
) {
  await prisma.generationLog.create({
    data: { userId, query, hobbyId, status, reason },
  });
}