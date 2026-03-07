// ═══════════════════════════════════════════════════
//  AI Hobby Coach — Chat endpoint
//  POST /api/coach/chat
//  Accepts: hobbyId, message, conversationHistory[]
//  Returns: { response: string }
// ═══════════════════════════════════════════════════

import type { VercelRequest, VercelResponse } from "@vercel/node";
import { PrismaClient } from "@prisma/client";
import Anthropic from "@anthropic-ai/sdk";
import { requireAuth } from "../../lib/auth";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../lib/middleware";

const prisma = new PrismaClient();
const MODEL = "claude-haiku-4-5-20251001";

let _client: Anthropic | null = null;
function getClient(): Anthropic {
  if (!_client) {
    _client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _client;
}

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId, message, conversationHistory } = req.body ?? {};

  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }
  if (!message || typeof message !== "string") {
    return errorResponse(res, 400, "message is required");
  }

  try {
    // Load hobby data
    const hobby = await prisma.hobby.findUnique({
      where: { id: hobbyId },
      include: {
        kitItems: true,
        roadmapSteps: { orderBy: { order: "asc" } },
      },
    });

    if (!hobby) {
      return errorResponse(res, 404, "Hobby not found");
    }

    // Load user's progress for this hobby
    const userHobby = await prisma.userHobby.findUnique({
      where: { userId_hobbyId: { userId, hobbyId } },
    });

    // Load recent journal entries
    const recentJournal = await prisma.journalEntry.findMany({
      where: { userId, hobbyId },
      orderBy: { createdAt: "desc" },
      take: 5,
    });

    // Build system prompt
    const systemPrompt = buildSystemPrompt(hobby, userHobby, recentJournal);

    // Build conversation messages
    const messages: ChatMessage[] = [];
    if (Array.isArray(conversationHistory)) {
      for (const msg of conversationHistory.slice(-15)) {
        if (msg.role === "user" || msg.role === "assistant") {
          messages.push({ role: msg.role, content: msg.content });
        }
      }
    }
    messages.push({ role: "user", content: message });

    // Call Claude
    const client = getClient();
    const response = await client.messages.create({
      model: MODEL,
      max_tokens: 512,
      system: systemPrompt,
      messages,
    });

    const text =
      response.content[0]?.type === "text" ? response.content[0].text : "";

    return res.status(200).json({ response: text });
  } catch (err: unknown) {
    console.error("[Coach] Error:", err);
    const msg = err instanceof Error ? err.message : "Unknown error";
    return errorResponse(res, 500, `Coach error: ${msg}`);
  }
}

function buildSystemPrompt(
  hobby: any,
  userHobby: any | null,
  recentJournal: any[]
): string {
  const kitList = hobby.kitItems
    ?.map((k: any) => `- ${k.name}: ${k.description}`)
    .join("\n") ?? "None";

  const roadmapList = hobby.roadmapSteps
    ?.map((s: any, i: number) => `${i + 1}. ${s.title} (${s.minutes}min)`)
    .join("\n") ?? "None";

  const journalSummary =
    recentJournal.length > 0
      ? recentJournal
          .map(
            (j: any) =>
              `[${new Date(j.createdAt).toLocaleDateString()}] ${j.text.slice(0, 100)}`
          )
          .join("\n")
      : "No journal entries yet.";

  // Determine user state
  let userState = "BROWSING";
  let progressInfo = "Not started yet.";
  if (userHobby) {
    if (userHobby.status === "trying" || userHobby.status === "active") {
      userState = "ACTIVE";
      const completedSteps = userHobby.completedSteps ?? 0;
      const totalSteps = hobby.roadmapSteps?.length ?? 0;
      progressInfo = `Status: ${userHobby.status}. Completed ${completedSteps}/${totalSteps} roadmap steps. Started: ${userHobby.startedAt ? new Date(userHobby.startedAt).toLocaleDateString() : "unknown"}.`;
    } else if (userHobby.status === "saved") {
      userState = "SAVED";
      progressInfo = "Saved but not started yet.";
    }
  }

  return `You are a friendly, encouraging coach for ${hobby.title}.
You ONLY discuss ${hobby.title} and directly related topics.

User state: ${userState}
${progressInfo}

Recent journal entries:
${journalSummary}

Hobby context:
- Category: ${hobby.categoryId}
- Difficulty: ${hobby.difficultyText ?? "Unknown"}
- Cost: ${hobby.costText ?? "Unknown"}
- Time: ${hobby.timeText ?? "Unknown"}

Starter kit:
${kitList}

Roadmap:
${roadmapList}

Rules:
- If asked about anything unrelated to ${hobby.title}, politely redirect and suggest they check other hobbies in the app.
- Keep responses concise (2-3 paragraphs max).
- Be encouraging but honest.
- Reference their specific progress when relevant.
- If they're BROWSING, share what makes this hobby special and encourage them to save it.
- If they're SAVED, address hesitation and help them take the first step.
- If they're ACTIVE, give specific guidance based on their current roadmap step.`;
}
