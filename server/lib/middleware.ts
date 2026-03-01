import type { VercelRequest, VercelResponse } from "@vercel/node";

// CORS headers for Flutter client
export function setCorsHeaders(res: VercelResponse): void {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

// Handle CORS preflight
export function handleCors(req: VercelRequest, res: VercelResponse): boolean {
  setCorsHeaders(res);
  if (req.method === "OPTIONS") {
    res.status(200).end();
    return true;
  }
  return false;
}

// Standard error response
export function errorResponse(
  res: VercelResponse,
  status: number,
  message: string
): void {
  res.status(status).json({ error: message });
}

// Method guard — returns true if the method is NOT allowed (and sends 405)
export function methodNotAllowed(
  req: VercelRequest,
  res: VercelResponse,
  allowed: string[]
): boolean {
  if (!allowed.includes(req.method ?? "")) {
    res.setHeader("Allow", allowed.join(", "));
    errorResponse(res, 405, `Method ${req.method} not allowed`);
    return true;
  }
  return false;
}
