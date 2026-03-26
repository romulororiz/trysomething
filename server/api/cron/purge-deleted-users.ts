import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handlePurgeDeletedUsers } from "../users/[path]";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  return handlePurgeDeletedUsers(req, res);
}
