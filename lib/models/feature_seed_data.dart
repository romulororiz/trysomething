import 'social.dart';
import 'features.dart';

/// Mock data for all new feature screens.
/// All data is hardcoded for UI development — will be replaced with backend.
class FeatureSeedData {
  FeatureSeedData._();

  // ═══════════════════════════════════════════════════
  //  JOURNAL ENTRIES
  // ═══════════════════════════════════════════════════

  static final List<JournalEntry> journalEntries = [
    JournalEntry(
      id: 'j1',
      hobbyId: 'pottery',
      text: 'My first pinch pot! Walls are uneven but I love the texture. The clay felt amazing between my fingers.',
      photoUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    JournalEntry(
      id: 'j2',
      hobbyId: 'pottery',
      text: 'Tried coil building today. Harder than expected but incredibly relaxing once I found the rhythm.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    JournalEntry(
      id: 'j3',
      hobbyId: 'bouldering',
      text: 'First time at the bouldering gym. Arms are completely dead but I sent two V0s! The community is so welcoming.',
      photoUrl: 'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    JournalEntry(
      id: 'j4',
      hobbyId: 'sourdough',
      text: 'Starter is finally active after 8 days! It doubled in 4 hours today. Baking my first loaf tomorrow.',
      photoUrl: 'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=400&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    JournalEntry(
      id: 'j5',
      hobbyId: 'calligraphy',
      text: 'Practiced basic strokes for 30 minutes. My downstrokes are getting much more consistent.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // ═══════════════════════════════════════════════════
  //  BUDDY MODE
  // ═══════════════════════════════════════════════════

  static final List<BuddyProfile> buddyProfiles = [
    BuddyProfile(id: 'buddy1', name: 'Marco', avatarInitial: 'M', currentHobbyId: 'pottery', progress: 0.4),
    BuddyProfile(id: 'buddy2', name: 'Lena', avatarInitial: 'L', currentHobbyId: 'bouldering', progress: 0.6),
  ];

  static final List<BuddyActivity> buddyActivities = [
    BuddyActivity(userId: 'buddy1', userName: 'Marco', text: "Marco completed 'Make a pinch pot'", timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    BuddyActivity(userId: 'you', userName: 'You', text: "You completed 'Try coil building'", timestamp: DateTime.now().subtract(const Duration(hours: 8))),
    BuddyActivity(userId: 'buddy1', userName: 'Marco', text: 'Marco saved a photo of his first pot', timestamp: DateTime.now().subtract(const Duration(days: 1))),
    BuddyActivity(userId: 'buddy2', userName: 'Lena', text: "Lena sent her first V1", timestamp: DateTime.now().subtract(const Duration(days: 2))),
  ];

  // ═══════════════════════════════════════════════════
  //  COMMUNITY STORIES
  // ═══════════════════════════════════════════════════

  static final List<CommunityStory> stories = [
    CommunityStory(
      id: 'st1',
      authorName: 'Julia',
      authorInitial: 'J',
      quote: "I started with zero artistic skills. Now I've made mugs for everyone in my family. The best part? It's the one time my brain actually shuts up.",
      hobbyId: 'pottery',
      reactions: {'heart': 142, 'fire': 38},
    ),
    CommunityStory(
      id: 'st2',
      authorName: 'David',
      authorInitial: 'D',
      quote: "Bouldering changed my relationship with my body. I went from 'I can\'t do pull-ups' to sending V4s in 6 months. The progression is addictive.",
      hobbyId: 'bouldering',
      reactions: {'heart': 89, 'fire': 67},
    ),
    CommunityStory(
      id: 'st3',
      authorName: 'Mei',
      authorInitial: 'M',
      quote: "My sourdough starter is named Gerald. He's 8 months old now and has produced over 50 loaves. My neighbors love me.",
      hobbyId: 'sourdough',
      reactions: {'heart': 234, 'fire': 12},
    ),
  ];

  // ═══════════════════════════════════════════════════
  //  NEARBY USERS
  // ═══════════════════════════════════════════════════

  static final List<NearbyUser> nearbyUsers = [
    NearbyUser(id: 'fake-sarah', name: 'Sarah K.', avatarInitial: 'S', hobbyId: 'pottery', distance: '2.3 km', startedText: 'Started this week'),
    NearbyUser(id: 'fake-alex', name: 'Alex M.', avatarInitial: 'A', hobbyId: 'bouldering', distance: '0.8 km', startedText: '3 weeks in'),
    NearbyUser(id: 'fake-priya', name: 'Priya T.', avatarInitial: 'P', hobbyId: 'sourdough', distance: '4.1 km', startedText: 'Started yesterday'),
    NearbyUser(id: 'fake-tom', name: 'Tom R.', avatarInitial: 'T', hobbyId: 'guitar', distance: '1.5 km', startedText: '2 months in'),
  ];

  // ═══════════════════════════════════════════════════
  //  WEEKLY CHALLENGES
  // ═══════════════════════════════════════════════════

  static final List<Challenge> challenges = [
    Challenge(
      id: 'ch1',
      title: 'Try Something New',
      description: 'Spend 15 minutes on a hobby you haven\'t tried before this week.',
      targetCount: 1,
      currentCount: 0,
      startDate: DateTime.now().subtract(const Duration(days: 4)),
      endDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Challenge(
      id: 'ch2',
      title: 'Complete 2 roadmap steps',
      description: 'Make progress on any of your active hobbies.',
      targetCount: 2,
      currentCount: 2,
      startDate: DateTime.now().subtract(const Duration(days: 11)),
      endDate: DateTime.now().subtract(const Duration(days: 4)),
      isCompleted: true,
    ),
    Challenge(
      id: 'ch3',
      title: 'Journal your session',
      description: 'Write about your hobby experience today.',
      targetCount: 1,
      currentCount: 1,
      startDate: DateTime.now().subtract(const Duration(days: 18)),
      endDate: DateTime.now().subtract(const Duration(days: 11)),
      isCompleted: true,
    ),
    Challenge(
      id: 'ch4',
      title: 'Share a hobby card',
      description: 'Send a hobby card to a friend who might enjoy it.',
      targetCount: 1,
      currentCount: 1,
      startDate: DateTime.now().subtract(const Duration(days: 25)),
      endDate: DateTime.now().subtract(const Duration(days: 18)),
      isCompleted: true,
    ),
  ];

  // ═══════════════════════════════════════════════════
  //  SCHEDULE EVENTS
  // ═══════════════════════════════════════════════════

  static final List<ScheduleEvent> scheduleEvents = [
    ScheduleEvent(id: 'ev1', hobbyId: 'pottery', dayOfWeek: 2, startTime: '19:00', durationMinutes: 90),
    ScheduleEvent(id: 'ev2', hobbyId: 'bouldering', dayOfWeek: 4, startTime: '18:30', durationMinutes: 75),
    ScheduleEvent(id: 'ev3', hobbyId: 'sourdough', dayOfWeek: 6, startTime: '09:00', durationMinutes: 60),
  ];

  // ═══════════════════════════════════════════════════
  //  HOBBY COMBOS
  // ═══════════════════════════════════════════════════

  static final List<HobbyCombo> combos = [
    HobbyCombo(
      hobbyId1: 'pottery',
      hobbyId2: 'calligraphy',
      reason: 'Both build hand-eye coordination and spatial awareness. The meditative flow state is similar.',
      sharedTags: ['creative', 'relaxing'],
    ),
    HobbyCombo(
      hobbyId1: 'bouldering',
      hobbyId2: 'hiking',
      reason: 'Climbing builds strength. Hiking builds endurance. Together they unlock outdoor adventures.',
      sharedTags: ['physical', 'outdoors'],
    ),
    HobbyCombo(
      hobbyId1: 'sourdough',
      hobbyId2: 'pottery',
      reason: 'Both are meditative making processes. You can make your own plates for your own bread.',
      sharedTags: ['creative', 'relaxing'],
    ),
  ];

  // ═══════════════════════════════════════════════════
  //  FAQ ITEMS (per hobby)
  // ═══════════════════════════════════════════════════

  static final Map<String, List<FaqItem>> faqByHobby = {
    'pottery': [
      FaqItem(question: 'Do I need a kiln to start?', answer: 'No! Air-dry clay needs no kiln at all. Many studios also offer kiln access for firing.', upvotes: 47),
      FaqItem(question: 'Can I use pottery without firing it?', answer: 'Air-dry clay pieces are functional for dry goods and decoration. For food-safe use, you\'ll need to glaze and fire.', upvotes: 32),
      FaqItem(question: 'How long does it take to get good?', answer: 'You can make satisfying pieces in your first session. "Good" is subjective — enjoy the process!', upvotes: 28),
    ],
    'bouldering': [
      FaqItem(question: 'Do I need to be strong to start?', answer: 'Not at all! Technique matters far more than strength. Most V0-V1 problems require balance, not power.', upvotes: 63),
      FaqItem(question: 'Will my fingers hurt?', answer: 'Yes, initially. Your skin toughens within 2-3 weeks. Avoid over-gripping and take rest days.', upvotes: 41),
      FaqItem(question: 'Should I buy shoes right away?', answer: 'Rent for your first 3-4 sessions. If you keep going, invest in beginner shoes (La Sportiva Tarantula is great).', upvotes: 35),
    ],
    'sourdough': [
      FaqItem(question: 'Can I use regular flour for sourdough?', answer: 'Yes, but bread flour gives better results due to higher protein. Whole wheat works great for starters.', upvotes: 52),
      FaqItem(question: 'My starter won\'t rise. Is it dead?', answer: 'Probably not! It can take 10-14 days in cold environments. Feed consistently and keep it warm (24-26°C ideal).', upvotes: 44),
      FaqItem(question: 'Why is my bread flat?', answer: 'Common causes: under-proofed, weak starter, not enough steam in oven, or cutting too soon after baking.', upvotes: 38),
    ],
    'chess': [
      FaqItem(question: 'Which app should I use?', answer: 'Chess.com and Lichess are both excellent. Lichess is 100% free. Chess.com has better lessons for beginners.', upvotes: 55),
      FaqItem(question: 'How do I stop losing every game?', answer: 'Focus on not hanging pieces (free captures for your opponent). Check every move for safety before you play it.', upvotes: 42),
      FaqItem(question: 'Should I learn openings?', answer: 'Not yet! Learn tactics first (forks, pins, skewers). Opening knowledge is useless without tactical vision.', upvotes: 39),
    ],
    'guitar': [
      FaqItem(question: 'Acoustic or electric for beginners?', answer: 'Acoustic is cheaper and more portable. Electric is easier on fingers. Choose based on the music you love.', upvotes: 58),
      FaqItem(question: 'How long until I can play a song?', answer: 'With 15 min/day practice, you can play a simple 2-chord song in about 1-2 weeks.', upvotes: 45),
      FaqItem(question: 'My fingers hurt. Is this normal?', answer: 'Completely normal! Calluses form in 2-3 weeks. Take short breaks but practice daily for best adaptation.', upvotes: 40),
    ],
  };

  // ═══════════════════════════════════════════════════
  //  COST BREAKDOWNS (per hobby)
  // ═══════════════════════════════════════════════════

  static final Map<String, CostBreakdown> costByHobby = {
    'pottery': CostBreakdown(starter: 35, threeMonth: 125, oneYear: 380, tips: [
      'Air-dry clay is much cheaper than kiln clay',
      'Studio classes often include materials in the fee',
      'Pottery costs less than a Netflix + gym combo after month 3',
    ]),
    'bouldering': CostBreakdown(starter: 20, threeMonth: 180, oneYear: 600, tips: [
      'Day passes are CHF 18-25. Monthly passes save money after 3 visits/month',
      'Rent shoes until you\'re sure you\'ll stick with it',
      'Chalk lasts months — don\'t overthink gear',
    ]),
    'sourdough': CostBreakdown(starter: 20, threeMonth: 45, oneYear: 100, tips: [
      'Flour is your only recurring cost — about CHF 5/month',
      'A Dutch oven is the single best upgrade you can make',
      'You\'ll save money vs. buying artisan bread',
    ]),
    'guitar': CostBreakdown(starter: 160, threeMonth: 180, oneYear: 250, tips: [
      'Free YouTube lessons are genuinely excellent',
      'A used guitar in good condition saves 40-50%',
      'Strings are the only recurring cost — CHF 8 every 2-3 months',
    ]),
    'chess': CostBreakdown(starter: 0, threeMonth: 0, oneYear: 30, tips: [
      'Lichess is completely free with no premium tier',
      'Chess is one of the cheapest hobbies that exists',
      'A physical set is nice but optional',
    ]),
    'calligraphy': CostBreakdown(starter: 23, threeMonth: 40, oneYear: 80, tips: [
      'Brush pens last months with proper care',
      'Practice paper is your main recurring cost',
      'Ink is very affordable — a bottle lasts over a year',
    ]),
    'hiking': CostBreakdown(starter: 95, threeMonth: 100, oneYear: 150, tips: [
      'Good shoes are the only must-have investment',
      'Start with trails close to home to avoid transport costs',
      'Hiking is essentially free once you have shoes',
    ]),
    'skateboarding': CostBreakdown(starter: 110, threeMonth: 130, oneYear: 200, tips: [
      'Buy a complete board, not individual parts for your first',
      'Shoes wear out fastest — budget for a new pair every 3-4 months',
      'Skateparks are free!',
    ]),
  };

  // ═══════════════════════════════════════════════════
  //  BUDGET ALTERNATIVES (per kit item)
  // ═══════════════════════════════════════════════════

  static final Map<String, List<BudgetAlternative>> budgetAlternatives = {
    'pottery': [
      BudgetAlternative(
        itemName: 'Air-dry clay',
        diyOption: 'Salt dough (flour+salt+water)',
        diyCost: 2,
        budgetOption: 'DAS air-dry clay 1kg',
        budgetCost: 8,
        premiumOption: 'Amaco Stonex 2.5kg',
        premiumCost: 25,
      ),
      BudgetAlternative(
        itemName: 'Tool set',
        diyOption: 'Kitchen utensils (fork, knife, skewer)',
        diyCost: 0,
        budgetOption: 'Basic 5-piece pottery set',
        budgetCost: 12,
        premiumOption: 'Kemper Pro tool kit',
        premiumCost: 35,
      ),
    ],
    'sourdough': [
      BudgetAlternative(
        itemName: 'Dutch oven',
        diyOption: 'Any oven-safe pot with lid',
        diyCost: 0,
        budgetOption: 'Basic cast iron pot',
        budgetCost: 25,
        premiumOption: 'Le Creuset Dutch Oven',
        premiumCost: 200,
      ),
    ],
  };

  // ═══════════════════════════════════════════════════
  //  SEASONAL PICKS
  // ═══════════════════════════════════════════════════

  static const Map<String, List<String>> seasonalHobbies = {
    'Winter Warmers': ['sourdough', 'pottery', 'calligraphy', 'chess'],
    'Spring Awakening': ['hiking', 'skateboarding', 'bouldering', 'guitar'],
    'Summer Adventures': ['hiking', 'skateboarding', 'bouldering', 'guitar'],
    'Autumn Coziness': ['pottery', 'sourdough', 'calligraphy', 'chess'],
  };

  // ═══════════════════════════════════════════════════
  //  MOOD → HOBBY TAG MAPPING
  // ═══════════════════════════════════════════════════

  static const Map<String, List<String>> moodToTags = {
    'Stressed': ['relaxing', 'meditative'],
    'Bored': ['physical', 'competitive'],
    'Lonely': ['social'],
    'Creative': ['creative'],
    'Restless': ['physical', 'outdoors'],
    'Curious': ['technical', 'creative'],
  };

  // ═══════════════════════════════════════════════════
  //  PROFILE PHOTOS (mock gallery)
  // ═══════════════════════════════════════════════════

  static const List<String> profilePhotos = [
    'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=300&q=80',
    'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=300&q=80',
    'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=300&q=80',
    'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=300&q=80',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=300&q=80',
    'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=300&q=80',
  ];

  // ═══════════════════════════════════════════════════
  //  ACTIVITY HEATMAP (mock daily data)
  // ═══════════════════════════════════════════════════

  /// Returns a map of date → activity level (0-3) for the last N days.
  static Map<DateTime, int> generateHeatmapData({int days = 112}) {
    final data = <DateTime, int>{};
    final now = DateTime.now();
    // Deterministic "random" based on day offset
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final hash = (date.day * 7 + date.month * 13 + date.weekday * 3) % 10;
      if (hash < 4) {
        data[date] = 0; // no activity
      } else if (hash < 7) {
        data[date] = 1; // light
      } else if (hash < 9) {
        data[date] = 2; // medium
      } else {
        data[date] = 3; // heavy
      }
    }
    return data;
  }

  /// Returns a description for a heatmap day.
  static String? heatmapTooltip(DateTime date, int level) {
    if (level == 0) return null;
    final hobbies = ['Pottery', 'Bouldering', 'Sourdough', 'Calligraphy'];
    final steps = ['Made a pinch pot', 'Sent a V0', 'Fed the starter', 'Practiced strokes'];
    final idx = (date.day + date.month) % hobbies.length;
    return '${hobbies[idx]}: ${steps[idx]}';
  }
}
