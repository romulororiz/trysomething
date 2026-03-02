// ═══════════════════════════════════════════════════
//  Unsplash image search for hobby images
// ═══════════════════════════════════════════════════

const UNSPLASH_API = "https://api.unsplash.com/search/photos";

// Fallback images per category (Unsplash URLs matching existing seed pattern)
const CATEGORY_FALLBACKS: Record<string, string> = {
  creative: "https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&h=800&fit=crop",
  outdoors: "https://images.unsplash.com/photo-1551632811-561732d1e306?w=600&h=800&fit=crop",
  fitness: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=600&h=800&fit=crop",
  maker: "https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=600&h=800&fit=crop",
  music: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=600&h=800&fit=crop",
  food: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=800&fit=crop",
  collecting: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=800&fit=crop",
  mind: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600&h=800&fit=crop",
  social: "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600&h=800&fit=crop",
};

const DEFAULT_FALLBACK = "https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&h=800&fit=crop";

export async function fetchHobbyImage(
  query: string,
  categoryId?: string
): Promise<string> {
  const accessKey = process.env.UNSPLASH_ACCESS_KEY;
  if (!accessKey) {
    return CATEGORY_FALLBACKS[categoryId ?? ""] ?? DEFAULT_FALLBACK;
  }

  try {
    const params = new URLSearchParams({
      query: `${query} hobby`,
      orientation: "portrait",
      per_page: "1",
    });

    const response = await fetch(`${UNSPLASH_API}?${params}`, {
      headers: { Authorization: `Client-ID ${accessKey}` },
    });

    if (!response.ok) {
      return CATEGORY_FALLBACKS[categoryId ?? ""] ?? DEFAULT_FALLBACK;
    }

    const data = (await response.json()) as { results?: { urls?: { raw?: string } }[] };
    const results = data.results;

    if (!results || results.length === 0) {
      return CATEGORY_FALLBACKS[categoryId ?? ""] ?? DEFAULT_FALLBACK;
    }

    // Use raw URL with crop params to match existing seed data pattern
    const rawUrl = results[0].urls?.raw;
    if (!rawUrl) {
      return CATEGORY_FALLBACKS[categoryId ?? ""] ?? DEFAULT_FALLBACK;
    }

    return `${rawUrl}&w=600&h=800&fit=crop`;
  } catch {
    return CATEGORY_FALLBACKS[categoryId ?? ""] ?? DEFAULT_FALLBACK;
  }
}
