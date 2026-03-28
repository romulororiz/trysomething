// ═══════════════════════════════════════════════════
//  Unsplash image search → Cloudinary upload for hobby covers
// ═══════════════════════════════════════════════════

import { v2 as cloudinary } from "cloudinary";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "dduhb4jtj",
  api_key: process.env.CLOUDINARY_API_KEY || "741933161127774",
  api_secret: process.env.CLOUDINARY_API_SECRET || "Vg4dYgdZvleSoeUhNsX_kqNmAyg",
});

const UNSPLASH_API = "https://api.unsplash.com/search/photos";

// Fallback images per category (already on Cloudinary)
const CATEGORY_FALLBACKS: Record<string, string> = {
  creative: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/sketching.jpg",
  outdoors: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/hiking.jpg",
  fitness: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/yoga.jpg",
  maker: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/woodworking.jpg",
  music: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/guitar.jpg",
  food: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/cooking-classes.jpg",
  collecting: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/vinyl-records.jpg",
  mind: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/meditation.jpg",
  social: "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/board-game-nights.jpg",
};

const DEFAULT_FALLBACK = "https://res.cloudinary.com/dduhb4jtj/image/upload/trysomething/hobbies/photography.jpg";

function slugify(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

async function uploadToCloudinary(url: string, slug: string): Promise<string | null> {
  try {
    const result = await cloudinary.uploader.upload(url, {
      folder: "trysomething/hobbies",
      public_id: slug,
      overwrite: true,
      resource_type: "image",
      transformation: [{ width: 600, height: 800, crop: "fill", gravity: "auto" }],
    });
    return result.secure_url;
  } catch {
    return null;
  }
}

export async function fetchHobbyImage(
  query: string,
  categoryId?: string
): Promise<string> {
  const accessKey = process.env.UNSPLASH_ACCESS_KEY;
  const fallback = CATEGORY_FALLBACKS[categoryId ?? ""] ?? DEFAULT_FALLBACK;

  if (!accessKey) return fallback;

  try {
    const params = new URLSearchParams({
      query: `${query} hobby`,
      orientation: "portrait",
      per_page: "1",
    });

    const response = await fetch(`${UNSPLASH_API}?${params}`, {
      headers: { Authorization: `Client-ID ${accessKey}` },
    });

    if (!response.ok) return fallback;

    const data = (await response.json()) as { results?: { urls?: { raw?: string } }[] };
    const results = data.results;

    if (!results || results.length === 0) return fallback;

    const rawUrl = results[0].urls?.raw;
    if (!rawUrl) return fallback;

    const unsplashUrl = `${rawUrl}&w=600&h=800&fit=crop`;

    // Upload to Cloudinary instead of hotlinking Unsplash
    const slug = slugify(query);
    const cloudinaryUrl = await uploadToCloudinary(unsplashUrl, slug);

    return cloudinaryUrl ?? fallback;
  } catch {
    return fallback;
  }
}
