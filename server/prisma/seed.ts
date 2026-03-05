import { PrismaClient } from "@prisma/client";

import { creativeHobbies, creativeKitItems, creativeRoadmapSteps, creativeFaqItems, creativeCostBreakdowns } from "./seed-data/creative";
import { outdoorsHobbies, outdoorsKitItems, outdoorsRoadmapSteps, outdoorsFaqItems, outdoorsCostBreakdowns } from "./seed-data/outdoors";
import { fitnessHobbies, fitnessKitItems, fitnessRoadmapSteps, fitnessFaqItems, fitnessCostBreakdowns } from "./seed-data/fitness";
import { makerHobbies, makerKitItems, makerRoadmapSteps, makerFaqItems, makerCostBreakdowns } from "./seed-data/maker";
import { musicHobbies, musicKitItems, musicRoadmapSteps, musicFaqItems, musicCostBreakdowns } from "./seed-data/music";
import { foodHobbies, foodKitItems, foodRoadmapSteps, foodFaqItems, foodCostBreakdowns } from "./seed-data/food";
import { collectingHobbies, collectingKitItems, collectingRoadmapSteps, collectingFaqItems, collectingCostBreakdowns } from "./seed-data/collecting";
import { mindHobbies, mindKitItems, mindRoadmapSteps, mindFaqItems, mindCostBreakdowns } from "./seed-data/mind";
import { socialHobbies, socialKitItems, socialRoadmapSteps, socialFaqItems, socialCostBreakdowns } from "./seed-data/social";

const prisma = new PrismaClient();

