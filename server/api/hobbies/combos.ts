import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { mapCombo } from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    const combos = await prisma.hobbyCombo.findMany();
    res.status(200).json(combos.map(mapCombo));
  } catch (err) {
    console.error("GET /api/hobbies/combos error:", err);
    errorResponse(res, 500, "Failed to fetch combos");
  }
}
