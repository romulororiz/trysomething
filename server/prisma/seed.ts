import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("Seeding TrySomething database...\n");

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
  console.log(`  ${categories.length} categories`);

  // ═══════════════════════════════════════════════════
  //  HOBBIES
  // ═══════════════════════════════════════════════════

  const hobbies = [
    {
      id: "pottery",
      title: "Pottery",
      hook: "Get your hands dirty. Make something real.",
      categoryId: "creative",
      imageUrl: "https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=600&h=800&fit=crop",
      tags: ["creative", "relaxing", "meditative"],
      costText: "CHF 40–120",
      timeText: "2h/week",
      difficultyText: "Moderate",
      whyLove: "The tactile satisfaction is unmatched. You lose track of time, your phone stays in your pocket, and you walk away with something you made with your own hands.",
      difficultyExplain: "Centering clay on a wheel takes practice. Hand-building is much easier to start with and just as rewarding.",
      pitfalls: [
        "Don't start with a wheel — try hand-building first.",
        "Air-dry clay cracks if too thin. Keep walls ≥5mm.",
        "Don't skip wedging. Air bubbles ruin your piece.",
      ],
      sortOrder: 0,
    },
    {
      id: "bouldering",
      title: "Bouldering",
      hook: "Solve puzzles with your body.",
      categoryId: "fitness",
      imageUrl: "https://images.unsplash.com/photo-1522163182402-834f871fd851?w=600&h=800&fit=crop",
      tags: ["physical", "social", "competitive"],
      costText: "CHF 20–60",
      timeText: "3h/week",
      difficultyText: "Moderate",
      whyLove: "It's social, physical, and mental all at once. You'll make friends at the gym and surprise yourself with what your body can do.",
      difficultyExplain: "Technique matters more than strength. Finger strength builds slowly — be patient with yourself.",
      pitfalls: [
        "Use your legs, not just your arms. Most beginners over-grip.",
        "Rest between problems. Tendons need time to adapt.",
        "Start on easy grades (V0–V1). Ego is the enemy.",
      ],
      sortOrder: 1,
    },
    {
      id: "sourdough",
      title: "Sourdough Baking",
      hook: "Flour, water, patience. Insanely rewarding.",
      categoryId: "food",
      imageUrl: "https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=600&h=800&fit=crop",
      tags: ["creative", "relaxing", "solo"],
      costText: "CHF 15–50",
      timeText: "2h/week",
      difficultyText: "Moderate",
      whyLove: "The smell. The ritual. Pulling a golden loaf from your own oven. You'll never look at supermarket bread the same way again.",
      difficultyExplain: "Timing is everything. Your first few loaves may be flat — that's completely normal and part of the process.",
      pitfalls: [
        "Don't rush fermentation. Cold overnight rise = more flavor.",
        "Your starter needs 7–10 days to mature. Be patient.",
        "Don't add too much flour. Wet dough = open crumb.",
      ],
      sortOrder: 2,
    },
    {
      id: "skateboarding",
      title: "Skateboarding",
      hook: "Four wheels, infinite possibilities.",
      categoryId: "fitness",
      imageUrl: "https://images.unsplash.com/photo-1564982752979-3f7bc974d29a?w=600&h=800&fit=crop",
      tags: ["physical", "outdoors", "creative"],
      costText: "CHF 80–200",
      timeText: "3h/week",
      difficultyText: "Hard",
      whyLove: "There's nothing like the feeling of rolling. The freedom, the flow state, the community. Every trick you land is pure magic.",
      difficultyExplain: "Balance takes time. You will fall — that's part of it. Protective gear helps confidence enormously.",
      pitfalls: [
        "Don't buy a cheap toy board. Spend at least CHF 80 on a real one.",
        "Learn to push and stop before attempting tricks.",
        "Skate on smooth ground first. Rough pavement is frustrating.",
      ],
      sortOrder: 3,
    },
    {
      id: "chess",
      title: "Chess",
      hook: "The ultimate thinking game. Infinite depth.",
      categoryId: "mind",
      imageUrl: "https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=600&h=800&fit=crop",
      tags: ["competitive", "solo", "technical"],
      costText: "CHF 0–30",
      timeText: "2h/week",
      difficultyText: "Easy",
      whyLove: "You can play anywhere, anytime. Online, in a park, with friends. Every game teaches you something new about strategy and yourself.",
      difficultyExplain: "Rules are simple to learn. Strategy depth is what keeps you playing for decades.",
      pitfalls: [
        "Don't try to memorize openings first. Learn tactics instead.",
        "Play longer time controls to actually learn. Avoid only bullet chess.",
        "Analyze your losses. That's where the growth is.",
      ],
      sortOrder: 4,
    },
    {
      id: "calligraphy",
      title: "Calligraphy",
      hook: "Turn words into art. Meditative, beautiful.",
      categoryId: "creative",
      imageUrl: "https://images.unsplash.com/photo-1455390582262-044cdead277a?w=600&h=800&fit=crop",
      tags: ["creative", "relaxing", "solo"],
      costText: "CHF 20–60",
      timeText: "1h/week",
      difficultyText: "Easy",
      whyLove: "The meditative rhythm of pen strokes. Watching beautiful letters flow from your hand. It's mindfulness made visible.",
      difficultyExplain: "Modern calligraphy is forgiving. Traditional styles require more discipline, but both are accessible.",
      pitfalls: [
        "Use the right paper. Regular paper bleeds and frays pen tips.",
        "Don't press too hard. Let the pen do the work.",
        "Start with drills, not letters. Build muscle memory first.",
      ],
      sortOrder: 5,
    },
    {
      id: "hiking",
      title: "Hiking",
      hook: "Step outside. The trail is calling.",
      categoryId: "outdoors",
      imageUrl: "https://images.unsplash.com/photo-1551632811-561732d1e306?w=600&h=800&fit=crop",
      tags: ["physical", "outdoors", "relaxing"],
      costText: "CHF 0–150",
      timeText: "4h/week",
      difficultyText: "Easy",
      whyLove: "The views, the fresh air, the sense of accomplishment at the summit. Nature is the best therapy — and it's free.",
      difficultyExplain: "Start with well-marked, flat trails. Difficulty is entirely in your control based on trail choice.",
      pitfalls: [
        "Check the weather before you go. Mountains change fast.",
        "Don't skip sunscreen. UV is stronger at elevation.",
        "Start shorter than you think. 3 hours is plenty for your first hike.",
      ],
      sortOrder: 6,
    },
    {
      id: "guitar",
      title: "Guitar",
      hook: "Six strings. Endless songs. Start tonight.",
      categoryId: "music",
      imageUrl: "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&h=800&fit=crop",
      tags: ["creative", "relaxing", "solo"],
      costText: "CHF 50–300",
      timeText: "3h/week",
      difficultyText: "Moderate",
      whyLove: "Playing your first full song is one of the most rewarding feelings. Music becomes yours to create, not just consume.",
      difficultyExplain: "Finger pain goes away after 2 weeks. Chord changes take practice. Use YouTube — there are incredible free teachers.",
      pitfalls: [
        "Your fingers will hurt for 2 weeks. Push through — calluses form fast.",
        "Don't try barre chords in week 1. Stick to open chords.",
        "Practice 15 minutes daily rather than 2 hours on weekends.",
      ],
      sortOrder: 7,
    },
  ];

  for (const hobby of hobbies) {
    await prisma.hobby.upsert({
      where: { id: hobby.id },
      update: hobby,
      create: hobby,
    });
  }
  console.log(`  ${hobbies.length} hobbies`);

  // ═══════════════════════════════════════════════════
  //  KIT ITEMS
  // ═══════════════════════════════════════════════════

  // Clear existing kit items to avoid duplicates on re-seed
  await prisma.kitItem.deleteMany();

  const kitItems = [
    // Pottery
    { hobbyId: "pottery", name: "Air-dry clay (2kg)", description: "No kiln needed. Perfect for first projects.", cost: 15, isOptional: false, sortOrder: 0 },
    { hobbyId: "pottery", name: "Basic tool set", description: "Wire cutter, rib, needle tool, sponge.", cost: 12, isOptional: false, sortOrder: 1 },
    { hobbyId: "pottery", name: "Canvas work surface", description: "Prevents sticking. A cutting board works too.", cost: 8, isOptional: true, sortOrder: 2 },
    // Bouldering
    { hobbyId: "bouldering", name: "Climbing shoes", description: "Rent first. Buy after 3-4 sessions if you're hooked.", cost: 0, isOptional: false, sortOrder: 0 },
    { hobbyId: "bouldering", name: "Chalk bag + chalk", description: "Keeps hands dry for better grip.", cost: 18, isOptional: true, sortOrder: 1 },
    // Sourdough
    { hobbyId: "sourdough", name: "Bread flour (1.5kg)", description: "High protein for better gluten development.", cost: 5, isOptional: false, sortOrder: 0 },
    { hobbyId: "sourdough", name: "Kitchen scale", description: "Baking is chemistry. Measure by weight, not volume.", cost: 15, isOptional: false, sortOrder: 1 },
    { hobbyId: "sourdough", name: "Dutch oven", description: "Creates steam for crispy crust. Game changer.", cost: 30, isOptional: true, sortOrder: 2 },
    // Skateboarding
    { hobbyId: "skateboarding", name: "Complete skateboard", description: "Buy a complete to start. Custom setups come later.", cost: 80, isOptional: false, sortOrder: 0 },
    { hobbyId: "skateboarding", name: "Helmet", description: "Non-negotiable for beginners.", cost: 30, isOptional: false, sortOrder: 1 },
    { hobbyId: "skateboarding", name: "Knee & elbow pads", description: "Falls are inevitable. Protect yourself.", cost: 25, isOptional: true, sortOrder: 2 },
    // Chess
    { hobbyId: "chess", name: "Chess.com account (free)", description: "Play online instantly. Puzzles and lessons included.", cost: 0, isOptional: false, sortOrder: 0 },
    { hobbyId: "chess", name: "Physical chess set", description: "Nice to have for playing with friends.", cost: 20, isOptional: true, sortOrder: 1 },
    // Calligraphy
    { hobbyId: "calligraphy", name: "Brush pen set", description: "Tombow Dual Brush or Pentel Touch. Great for beginners.", cost: 15, isOptional: false, sortOrder: 0 },
    { hobbyId: "calligraphy", name: "Practice paper", description: "Smooth, bleed-proof paper with guide lines.", cost: 8, isOptional: false, sortOrder: 1 },
    { hobbyId: "calligraphy", name: "Dip pen + ink", description: "For traditional pointed-pen calligraphy.", cost: 20, isOptional: true, sortOrder: 2 },
    // Hiking
    { hobbyId: "hiking", name: "Trail shoes", description: "Good grip and ankle support. Your feet will thank you.", cost: 80, isOptional: false, sortOrder: 0 },
    { hobbyId: "hiking", name: "Water bottle (1L)", description: "Hydration is non-negotiable.", cost: 15, isOptional: false, sortOrder: 1 },
    { hobbyId: "hiking", name: "Daypack", description: "A simple 20L pack for snacks, layers, first aid.", cost: 40, isOptional: true, sortOrder: 2 },
    // Guitar
    { hobbyId: "guitar", name: "Acoustic guitar", description: "Yamaha FG800 or similar. Don't overspend on your first.", cost: 150, isOptional: false, sortOrder: 0 },
    { hobbyId: "guitar", name: "Tuner app", description: "GuitarTuna (free). Tuning by ear comes later.", cost: 0, isOptional: false, sortOrder: 1 },
    { hobbyId: "guitar", name: "Capo", description: "Makes many songs easier to play.", cost: 10, isOptional: true, sortOrder: 2 },
  ];

  await prisma.kitItem.createMany({ data: kitItems });
  console.log(`  ${kitItems.length} kit items`);

  // ═══════════════════════════════════════════════════
  //  ROADMAP STEPS
  // ═══════════════════════════════════════════════════

  await prisma.roadmapStep.deleteMany();

  const roadmapSteps = [
    // Pottery
    { id: "p1", hobbyId: "pottery", title: "Make a pinch pot", description: "The simplest form. Just a ball of clay and your thumbs.", estimatedMinutes: 25, milestone: null, sortOrder: 0 },
    { id: "p2", hobbyId: "pottery", title: "Try coil building", description: "Roll snakes of clay and stack them into a vessel.", estimatedMinutes: 40, milestone: null, sortOrder: 1 },
    { id: "p3", hobbyId: "pottery", title: "Make a slab plate", description: "Roll clay flat, cut a shape, add a foot ring.", estimatedMinutes: 35, milestone: "First functional piece", sortOrder: 2 },
    { id: "p4", hobbyId: "pottery", title: "Learn surface texture", description: "Use stamps, fabric, or tools to add patterns.", estimatedMinutes: 30, milestone: null, sortOrder: 3 },
    { id: "p5", hobbyId: "pottery", title: "Try a local class", description: "Find a studio for wheel throwing.", estimatedMinutes: 90, milestone: "Wheel experience", sortOrder: 4 },
    // Bouldering
    { id: "b1", hobbyId: "bouldering", title: "Visit a gym", description: "Just go, rent shoes, try the easiest walls.", estimatedMinutes: 60, milestone: null, sortOrder: 0 },
    { id: "b2", hobbyId: "bouldering", title: "Learn footwork", description: "Watch your feet. Place them precisely.", estimatedMinutes: 45, milestone: null, sortOrder: 1 },
    { id: "b3", hobbyId: "bouldering", title: "Send your first V1", description: "Complete a V1 top to bottom without falling.", estimatedMinutes: 60, milestone: "First send", sortOrder: 2 },
    // Sourdough
    { id: "s1", hobbyId: "sourdough", title: "Create your starter", description: "Mix flour + water. Feed daily for 7–10 days.", estimatedMinutes: 10, milestone: null, sortOrder: 0 },
    { id: "s2", hobbyId: "sourdough", title: "Bake your first loaf", description: "Follow a simple recipe. Don't stress.", estimatedMinutes: 30, milestone: "First loaf", sortOrder: 1 },
    { id: "s3", hobbyId: "sourdough", title: "Master stretch & fold", description: "Build gluten without kneading.", estimatedMinutes: 20, milestone: null, sortOrder: 2 },
    // Skateboarding
    { id: "sk1", hobbyId: "skateboarding", title: "Stand and push", description: "Get comfortable standing on the board and pushing.", estimatedMinutes: 30, milestone: null, sortOrder: 0 },
    { id: "sk2", hobbyId: "skateboarding", title: "Learn to stop", description: "Foot brake and power slide basics.", estimatedMinutes: 30, milestone: null, sortOrder: 1 },
    { id: "sk3", hobbyId: "skateboarding", title: "Turn and carve", description: "Lean into turns. Feel the flow.", estimatedMinutes: 45, milestone: "First carve", sortOrder: 2 },
    { id: "sk4", hobbyId: "skateboarding", title: "Ollie attempts", description: "The foundation of all street tricks.", estimatedMinutes: 60, milestone: "First ollie", sortOrder: 3 },
    // Chess
    { id: "ch1", hobbyId: "chess", title: "Learn the rules", description: "How pieces move, check, checkmate, special moves.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
    { id: "ch2", hobbyId: "chess", title: "Play 5 games online", description: "Just play. Don't worry about winning.", estimatedMinutes: 50, milestone: "First games", sortOrder: 1 },
    { id: "ch3", hobbyId: "chess", title: "Learn basic tactics", description: "Forks, pins, skewers. The building blocks.", estimatedMinutes: 30, milestone: null, sortOrder: 2 },
    { id: "ch4", hobbyId: "chess", title: "Solve 20 puzzles", description: "Daily puzzles on Chess.com or Lichess.", estimatedMinutes: 20, milestone: "Puzzle streak", sortOrder: 3 },
    // Calligraphy
    { id: "ca1", hobbyId: "calligraphy", title: "Basic strokes", description: "Upstrokes (thin) and downstrokes (thick). The foundation.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
    { id: "ca2", hobbyId: "calligraphy", title: "Lowercase alphabet", description: "Apply basic strokes to form each letter.", estimatedMinutes: 40, milestone: "Full alphabet", sortOrder: 1 },
    { id: "ca3", hobbyId: "calligraphy", title: "Connect letters", description: "Link letters into flowing words.", estimatedMinutes: 30, milestone: null, sortOrder: 2 },
    { id: "ca4", hobbyId: "calligraphy", title: "Write a quote", description: "Pick your favorite quote. Make it art.", estimatedMinutes: 25, milestone: "First piece", sortOrder: 3 },
    // Hiking
    { id: "h1", hobbyId: "hiking", title: "Find a local trail", description: "Use AllTrails or Komoot. Pick something rated \"easy\".", estimatedMinutes: 15, milestone: null, sortOrder: 0 },
    { id: "h2", hobbyId: "hiking", title: "Do your first hike", description: "Keep it under 2 hours. Enjoy the walk.", estimatedMinutes: 120, milestone: "First trail", sortOrder: 1 },
    { id: "h3", hobbyId: "hiking", title: "Try a longer trail", description: "3-4 hours with some elevation gain.", estimatedMinutes: 180, milestone: null, sortOrder: 2 },
    { id: "h4", hobbyId: "hiking", title: "Reach a summit", description: "Pick a peak and make it your goal.", estimatedMinutes: 240, milestone: "First summit", sortOrder: 3 },
    // Guitar
    { id: "g1", hobbyId: "guitar", title: "Learn 3 chords", description: "G, C, D — these three unlock hundreds of songs.", estimatedMinutes: 25, milestone: null, sortOrder: 0 },
    { id: "g2", hobbyId: "guitar", title: "Strum a pattern", description: "Down-down-up-up-down-up. The universal strum.", estimatedMinutes: 20, milestone: "First strum pattern", sortOrder: 1 },
    { id: "g3", hobbyId: "guitar", title: "Play your first song", description: "Try \"Horse With No Name\" — it's just 2 chords.", estimatedMinutes: 30, milestone: "First song", sortOrder: 2 },
    { id: "g4", hobbyId: "guitar", title: "Learn chord switching", description: "Practice moving between G, C, D smoothly.", estimatedMinutes: 30, milestone: null, sortOrder: 3 },
    { id: "g5", hobbyId: "guitar", title: "Play and sing", description: "Combine strumming with singing. It's harder than it sounds!", estimatedMinutes: 40, milestone: "Campfire ready", sortOrder: 4 },
  ];

  await prisma.roadmapStep.createMany({ data: roadmapSteps });
  console.log(`  ${roadmapSteps.length} roadmap steps`);

  // ═══════════════════════════════════════════════════
  //  FAQ ITEMS
  // ═══════════════════════════════════════════════════

  await prisma.faqItem.deleteMany();

  const faqItems = [
    // Pottery
    { hobbyId: "pottery", question: "Do I need a kiln to start?", answer: "No! Air-dry clay needs no kiln at all. Many studios also offer kiln access for firing.", upvotes: 47 },
    { hobbyId: "pottery", question: "Can I use pottery without firing it?", answer: "Air-dry clay pieces are functional for dry goods and decoration. For food-safe use, you'll need to glaze and fire.", upvotes: 32 },
    { hobbyId: "pottery", question: "How long does it take to get good?", answer: "You can make satisfying pieces in your first session. \"Good\" is subjective — enjoy the process!", upvotes: 28 },
    // Bouldering
    { hobbyId: "bouldering", question: "Do I need to be strong to start?", answer: "Not at all! Technique matters far more than strength. Most V0-V1 problems require balance, not power.", upvotes: 63 },
    { hobbyId: "bouldering", question: "Will my fingers hurt?", answer: "Yes, initially. Your skin toughens within 2-3 weeks. Avoid over-gripping and take rest days.", upvotes: 41 },
    { hobbyId: "bouldering", question: "Should I buy shoes right away?", answer: "Rent for your first 3-4 sessions. If you keep going, invest in beginner shoes (La Sportiva Tarantula is great).", upvotes: 35 },
    // Sourdough
    { hobbyId: "sourdough", question: "Can I use regular flour for sourdough?", answer: "Yes, but bread flour gives better results due to higher protein. Whole wheat works great for starters.", upvotes: 52 },
    { hobbyId: "sourdough", question: "My starter won't rise. Is it dead?", answer: "Probably not! It can take 10-14 days in cold environments. Feed consistently and keep it warm (24-26°C ideal).", upvotes: 44 },
    { hobbyId: "sourdough", question: "Why is my bread flat?", answer: "Common causes: under-proofed, weak starter, not enough steam in oven, or cutting too soon after baking.", upvotes: 38 },
    // Chess
    { hobbyId: "chess", question: "Which app should I use?", answer: "Chess.com and Lichess are both excellent. Lichess is 100% free. Chess.com has better lessons for beginners.", upvotes: 55 },
    { hobbyId: "chess", question: "How do I stop losing every game?", answer: "Focus on not hanging pieces (free captures for your opponent). Check every move for safety before you play it.", upvotes: 42 },
    { hobbyId: "chess", question: "Should I learn openings?", answer: "Not yet! Learn tactics first (forks, pins, skewers). Opening knowledge is useless without tactical vision.", upvotes: 39 },
    // Guitar
    { hobbyId: "guitar", question: "Acoustic or electric for beginners?", answer: "Acoustic is cheaper and more portable. Electric is easier on fingers. Choose based on the music you love.", upvotes: 58 },
    { hobbyId: "guitar", question: "How long until I can play a song?", answer: "With 15 min/day practice, you can play a simple 2-chord song in about 1-2 weeks.", upvotes: 45 },
    { hobbyId: "guitar", question: "My fingers hurt. Is this normal?", answer: "Completely normal! Calluses form in 2-3 weeks. Take short breaks but practice daily for best adaptation.", upvotes: 40 },
  ];

  await prisma.faqItem.createMany({ data: faqItems });
  console.log(`  ${faqItems.length} FAQ items`);

  // ═══════════════════════════════════════════════════
  //  COST BREAKDOWNS
  // ═══════════════════════════════════════════════════

  await prisma.costBreakdown.deleteMany();

  const costBreakdowns = [
    { hobbyId: "pottery", starter: 35, threeMonth: 125, oneYear: 380, tips: ["Air-dry clay is much cheaper than kiln clay", "Studio classes often include materials in the fee", "Pottery costs less than a Netflix + gym combo after month 3"] },
    { hobbyId: "bouldering", starter: 20, threeMonth: 180, oneYear: 600, tips: ["Day passes are CHF 18-25. Monthly passes save money after 3 visits/month", "Rent shoes until you're sure you'll stick with it", "Chalk lasts months — don't overthink gear"] },
    { hobbyId: "sourdough", starter: 20, threeMonth: 45, oneYear: 100, tips: ["Flour is your only recurring cost — about CHF 5/month", "A Dutch oven is the single best upgrade you can make", "You'll save money vs. buying artisan bread"] },
    { hobbyId: "guitar", starter: 160, threeMonth: 180, oneYear: 250, tips: ["Free YouTube lessons are genuinely excellent", "A used guitar in good condition saves 40-50%", "Strings are the only recurring cost — CHF 8 every 2-3 months"] },
    { hobbyId: "chess", starter: 0, threeMonth: 0, oneYear: 30, tips: ["Lichess is completely free with no premium tier", "Chess is one of the cheapest hobbies that exists", "A physical set is nice but optional"] },
    { hobbyId: "calligraphy", starter: 23, threeMonth: 40, oneYear: 80, tips: ["Brush pens last months with proper care", "Practice paper is your main recurring cost", "Ink is very affordable — a bottle lasts over a year"] },
    { hobbyId: "hiking", starter: 95, threeMonth: 100, oneYear: 150, tips: ["Good shoes are the only must-have investment", "Start with trails close to home to avoid transport costs", "Hiking is essentially free once you have shoes"] },
    { hobbyId: "skateboarding", starter: 110, threeMonth: 130, oneYear: 200, tips: ["Buy a complete board, not individual parts for your first", "Shoes wear out fastest — budget for a new pair every 3-4 months", "Skateparks are free!"] },
  ];

  await prisma.costBreakdown.createMany({ data: costBreakdowns });
  console.log(`  ${costBreakdowns.length} cost breakdowns`);

  // ═══════════════════════════════════════════════════
  //  BUDGET ALTERNATIVES
  // ═══════════════════════════════════════════════════

  await prisma.budgetAlternative.deleteMany();

  const budgetAlts = [
    // Pottery
    { hobbyId: "pottery", itemName: "Air-dry clay", diyOption: "Salt dough (flour+salt+water)", diyCost: 2, budgetOption: "DAS air-dry clay 1kg", budgetCost: 8, premiumOption: "Amaco Stonex 2.5kg", premiumCost: 25, sortOrder: 0 },
    { hobbyId: "pottery", itemName: "Tool set", diyOption: "Kitchen utensils (fork, knife, skewer)", diyCost: 0, budgetOption: "Basic 5-piece pottery set", budgetCost: 12, premiumOption: "Kemper Pro tool kit", premiumCost: 35, sortOrder: 1 },
    // Sourdough
    { hobbyId: "sourdough", itemName: "Dutch oven", diyOption: "Any oven-safe pot with lid", diyCost: 0, budgetOption: "Basic cast iron pot", budgetCost: 25, premiumOption: "Le Creuset Dutch Oven", premiumCost: 200, sortOrder: 0 },
  ];

  await prisma.budgetAlternative.createMany({ data: budgetAlts });
  console.log(`  ${budgetAlts.length} budget alternatives`);

  // ═══════════════════════════════════════════════════
  //  HOBBY COMBOS
  // ═══════════════════════════════════════════════════

  await prisma.hobbyCombo.deleteMany();

  const combos = [
    { hobbyId1: "pottery", hobbyId2: "calligraphy", reason: "Both build hand-eye coordination and spatial awareness. The meditative flow state is similar.", sharedTags: ["creative", "relaxing"] },
    { hobbyId1: "bouldering", hobbyId2: "hiking", reason: "Climbing builds strength. Hiking builds endurance. Together they unlock outdoor adventures.", sharedTags: ["physical", "outdoors"] },
    { hobbyId1: "sourdough", hobbyId2: "pottery", reason: "Both are meditative making processes. You can make your own plates for your own bread.", sharedTags: ["creative", "relaxing"] },
  ];

  await prisma.hobbyCombo.createMany({ data: combos });
  console.log(`  ${combos.length} hobby combos`);

  // ═══════════════════════════════════════════════════
  //  SEASONAL PICKS
  // ═══════════════════════════════════════════════════

  await prisma.seasonalPick.deleteMany();

  const seasonalPicks: { hobbyId: string; season: string }[] = [];
  const seasonalMap: Record<string, string[]> = {
    "Winter Warmers": ["sourdough", "pottery", "calligraphy", "chess"],
    "Spring Awakening": ["hiking", "skateboarding", "bouldering", "guitar"],
    "Summer Adventures": ["hiking", "skateboarding", "bouldering", "guitar"],
    "Autumn Coziness": ["pottery", "sourdough", "calligraphy", "chess"],
  };

  for (const [season, hobbyIds] of Object.entries(seasonalMap)) {
    for (const hobbyId of hobbyIds) {
      seasonalPicks.push({ hobbyId, season });
    }
  }

  await prisma.seasonalPick.createMany({ data: seasonalPicks });
  console.log(`  ${seasonalPicks.length} seasonal picks`);

  // ═══════════════════════════════════════════════════
  //  MOOD TAGS
  // ═══════════════════════════════════════════════════

  await prisma.moodTag.deleteMany();

  // Map moods to hobby tags, then resolve hobbies matching those tags
  const moodToTags: Record<string, string[]> = {
    Stressed: ["relaxing", "meditative"],
    Bored: ["physical", "competitive"],
    Lonely: ["social"],
    Creative: ["creative"],
    Restless: ["physical", "outdoors"],
    Curious: ["technical", "creative"],
  };

  const allHobbies = hobbies;
  const moodTags: { hobbyId: string; mood: string }[] = [];

  for (const [mood, tags] of Object.entries(moodToTags)) {
    for (const hobby of allHobbies) {
      if (hobby.tags.some((t) => tags.includes(t))) {
        moodTags.push({ hobbyId: hobby.id, mood });
      }
    }
  }

  await prisma.moodTag.createMany({ data: moodTags, skipDuplicates: true });
  console.log(`  ${moodTags.length} mood tags`);

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