async function main() {
  console.log("Seeding TrySomething database (150 hobbies)...\n");

  // ═══════════════════════════════════════════════════
  //  CATEGORIES
  // ═══════════════════════════════════════════════════

  const categories = [
    { id: "creative", name: "Creative", imageUrl: "https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&q=80", sortOrder: 0 },
    { id: "outdoors", name: "Outdoors", imageUrl: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600&q=80", sortOrder: 1 },
    { id: "fitness", name: "Fitness", imageUrl: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=600&q=80", sortOrder: 2 },
    { id: "maker", name: "Maker/DIY", imageUrl: "https://images.unsplash.com/photo-1581783898377-1c85bf937427?w=600&q=80", sortOrder: 3 },
    { id: "music", name: "Music", imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=600&q=80", sortOrder: 4 },
    { id: "food", name: "Food", imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=600&q=80", sortOrder: 5 },
    { id: "collecting", name: "Collecting", imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&q=80", sortOrder: 6 },
    { id: "mind", name: "Mind", imageUrl: "https://images.unsplash.com/photo-1508672019048-805c876b67e2?w=600&q=80", sortOrder: 7 },
    { id: "social", name: "Social", imageUrl: "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600&q=80", sortOrder: 8 },
  ];

  for (const cat of categories) {
    await prisma.category.upsert({
      where: { id: cat.id },
      update: cat,
      create: cat,
    });
  }
  console.log(`  ✓ ${categories.length} categories`);

  // ═══════════════════════════════════════════════════
  //  HOBBIES (150 total)
  // ═══════════════════════════════════════════════════

  const allHobbies = [
    ...creativeHobbies,
    ...outdoorsHobbies,
    ...fitnessHobbies,
    ...makerHobbies,
    ...musicHobbies,
    ...foodHobbies,
    ...collectingHobbies,
    ...mindHobbies,
    ...socialHobbies,
  ];

  for (const hobby of allHobbies) {
    await prisma.hobby.upsert({
      where: { id: hobby.id },
      update: hobby,
      create: hobby,
    });
  }
  console.log(`  ✓ ${allHobbies.length} hobbies`);

  // ═══════════════════════════════════════════════════
  //  KIT ITEMS
  // ═══════════════════════════════════════════════════

  await prisma.kitItem.deleteMany();

  const allKitItems = [
    ...creativeKitItems,
    ...outdoorsKitItems,
    ...fitnessKitItems,
    ...makerKitItems,
    ...musicKitItems,
    ...foodKitItems,
    ...collectingKitItems,
    ...mindKitItems,
    ...socialKitItems,
  ];

  await prisma.kitItem.createMany({ data: allKitItems });
  console.log(`  ✓ ${allKitItems.length} kit items`);

  // ═══════════════════════════════════════════════════
  //  ROADMAP STEPS
  // ═══════════════════════════════════════════════════

  await prisma.roadmapStep.deleteMany();

  const allRoadmapSteps = [
    ...creativeRoadmapSteps,
    ...outdoorsRoadmapSteps,
    ...fitnessRoadmapSteps,
    ...makerRoadmapSteps,
    ...musicRoadmapSteps,
    ...foodRoadmapSteps,
    ...collectingRoadmapSteps,
    ...mindRoadmapSteps,
    ...socialRoadmapSteps,
  ];

  await prisma.roadmapStep.createMany({ data: allRoadmapSteps });
  console.log(`  ✓ ${allRoadmapSteps.length} roadmap steps`);

  // ═══════════════════════════════════════════════════
  //  FAQ ITEMS
  // ═══════════════════════════════════════════════════

  await prisma.faqItem.deleteMany();

  const allFaqItems = [
    ...creativeFaqItems,
    ...outdoorsFaqItems,
    ...fitnessFaqItems,
    ...makerFaqItems,
    ...musicFaqItems,
    ...foodFaqItems,
    ...collectingFaqItems,
    ...mindFaqItems,
    ...socialFaqItems,
  ];

  await prisma.faqItem.createMany({ data: allFaqItems });
  console.log(`  ✓ ${allFaqItems.length} FAQ items`);

  // ═══════════════════════════════════════════════════
  //  COST BREAKDOWNS
  // ═══════════════════════════════════════════════════

  await prisma.costBreakdown.deleteMany();

  const allCostBreakdowns = [
    ...creativeCostBreakdowns,
    ...outdoorsCostBreakdowns,
    ...fitnessCostBreakdowns,
    ...makerCostBreakdowns,
    ...musicCostBreakdowns,
    ...foodCostBreakdowns,
    ...collectingCostBreakdowns,
    ...mindCostBreakdowns,
    ...socialCostBreakdowns,
  ];

  await prisma.costBreakdown.createMany({ data: allCostBreakdowns });
  console.log(`  ✓ ${allCostBreakdowns.length} cost breakdowns`);

  // ═══════════════════════════════════════════════════
  //  HOBBY COMBOS (25 pairs)
  // ═══════════════════════════════════════════════════

  await prisma.hobbyCombo.deleteMany();

  const combos = [
    // Cross-category creative pairings
    { hobbyId1: "pottery", hobbyId2: "calligraphy", reason: "Both build hand-eye coordination and spatial awareness. The meditative flow state is similar.", sharedTags: ["creative", "relaxing"] },
    { hobbyId1: "sourdough", hobbyId2: "pottery", reason: "Both are meditative making processes. You can make your own plates for your own bread.", sharedTags: ["creative", "relaxing"] },
    { hobbyId1: "photography", hobbyId2: "hiking", reason: "Nature gives you endless subjects. Hiking takes you to the best vantage points.", sharedTags: ["outdoors", "creative"] },
    { hobbyId1: "watercolor", hobbyId2: "nature-photography", reason: "Use your photos as references for paintings. Both train your eye for light and composition.", sharedTags: ["creative", "outdoors"] },
    { hobbyId1: "guitar", hobbyId2: "songwriting", reason: "Guitar gives you the chords. Songwriting gives you the words. Together they're magic.", sharedTags: ["creative"] },
    // Fitness combos
    { hobbyId1: "bouldering", hobbyId2: "yoga", reason: "Yoga builds the flexibility and balance that make you a better climber.", sharedTags: ["physical"] },
    { hobbyId1: "bouldering", hobbyId2: "hiking", reason: "Climbing builds strength. Hiking builds endurance. Together they unlock outdoor adventures.", sharedTags: ["physical", "outdoors"] },
    { hobbyId1: "cycling", hobbyId2: "trail-running", reason: "Both are endurance sports. Cross-training prevents injury and keeps things fresh.", sharedTags: ["physical", "outdoors"] },
    { hobbyId1: "martial-arts", hobbyId2: "meditation", reason: "Martial arts trains the body, meditation trains the mind. Both cultivate discipline and presence.", sharedTags: ["physical", "meditative"] },
    { hobbyId1: "swimming", hobbyId2: "surfing", reason: "Swimming builds water confidence. Surfing puts it to use in the most exhilarating way.", sharedTags: ["physical", "outdoors"] },
    // Maker combos
    { hobbyId1: "woodworking", hobbyId2: "leathercraft", reason: "Natural materials, hand tools, timeless crafts. The skills complement each other beautifully.", sharedTags: ["creative", "technical"] },
    { hobbyId1: "electronics", hobbyId2: "3d-printing", reason: "Print custom enclosures for your electronics projects. The ultimate maker combo.", sharedTags: ["technical"] },
    { hobbyId1: "candle-making", hobbyId2: "soap-making", reason: "Similar processes, shared supplies. Both make amazing gifts and potential side income.", sharedTags: ["creative"] },
    // Food combos
    { hobbyId1: "sourdough", hobbyId2: "pizza", reason: "Master sourdough, then use it for the best pizza dough you've ever tasted.", sharedTags: ["creative"] },
    { hobbyId1: "fermentation", hobbyId2: "kombucha", reason: "Both involve cultivating living cultures. The science of fermentation unlocks both.", sharedTags: ["creative", "technical"] },
    { hobbyId1: "coffee-roasting", hobbyId2: "pastry", reason: "Roast your own beans, bake your own pastries. The ultimate café-at-home combo.", sharedTags: ["creative"] },
    { hobbyId1: "cocktails", hobbyId2: "wine-tasting", reason: "Both deepen your understanding of flavors, aromas, and the craft of beverages.", sharedTags: ["social", "creative"] },
    // Mind + social combos
    { hobbyId1: "chess", hobbyId2: "board-game-nights", reason: "Chess sharpens strategic thinking. Board games bring the social element.", sharedTags: ["competitive", "social"] },
    { hobbyId1: "creative-writing", hobbyId2: "book-club", reason: "Reading critically makes you a better writer. Writing makes you a more insightful reader.", sharedTags: ["creative", "social"] },
    { hobbyId1: "journaling", hobbyId2: "meditation", reason: "Meditation quiets the mind. Journaling captures what emerges. A powerful self-reflection duo.", sharedTags: ["meditative", "solo"] },
    { hobbyId1: "language-learning", hobbyId2: "language-exchange", reason: "Learn the theory, then practice with native speakers. The fastest way to fluency.", sharedTags: ["social", "technical"] },
    // Collecting + lifestyle combos
    { hobbyId1: "vinyl-records", hobbyId2: "dj-mixing", reason: "Start collecting records, end up mixing them. The natural evolution of a music lover.", sharedTags: ["creative"] },
    { hobbyId1: "plants", hobbyId2: "gardening", reason: "Indoor plants teach you the basics. A garden lets you go wild.", sharedTags: ["relaxing", "outdoors"] },
    { hobbyId1: "sketching", hobbyId2: "embroidery", reason: "Sketch your designs, then stitch them into fabric. Drawing meets textile art.", sharedTags: ["creative", "relaxing"] },
    { hobbyId1: "improv", hobbyId2: "toastmasters", reason: "Improv builds spontaneity. Toastmasters builds structure. Together they make you an incredible communicator.", sharedTags: ["social"] },
  ];

  await prisma.hobbyCombo.createMany({ data: combos });
  console.log(`  ✓ ${combos.length} hobby combos`);

  // ═══════════════════════════════════════════════════
  //  SEASONAL PICKS
  // ═══════════════════════════════════════════════════

  await prisma.seasonalPick.deleteMany();

  const seasonalPicks: { hobbyId: string; season: string }[] = [];
  const seasonalMap: Record<string, string[]> = {
    "Winter Warmers": [
      "sourdough", "pottery", "calligraphy", "chess", "knitting", "crochet",
      "candle-making", "bread-baking", "chocolate", "journaling", "piano",
      "creative-writing", "board-game-nights", "model-building",
    ],
    "Spring Awakening": [
      "hiking", "gardening", "birdwatching", "cycling", "trail-running",
      "photography", "watercolor", "foraging", "yoga", "plants",
      "running-groups", "volunteering",
    ],
    "Summer Adventures": [
      "surfing", "kayaking", "camping", "skateboarding", "rock-climbing",
      "beach-volleyball", "mountain-biking", "sailing", "tie-dye",
      "smoking-bbq", "cocktails", "dance-socials",
    ],
    "Autumn Coziness": [
      "pottery", "sourdough", "calligraphy", "chess", "embroidery",
      "woodworking", "fermentation", "pickling", "coffee-roasting",
      "reading-challenges", "book-club", "wine-tasting",
    ],
  };

  for (const [season, hobbyIds] of Object.entries(seasonalMap)) {
    for (const hobbyId of hobbyIds) {
      seasonalPicks.push({ hobbyId, season });
    }
  }

  await prisma.seasonalPick.createMany({ data: seasonalPicks, skipDuplicates: true });
  console.log(`  ✓ ${seasonalPicks.length} seasonal picks`);

  // ═══════════════════════════════════════════════════
  //  MOOD TAGS
  // ═══════════════════════════════════════════════════

  await prisma.moodTag.deleteMany();

  const moodToTags: Record<string, string[]> = {
    Stressed: ["relaxing", "meditative"],
    Bored: ["physical", "competitive"],
    Lonely: ["social"],
    Creative: ["creative"],
    Restless: ["physical", "outdoors"],
    Curious: ["technical", "creative"],
  };

  const moodTags: { hobbyId: string; mood: string }[] = [];

  for (const [mood, tags] of Object.entries(moodToTags)) {
    for (const hobby of allHobbies) {
      if (hobby.tags.some((t: string) => tags.includes(t))) {
        moodTags.push({ hobbyId: hobby.id, mood });
      }
    }
  }

  await prisma.moodTag.createMany({ data: moodTags, skipDuplicates: true });
  console.log(`  ✓ ${moodTags.length} mood tags`);

  // ═══════════════════════════════════════════════════
  //  SUMMARY
  // ═══════════════════════════════════════════════════

  console.log("\n═══════════════════════════════════════");
  console.log(`  Total hobbies:       ${allHobbies.length}`);
  console.log(`  Total kit items:     ${allKitItems.length}`);
  console.log(`  Total roadmap steps: ${allRoadmapSteps.length}`);
  console.log(`  Total FAQ items:     ${allFaqItems.length}`);
  console.log(`  Total combos:        ${combos.length}`);
  console.log("═══════════════════════════════════════");
  console.log("\nSeed complete!");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
