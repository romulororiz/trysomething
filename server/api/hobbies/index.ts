import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { mapHobby } from "../../lib/mappers";

const hobbyIncludes = {
  kitItems: { orderBy: { sortOrder: "asc" as const } },
  roadmapSteps: { orderBy: { sortOrder: "asc" as const } },
};

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    const hobbies = await prisma.hobby.findMany({
      orderBy: { sortOrder: "asc" },
      include: hobbyIncludes,
    });

    res.status(200).json(hobbies.map(mapHobby));
  } catch (err) {
    console.error("GET /api/hobbies error:", err);
    errorResponse(res, 500, "Failed to fetch hobbies");
  }
}
