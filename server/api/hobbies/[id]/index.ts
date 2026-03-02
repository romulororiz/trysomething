import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../../lib/middleware";
import { prisma } from "../../../lib/db";
import { mapHobby } from "../../../lib/mappers";

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

    const hobby = await prisma.hobby.findUnique({
      where: { id },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" as const } },
        roadmapSteps: { orderBy: { sortOrder: "asc" as const } },
      },
    });

    if (!hobby) {
      errorResponse(res, 404, `Hobby '${id}' not found`);
      return;
    }

    res.status(200).json(mapHobby(hobby));
  } catch (err) {
    console.error("GET /api/hobbies/[id] error:", err);
    errorResponse(res, 500, "Failed to fetch hobby");
  }
}
