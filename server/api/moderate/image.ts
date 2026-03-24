// ═══════════════════════════════════════════════════
//  Image Moderation — Pre-upload safety gate
//  POST /api/moderate/image
//
//  Accepts base64-encoded image, screens via Claude Haiku
//  vision, blocks NSFW / violence / policy violations
//  BEFORE the image ever reaches Cloudinary.
// ═══════════════════════════════════════════════════

import type { VercelRequest, VercelResponse } from "@vercel/node";
import Anthropic from "@anthropic-ai/sdk";
import { requireAuth } from "../../lib/auth";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";

// Use Haiku for speed + cost (moderation is a classification task)
const MODERATION_MODEL = "claude-haiku-4-5-20251001";
const MAX_IMAGE_BYTES = 2 * 1024 * 1024; // 2MB max base64 payload

// ── Strict moderation prompt ──────────────────────
const MODERATION_PROMPT = `You are an image content safety classifier for a hobby discovery app (TrySomething). Your ONLY job is to determine if an uploaded image is safe for a general-audience mobile app.

REJECT (unsafe = true) if the image contains ANY of the following:
- Nudity or partial nudity (including lingerie, suggestive poses)
- Sexual or sexually suggestive content of any kind
- Pornographic content
- Violence, gore, blood, wounds, or graphic injury
- Weapons (guns, knives used threateningly, explosives)
- Drug use, drug paraphernalia, or substance abuse
- Self-harm or suicide imagery
- Hate symbols, extremist imagery, or discriminatory content
- Graphic medical/surgical imagery
- Child exploitation or endangerment of any kind
- Illegal activity being depicted
- Disturbing, grotesque, or shock content
- Text overlays containing hate speech, slurs, or threats

ALLOW (unsafe = false) for:
- Hobby activities (painting, cooking, gardening, crafts, sports, music, etc.)
- Nature, landscapes, animals, pets
- Food, recipes, ingredients
- Tools, materials, equipment for hobbies
- Selfies and portraits (clothed, appropriate)
- Progress photos of creative work
- Indoor/outdoor scenes
- Screenshots of hobby-related content

You MUST err on the side of caution. If you are even slightly uncertain, REJECT.

Respond with EXACTLY this JSON format, nothing else:
{"unsafe": false}
or
{"unsafe": true, "reason": "brief explanation"}`;

function getClient(): Anthropic {
  return new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY! });
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (handleCors(req, res)) return;
  if (req.method !== "POST") return methodNotAllowed(res);

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const { image, mediaType } = req.body ?? {};

    if (!image || typeof image !== "string") {
      return errorResponse(res, 400, "Missing image (base64 string)");
    }

    // Validate payload size (base64 string length ≈ 1.37× raw bytes)
    if (image.length > MAX_IMAGE_BYTES * 1.4) {
      return errorResponse(res, 413, "Image too large (max 2MB)");
    }

    // Validate media type
    const validTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];
    const resolvedType = validTypes.includes(mediaType) ? mediaType : "image/jpeg";

    const client = getClient();
    const response = await client.messages.create({
      model: MODERATION_MODEL,
      max_tokens: 100,
      temperature: 0,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: resolvedType,
                data: image,
              },
            },
            {
              type: "text",
              text: "Classify this image. Respond with JSON only.",
            },
          ],
        },
      ],
      system: MODERATION_PROMPT,
    });

    const text =
      response.content[0]?.type === "text" ? response.content[0].text : "";

    // Parse the classification response
    let result: { unsafe: boolean; reason?: string };
    try {
      // Extract JSON from response (handle potential markdown wrapping)
      const jsonMatch = text.match(/\{[^}]+\}/);
      result = jsonMatch ? JSON.parse(jsonMatch[0]) : { unsafe: true, reason: "Failed to parse moderation response" };
    } catch {
      // If parsing fails, default to REJECT (fail closed)
      result = { unsafe: true, reason: "Moderation check inconclusive — rejected for safety" };
    }

    // FAIL CLOSED: if anything unexpected, reject
    if (typeof result.unsafe !== "boolean") {
      result = { unsafe: true, reason: "Invalid moderation response" };
    }

    return res.status(200).json({
      safe: !result.unsafe,
      reason: result.unsafe ? (result.reason || "Content policy violation") : undefined,
    });
  } catch (err: unknown) {
    console.error("[Moderate] Error:", err);
    // FAIL CLOSED: if moderation itself errors, reject the upload
    return res.status(200).json({
      safe: false,
      reason: "Moderation service unavailable — please try again",
    });
  }
}
