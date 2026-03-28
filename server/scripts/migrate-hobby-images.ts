/**
 * Migrate all hobby cover images from Unsplash to Cloudinary.
 *
 * For each hobby:
 * 1. Upload current Unsplash URL to Cloudinary under trysomething/hobbies/{slug}
 * 2. Update the database with the new Cloudinary URL
 * 3. Flag hobbies using category fallback images (likely mismatched)
 *
 * Usage: npx tsx scripts/migrate-hobby-images.ts [--dry-run] [--re-search]
 *   --dry-run    Show what would be done without making changes
 *   --re-search  Re-fetch images from Unsplash for better matches
 */

import { PrismaClient } from "@prisma/client";
import { v2 as cloudinary } from "cloudinary";

const prisma = new PrismaClient();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "dduhb4jtj",
  api_key: process.env.CLOUDINARY_API_KEY || "741933161127774",
  api_secret: process.env.CLOUDINARY_API_SECRET || "Vg4dYgdZvleSoeUhNsX_kqNmAyg",
});

// Known category fallback images — these are generic and likely don't match
const CATEGORY_FALLBACKS = new Set([
  "photo-1513364776144-60967b0f800f", // creative
  "photo-1551632811-561732d1e306", // outdoors
  "photo-1517836357463-d25dfeac3438", // fitness
  "photo-1452587925148-ce544e77e70d", // maker
  "photo-1511379938547-c1f69419868d", // music
  "photo-1556909114-f6e7ad7d3136", // food
  "photo-1558618666-fcd25c85f82e", // collecting
  "photo-1506126613408-eca07ce68773", // mind
  "photo-1529156069898-49953e39b3ac", // social
]);

const UNSPLASH_API = "https://api.unsplash.com/search/photos";

function slugify(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function isFallbackImage(url: string): boolean {
  return [...CATEGORY_FALLBACKS].some((id) => url.includes(id));
}

async function searchUnsplash(query: string): Promise<string | null> {
  const accessKey = process.env.UNSPLASH_ACCESS_KEY;
  if (!accessKey) {
    console.warn("  ⚠ No UNSPLASH_ACCESS_KEY — skipping re-search");
    return null;
  }

  const params = new URLSearchParams({
    query: `${query} hobby activity`,
    orientation: "portrait",
    per_page: "3",
  });

  const res = await fetch(`${UNSPLASH_API}?${params}`, {
    headers: { Authorization: `Client-ID ${accessKey}` },
  });

  if (!res.ok) return null;

  const data = (await res.json()) as {
    results?: { urls?: { raw?: string }; description?: string }[];
  };
  const results = data.results;
  if (!results || results.length === 0) return null;

  const rawUrl = results[0].urls?.raw;
  return rawUrl ? `${rawUrl}&w=600&h=800&fit=crop` : null;
}

async function uploadToCloudinary(
  url: string,
  slug: string
): Promise<string | null> {
  try {
    const result = await cloudinary.uploader.upload(url, {
      folder: "trysomething/hobbies",
      public_id: slug,
      overwrite: true,
      resource_type: "image",
      transformation: [{ width: 600, height: 800, crop: "fill", gravity: "auto" }],
    });
    return result.secure_url;
  } catch (err) {
    console.error(`  ✗ Upload failed:`, err);
    return null;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const reSearch = args.includes("--re-search");

  console.log(`\n🔄 Hobby Image Migration ${dryRun ? "(DRY RUN)" : ""}`);
  console.log(`   Re-search: ${reSearch ? "YES" : "NO"}\n`);

  const hobbies = await prisma.hobby.findMany({
    select: { id: true, title: true, imageUrl: true, category: true },
    orderBy: { title: "asc" },
  });

  console.log(`Found ${hobbies.length} hobbies\n`);

  let migrated = 0;
  let reSearched = 0;
  let failed = 0;
  let skipped = 0;
  const flagged: string[] = [];

  for (const hobby of hobbies) {
    const slug = slugify(hobby.title);
    const isFallback = hobby.imageUrl ? isFallbackImage(hobby.imageUrl) : true;

    // Already on Cloudinary? Skip
    if (hobby.imageUrl?.includes("cloudinary")) {
      console.log(`  ✓ ${hobby.title} — already on Cloudinary`);
      skipped++;
      continue;
    }

    let sourceUrl = hobby.imageUrl;

    // Flag fallback images
    if (isFallback) {
      flagged.push(`${hobby.title} (${hobby.category || "no category"})`);

      if (reSearch) {
        console.log(`  🔍 ${hobby.title} — fallback detected, re-searching...`);
        const better = await searchUnsplash(hobby.title);
        if (better) {
          sourceUrl = better;
          reSearched++;
          console.log(`  ↻ Found better image`);
        } else {
          console.log(`  ⚠ No better image found, using fallback`);
        }
        // Rate limit: Unsplash allows 50 req/hour
        await new Promise((r) => setTimeout(r, 1500));
      }
    }

    if (!sourceUrl) {
      console.log(`  ✗ ${hobby.title} — no image URL`);
      failed++;
      continue;
    }

    if (dryRun) {
      console.log(
        `  → ${hobby.title} → trysomething/hobbies/${slug}${isFallback ? " ⚠ FALLBACK" : ""}`
      );
      migrated++;
      continue;
    }

    // Upload to Cloudinary
    const newUrl = await uploadToCloudinary(sourceUrl, slug);
    if (!newUrl) {
      console.log(`  ✗ ${hobby.title} — upload failed`);
      failed++;
      continue;
    }

    // Update DB
    await prisma.hobby.update({
      where: { id: hobby.id },
      data: { imageUrl: newUrl },
    });

    console.log(`  ✓ ${hobby.title} → ${slug}`);
    migrated++;

    // Small delay to avoid rate limits
    await new Promise((r) => setTimeout(r, 200));
  }

  console.log(`\n${"═".repeat(50)}`);
  console.log(`✓ Migrated: ${migrated}`);
  console.log(`↻ Re-searched: ${reSearched}`);
  console.log(`⊘ Skipped: ${skipped}`);
  console.log(`✗ Failed: ${failed}`);

  if (flagged.length > 0) {
    console.log(`\n⚠ FLAGGED — using generic fallback images (${flagged.length}):`);
    flagged.forEach((f) => console.log(`  - ${f}`));
  }

  console.log("");
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
