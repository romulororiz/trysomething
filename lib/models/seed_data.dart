import 'hobby.dart';

/// TrySomething — Seed Data
///
/// Local dataset powering the UI before backend integration.
/// Ported from the JSX prototype with additional hobbies for feed variety.

class SeedData {
  SeedData._();

  // ═══════════════════════════════════════════════════
  //  CATEGORIES
  // ═══════════════════════════════════════════════════

  static final List<HobbyCategory> categories = [
    HobbyCategory(id: 'creative', name: 'Creative', count: 12, imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=600&q=80'),
    HobbyCategory(id: 'outdoors', name: 'Outdoors', count: 8, imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600&q=80'),
    HobbyCategory(id: 'fitness', name: 'Fitness', count: 9, imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=600&q=80'),
    HobbyCategory(id: 'maker', name: 'Maker/DIY', count: 7, imageUrl: 'https://images.unsplash.com/photo-1581783898377-1c85bf937427?w=600&q=80'),
    HobbyCategory(id: 'music', name: 'Music', count: 6, imageUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=600&q=80'),
    HobbyCategory(id: 'food', name: 'Food', count: 11, imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=600&q=80'),
    HobbyCategory(id: 'collecting', name: 'Collecting', count: 5, imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&q=80'),
    HobbyCategory(id: 'mind', name: 'Mind', count: 8, imageUrl: 'https://images.unsplash.com/photo-1508672019048-805c876b67e2?w=600&q=80'),
    HobbyCategory(id: 'social', name: 'Social', count: 6, imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600&q=80'),
  ];

  // ═══════════════════════════════════════════════════
  //  HOBBIES
  // ═══════════════════════════════════════════════════

  static final List<Hobby> hobbies = [
    Hobby(
      id: 'pottery',
      title: 'Pottery',
      hook: 'Get your hands dirty. Make something real.',
      category: 'Creative',

      imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=600&h=800&fit=crop',
      tags: ['creative', 'relaxing', 'meditative'],
      costText: 'CHF 40–120',
      timeText: '2h/week',
      difficultyText: 'Medium',
      whyLove: 'The tactile satisfaction is unmatched. You lose track of time, your phone stays in your pocket, and you walk away with something you made with your own hands.',
      difficultyExplain: 'Centering clay on a wheel takes practice. Hand-building is much easier to start with and just as rewarding.',
      starterKit: [
        KitItem(name: 'Air-dry clay (2kg)', description: 'No kiln needed. Perfect for first projects.', cost: 15),
        KitItem(name: 'Basic tool set', description: 'Wire cutter, rib, needle tool, sponge.', cost: 12),
        KitItem(name: 'Canvas work surface', description: 'Prevents sticking. A cutting board works too.', cost: 8, isOptional: true),
      ],
      pitfalls: [
        "Don't start with a wheel — try hand-building first.",
        'Air-dry clay cracks if too thin. Keep walls ≥5mm.',
        "Don't skip wedging. Air bubbles ruin your piece.",
      ],
      quittingReasons: [
        'People overbuy gear early — start with air-dry clay, not a kiln',
        'Expecting perfect results on day one kills motivation',
        'Drying and cracking feels like failure, but it\'s normal',
        'Studio classes feel expensive — try hand-building at home first',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'p1', title: 'Make a pinch pot', description: 'The simplest form. Just a ball of clay and your thumbs.', estimatedMinutes: 25),
        RoadmapStep(id: 'p2', title: 'Try coil building', description: 'Roll snakes of clay and stack them into a vessel.', estimatedMinutes: 40),
        RoadmapStep(id: 'p3', title: 'Make a slab plate', description: 'Roll clay flat, cut a shape, add a foot ring.', estimatedMinutes: 35, milestone: 'First functional piece'),
        RoadmapStep(id: 'p4', title: 'Learn surface texture', description: 'Use stamps, fabric, or tools to add patterns.', estimatedMinutes: 30),
        RoadmapStep(id: 'p5', title: 'Try a local class', description: 'Find a studio for wheel throwing.', estimatedMinutes: 90, milestone: 'Wheel experience'),
      ],
    ),

    Hobby(
      id: 'bouldering',
      title: 'Bouldering',
      hook: 'Solve puzzles with your body.',
      category: 'Fitness',

      imageUrl: 'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=600&h=800&fit=crop',
      tags: ['physical', 'social', 'competitive'],
      costText: 'CHF 20–60',
      timeText: '3h/week',
      difficultyText: 'Medium',
      whyLove: "It's social, physical, and mental all at once. You'll make friends at the gym and surprise yourself with what your body can do.",
      difficultyExplain: 'Technique matters more than strength. Finger strength builds slowly — be patient with yourself.',
      starterKit: [
        KitItem(name: 'Climbing shoes', description: 'Rent first. Buy after 3-4 sessions if you\'re hooked.', cost: 0),
        KitItem(name: 'Chalk bag + chalk', description: 'Keeps hands dry for better grip.', cost: 18, isOptional: true),
      ],
      pitfalls: [
        'Use your legs, not just your arms. Most beginners over-grip.',
        'Rest between problems. Tendons need time to adapt.',
        'Start on easy grades (V0–V1). Ego is the enemy.',
      ],
      quittingReasons: [
        'Finger tendons hurt — people push too hard too fast',
        'Comparing yourself to regulars who\'ve climbed for years',
        'Going alone feels intimidating at first',
        'Thinking you need to be strong to start (you don\'t)',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'b1', title: 'Visit a gym', description: 'Just go, rent shoes, try the easiest walls.', estimatedMinutes: 60),
        RoadmapStep(id: 'b2', title: 'Learn footwork', description: 'Watch your feet. Place them precisely.', estimatedMinutes: 45),
        RoadmapStep(id: 'b3', title: 'Send your first V1', description: 'Complete a V1 top to bottom without falling.', estimatedMinutes: 60, milestone: 'First send'),
      ],
    ),

    Hobby(
      id: 'sourdough',
      title: 'Sourdough Baking',
      hook: 'Flour, water, patience. Insanely rewarding.',
      category: 'Food',

      imageUrl: 'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=600&h=800&fit=crop',
      tags: ['creative', 'relaxing', 'solo'],
      costText: 'CHF 15–50',
      timeText: '2h/week',
      difficultyText: 'Medium',
      whyLove: "The smell. The ritual. Pulling a golden loaf from your own oven. You'll never look at supermarket bread the same way again.",
      difficultyExplain: "Timing is everything. Your first few loaves may be flat — that's completely normal and part of the process.",
      starterKit: [
        KitItem(name: 'Bread flour (1.5kg)', description: 'High protein for better gluten development.', cost: 5),
        KitItem(name: 'Kitchen scale', description: 'Baking is chemistry. Measure by weight, not volume.', cost: 15),
        KitItem(name: 'Dutch oven', description: 'Creates steam for crispy crust. Game changer.', cost: 30, isOptional: true),
      ],
      pitfalls: [
        "Don't rush fermentation. Cold overnight rise = more flavor.",
        'Your starter needs 7–10 days to mature. Be patient.',
        "Don't add too much flour. Wet dough = open crumb.",
      ],
      quittingReasons: [
        'Starter dies in the first week — feels like starting over',
        'First loaves look nothing like Instagram posts',
        'The time commitment (waiting hours) feels impractical',
        'Buying fancy flour and tools before mastering basics',
      ],
      roadmapSteps: [
        RoadmapStep(id: 's1', title: 'Create your starter', description: 'Mix flour + water. Feed daily for 7–10 days.', estimatedMinutes: 10),
        RoadmapStep(id: 's2', title: 'Bake your first loaf', description: "Follow a simple recipe. Don't stress.", estimatedMinutes: 30, milestone: 'First loaf'),
        RoadmapStep(id: 's3', title: 'Master stretch & fold', description: 'Build gluten without kneading.', estimatedMinutes: 20),
      ],
    ),

    Hobby(
      id: 'skateboarding',
      title: 'Skateboarding',
      hook: 'Four wheels, infinite possibilities.',
      category: 'Fitness',

      imageUrl: 'https://images.unsplash.com/photo-1564982752979-3f7bc974d29a?w=600&h=800&fit=crop',
      tags: ['physical', 'outdoors', 'creative'],
      costText: 'CHF 80–200',
      timeText: '3h/week',
      difficultyText: 'Hard',
      whyLove: "There's nothing like the feeling of rolling. The freedom, the flow state, the community. Every trick you land is pure magic.",
      difficultyExplain: 'Balance takes time. You will fall — that\'s part of it. Protective gear helps confidence enormously.',
      starterKit: [
        KitItem(name: 'Complete skateboard', description: 'Buy a complete to start. Custom setups come later.', cost: 80),
        KitItem(name: 'Helmet', description: 'Non-negotiable for beginners.', cost: 30),
        KitItem(name: 'Knee & elbow pads', description: 'Falls are inevitable. Protect yourself.', cost: 25, isOptional: true),
      ],
      pitfalls: [
        "Don't buy a cheap toy board. Spend at least CHF 80 on a real one.",
        'Learn to push and stop before attempting tricks.',
        'Skate on smooth ground first. Rough pavement is frustrating.',
      ],
      quittingReasons: [
        'Falls hurt and feel embarrassing in public',
        'Progress feels invisible for the first few weeks',
        'Buying a cheap board that rides terribly',
        'Trying tricks too early instead of getting comfortable riding',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'sk1', title: 'Stand and push', description: 'Get comfortable standing on the board and pushing.', estimatedMinutes: 30),
        RoadmapStep(id: 'sk2', title: 'Learn to stop', description: 'Foot brake and power slide basics.', estimatedMinutes: 30),
        RoadmapStep(id: 'sk3', title: 'Turn and carve', description: 'Lean into turns. Feel the flow.', estimatedMinutes: 45, milestone: 'First carve'),
        RoadmapStep(id: 'sk4', title: 'Ollie attempts', description: 'The foundation of all street tricks.', estimatedMinutes: 60, milestone: 'First ollie'),
      ],
    ),

    Hobby(
      id: 'chess',
      title: 'Chess',
      hook: 'The ultimate thinking game. Infinite depth.',
      category: 'Mind',

      imageUrl: 'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=600&h=800&fit=crop',
      tags: ['competitive', 'solo', 'technical'],
      costText: 'CHF 0–30',
      timeText: '2h/week',
      difficultyText: 'Easy',
      whyLove: "You can play anywhere, anytime. Online, in a park, with friends. Every game teaches you something new about strategy and yourself.",
      difficultyExplain: 'Rules are simple to learn. Strategy depth is what keeps you playing for decades.',
      starterKit: [
        KitItem(name: 'Chess.com account (free)', description: 'Play online instantly. Puzzles and lessons included.', cost: 0),
        KitItem(name: 'Physical chess set', description: 'Nice to have for playing with friends.', cost: 20, isOptional: true),
      ],
      pitfalls: [
        "Don't try to memorize openings first. Learn tactics instead.",
        "Play longer time controls to actually learn. Avoid only bullet chess.",
        "Analyze your losses. That's where the growth is.",
      ],
      quittingReasons: [
        'Losing constantly online feels demoralizing',
        'Memorizing openings instead of understanding principles',
        'Playing only bullet/blitz and not learning from mistakes',
        'Thinking you need to be "smart enough" — chess is a skill, not talent',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'ch1', title: 'Learn the rules', description: 'How pieces move, check, checkmate, special moves.', estimatedMinutes: 20),
        RoadmapStep(id: 'ch2', title: 'Play 5 games online', description: 'Just play. Don\'t worry about winning.', estimatedMinutes: 50, milestone: 'First games'),
        RoadmapStep(id: 'ch3', title: 'Learn basic tactics', description: 'Forks, pins, skewers. The building blocks.', estimatedMinutes: 30),
        RoadmapStep(id: 'ch4', title: 'Solve 20 puzzles', description: 'Daily puzzles on Chess.com or Lichess.', estimatedMinutes: 20, milestone: 'Puzzle streak'),
      ],
    ),

    Hobby(
      id: 'calligraphy',
      title: 'Calligraphy',
      hook: 'Turn words into art. Meditative, beautiful.',
      category: 'Creative',

      imageUrl: 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=600&h=800&fit=crop',
      tags: ['creative', 'relaxing', 'solo'],
      costText: 'CHF 20–60',
      timeText: '1h/week',
      difficultyText: 'Easy',
      whyLove: "The meditative rhythm of pen strokes. Watching beautiful letters flow from your hand. It's mindfulness made visible.",
      difficultyExplain: 'Modern calligraphy is forgiving. Traditional styles require more discipline, but both are accessible.',
      starterKit: [
        KitItem(name: 'Brush pen set', description: 'Tombow Dual Brush or Pentel Touch. Great for beginners.', cost: 15),
        KitItem(name: 'Practice paper', description: 'Smooth, bleed-proof paper with guide lines.', cost: 8),
        KitItem(name: 'Dip pen + ink', description: 'For traditional pointed-pen calligraphy.', cost: 20, isOptional: true),
      ],
      pitfalls: [
        'Use the right paper. Regular paper bleeds and frays pen tips.',
        "Don't press too hard. Let the pen do the work.",
        'Start with drills, not letters. Build muscle memory first.',
      ],
      quittingReasons: [
        'Comparing your practice to polished Instagram calligraphy',
        'Using the wrong paper and thinking the pen is broken',
        'Rushing to write words before mastering basic strokes',
        'Hand cramping from gripping too hard',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'ca1', title: 'Basic strokes', description: 'Upstrokes (thin) and downstrokes (thick). The foundation.', estimatedMinutes: 20),
        RoadmapStep(id: 'ca2', title: 'Lowercase alphabet', description: 'Apply basic strokes to form each letter.', estimatedMinutes: 40, milestone: 'Full alphabet'),
        RoadmapStep(id: 'ca3', title: 'Connect letters', description: 'Link letters into flowing words.', estimatedMinutes: 30),
        RoadmapStep(id: 'ca4', title: 'Write a quote', description: 'Pick your favorite quote. Make it art.', estimatedMinutes: 25, milestone: 'First piece'),
      ],
    ),

    Hobby(
      id: 'hiking',
      title: 'Hiking',
      hook: 'Step outside. The trail is calling.',
      category: 'Outdoors',

      imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=600&h=800&fit=crop',
      tags: ['physical', 'outdoors', 'relaxing'],
      costText: 'CHF 0–150',
      timeText: '4h/week',
      difficultyText: 'Easy',
      whyLove: 'The views, the fresh air, the sense of accomplishment at the summit. Nature is the best therapy — and it\'s free.',
      difficultyExplain: 'Start with well-marked, flat trails. Difficulty is entirely in your control based on trail choice.',
      starterKit: [
        KitItem(name: 'Trail shoes', description: 'Good grip and ankle support. Your feet will thank you.', cost: 80),
        KitItem(name: 'Water bottle (1L)', description: 'Hydration is non-negotiable.', cost: 15),
        KitItem(name: 'Daypack', description: 'A simple 20L pack for snacks, layers, first aid.', cost: 40, isOptional: true),
      ],
      pitfalls: [
        'Check the weather before you go. Mountains change fast.',
        "Don't skip sunscreen. UV is stronger at elevation.",
        'Start shorter than you think. 3 hours is plenty for your first hike.',
      ],
      quittingReasons: [
        'Picking a trail that\'s too hard and having a miserable time',
        'Overbuying gear before knowing what you actually need',
        'Going alone and feeling unsafe or bored',
        'Bad weather on your first attempt and never trying again',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'h1', title: 'Find a local trail', description: 'Use AllTrails or Komoot. Pick something rated "easy".', estimatedMinutes: 15),
        RoadmapStep(id: 'h2', title: 'Do your first hike', description: 'Keep it under 2 hours. Enjoy the walk.', estimatedMinutes: 120, milestone: 'First trail'),
        RoadmapStep(id: 'h3', title: 'Try a longer trail', description: '3-4 hours with some elevation gain.', estimatedMinutes: 180),
        RoadmapStep(id: 'h4', title: 'Reach a summit', description: 'Pick a peak and make it your goal.', estimatedMinutes: 240, milestone: 'First summit'),
      ],
    ),

    Hobby(
      id: 'guitar',
      title: 'Guitar',
      hook: 'Six strings. Endless songs. Start tonight.',
      category: 'Music',

      imageUrl: 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=600&h=800&fit=crop',
      tags: ['creative', 'relaxing', 'solo'],
      costText: 'CHF 50–300',
      timeText: '3h/week',
      difficultyText: 'Medium',
      whyLove: "Playing your first full song is one of the most rewarding feelings. Music becomes yours to create, not just consume.",
      difficultyExplain: 'Finger pain goes away after 2 weeks. Chord changes take practice. Use YouTube — there are incredible free teachers.',
      starterKit: [
        KitItem(name: 'Acoustic guitar', description: 'Yamaha FG800 or similar. Don\'t overspend on your first.', cost: 150),
        KitItem(name: 'Tuner app', description: 'GuitarTuna (free). Tuning by ear comes later.', cost: 0),
        KitItem(name: 'Capo', description: 'Makes many songs easier to play.', cost: 10, isOptional: true),
      ],
      pitfalls: [
        "Your fingers will hurt for 2 weeks. Push through — calluses form fast.",
        "Don't try barre chords in week 1. Stick to open chords.",
        'Practice 15 minutes daily rather than 2 hours on weekends.',
      ],
      quittingReasons: [
        'Sore fingers in the first two weeks — calluses take time',
        'Expecting to play songs immediately instead of building basics',
        'Practicing once a week for 2 hours instead of daily for 15 min',
        'Buying a guitar that\'s hard to play (high action, thick strings)',
      ],
      roadmapSteps: [
        RoadmapStep(id: 'g1', title: 'Learn 3 chords', description: 'G, C, D — these three unlock hundreds of songs.', estimatedMinutes: 25),
        RoadmapStep(id: 'g2', title: 'Strum a pattern', description: 'Down-down-up-up-down-up. The universal strum.', estimatedMinutes: 20, milestone: 'First strum pattern'),
        RoadmapStep(id: 'g3', title: 'Play your first song', description: 'Try "Horse With No Name" — it\'s just 2 chords.', estimatedMinutes: 30, milestone: 'First song'),
        RoadmapStep(id: 'g4', title: 'Learn chord switching', description: 'Practice moving between G, C, D smoothly.', estimatedMinutes: 30),
        RoadmapStep(id: 'g5', title: 'Play and sing', description: 'Combine strumming with singing. It\'s harder than it sounds!', estimatedMinutes: 40, milestone: 'Campfire ready'),
      ],
    ),
  ];

  /// Get hobby by ID
  static Hobby? getHobby(String id) {
    try {
      return hobbies.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get hobbies by category
  static List<Hobby> getByCategory(String category) {
    return hobbies.where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Get related hobbies (same category, excluding self)
  static List<Hobby> getRelated(String hobbyId, {int limit = 3}) {
    final hobby = getHobby(hobbyId);
    if (hobby == null) return [];
    return hobbies
        .where((h) => h.id != hobbyId && (h.category == hobby.category || h.tags.any((t) => hobby.tags.contains(t))))
        .take(limit)
        .toList();
  }
}
