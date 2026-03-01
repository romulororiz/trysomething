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
    const picks = await prisma.seasonalPick.findMany();
    const grouped = groupByField(picks, "season", "hobbyId");
    res.status(200).json(grouped);
  } catch (err) {
    console.error("GET /api/hobbies/seasonal error:", err);
    errorResponse(res, 500, "Failed to fetch seasonal picks");
  }
}
