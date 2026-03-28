/**
 * Download all current hobby cover images from DB (Cloudinary URLs) to a local folder.
 * This gets fresh images reflecting the current DB state (not stale cache).
 *
 * Usage: npx tsx scripts/download-all-covers.ts
 */

import { PrismaClient } from "@prisma/client";
import * as fs from "fs";
import * as path from "path";
import "dotenv/config";

const prisma = new PrismaClient();

const OUTPUT_DIR = path.join(
  process.env.USERPROFILE || process.env.HOME || ".",
  "tmp",
  "hobby-covers-fresh"
);

function slugify(title: string): string {
  return title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

async function downloadImage(url: string, filePath: string): Promise<boolean> {
  try {
    const res = await fetch(url, { redirect: "follow" });
    if (!res.ok) {
      console.error(`  HTTP ${res.status} for ${url}`);
      return false;
    }
    const buffer = await res.arrayBuffer();
    fs.writeFileSync(filePath, Buffer.from(buffer));
    return true;
  } catch (err) {
    console.error(`  Download error: ${err}`);
    return false;
  }
}

async function main() {
  // Create output dir
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const hobbies = await prisma.hobby.findMany({
    select: { id: true, title: true, imageUrl: true },
    orderBy: { title: "asc" },
  });

  console.log(`\nDownloading ${hobbies.length} hobby covers to ${OUTPUT_DIR}\n`);

  let ok = 0, failed = 0;

  // Write a mapping file: slug -> title -> url for reference
  const mapping: Record<string, { title: string; url: string; slug: string }> = {};

  for (const hobby of hobbies) {
    const slug = slugify(hobby.title);
    const filePath = path.join(OUTPUT_DIR, `${slug}.jpg`);

    if (!hobby.imageUrl) {
      console.log(`  ✗ ${hobby.title} — no imageUrl`);
      failed++;
      continue;
    }

    process.stdout.write(`  ${hobby.title}...`);
    const success = await downloadImage(hobby.imageUrl, filePath);
    if (success) {
      console.log(" ✓");
      ok++;
      mapping[slug] = { title: hobby.title, url: hobby.imageUrl, slug };
    } else {
      console.log(" ✗");
      failed++;
    }

    // Small delay to avoid hammering Cloudinary
    await new Promise((r) => setTimeout(r, 80));
  }

  // Write mapping JSON
  fs.writeFileSync(
    path.join(OUTPUT_DIR, "_mapping.json"),
    JSON.stringify(mapping, null, 2)
  );

  console.log(`\n${"═".repeat(50)}`);
  console.log(`✓ Downloaded: ${ok}`);
  console.log(`✗ Failed:     ${failed}`);
  console.log(`\nSaved to: ${OUTPUT_DIR}`);
  console.log(`Mapping:  ${OUTPUT_DIR}/_mapping.json\n`);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
