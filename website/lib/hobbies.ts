/**
 * Subset of hobby data from SeedData for landing page demos.
 * Curated for visual variety across categories.
 */

import type { CategoryId } from "./tokens";

export interface HobbyData {
  id: string;
  name: string;
  tagline: string;
  hook: string;
  category: CategoryId;
  imageUrl: string;
  cost: string;
  time: string;
  difficulty: string;
  tags: string[];
  kitItems: { name: string; price: string; essential: boolean }[];
  roadmapSteps: {
    id: string;
    title: string;
    description: string;
    timeEstimate: string;
  }[];
  pitfalls: string[];
}

export const hobbies: HobbyData[] = [
  {
    id: "pottery",
    name: "Pottery",
    tagline: "Shape earth with your hands",
    hook: "There's something deeply satisfying about centering clay on a wheel and watching a form emerge from nothing.",
    category: "creative",
    imageUrl: "/images/hobby-photos/pottery.jpg",
    cost: "$50-150",
    time: "2-3 hrs/week",
    difficulty: "Beginner",
    tags: ["Hands-on", "Meditative", "Creative"],
    kitItems: [
      { name: "Air-dry clay (2 kg)", price: "$12", essential: true },
      { name: "Basic tool set", price: "$15", essential: true },
      { name: "Rolling pin & mat", price: "$8", essential: false },
    ],
    roadmapSteps: [
      {
        id: "pottery-1",
        title: "Pinch your first bowl",
        description:
          "Start with a ball of clay and your thumbs. No wheel needed.",
        timeEstimate: "30 min",
      },
      {
        id: "pottery-2",
        title: "Learn coil building",
        description: "Roll ropes of clay and stack them to build taller forms.",
        timeEstimate: "1 hour",
      },
      {
        id: "pottery-3",
        title: "Try the wheel",
        description:
          "Book a community studio session and center your first lump.",
        timeEstimate: "2 hours",
      },
    ],
    pitfalls: [
      "Don't buy a wheel before trying a studio class",
      "Air-dry clay cracks if walls are too thick — aim for 6mm",
      "Let pieces dry slowly under plastic to avoid warping",
    ],
  },
  {
    id: "bouldering",
    name: "Bouldering",
    tagline: "Solve problems with your body",
    hook: "Every route is a puzzle. Your body is the solution. No ropes, no harness — just you, the wall, and gravity.",
    category: "fitness",
    imageUrl: "/images/hobby-photos/bouldering.jpg",
    cost: "$40-80/mo",
    time: "2-3 hrs/week",
    difficulty: "Beginner",
    tags: ["Active", "Social", "Problem-solving"],
    kitItems: [
      { name: "Climbing shoes (rental)", price: "$5/visit", essential: true },
      { name: "Chalk bag + chalk", price: "$15", essential: true },
      { name: "Gym day pass", price: "$15-20", essential: true },
    ],
    roadmapSteps: [
      {
        id: "boulder-1",
        title: "Visit a climbing gym",
        description: "Rent shoes, get an intro tour, try V0-V1 routes.",
        timeEstimate: "2 hours",
      },
      {
        id: "boulder-2",
        title: "Learn footwork basics",
        description:
          "Focus on precise foot placement — it matters more than arm strength.",
        timeEstimate: "3 sessions",
      },
      {
        id: "boulder-3",
        title: "Project your first V2",
        description:
          "Pick a route that challenges you and work it across multiple sessions.",
        timeEstimate: "1-2 weeks",
      },
    ],
    pitfalls: [
      "Don't death-grip — relax your hands, trust your feet",
      "Rest days matter more than climbing days for beginners",
      "Tight shoes are normal but pain is not — size carefully",
    ],
  },
  {
    id: "sourdough",
    name: "Sourdough Baking",
    tagline: "Cultivate patience, eat the results",
    hook: "You'll spend days nurturing a living culture, then be rewarded with bread that's unlike anything from a store.",
    category: "food",
    imageUrl: "/images/hobby-photos/sourdough.jpg",
    cost: "$20-40",
    time: "30 min/day",
    difficulty: "Intermediate",
    tags: ["Slow living", "Rewarding", "Delicious"],
    kitItems: [
      { name: "Bread flour (2 kg)", price: "$6", essential: true },
      { name: "Kitchen scale", price: "$12", essential: true },
      { name: "Dutch oven", price: "$30", essential: false },
    ],
    roadmapSteps: [
      {
        id: "bread-1",
        title: "Start your starter",
        description:
          "Mix flour and water. Feed daily for 7 days until it doubles.",
        timeEstimate: "7 days",
      },
      {
        id: "bread-2",
        title: "Bake your first loaf",
        description:
          "Follow a simple recipe: mix, fold, shape, proof overnight, bake.",
        timeEstimate: "24 hours",
      },
      {
        id: "bread-3",
        title: "Master the scoring",
        description:
          "Use a razor blade to score patterns — it controls the rise and looks beautiful.",
        timeEstimate: "3-4 bakes",
      },
    ],
    pitfalls: [
      "Your starter isn't dead — it just needs consistent feeding",
      "Use a scale, not cups — hydration ratios matter",
      "Underproofed > overproofed for beginners",
    ],
  },
  {
    id: "guitar",
    name: "Guitar",
    tagline: "Your first song is closer than you think",
    hook: "Four chords. That's all it takes to play hundreds of songs. Pick up a guitar and surprise yourself.",
    category: "music",
    imageUrl: "/images/hobby-photos/guitar.jpg",
    cost: "$80-200",
    time: "20 min/day",
    difficulty: "Beginner",
    tags: ["Musical", "Relaxing", "Portable"],
    kitItems: [
      { name: "Acoustic guitar (beginner)", price: "$120", essential: true },
      { name: "Picks (variety pack)", price: "$5", essential: true },
      { name: "Clip-on tuner", price: "$10", essential: true },
    ],
    roadmapSteps: [
      {
        id: "guitar-1",
        title: "Learn your first 4 chords",
        description: "G, C, D, Em — these unlock hundreds of songs.",
        timeEstimate: "1 week",
      },
      {
        id: "guitar-2",
        title: "Strum a full song",
        description:
          "Pick an easy song you love and play it start to finish.",
        timeEstimate: "2 weeks",
      },
      {
        id: "guitar-3",
        title: "Try fingerpicking",
        description:
          "Move beyond strumming with simple fingerpicking patterns.",
        timeEstimate: "3 weeks",
      },
    ],
    pitfalls: [
      "Sore fingers are normal for 2 weeks — push through gently",
      "Don't start with an electric — acoustic builds finger strength",
      "Practice 20 minutes daily beats 2 hours on weekends",
    ],
  },
  {
    id: "hiking",
    name: "Hiking",
    tagline: "Every trail tells a story",
    hook: "Step away from screens and into nature. All you need is a pair of shoes and a trail to follow.",
    category: "outdoors",
    imageUrl: "/images/hobby-photos/hiking.jpg",
    cost: "$0-50",
    time: "2-4 hrs/week",
    difficulty: "Beginner",
    tags: ["Nature", "Exercise", "Mindful"],
    kitItems: [
      { name: "Trail shoes", price: "$60", essential: true },
      { name: "Water bottle (1L)", price: "$15", essential: true },
      { name: "Day pack (20L)", price: "$30", essential: false },
    ],
    roadmapSteps: [
      {
        id: "hike-1",
        title: "Find a local trail",
        description:
          "Use AllTrails or local park sites to find an easy 2-3 mile loop.",
        timeEstimate: "30 min",
      },
      {
        id: "hike-2",
        title: "Complete your first hike",
        description: "Pack water, wear layers, and take your time.",
        timeEstimate: "2 hours",
      },
      {
        id: "hike-3",
        title: "Try a longer trail",
        description:
          "Graduate to a 5+ mile hike with some elevation gain.",
        timeEstimate: "Half day",
      },
    ],
    pitfalls: [
      "Cotton kills — wear moisture-wicking layers",
      "Start earlier than you think to avoid afternoon heat",
      "Tell someone your trail plan before heading out",
    ],
  },
  {
    id: "chess",
    name: "Chess",
    tagline: "The ultimate mental workout",
    hook: "A 1,500-year-old game that's more popular now than ever. Every game is a new puzzle to solve.",
    category: "mind",
    imageUrl: "/images/hobby-photos/chess.jpg",
    cost: "$0",
    time: "15-30 min/day",
    difficulty: "Beginner",
    tags: ["Strategic", "Competitive", "Free"],
    kitItems: [
      { name: "Chess.com account (free)", price: "$0", essential: true },
      { name: "Physical board & pieces", price: "$20", essential: false },
      { name: "Tactics trainer app", price: "$0", essential: false },
    ],
    roadmapSteps: [
      {
        id: "chess-1",
        title: "Learn the rules",
        description:
          "How each piece moves, castling, en passant, checkmate.",
        timeEstimate: "1 hour",
      },
      {
        id: "chess-2",
        title: "Play 10 games online",
        description:
          "Jump in against other beginners. Lose fast, learn fast.",
        timeEstimate: "1 week",
      },
      {
        id: "chess-3",
        title: "Study basic tactics",
        description:
          "Forks, pins, skewers — patterns that win you pieces.",
        timeEstimate: "2 weeks",
      },
    ],
    pitfalls: [
      "Don't memorize openings — learn principles instead",
      "Always ask 'what is my opponent threatening?' each move",
      "Puzzles improve your play faster than just playing games",
    ],
  },
];

export function getHobbyById(id: string): HobbyData | undefined {
  return hobbies.find((h) => h.id === id);
}
