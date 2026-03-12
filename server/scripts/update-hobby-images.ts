import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();
const UNSPLASH_KEY = process.env.UNSPLASH_ACCESS_KEY;
const CACHE_FILE = path.join(__dirname, 'hobby-images-cache.json');

// 150 hobbies with specific search queries to get unique, relevant images.
// Queries are intentionally distinct even for related hobbies (e.g. pottery vs pottery-wheel).
const hobbies: { id: string; query: string }[] = [
  // CREATIVE
  { id: 'pottery',           query: 'pottery clay hand shaping' },
  { id: 'watercolor',        query: 'watercolor painting wet brush' },
  { id: 'sketching',         query: 'pencil sketch drawing paper' },
  { id: 'calligraphy',       query: 'calligraphy ink dip pen lettering' },
  { id: 'knitting',          query: 'knitting needles wool yarn' },
  { id: 'crochet',           query: 'crochet hook colorful yarn handmade' },
  { id: 'embroidery',        query: 'embroidery hoop needle floral thread' },
  { id: 'photography',       query: 'camera photographer dslr portrait' },
  { id: 'digital-art',       query: 'digital art drawing tablet stylus' },
  { id: 'woodburning',       query: 'wood burning pyrography art tool' },
  { id: 'origami',           query: 'origami paper folding crane art' },
  { id: 'scrapbooking',      query: 'scrapbook memory album photo pages' },
  { id: 'jewelry-making',    query: 'jewelry making silver wire pliers' },
  { id: 'resin-art',         query: 'resin art pouring epoxy colorful' },
  { id: 'screen-printing',   query: 'screen printing silk screen ink press' },
  { id: 'macrame',           query: 'macrame wall hanging rope knots' },
  { id: 'collage',           query: 'paper collage cutting artistic mixed media' },
  { id: 'sewing',            query: 'sewing machine fabric stitch thread' },
  { id: 'tie-dye',           query: 'tie dye colorful fabric spiral' },
  { id: 'mosaic',            query: 'mosaic tiles colorful glass art' },
  { id: 'stained-glass',     query: 'stained glass colorful church window' },
  { id: 'candle-decorating', query: 'decorated candles artistic painted wax' },

  // OUTDOORS
  { id: 'hiking',            query: 'hiking trail mountain forest path' },
  { id: 'birdwatching',      query: 'birdwatching binoculars bird nature' },
  { id: 'kayaking',          query: 'kayaking river paddle water sport' },
  { id: 'gardening',         query: 'gardening hands soil planting seeds' },
  { id: 'stargazing',        query: 'stargazing night sky milky way telescope' },
  { id: 'geocaching',        query: 'geocaching gps compass outdoor treasure' },
  { id: 'trail-running',     query: 'trail running forest dirt path athlete' },
  { id: 'rock-climbing',     query: 'rock climbing cliff face outdoor' },
  { id: 'surfing',           query: 'surfing ocean wave board sunset' },
  { id: 'camping',           query: 'camping tent stars fire night' },
  { id: 'fishing',           query: 'fly fishing river trout water' },
  { id: 'mountain-biking',   query: 'mountain bike trail dirt jump' },
  { id: 'foraging',          query: 'foraging mushrooms wild forest basket' },
  { id: 'nature-photography',query: 'wildlife photography forest lens nature' },
  { id: 'sailing',           query: 'sailing yacht sea horizon wind' },
  { id: 'skiing',            query: 'skiing snow slope mountain powder' },
  { id: 'horseback-riding',  query: 'horseback riding horse equestrian field' },
  { id: 'beach-volleyball',  query: 'beach volleyball sand net game' },

  // FITNESS
  { id: 'bouldering',        query: 'bouldering indoor climbing gym wall' },
  { id: 'yoga',              query: 'yoga pose mat sunrise outdoor' },
  { id: 'swimming',          query: 'swimming pool lane underwater' },
  { id: 'martial-arts',      query: 'martial arts karate kick training' },
  { id: 'dance',             query: 'dance contemporary ballet studio' },
  { id: 'crossfit',          query: 'crossfit barbell workout gym' },
  { id: 'boxing',            query: 'boxing training gloves heavy bag' },
  { id: 'pilates',           query: 'pilates reformer studio stretch' },
  { id: 'cycling',           query: 'road cycling bike helmet speed' },
  { id: 'skateboarding',     query: 'skateboarding trick ramp urban' },
  { id: 'parkour',           query: 'parkour urban freerunning jump rooftop' },
  { id: 'fencing',           query: 'fencing sword sport mask duel' },
  { id: 'archery',           query: 'archery bow arrow target range' },
  { id: 'rowing',            query: 'rowing boat water crew sport' },
  { id: 'jump-rope',         query: 'jump rope skipping fitness street' },
  { id: 'aerial-silks',      query: 'aerial silks circus acrobatics performance' },
  { id: 'ice-skating',       query: 'ice skating rink figure glide' },
  { id: 'tai-chi',           query: 'tai chi morning park slow motion' },

  // MAKER
  { id: 'woodworking',          query: 'woodworking workshop chisel plane craft' },
  { id: '3d-printing',          query: '3d printer technology filament model' },
  { id: 'electronics',          query: 'electronics soldering circuit board maker' },
  { id: 'leathercraft',         query: 'leather craft tooling hand stitching' },
  { id: 'candle-making',        query: 'candle making wax pour mold workshop' },
  { id: 'soap-making',          query: 'handmade soap natural bar ingredients' },
  { id: 'metalworking',         query: 'metalworking blacksmith forge anvil sparks' },
  { id: 'model-building',       query: 'scale model kit airplane assembly miniature' },
  { id: 'bookbinding',          query: 'bookbinding craft stitch leather cover' },
  { id: 'furniture-restoration',query: 'furniture restoration workshop sanding refinish' },
  { id: 'knife-making',         query: 'knife making blade blacksmith grind' },
  { id: 'pottery-wheel',        query: 'pottery wheel spinning studio artist' },
  { id: 'glassblowing',         query: 'glassblowing molten glass pipe studio' },
  { id: 'loom-weaving',         query: 'loom weaving textile shuttle thread' },
  { id: 'clock-repair',         query: 'clock repair watchmaker tiny gears precision' },
  { id: 'drone-building',       query: 'drone building hobby electronics propeller' },

  // MUSIC
  { id: 'guitar',           query: 'acoustic guitar playing musician hands' },
  { id: 'ukulele',          query: 'ukulele strumming beach happy musician' },
  { id: 'piano',            query: 'piano keys playing classical fingers' },
  { id: 'drumming',         query: 'drum kit playing sticks musician' },
  { id: 'singing',          query: 'singer microphone studio recording' },
  { id: 'violin',           query: 'violin bow playing classical musician' },
  { id: 'dj-mixing',        query: 'dj mixer turntable nightclub music' },
  { id: 'music-production', query: 'music production studio mixing board headphones' },
  { id: 'harmonica',        query: 'harmonica blues music playing closeup' },
  { id: 'bass-guitar',      query: 'bass guitar electric strings musician' },
  { id: 'flute',            query: 'flute classical musician playing keys' },
  { id: 'saxophone',        query: 'saxophone jazz musician blowing' },
  { id: 'cajon',            query: 'cajon box drum percussion playing' },
  { id: 'beatboxing',       query: 'beatboxing hip hop vocal performance street' },
  { id: 'songwriting',      query: 'songwriter notebook guitar lyrics writing' },
  { id: 'music-theory',     query: 'music theory sheet notes score' },

  // FOOD
  { id: 'sourdough',        query: 'sourdough bread scoring baking loaf' },
  { id: 'fermentation',     query: 'fermentation jars kimchi vegetables crock' },
  { id: 'coffee-roasting',  query: 'coffee roasting beans drum aroma' },
  { id: 'pasta-making',     query: 'fresh pasta making dough rolling' },
  { id: 'sushi',            query: 'sushi making roll mat nori rice' },
  { id: 'smoking-bbq',      query: 'bbq smoking wood fire meat grill' },
  { id: 'bread-baking',     query: 'artisan bread baking oven crust' },
  { id: 'cocktails',        query: 'cocktail bartender shaker mixing drink' },
  { id: 'cheese-making',    query: 'cheese making aging wheel dairy' },
  { id: 'chocolate',        query: 'chocolate making temper artisan dark cacao' },
  { id: 'pickling',         query: 'pickling jars cucumbers brine preservation' },
  { id: 'hot-sauce',        query: 'hot sauce peppers spicy bottle making' },
  { id: 'korean-cooking',   query: 'korean cooking bibimbap kimchi food' },
  { id: 'indian-curry',     query: 'indian curry spices masala cooking' },
  { id: 'pizza',            query: 'pizza dough stretching wood fire oven' },
  { id: 'pastry',           query: 'pastry croissant laminated dough baking' },
  { id: 'tea-ceremony',     query: 'japanese tea ceremony matcha bowl whisk' },
  { id: 'kombucha',         query: 'kombucha brew ferment scoby jar' },

  // COLLECTING
  { id: 'vinyl-records',    query: 'vinyl record collection player needle' },
  { id: 'vintage-cameras',  query: 'vintage film camera analog collection' },
  { id: 'plants',           query: 'houseplant collection tropical indoor shelf' },
  { id: 'coins',            query: 'coin collection numismatics magnify ancient' },
  { id: 'stamps',           query: 'stamp collection philately album tweezers' },
  { id: 'sneakers',         query: 'sneaker collection shelf display shoes' },
  { id: 'watches',          query: 'watch collection luxury timepiece display' },
  { id: 'antique-books',    query: 'antique books leather bound library' },
  { id: 'crystals',         query: 'crystal mineral collection gems display' },
  { id: 'postcards',        query: 'vintage postcard collection travel map' },
  { id: 'board-games',      query: 'board game collection shelf hobby room' },
  { id: 'pokemon-cards',    query: 'trading card game binder collection' },
  { id: 'vintage-posters',  query: 'vintage poster art collection framed wall' },
  { id: 'enamel-pins',      query: 'enamel pin badge collection display board' },

  // MIND
  { id: 'chess',            query: 'chess board pieces strategy game' },
  { id: 'journaling',       query: 'journal writing pen notebook morning' },
  { id: 'meditation',       query: 'meditation sitting peaceful mindfulness' },
  { id: 'language-learning',query: 'language learning study flashcards books' },
  { id: 'puzzles',          query: 'jigsaw puzzle assembling pieces table' },
  { id: 'reading-challenges',query: 'reading book cozy light armchair' },
  { id: 'philosophy',       query: 'philosophy thinking books library contemplation' },
  { id: 'creative-writing', query: 'typewriter writing creative author notebook' },
  { id: 'astronomy',        query: 'astronomy telescope stars night observatory' },
  { id: 'brain-teasers',    query: 'puzzle brain teaser logic thinking' },
  { id: 'speed-cubing',     query: 'rubik cube speed solving timer competition' },
  { id: 'memory-training',  query: 'memory training concentration mind exercise' },
  { id: 'mind-calligraphy', query: 'zen calligraphy brush ink mindful stroke' },
  { id: 'lucid-dreaming',   query: 'dream sleep surreal night consciousness' },

  // SOCIAL
  { id: 'board-game-nights',query: 'board game night friends laughing table' },
  { id: 'improv',           query: 'improv comedy theater stage performance' },
  { id: 'volunteering',     query: 'volunteering community garden outdoor helping' },
  { id: 'book-club',        query: 'book club reading group friends coffee' },
  { id: 'trivia',           query: 'trivia quiz night pub team competition' },
  { id: 'community-theater',query: 'community theater stage costume performance' },
  { id: 'wine-tasting',     query: 'wine tasting vineyard glass swirl' },
  { id: 'hiking-clubs',     query: 'group hiking friends trail outdoor mountain' },
  { id: 'cooking-classes',  query: 'cooking class chef instruction kitchen group' },
  { id: 'dance-socials',    query: 'social dance ballroom swing couple evening' },
  { id: 'language-exchange',query: 'language exchange conversation cafe notebook' },
  { id: 'toastmasters',     query: 'public speaking podium presentation confidence' },
  { id: 'potluck-clubs',    query: 'potluck dinner table food sharing friends' },
  { id: 'running-groups',   query: 'running group park morning race street' },
];

