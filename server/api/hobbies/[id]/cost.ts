import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../../lib/middleware";
import { prisma } from "../../../lib/db";
import { mapCostBreakdown } from "../../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    const { id } = req.query;
    if (!id || typeof id !== "string") {
      errorResponse(res, 400, "Missing hobby ID");
      return;
    }

    const breakdown = await prisma.costBreakdown.findUnique({
      where: { hobbyId: id },
    });

    if (!breakdown) {
      errorResponse(res, 404, `No cost data for hobby '${id}'`);
      return;
    }

    res.status(200).json(mapCostBreakdown(breakdown));
  } catch (err) {
    console.error("GET /api/hobbies/[id]/cost error:", err);
    errorResponse(res, 500, "Failed to fetch cost breakdown");
  }
}
