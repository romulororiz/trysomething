// ═══════════════════════════════════════════════════════════
//  MIND — 14 hobbies
// ═══════════════════════════════════════════════════════════

export const mindHobbies = [
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
    sortOrder: 0,
  },
  {
    id: "journaling",
    title: "Journaling",
    hook: "Write your mind clear. One page at a time.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1771254239887-c526a301e647?w=800&h=1066&fit=crop&q=85",
    tags: ["relaxing", "solo", "creative"],
    costText: "CHF 10–30",
    timeText: "1h/week",
    difficultyText: "Easy",
    whyLove: "Journaling is the cheapest therapy. It untangles your thoughts, tracks your growth, and gives you a written record of your life you'll treasure decades later.",
    difficultyExplain: "There are no rules. Just write. Morning pages, bullet journals, gratitude lists — find what clicks and do it.",
    pitfalls: [
      "Don't aim for perfection. Messy journals are real journals.",
      "Don't start with an expensive notebook — you'll be afraid to use it.",
      "Write consistently, even if it's just 3 sentences.",
    ],
    sortOrder: 1,
  },
  {
    id: "meditation",
    title: "Meditation",
    hook: "Sit still. Breathe. Everything changes.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&h=800&fit=crop",
    tags: ["relaxing", "meditative", "solo"],
    costText: "CHF 0–20",
    timeText: "1h/week",
    difficultyText: "Easy",
    whyLove: "The benefits compound silently — less anxiety, better focus, deeper sleep. Ten minutes a day rewires how you respond to stress. It's mental fitness training.",
    difficultyExplain: "Sitting still is simple but not easy. Your mind will wander — that's the practice. Start with 5 minutes and build up.",
    pitfalls: [
      "Don't judge your meditation. A distracted session still counts.",
      "Don't try to stop thinking. Just observe thoughts without following them.",
      "Start with guided meditation (Insight Timer is free) before going solo.",
    ],
    sortOrder: 2,
  },
  {
    id: "language-learning",
    title: "Language Learning",
    hook: "Unlock a new world with every word.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1673515334893-2c20c91d0e93?w=800&h=1066&fit=crop&q=85",
    tags: ["social", "solo", "technical"],
    costText: "CHF 0–30",
    timeText: "3h/week",
    difficultyText: "Medium",
    whyLove: "Speaking another language opens doors you didn't know existed — travel, friendships, career opportunities. The moment someone responds to you in their language is pure joy.",
    difficultyExplain: "Consistency matters more than talent. 15 minutes daily beats 2 hours weekly. Some languages are harder for English speakers than others.",
    pitfalls: [
      "Don't study grammar for months before speaking. Speak from day one.",
      "Don't use only one app. Combine Duolingo with podcasts and conversation.",
      "Don't switch languages every few weeks. Commit to one for 6 months.",
    ],
    sortOrder: 3,
  },
  {
    id: "puzzles",
    title: "Puzzles",
    hook: "1000 pieces. One satisfying click at a time.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=800&fit=crop",
    tags: ["relaxing", "solo", "meditative"],
    costText: "CHF 10–30",
    timeText: "2h/week",
    difficultyText: "Easy",
    whyLove: "Puzzles quiet the noisy brain. There's a meditative satisfaction in finding the right piece. No screens, no pressure, just you and the picture coming together.",
    difficultyExplain: "Start with 500 pieces. 1000-piece puzzles need patience and space. Sort by color and edge pieces first.",
    pitfalls: [
      "Get a puzzle mat if you don't have a dedicated table. Cats are your enemy.",
      "Don't force pieces. If it doesn't click smoothly, it's wrong.",
      "Sort edge pieces first. Build the frame, then fill in sections by color.",
    ],
    sortOrder: 4,
  },
  {
    id: "reading-challenges",
    title: "Reading Challenges",
    hook: "Set a goal. Read with purpose.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1586800530994-79abd9d49abb?w=800&h=1066&fit=crop&q=85",
    tags: ["relaxing", "solo"],
    costText: "CHF 0–20",
    timeText: "3h/week",
    difficultyText: "Easy",
    whyLove: "A reading challenge pushes you beyond your comfort zone — new genres, diverse authors, topics you'd never pick. Libraries make it free. Book communities make it social.",
    difficultyExplain: "Start with 12 books in 12 months (one per month). Audiobooks count. Adjust the pace to your life.",
    pitfalls: [
      "Don't force yourself through a book you hate. Life's too short. Quit and move on.",
      "Track your reading on Goodreads — it's motivating to see progress.",
      "Don't compare your reading speed to others. Slow readers retain more.",
    ],
    sortOrder: 5,
  },
  {
    id: "philosophy",
    title: "Philosophy",
    hook: "Ask the big questions. Think deeper.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1763936783251-4a3eb135f07f?w=800&h=1066&fit=crop&q=85",
    tags: ["solo", "social"],
    costText: "CHF 0–20",
    timeText: "2h/week",
    difficultyText: "Medium",
    whyLove: "Philosophy gives you frameworks for understanding life, ethics, and your own mind. It sharpens critical thinking and makes you a better conversationalist and decision-maker.",
    difficultyExplain: "Start with accessible writers (Alain de Botton, Michael Sandel) before tackling primary texts. YouTube channels like Philosophize This! make it approachable.",
    pitfalls: [
      "Don't start with Kant or Hegel. You'll bounce off hard. Start accessible.",
      "Discuss what you read with others — philosophy is a dialogue, not a monologue.",
      "Don't try to read everything. Pick one tradition and go deep first.",
    ],
    sortOrder: 6,
  },
  {
    id: "creative-writing",
    title: "Creative Writing",
    hook: "Build worlds. Tell stories. Find your voice.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1722872094963-63c19ac7232c?w=800&h=1066&fit=crop&q=85",
    tags: ["creative", "solo"],
    costText: "CHF 0–15",
    timeText: "2h/week",
    difficultyText: "Medium",
    whyLove: "Writing is the most accessible creative outlet. A blank page and your imagination are all you need. The stories in your head deserve to exist.",
    difficultyExplain: "First drafts are supposed to be bad. The skill is in revision. Writing daily — even badly — builds the muscle faster than waiting for inspiration.",
    pitfalls: [
      "Don't edit while you write. First draft first, revisions later.",
      "Don't wait for inspiration. Sit down and write. Inspiration follows action.",
      "Share your work early — feedback is how you improve fastest.",
    ],
    sortOrder: 7,
  },
  {
    id: "astronomy",
    title: "Astronomy",
    hook: "Look up. The universe is staggering.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f0?w=600&h=800&fit=crop",
    tags: ["solo", "technical", "outdoors"],
    costText: "CHF 0–200",
    timeText: "2h/week",
    difficultyText: "Easy",
    whyLove: "Seeing Saturn's rings through a telescope for the first time is a life-changing moment. The night sky connects you to something vast and humbling.",
    difficultyExplain: "Start with naked-eye stargazing and a free app (Stellarium). No telescope needed yet. Learn constellations, then the planets.",
    pitfalls: [
      "Don't buy a cheap department store telescope. Binoculars are better to start.",
      "Give your eyes 20 minutes to dark-adapt. No phone screens.",
      "Check light pollution maps. Drive 30 minutes from the city and the sky transforms.",
    ],
    sortOrder: 8,
  },
  {
    id: "brain-teasers",
    title: "Brain Teasers",
    hook: "Stretch your brain like a muscle.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=800&fit=crop",
    tags: ["solo", "competitive", "technical"],
    costText: "CHF 0–15",
    timeText: "1h/week",
    difficultyText: "Easy",
    whyLove: "The moment a tricky puzzle clicks is pure dopamine. Logic puzzles, riddles, and math challenges keep your mind sharp and make commutes fly by.",
    difficultyExplain: "Start easy and increase difficulty. The point is the satisfying struggle, not instant answers.",
    pitfalls: [
      "Don't check the answer too quickly. Struggle is where learning happens.",
      "Mix puzzle types — logic, spatial, verbal, mathematical.",
      "Don't do brain teasers right before bed. Your brain won't shut off.",
    ],
    sortOrder: 9,
  },
  {
    id: "speed-cubing",
    title: "Speed Cubing",
    hook: "Solve a Rubik's cube in under a minute.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=800&fit=crop",
    tags: ["competitive", "solo", "technical"],
    costText: "CHF 10–40",
    timeText: "2h/week",
    difficultyText: "Medium",
    whyLove: "Once you learn the method, every solve is a race against yourself. Watching your times drop from 3 minutes to 30 seconds is incredibly satisfying. People will think you're a genius.",
    difficultyExplain: "The beginner method has ~6 algorithms. Memorizing them takes a week. Speed comes from practice and finger tricks.",
    pitfalls: [
      "Don't use the Rubik's brand cube — buy a speed cube (MoYu, QiYi). Huge difference.",
      "Learn the beginner method fully before attempting CFOP or other advanced methods.",
      "Practice algorithms slowly at first. Speed comes from accuracy, not rushing.",
    ],
    sortOrder: 10,
  },
  {
    id: "memory-training",
    title: "Memory Training",
    hook: "Remember everything. Forget nothing.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=800&fit=crop",
    tags: ["solo", "technical", "competitive"],
    costText: "CHF 0–15",
    timeText: "1h/week",
    difficultyText: "Medium",
    whyLove: "Memory techniques feel like a superpower. Memorize a deck of cards, long number sequences, or everything you read. These skills transfer to every area of life.",
    difficultyExplain: "The palace technique is learnable in a day. Building speed and capacity takes months of practice. Consistency is key.",
    pitfalls: [
      "Don't skip building your first memory palace. It's the foundation of everything.",
      "Practice daily, even for just 10 minutes. Memory fades without use.",
      "Don't try to memorize random things. Start with practical info (names, numbers, facts).",
    ],
    sortOrder: 11,
  },
  {
    id: "mind-calligraphy",
    title: "Calligraphy",
    hook: "Master beautiful lettering. Meditative focus.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&h=800&fit=crop",
    tags: ["relaxing", "meditative", "solo"],
    costText: "CHF 15–50",
    timeText: "1h/week",
    difficultyText: "Medium",
    whyLove: "Calligraphy is moving meditation. Each stroke demands full presence. The discipline of form quiets mental noise while producing something beautiful.",
    difficultyExplain: "Traditional scripts (Copperplate, Spencerian) require disciplined practice. Modern calligraphy is more forgiving. Both reward patience.",
    pitfalls: [
      "Use smooth, coated paper. Regular paper causes bleeding and feathering.",
      "Warm up with basic strokes before writing letters. Build muscle memory.",
      "Don't grip too tightly — let the pen glide. Tension shows in your strokes.",
    ],
    sortOrder: 12,
  },
  {
    id: "lucid-dreaming",
    title: "Lucid Dreaming",
    hook: "Control your dreams. Explore the impossible.",
    categoryId: "mind",
    imageUrl: "https://images.unsplash.com/photo-1679706292806-3a7d5eb2dd75?w=800&h=1066&fit=crop&q=85",
    tags: ["solo", "creative"],
    costText: "CHF 0–15",
    timeText: "1h/week",
    difficultyText: "Hard",
    whyLove: "Flying, time travel, talking to your subconscious — lucid dreaming turns sleep into an adventure. It's the ultimate free entertainment and a window into your own mind.",
    difficultyExplain: "Most people can achieve their first lucid dream in 2-8 weeks with consistent practice. Dream journaling and reality checks are the core techniques.",
    pitfalls: [
      "Keep a dream journal by your bed. Write immediately upon waking.",
      "Do reality checks during the day — they'll carry into dreams.",
      "Don't get frustrated. Some nights nothing happens. Consistency wins.",
    ],
    sortOrder: 13,
  },
];