async function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function fetchUnsplashPhoto(query: string): Promise<string | null> {
  const url = `https://api.unsplash.com/search/photos?query=${encodeURIComponent(query)}&orientation=portrait&per_page=3&order_by=relevant&client_id=${UNSPLASH_KEY}`;
  const response = await fetch(url);

  if (response.status === 429) {
    console.log('  Rate limited — waiting 65 seconds...');
    await sleep(65_000);
    return fetchUnsplashPhoto(query); // retry once
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

  // Prefer photos with good dimensions (portrait ratio)
  const photo = data.results[0];
  const raw: string = photo.urls.raw;
  // Request 800×1066 portrait crop (matches the cinematic card 3:4 ratio)
  return `${raw}&w=800&h=1066&fit=crop&q=85`;
}

async function main() {
  if (!UNSPLASH_KEY) {
    throw new Error('UNSPLASH_ACCESS_KEY env var is required. Get a free key at https://unsplash.com/developers');
  }

  // Load progress cache so the script is resumable
  const cache: Record<string, string> = fs.existsSync(CACHE_FILE)
    ? JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'))
    : {};

  console.log(`Starting image update for ${hobbies.length} hobbies`);
  console.log(`Already cached: ${Object.keys(cache).length}`);

  let updated = 0;
  let skipped = 0;
  let failed = 0;

  for (const hobby of hobbies) {
    if (cache[hobby.id]) {
      console.log(`  ✓ ${hobby.id} (cached)`);
      skipped++;
      continue;
    }

    process.stdout.write(`  → ${hobby.id}... `);
    const imageUrl = await fetchUnsplashPhoto(hobby.query);

    if (!imageUrl) {
      console.log('SKIP (no result)');
      failed++;
      continue;
    }

    await prisma.hobby.update({
      where: { id: hobby.id },
      data: { imageUrl },
    });

    cache[hobby.id] = imageUrl;
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
    console.log('DONE');
    updated++;

    // ~1.5s between requests → stays well within 50 req/hour demo limit
    await sleep(1_500);
  }

  console.log(`\nFinished: ${updated} updated, ${skipped} skipped, ${failed} failed`);
  if (failed > 0) {
    console.log('Re-run the script to retry failed hobbies');
  }
}

main()
  .catch(err => { console.error(err); process.exit(1); })
  .finally(() => prisma.$disconnect());
