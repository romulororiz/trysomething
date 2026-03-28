/**
 * Fix mismatched hobby cover images.
 * Re-searches Unsplash with specific queries and uploads to Cloudinary.
 *
 * Usage: npx tsx scripts/fix-mismatched-covers.ts
 */

import { PrismaClient } from "@prisma/client";
import { v2 as cloudinary } from "cloudinary";
import "dotenv/config";

const prisma = new PrismaClient();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "dduhb4jtj",
  api_key: process.env.CLOUDINARY_API_KEY || "741933161127774",
  api_secret: process.env.CLOUDINARY_API_SECRET || "Vg4dYgdZvleSoeUhNsX_kqNmAyg",
});

const UNSPLASH_API = "https://api.unsplash.com/search/photos";

// Specific search queries for each mismatched hobby
const FIXES: Record<string, string> = {
  // Batch 1
  "Acting": "theater actor on stage spotlight",
  "Aerial Silks": "aerial silks acrobat hanging fabric",
  "Antique Books": "antique leather bound old books shelf",
  "Beatboxing": "beatboxer microphone mouth percussion",
  "Birdwatching": "person binoculars birdwatching nature",
  "Boxing": "boxer punching bag boxing gloves gym",
  "Cajon": "cajon box drum percussion hands playing",
  "Calligraphy": "calligraphy pen ink brush lettering",
  "Candle Decorating": "decorated candles wax craft colorful",
  "Coffee Roasting": "coffee beans roasting roaster machine",
  "Coins": "coin collection numismatic rare coins",
  "Collage": "paper collage art crafting scissors glue",
  "Crochet": "crochet hook yarn blanket handmade",
  "Crosswalking": "urban walking city exploration pedestrian",
  "Crystals": "crystals minerals amethyst quartz collection",
  "Dance Socials": "salsa dancing couple social dance floor",

  // Batch 2
  "DJ/Mixing": "dj turntable mixer headphones club",
  "Drone Building": "drone assembly parts soldering fpv build",
  "Enamel Pins": "enamel pins collection backpack colorful",
  "Fencing": "fencing sport sword mask epee foil",
  "Fermentation": "fermentation jars kimchi sauerkraut kombucha",
  "Fishing": "person fishing rod lake river casting",
  "Foosball": "foosball table game players handles",
  "Furniture Restoration": "furniture restoration sanding refinishing antique",
  "Geocaching": "geocaching gps treasure box forest",
  "Glassblowing": "glassblowing furnace molten glass artisan",
  "Home Decoration": "interior design home decor living room styling",
  "Hot Sauce Making": "hot sauce chili peppers bottles making",
  "Ice Skating": "ice skating rink person blades winter",
  "Jet Skiing": "jet ski water sport ocean speed",
  "Jump Rope": "jump rope exercise skipping fitness",
  "Knife Making": "knife making forge blacksmith blade anvil",
  "Kombucha Brewing": "kombucha scoby jar brewing fermented tea",
  "Language Exchange": "people conversation language exchange cafe",

  // Batch 3
  "Leathercraft": "leather tooling crafting stitching wallet belt",
  "Loom Weaving": "loom weaving shuttle yarn textile threads",
  "Macramé": "macrame wall hanging plant hanger knots",
  "Meditation": "person meditating seated cross legged peaceful",
  "Model Building": "scale model building miniature airplane ship",
  "Mosaic": "mosaic tile art colorful pattern handmade",
  "Numbered Painting": "paint by numbers canvas brushes artwork",
  "Parkour": "parkour freerunning jumping urban rooftop",
  "Pickling": "pickled vegetables jars cucumber brine",
  "Postcards": "vintage postcards travel writing stamps",
  "Potluck Clubs": "potluck dinner friends food sharing table",
  "Pottery Wheel": "hands clay pottery wheel spinning",
  "Reading Challenges": "stack of books reading cozy bookshelf",
  "Rowing": "rowing crew boat oars water sport",
  "Running Groups": "group running together jogging park",

  // Batch 4
  "Scrapbooking": "scrapbook pages stickers photos decorative",
  "Scooter Riding": "kick scooter riding person street",
  "Skiing": "person skiing downhill snow mountain",
  "Swimming": "swimmer pool lanes stroke",
  "Tai Chi": "tai chi practice park morning slow movement",
  "Tea Ceremony": "japanese tea ceremony matcha teapot cups",
  "Tie-Dye": "tie dye fabric spiral colorful pattern shirt",
  "Trail Running": "person trail running mountain forest",
  "Vintage Cameras": "vintage film camera retro analog photography",
  "Vintage Posters": "vintage retro poster art deco collection",
  "Violin": "violin player strings classical instrument",
  "Volunteering": "volunteers community service helping teamwork",
  "Watercolor": "watercolor painting palette brush artwork",
  "Woodburning": "pyrography wood burning pen art craft",
  "Woodworking": "woodworking bench chisel plane handcraft",
  "Yoga": "yoga pose mat stretching studio",
  "Jewelry Making": "jewelry making beads wire pliers crafting",
  "Fishing": "person fishing rod lake river casting",
};

function slugify(title: string): string {
  return title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

async function searchUnsplash(query: string): Promise<string | null> {
  const accessKey = process.env.UNSPLASH_ACCESS_KEY;
  if (!accessKey) {
    console.error("No UNSPLASH_ACCESS_KEY set!");
    return null;
  }

  const params = new URLSearchParams({
    query,
    orientation: "portrait",
    per_page: "1",
  });

  const res = await fetch(`${UNSPLASH_API}?${params}`, {
    headers: { Authorization: `Client-ID ${accessKey}` },
  });

  if (!res.ok) {
    console.error(`  Unsplash error: ${res.status}`);
    return null;
  }

  const data = (await res.json()) as {
    results?: { urls?: { raw?: string } }[];
  };

  const rawUrl = data.results?.[0]?.urls?.raw;
  return rawUrl ? `${rawUrl}&w=600&h=800&fit=crop` : null;
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
  } catch (err) {
    console.error(`  Upload failed:`, err);
    return null;
  }
}

async function main() {
  const titles = Object.keys(FIXES);
  console.log(`\n🔧 Fixing ${titles.length} mismatched hobby covers\n`);

  let fixed = 0, failed = 0;

  for (const title of titles) {
    const query = FIXES[title];
    const slug = slugify(title);

    process.stdout.write(`  ${title}...`);

    // Search Unsplash
    const unsplashUrl = await searchUnsplash(query);
    if (!unsplashUrl) {
      console.log(" ✗ no Unsplash result");
      failed++;
      await new Promise(r => setTimeout(r, 1500));
      continue;
    }

    // Upload to Cloudinary
    const cloudinaryUrl = await uploadToCloudinary(unsplashUrl, slug);
    if (!cloudinaryUrl) {
      console.log(" ✗ upload failed");
      failed++;
      await new Promise(r => setTimeout(r, 1500));
      continue;
    }

    // Update DB
    await prisma.hobby.updateMany({
      where: { title },
      data: { imageUrl: cloudinaryUrl },
    });

    console.log(" ✓");
    fixed++;

    // Rate limit: Unsplash allows 50 req/hour on free tier
    await new Promise(r => setTimeout(r, 1500));
  }

  console.log(`\n${"═".repeat(40)}`);
  console.log(`✓ Fixed: ${fixed}`);
  console.log(`✗ Failed: ${failed}`);
  console.log("");
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
