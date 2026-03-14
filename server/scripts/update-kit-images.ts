import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env manually (dotenv may not be available)
const envCandidates = [
  path.join(__dirname, '..', '.env'),
  path.join(process.cwd(), '.env'),
];
for (const envPath of envCandidates) {
  if (fs.existsSync(envPath)) {
    for (const rawLine of fs.readFileSync(envPath, 'utf8').split('\n')) {
      const line = rawLine.trim();
      const match = line.match(/^(\w+)=["']?(.+?)["']?$/);
      if (match && !process.env[match[1]]) {
        process.env[match[1]] = match[2];
      }
    }
    break;
  }
}

const UNSPLASH_KEY = process.env.UNSPLASH_ACCESS_KEY;
const DATABASE_URL = process.env.DATABASE_URL;
const CACHE_FILE = path.join(__dirname, 'kit-images-cache.json');

// Specific search queries for each kit item, grouped by hobby.
// Queries target product-style images for accurate shopping list visuals.
const kitItemQueries: Record<string, string> = {
  // ── Acting ──
  'Acting for Dummies or A Practical Handbook for the Actor': 'acting textbook drama book',
  'Full-Length Mirror': 'full length mirror standing bedroom',
  'Script Notebook or Binder': 'notebook binder script writing',
  'Voice Recorder (smartphone app or device)': 'voice recorder digital device',
  'Theater Workshop or Community Class': 'theater acting class workshop stage',

  // ── Crosswalking ──
  'Comfortable walking shoes': 'walking shoes comfortable sneakers',
  'Small notebook & pen': 'small notebook pen pocket journal',
  'Pocket city map or printed neighborhood guide': 'city map paper folded urban',
  'Reusable water bottle': 'reusable water bottle stainless steel',
  'Weather-appropriate jacket': 'lightweight rain jacket outdoor',
  'Basic camera or smartphone': 'smartphone camera photography',

  // ── Drone Flying ──
  'Beginner Drone (DJI Mini or equivalent)': 'dji mini drone quadcopter',
  'Extra Batteries (2-pack)': 'drone battery lithium pack',
  'Propeller Guards': 'drone propeller guards protection',
  'ND/Polarizing Filters': 'camera nd filter polarizing lens',
  'Portable Charging Hub': 'portable charging hub drone battery',
  'Carrying Case or Backpack': 'drone carrying case backpack hard',

  // ── Jet Skiing ──
  'Wetsuit (3–5mm)': 'wetsuit neoprene water sport black',
  'Personal Flotation Device (PFD)': 'life jacket flotation device water',
  'Water Shoes': 'water shoes aqua neoprene',
  'Waterproof Sunscreen (SPF 50+)': 'sunscreen spf waterproof sport bottle',
  'Dry Bag or Waterproof Case': 'dry bag waterproof roll top',
  'Rash Guard (optional under wetsuit)': 'rash guard swim shirt uv',

  // ── Jogging ──
  'Running Shoes': 'running shoes athletic sneakers road',
  'Moisture-Wicking Shirt': 'athletic moisture wicking shirt sport',
  'Athletic Shorts or Tights': 'running shorts athletic tights sport',
  'Running Watch or Smartphone App': 'running watch gps fitness tracker',
  'Running Belt or Armband': 'running belt phone armband sport',
  'Reflective Gear or Lights': 'reflective running vest light safety',

  // ── Kickboxing ──
  'Hand Wraps': 'boxing hand wraps red black',
  'Boxing Gloves (12–14 oz)': 'boxing gloves red leather kickboxing',
  'Shin Guards': 'kickboxing shin guards muay thai',
  'Kickboxing Shorts': 'muay thai shorts kickboxing satin',
  'Heavy Bag or Gym Membership': 'heavy punching bag boxing gym',
  'Mouthguard': 'sports mouthguard protective boxing',

  // ── Kite Surfing ──
  'Kite Surfing Lessons (5 sessions)': 'kite surfing lesson beach instructor',
  'Kite (7–12m, beginner-friendly)': 'kitesurfing kite colorful water sport',
  'Board (directional or twin-tip)': 'kiteboard twin tip board water',
  'Bar and Lines': 'kite bar lines control kitesurfing',
  'Life Vest/Impact Vest': 'impact vest water sport kitesurfing',
  'Helmet': 'water sport helmet kitesurfing safety',

  // ── Model Railroading ──
  'Starter Train Set (HO Scale)': 'model train set ho scale locomotive',
  'Track Cleaning Tool': 'model railroad track cleaning tool',
  'Folding Layout Table (2×3m)': 'model railroad layout table plywood',
  'Scenery Starter Kit (trees, buildings, ballast)': 'model train scenery miniature trees buildings',
  'Basic Tool Kit (tweezers, knife, glue, file)': 'hobby tool kit tweezers craft knife',
  'Digital Decoder & Controller (optional upgrade)': 'model train dcc controller digital',

  // ── Pencil Coloring ──
  'Colored Pencil Set (24–48 colors)': 'colored pencil set prismacolor faber',
  'Coloring Book or Pad': 'adult coloring book detailed pages',
  'Blending Stumps or Colorless Blender Pencil': 'blending stump pencil art tool',
  'Sharpener (Electric or Manual)': 'pencil sharpener electric art',
  'Smooth Paper or Specialty Coloring Pad': 'smooth drawing paper pad art',
  'Fixative Spray': 'fixative spray art pencil drawing',

  // ── Programming ──
  'Computer (laptop or desktop)': 'laptop computer coding developer',
  'Code Editor (VS Code)': 'code editor screen programming vscode',
  'Programming Course or Books': 'programming book coding textbook python',
  'Notebook for Planning': 'developer notebook planning dotted grid',
  'GitHub Account (Free)': 'github code collaboration screen',
  'Online Communities (Discord/Reddit)': 'online community developer chat screen',

  // ── Therapeutic Massage ──
  'Massage Oil': 'massage oil bottle essential aromatherapy',
  'Massage Cushion or Bolster': 'massage bolster cushion therapy table',
  'Beginner Massage Course or eBook': 'massage therapy course book learning',
  'Massage Therapy Handbook': 'massage therapy handbook textbook anatomy',
  'Massage Balls Set': 'massage ball set therapy myofascial',
  'Heated Massage Pad': 'heated massage pad therapy electric',
};

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function fetchUnsplashPhoto(query: string): Promise<string | null> {
  const url = `https://api.unsplash.com/search/photos?query=${encodeURIComponent(query)}&orientation=squarish&per_page=3&order_by=relevant&client_id=${UNSPLASH_KEY}`;
  const response = await fetch(url);

  if (response.status === 429) {
    console.log('  Rate limited — waiting 65 seconds...');
    await sleep(65_000);
    return fetchUnsplashPhoto(query);
  }

  if (!response.ok) {
    console.warn(`  HTTP ${response.status} for query "${query}"`);
    return null;
  }

  const data = await response.json() as any;
  if (!data.results || data.results.length === 0) {
    console.warn(`  No results for "${query}"`);
    return null;
  }

  const photo = data.results[0];
  const raw: string = photo.urls.raw;
  // Square crop for product-style kit item images
  return `${raw}&w=400&h=400&fit=crop&q=80`;
}

async function main() {
  if (!UNSPLASH_KEY) {
    throw new Error('UNSPLASH_ACCESS_KEY env var is required.');
  }
  if (!DATABASE_URL) {
    throw new Error('DATABASE_URL env var is required (loaded from server/.env).');
  }

  const pool = new pg.Pool({ connectionString: DATABASE_URL, ssl: { rejectUnauthorized: false } });

  // Load progress cache so the script is resumable
  const cache: Record<string, string> = fs.existsSync(CACHE_FILE)
    ? JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'))
    : {};

  // Fetch all kit items missing images
  const { rows: items } = await pool.query<{ id: string; name: string; hobby_title: string }>(
    `SELECT ki.id, ki.name, h.title as hobby_title
     FROM "KitItem" ki
     JOIN "Hobby" h ON h.id = ki."hobbyId"
     WHERE ki."imageUrl" IS NULL OR ki."imageUrl" = ''
     ORDER BY h.title, ki."sortOrder"`
  );

  console.log(`Found ${items.length} kit items without images`);
  console.log(`Already cached: ${Object.keys(cache).length}`);

  let updated = 0;
  let skipped = 0;
  let failed = 0;

  for (const item of items) {
    if (cache[item.id]) {
      console.log(`  ✓ ${item.name} (cached)`);
      skipped++;
      continue;
    }

    // Look up specific query, or fall back to generic search
    const specificQuery = kitItemQueries[item.name];
    const query = specificQuery || `${item.name} product`;

    process.stdout.write(`  → [${item.hobby_title}] ${item.name}... `);
    const imageUrl = await fetchUnsplashPhoto(query);

    if (!imageUrl) {
      console.log('SKIP (no result)');
      failed++;
      continue;
    }

    await pool.query(
      `UPDATE "KitItem" SET "imageUrl" = $1 WHERE id = $2`,
      [imageUrl, item.id]
    );

    cache[item.id] = imageUrl;
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
    console.log('DONE');
    updated++;

    // ~1.5s between requests to stay within Unsplash rate limits
    await sleep(1_500);
  }

  console.log(`\nFinished: ${updated} updated, ${skipped} skipped, ${failed} failed`);
  if (failed > 0) {
    console.log('Re-run the script to retry failed items');
  }

  await pool.end();
}

main()
  .catch(err => { console.error(err); process.exit(1); });
