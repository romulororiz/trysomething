import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { groupByField } from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    const tags = await prisma.moodTag.findMany();
    const grouped = groupByField(tags, "mood", "hobbyId");
    res.status(200).json(grouped);
  } catch (err) {
    console.error("GET /api/hobbies/mood error:", err);
    errorResponse(res, 500, "Failed to fetch mood tags");
  }
}