export const mindKitItems = [
  // Chess
  { hobbyId: "chess", name: "Chess.com account (free)", description: "Play online instantly. Puzzles and lessons included.", cost: 0, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=400&q=80", affiliateUrl: "https://www.chess.com/", affiliateSource: "amazon_de" },
  { hobbyId: "chess", name: "Physical chess set", description: "Weighted plastic pieces with vinyl board.", cost: 20, isOptional: true, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=chess+set+weighted+pieces&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "chess", name: "Chess clock", description: "For timed games with friends. Digital preferred.", cost: 25, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=digital+chess+clock&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Journaling
  { hobbyId: "journaling", name: "Notebook (A5, dot grid)", description: "Leuchtturm1917 or Moleskine. Dot grid is versatile.", cost: 18, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Leuchtturm1917+A5+dot+grid+notebook&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "journaling", name: "Pen (fine tip)", description: "Pilot G2 or Muji 0.5mm. Smooth and reliable.", cost: 4, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Muji+gel+pen+0.5mm&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "journaling", name: "Washi tape set", description: "For decoration and section dividers. Makes pages pop.", cost: 8, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=washi+tape+set+journal&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Meditation
  { hobbyId: "meditation", name: "Meditation cushion (zafu)", description: "Elevates hips for comfortable sitting. Buckwheat fill is best.", cost: 35, isOptional: true, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=zafu+meditation+cushion+buckwheat&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "meditation", name: "Insight Timer app (free)", description: "Thousands of free guided meditations and a timer.", cost: 0, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80", affiliateUrl: "https://insighttimer.com/", affiliateSource: "amazon_de" },
  { hobbyId: "meditation", name: "Meditation book", description: "'Wherever You Go, There You Are' by Jon Kabat-Zinn.", cost: 15, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Wherever+You+Go+There+You+Are+Kabat-Zinn&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Language Learning
  { hobbyId: "language-learning", name: "Duolingo app (free tier)", description: "Gamified daily lessons. Best for building a habit.", cost: 0, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.duolingo.com/", affiliateSource: "amazon_de" },
  { hobbyId: "language-learning", name: "Phrase book", description: "Lonely Planet phrasebooks cover essentials for any language.", cost: 10, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Lonely+Planet+phrasebook&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "language-learning", name: "Anki flashcard app (free)", description: "Spaced repetition for vocabulary. The gold standard.", cost: 0, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://apps.ankiweb.net/", affiliateSource: "amazon_de" },

  // Puzzles
  { hobbyId: "puzzles", name: "500-piece jigsaw puzzle", description: "A scenic landscape or art print. Perfect first puzzle.", cost: 15, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=jigsaw+puzzle+500+pieces&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "puzzles", name: "Puzzle mat (roll-up)", description: "Roll up your in-progress puzzle. Save table space.", cost: 15, isOptional: true, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=jigsaw+puzzle+roll+up+mat&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "puzzles", name: "Sorting trays", description: "Separate pieces by color, edge, and pattern.", cost: 12, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=jigsaw+puzzle+sorting+trays&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Reading Challenges
  { hobbyId: "reading-challenges", name: "Library card (free)", description: "Free books. Unlimited. Your taxes already paid for it.", cost: 0, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=book+reading+list+journal&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "reading-challenges", name: "Reading journal", description: "Track books read, favorite quotes, and ratings.", cost: 12, isOptional: true, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=reading+journal+book+tracker&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "reading-challenges", name: "Book light (clip-on)", description: "Read in bed without disturbing your partner.", cost: 10, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=clip+on+book+reading+light&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Philosophy
  { hobbyId: "philosophy", name: "'Justice' by Michael Sandel", description: "Engaging intro to moral philosophy. Based on Harvard's most popular course.", cost: 15, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Justice+Michael+Sandel&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "philosophy", name: "Notebook for notes", description: "Philosophy demands active reading. Take notes.", cost: 8, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=A5+notebook+philosophy+notes&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "philosophy", name: "'Sophie's World' by Jostein Gaarder", description: "History of philosophy as a novel. Surprisingly gripping.", cost: 12, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Sophie+World+Jostein+Gaarder&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Creative Writing
  { hobbyId: "creative-writing", name: "Writing notebook or laptop", description: "Whatever gets words out of your head. Paper or screen.", cost: 0, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=writer+notebook+A5&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "creative-writing", name: "'On Writing' by Stephen King", description: "Part memoir, part masterclass. Essential reading for any writer.", cost: 12, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=On+Writing+Stephen+King&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "creative-writing", name: "Writing prompts deck", description: "Cards with story starters for when you're stuck.", cost: 12, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=creative+writing+prompts+cards&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Astronomy
  { hobbyId: "astronomy", name: "Stellarium app (free)", description: "Point your phone at the sky and identify everything.", cost: 0, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f0?w=400&q=80", affiliateUrl: "https://stellarium.org/", affiliateSource: "amazon_de" },
  { hobbyId: "astronomy", name: "Binoculars (10x50)", description: "Better than a cheap telescope. See craters on the Moon.", cost: 60, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f0?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=binoculars+10x50+astronomy&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "astronomy", name: "Star chart (planisphere)", description: "Rotating disc shows tonight's sky. No batteries needed.", cost: 12, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f0?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=planisphere+star+chart&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "astronomy", name: "Red flashlight", description: "Preserves night vision while reading charts.", cost: 8, isOptional: true, sortOrder: 3, imageUrl: "https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f0?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=red+light+flashlight+astronomy&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Brain Teasers
  { hobbyId: "brain-teasers", name: "Puzzle book (mixed)", description: "Logic puzzles, riddles, and lateral thinking challenges.", cost: 12, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=brain+teasers+puzzle+book+adults&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "brain-teasers", name: "Metal puzzle set", description: "3D interlocking metal puzzles. Tactile and challenging.", cost: 15, isOptional: true, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=metal+brain+teaser+puzzle+set&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "brain-teasers", name: "Sudoku/KenKen pad", description: "Number logic puzzles in escalating difficulty.", cost: 8, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=sudoku+kenken+puzzle+book&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Speed Cubing
  { hobbyId: "speed-cubing", name: "Speed cube (MoYu RS3M)", description: "Smooth, magnetic, and cheap. Night-and-day vs. Rubik's brand.", cost: 10, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=MoYu+RS3M+speed+cube&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "speed-cubing", name: "Cube timer (csTimer.net)", description: "Free online timer with scrambles and statistics.", cost: 0, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://cstimer.net/", affiliateSource: "amazon_de" },
  { hobbyId: "speed-cubing", name: "Cube lube", description: "A drop of silicone lube makes turns butter-smooth.", cost: 5, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=speed+cube+lube+silicone&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Memory Training
  { hobbyId: "memory-training", name: "'Moonwalking with Einstein' by Joshua Foer", description: "The book that launched a thousand memory competitors. Essential reading.", cost: 15, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Moonwalking+with+Einstein+Joshua+Foer&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "memory-training", name: "Deck of playing cards", description: "The classic memory training tool. Memorize the full deck.", cost: 5, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=playing+cards+deck&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "memory-training", name: "Anki flashcards (free)", description: "Spaced repetition software. The memory athlete's daily driver.", cost: 0, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&q=80", affiliateUrl: "https://apps.ankiweb.net/", affiliateSource: "amazon_de" },

  // Calligraphy (Mind)
  { hobbyId: "mind-calligraphy", name: "Calligraphy starter set", description: "Parallel pen, ink cartridges, and exemplar sheets.", cost: 20, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Pilot+Parallel+Pen+calligraphy+set&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "mind-calligraphy", name: "Practice paper (smooth)", description: "Rhodia or Clairefontaine. Smooth, no bleed.", cost: 8, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Rhodia+calligraphy+practice+paper&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "mind-calligraphy", name: "Ink bottle (Sumi or walnut)", description: "Bottled ink is cheaper and offers more color options.", cost: 10, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=sumi+ink+calligraphy+bottle&tag=trysomething-21", affiliateSource: "amazon_de" },

  // Lucid Dreaming
  { hobbyId: "lucid-dreaming", name: "Dream journal", description: "A notebook by your bed. Write immediately on waking.", cost: 10, isOptional: false, sortOrder: 0, imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=dream+journal+notebook&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "lucid-dreaming", name: "'Exploring the World of Lucid Dreaming' by Stephen LaBerge", description: "The definitive guide by the scientist who pioneered the field.", cost: 15, isOptional: false, sortOrder: 1, imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=Exploring+World+Lucid+Dreaming+LaBerge&tag=trysomething-21", affiliateSource: "amazon_de" },
  { hobbyId: "lucid-dreaming", name: "Sleep mask", description: "Blocks light for deeper REM sleep. Essential in light rooms.", cost: 8, isOptional: true, sortOrder: 2, imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&q=80", affiliateUrl: "https://www.amazon.de/s?k=silk+sleep+mask+comfortable&tag=trysomething-21", affiliateSource: "amazon_de" },
];

export const mindRoadmapSteps = [
  // Chess
  { id: "mch1", hobbyId: "chess", title: "Learn the rules", description: "How pieces move, check, checkmate, special moves.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
  { id: "mch2", hobbyId: "chess", title: "Play 5 games online", description: "Just play. Don't worry about winning.", estimatedMinutes: 50, milestone: "First games", sortOrder: 1 },
  { id: "mch3", hobbyId: "chess", title: "Learn basic tactics", description: "Forks, pins, skewers. The building blocks.", estimatedMinutes: 30, milestone: null, sortOrder: 2 },
  { id: "mch4", hobbyId: "chess", title: "Solve 20 puzzles", description: "Daily puzzles on Chess.com or Lichess.", estimatedMinutes: 20, milestone: "Puzzle streak", sortOrder: 3 },
  { id: "mch5", hobbyId: "chess", title: "Play a rated game and analyze it", description: "Review with engine analysis. Find your mistakes.", estimatedMinutes: 30, milestone: "First analysis", sortOrder: 4 },

  // Journaling
  { id: "mj1", hobbyId: "journaling", title: "Write your first page", description: "Stream of consciousness. No rules. Just write.", estimatedMinutes: 10, milestone: null, sortOrder: 0 },
  { id: "mj2", hobbyId: "journaling", title: "Try morning pages", description: "Write 3 pages first thing in the morning for 5 days.", estimatedMinutes: 20, milestone: "Morning routine", sortOrder: 1 },
  { id: "mj3", hobbyId: "journaling", title: "Try a gratitude list", description: "Write 3 things you're grateful for each night.", estimatedMinutes: 5, milestone: null, sortOrder: 2 },
  { id: "mj4", hobbyId: "journaling", title: "Journal for 2 weeks straight", description: "Consistency matters more than length.", estimatedMinutes: 10, milestone: "Habit formed", sortOrder: 3 },
  { id: "mj5", hobbyId: "journaling", title: "Re-read your first entry", description: "Notice how your thinking has evolved.", estimatedMinutes: 10, milestone: "Self-reflection", sortOrder: 4 },

  // Meditation
  { id: "mm1", hobbyId: "meditation", title: "Try a 5-minute guided meditation", description: "Insight Timer or YouTube. Just sit and follow along.", estimatedMinutes: 5, milestone: null, sortOrder: 0 },
  { id: "mm2", hobbyId: "meditation", title: "Meditate 5 days in a row", description: "Same time each day. Build the habit.", estimatedMinutes: 5, milestone: "5-day streak", sortOrder: 1 },
  { id: "mm3", hobbyId: "meditation", title: "Extend to 10 minutes", description: "When 5 feels easy, push to 10.", estimatedMinutes: 10, milestone: null, sortOrder: 2 },
  { id: "mm4", hobbyId: "meditation", title: "Try body scan meditation", description: "Focus attention on each body part sequentially.", estimatedMinutes: 15, milestone: null, sortOrder: 3 },
  { id: "mm5", hobbyId: "meditation", title: "Meditate without guidance", description: "Set a timer. Just breathe. You don't need the app anymore.", estimatedMinutes: 10, milestone: "Independent practice", sortOrder: 4 },

  // Language Learning
  { id: "ml1", hobbyId: "language-learning", title: "Choose your language", description: "Pick one you're passionate about. Motivation > difficulty.", estimatedMinutes: 15, milestone: null, sortOrder: 0 },
  { id: "ml2", hobbyId: "language-learning", title: "Learn 50 essential words", description: "Greetings, numbers, common verbs and nouns.", estimatedMinutes: 60, milestone: "First 50 words", sortOrder: 1 },
  { id: "ml3", hobbyId: "language-learning", title: "Complete 7-day Duolingo streak", description: "Daily practice builds the habit.", estimatedMinutes: 15, milestone: "Week streak", sortOrder: 2 },
  { id: "ml4", hobbyId: "language-learning", title: "Have your first conversation", description: "HelloTalk, italki, or a local conversation partner.", estimatedMinutes: 30, milestone: "First conversation", sortOrder: 3 },
  { id: "ml5", hobbyId: "language-learning", title: "Watch a show in your target language", description: "Subtitles on. Immersion starts here.", estimatedMinutes: 30, milestone: null, sortOrder: 4 },

  // Puzzles
  { id: "mp1", hobbyId: "puzzles", title: "Open and sort your puzzle", description: "Separate edges, corners, and color groups.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
  { id: "mp2", hobbyId: "puzzles", title: "Build the border", description: "All edge pieces first. The frame grounds everything.", estimatedMinutes: 30, milestone: "Frame complete", sortOrder: 1 },
  { id: "mp3", hobbyId: "puzzles", title: "Fill in sections by color", description: "Work on distinct areas — sky, ground, objects.", estimatedMinutes: 60, milestone: null, sortOrder: 2 },
  { id: "mp4", hobbyId: "puzzles", title: "Complete your first puzzle", description: "That last piece clicks. Pure satisfaction.", estimatedMinutes: 60, milestone: "First complete", sortOrder: 3 },
  { id: "mp5", hobbyId: "puzzles", title: "Try a 1000-piece puzzle", description: "Level up. More pieces, more patience, more reward.", estimatedMinutes: 120, milestone: "1000 pieces", sortOrder: 4 },

  // Reading Challenges
  { id: "mr1", hobbyId: "reading-challenges", title: "Set your reading goal", description: "12 books in 12 months is a great start.", estimatedMinutes: 10, milestone: null, sortOrder: 0 },
  { id: "mr2", hobbyId: "reading-challenges", title: "Read a book outside your comfort zone", description: "A genre you've never tried. Surprise yourself.", estimatedMinutes: 120, milestone: "Genre explorer", sortOrder: 1 },
  { id: "mr3", hobbyId: "reading-challenges", title: "Join Goodreads and track progress", description: "Social accountability and recommendations.", estimatedMinutes: 15, milestone: null, sortOrder: 2 },
  { id: "mr4", hobbyId: "reading-challenges", title: "Finish your first book", description: "One down. The momentum begins.", estimatedMinutes: 180, milestone: "First book", sortOrder: 3 },
  { id: "mr5", hobbyId: "reading-challenges", title: "Write a short review", description: "Even 3 sentences. It deepens your reading.", estimatedMinutes: 15, milestone: "First review", sortOrder: 4 },

  // Philosophy
  { id: "mph1", hobbyId: "philosophy", title: "Watch 'Philosophize This!' episode 1", description: "Free podcast. Engaging introduction to Western philosophy.", estimatedMinutes: 30, milestone: null, sortOrder: 0 },
  { id: "mph2", hobbyId: "philosophy", title: "Read a short accessible text", description: "Plato's 'Allegory of the Cave' or Camus' 'The Myth of Sisyphus'.", estimatedMinutes: 30, milestone: null, sortOrder: 1 },
  { id: "mph3", hobbyId: "philosophy", title: "Discuss a philosophical question with someone", description: "Ethics, free will, consciousness — pick one and debate.", estimatedMinutes: 30, milestone: "First dialogue", sortOrder: 2 },
  { id: "mph4", hobbyId: "philosophy", title: "Read one full philosophy book", description: "Sandel's 'Justice' or Camus' 'The Stranger'.", estimatedMinutes: 180, milestone: "First book", sortOrder: 3 },
  { id: "mph5", hobbyId: "philosophy", title: "Write your own philosophical reflection", description: "Take a position on a big question. Defend it.", estimatedMinutes: 30, milestone: "Philosopher", sortOrder: 4 },

  // Creative Writing
  { id: "mcw1", hobbyId: "creative-writing", title: "Write for 15 minutes without stopping", description: "Freewrite. No editing, no pausing. Just words.", estimatedMinutes: 15, milestone: null, sortOrder: 0 },
  { id: "mcw2", hobbyId: "creative-writing", title: "Write a flash fiction (under 500 words)", description: "A complete story in half a page. Beginning, middle, end.", estimatedMinutes: 30, milestone: "First story", sortOrder: 1 },
  { id: "mcw3", hobbyId: "creative-writing", title: "Use a writing prompt", description: "Pick a random prompt and write for 20 minutes.", estimatedMinutes: 20, milestone: null, sortOrder: 2 },
  { id: "mcw4", hobbyId: "creative-writing", title: "Share your work and get feedback", description: "Writers group, Reddit, or a trusted friend.", estimatedMinutes: 30, milestone: "First feedback", sortOrder: 3 },
  { id: "mcw5", hobbyId: "creative-writing", title: "Revise a piece based on feedback", description: "Rewriting is where the real writing happens.", estimatedMinutes: 45, milestone: "Second draft", sortOrder: 4 },

  // Astronomy
  { id: "ma1", hobbyId: "astronomy", title: "Download Stellarium and identify 5 constellations", description: "Point your phone at the sky. Start with the Big Dipper.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
  { id: "ma2", hobbyId: "astronomy", title: "Find a planet with naked eye", description: "Venus, Jupiter, or Mars. They don't twinkle like stars.", estimatedMinutes: 15, milestone: "First planet", sortOrder: 1 },
  { id: "ma3", hobbyId: "astronomy", title: "Observe the Moon through binoculars", description: "Craters, seas, and mountains. It's stunning up close.", estimatedMinutes: 20, milestone: null, sortOrder: 2 },
  { id: "ma4", hobbyId: "astronomy", title: "Watch a satellite pass (ISS)", description: "Use ISS Detector app. It crosses the sky in 5 minutes.", estimatedMinutes: 15, milestone: "ISS spotted", sortOrder: 3 },
  { id: "ma5", hobbyId: "astronomy", title: "Drive to a dark sky site", description: "30+ minutes from city lights. The Milky Way will blow your mind.", estimatedMinutes: 120, milestone: "Dark sky experience", sortOrder: 4 },

  // Brain Teasers
  { id: "mbt1", hobbyId: "brain-teasers", title: "Solve 10 logic puzzles", description: "Start with easy ones. Build confidence.", estimatedMinutes: 30, milestone: null, sortOrder: 0 },
  { id: "mbt2", hobbyId: "brain-teasers", title: "Try a lateral thinking puzzle", description: "'A man walks into a bar...' style. Think sideways.", estimatedMinutes: 15, milestone: null, sortOrder: 1 },
  { id: "mbt3", hobbyId: "brain-teasers", title: "Complete a metal puzzle", description: "Take apart an interlocking metal puzzle. No peeking at solutions.", estimatedMinutes: 30, milestone: "First metal solve", sortOrder: 2 },
  { id: "mbt4", hobbyId: "brain-teasers", title: "Try KenKen or Kakuro", description: "Math-based logic puzzles. Addictive once you start.", estimatedMinutes: 20, milestone: null, sortOrder: 3 },
  { id: "mbt5", hobbyId: "brain-teasers", title: "Create your own brain teaser", description: "Making puzzles is harder than solving them.", estimatedMinutes: 30, milestone: "Puzzle creator", sortOrder: 4 },

  // Speed Cubing
  { id: "msc1", hobbyId: "speed-cubing", title: "Learn the beginner method", description: "Layer-by-layer. YouTube tutorials by JPerm are excellent.", estimatedMinutes: 60, milestone: null, sortOrder: 0 },
  { id: "msc2", hobbyId: "speed-cubing", title: "Solve the cube from memory", description: "No looking at the tutorial. You know the algorithms.", estimatedMinutes: 15, milestone: "First solo solve", sortOrder: 1 },
  { id: "msc3", hobbyId: "speed-cubing", title: "Get under 2 minutes", description: "Practice algorithms until they're muscle memory.", estimatedMinutes: 30, milestone: "Sub-2 minutes", sortOrder: 2 },
  { id: "msc4", hobbyId: "speed-cubing", title: "Learn finger tricks", description: "Flick instead of regrip. This is where speed happens.", estimatedMinutes: 30, milestone: null, sortOrder: 3 },
  { id: "msc5", hobbyId: "speed-cubing", title: "Get under 1 minute", description: "Sub-60 seconds. You're officially a speed cuber.", estimatedMinutes: 45, milestone: "Sub-1 minute", sortOrder: 4 },

  // Memory Training
  { id: "mmt1", hobbyId: "memory-training", title: "Build your first memory palace", description: "Pick a familiar route (your apartment). Place 10 items.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
  { id: "mmt2", hobbyId: "memory-training", title: "Memorize a 20-item list", description: "Use your palace. Visualize each item vividly.", estimatedMinutes: 15, milestone: "20-item recall", sortOrder: 1 },
  { id: "mmt3", hobbyId: "memory-training", title: "Learn the PAO system for numbers", description: "Person-Action-Object. Turns numbers into stories.", estimatedMinutes: 30, milestone: null, sortOrder: 2 },
  { id: "mmt4", hobbyId: "memory-training", title: "Memorize a deck of cards", description: "The classic test. Even halfway through is impressive.", estimatedMinutes: 30, milestone: "First deck attempt", sortOrder: 3 },
  { id: "mmt5", hobbyId: "memory-training", title: "Use memory techniques in daily life", description: "Names, shopping lists, phone numbers. Make it practical.", estimatedMinutes: 15, milestone: "Practical memory", sortOrder: 4 },

  // Calligraphy (Mind)
  { id: "mcal1", hobbyId: "mind-calligraphy", title: "Practice basic strokes", description: "Thick downstrokes, thin upstrokes. The alphabet of calligraphy.", estimatedMinutes: 20, milestone: null, sortOrder: 0 },
  { id: "mcal2", hobbyId: "mind-calligraphy", title: "Write the lowercase alphabet", description: "Consistent letterforms. Focus on spacing.", estimatedMinutes: 30, milestone: "Full alphabet", sortOrder: 1 },
  { id: "mcal3", hobbyId: "mind-calligraphy", title: "Write a word with connected letters", description: "Spacing and rhythm between letters.", estimatedMinutes: 20, milestone: null, sortOrder: 2 },
  { id: "mcal4", hobbyId: "mind-calligraphy", title: "Copy a quote in your best hand", description: "Pick something meaningful. Take your time.", estimatedMinutes: 25, milestone: "First finished piece", sortOrder: 3 },
  { id: "mcal5", hobbyId: "mind-calligraphy", title: "Try a different script style", description: "Italic, Copperplate, or Gothic. Each has its own character.", estimatedMinutes: 30, milestone: "Multi-script", sortOrder: 4 },

  // Lucid Dreaming
  { id: "mld1", hobbyId: "lucid-dreaming", title: "Start a dream journal", description: "Write everything you remember immediately upon waking.", estimatedMinutes: 10, milestone: null, sortOrder: 0 },
  { id: "mld2", hobbyId: "lucid-dreaming", title: "Practice reality checks 10x/day", description: "Look at your hands, check clocks, push a finger through your palm.", estimatedMinutes: 5, milestone: null, sortOrder: 1 },
  { id: "mld3", hobbyId: "lucid-dreaming", title: "Identify dream signs", description: "Read your journal. Find recurring themes, places, people.", estimatedMinutes: 15, milestone: "Dream signs found", sortOrder: 2 },
  { id: "mld4", hobbyId: "lucid-dreaming", title: "Try MILD technique before sleep", description: "Repeat 'I will realize I'm dreaming' as you fall asleep.", estimatedMinutes: 10, milestone: null, sortOrder: 3 },
  { id: "mld5", hobbyId: "lucid-dreaming", title: "Achieve your first lucid dream", description: "You realize you're dreaming — and stay in it. Magical.", estimatedMinutes: 0, milestone: "First lucid dream", sortOrder: 4 },
];

export const mindFaqItems = [
  // Chess
  { hobbyId: "chess", question: "Which app should I use?", answer: "Chess.com and Lichess are both excellent. Lichess is 100% free. Chess.com has better lessons for beginners.", upvotes: 55 },
  { hobbyId: "chess", question: "How do I stop losing every game?", answer: "Focus on not hanging pieces (free captures for your opponent). Check every move for safety before you play it.", upvotes: 42 },
  { hobbyId: "chess", question: "Should I learn openings?", answer: "Not yet! Learn tactics first (forks, pins, skewers). Opening knowledge is useless without tactical vision.", upvotes: 39 },

  // Journaling
  { hobbyId: "journaling", question: "What should I write about?", answer: "Anything. Your day, your feelings, a gratitude list, goals, rants. There are no rules. The blank page is scarier than it deserves to be.", upvotes: 48 },
  { hobbyId: "journaling", question: "Digital or paper journal?", answer: "Paper is better for reflection and memory. Digital is better for searchability. Try both and see what sticks.", upvotes: 41 },

  // Meditation
  { hobbyId: "meditation", question: "Am I meditating wrong if my mind keeps wandering?", answer: "No! Noticing your mind has wandered IS the practice. Each time you bring attention back, you're doing a mental rep. Wandering is completely normal.", upvotes: 67 },
  { hobbyId: "meditation", question: "How long until I notice benefits?", answer: "Many people report feeling calmer after 1-2 weeks of daily practice. Measurable changes in stress response appear around 8 weeks (per research).", upvotes: 52 },
  { hobbyId: "meditation", question: "Do I need to sit cross-legged?", answer: "No. Sit however is comfortable — chair, cushion, bench. The posture that lets you be alert without pain is the right one.", upvotes: 44 },

  // Language Learning
  { hobbyId: "language-learning", question: "What's the fastest way to learn a language?", answer: "Immersion + spaced repetition + speaking from day one. No single app is enough. Combine Duolingo for habit, Anki for vocab, and italki/HelloTalk for speaking.", upvotes: 58 },
  { hobbyId: "language-learning", question: "Which language should I learn?", answer: "The one you're most motivated to use. Spanish and French are easier for English speakers. Mandarin and Arabic are harder but open huge opportunities.", upvotes: 45 },

  // Puzzles
  { hobbyId: "puzzles", question: "How do I not lose puzzle pieces?", answer: "Work on a flat surface you can dedicate to the puzzle, or invest in a puzzle mat (CHF 15). Keep pieces in a shallow box, never the floor. Check under the sofa.", upvotes: 36 },
  { hobbyId: "puzzles", question: "What puzzle count should I start with?", answer: "500 pieces is the sweet spot for beginners. It's challenging enough to be rewarding but completable in 2-3 sessions. Graduate to 1000 when ready.", upvotes: 33 },
];

export const mindCostBreakdowns = [
  { hobbyId: "chess", starter: 0, threeMonth: 0, oneYear: 30, tips: ["Lichess is completely free with no premium tier", "Chess is one of the cheapest hobbies that exists", "A physical set is nice but optional"] },
  { hobbyId: "journaling", starter: 22, threeMonth: 25, oneYear: 50, tips: ["One notebook lasts 3-6 months depending on how much you write", "Fancy pens are fun but a CHF 2 pen works perfectly", "Journaling is essentially the cost of paper"] },
  { hobbyId: "meditation", starter: 0, threeMonth: 0, oneYear: 35, tips: ["Insight Timer is free and has thousands of guided meditations", "A cushion is nice but a folded blanket works fine", "The only real investment is your time"] },
  { hobbyId: "language-learning", starter: 0, threeMonth: 10, oneYear: 40, tips: ["Duolingo's free tier is genuinely useful for building a habit", "Libraries have language learning resources for free", "HelloTalk connects you with native speakers for free"] },
  { hobbyId: "puzzles", starter: 15, threeMonth: 40, oneYear: 80, tips: ["Swap completed puzzles with friends or on Facebook groups", "Charity shops sell puzzles for CHF 3-5", "One puzzle gives 5-10 hours of entertainment"] },
  { hobbyId: "reading-challenges", starter: 0, threeMonth: 0, oneYear: 20, tips: ["Libraries make this hobby completely free", "E-book sales and Project Gutenberg offer free classics", "Book swaps and Little Free Libraries are everywhere"] },
  { hobbyId: "philosophy", starter: 15, threeMonth: 25, oneYear: 50, tips: ["Many classic philosophical texts are free online (Project Gutenberg)", "Podcasts and YouTube channels are free and excellent", "One good book can occupy you for months of reflection"] },
  { hobbyId: "creative-writing", starter: 0, threeMonth: 12, oneYear: 30, tips: ["Google Docs is free and saves automatically", "Writing groups are free to join (online and in-person)", "The only real cost is a book on craft — and even that's optional"] },
  { hobbyId: "astronomy", starter: 60, threeMonth: 70, oneYear: 100, tips: ["Stellarium app is free and teaches you the sky", "Binoculars are a better first investment than a telescope", "Dark skies are free — just drive away from the city"] },
  { hobbyId: "brain-teasers", starter: 12, threeMonth: 20, oneYear: 40, tips: ["Most brain teaser apps have free tiers", "A good puzzle book provides months of entertainment", "Challenge friends for free. The best puzzles are shared"] },
  { hobbyId: "speed-cubing", starter: 10, threeMonth: 15, oneYear: 30, tips: ["A CHF 10 speed cube is all you need to start and compete", "csTimer.net is free and tracks all your statistics", "The cheapest hobby with the highest cool factor"] },
  { hobbyId: "memory-training", starter: 20, threeMonth: 20, oneYear: 25, tips: ["One book and a deck of cards is all the equipment you need", "Anki is free on desktop and the best spaced repetition tool", "Memory training is practically free once you learn the techniques"] },
  { hobbyId: "mind-calligraphy", starter: 28, threeMonth: 40, oneYear: 70, tips: ["Pilot Parallel Pens are the best value calligraphy tool (CHF 10 each)", "Practice paper is the main recurring cost", "Ink cartridges last a long time — refills are cheap"] },
  { hobbyId: "lucid-dreaming", starter: 10, threeMonth: 10, oneYear: 15, tips: ["The cheapest hobby — all you need is a notebook and sleep", "Most resources are free online (Reddit r/LucidDreaming)", "You literally practice while sleeping"] },
];
