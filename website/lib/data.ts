/**
 * TrySomething — Landing page data
 */

export interface ShowcaseSlide {
  id: string;
  label: string;
  title: string;
  description: string;
  gradient: string;
  features: string[];
}

export const showcaseSlides: ShowcaseSlide[] = [
  {
    id: "discover",
    label: "Discover",
    title: "One perfect match",
    description:
      "Not 500 options. One hobby matched to your time, budget, and energy. Swipe through personalized picks or search naturally.",
    gradient: "from-teal-900/40 via-transparent to-transparent",
    features: ["Personalized matching", "Natural search", "Budget filters"],
  },
  {
    id: "detail",
    label: "Hobby Detail",
    title: "Everything before day one",
    description:
      "Starter kit with exact costs. A 4-week roadmap. Common pitfalls to avoid. Real answers, not Pinterest boards.",
    gradient: "from-amber-900/30 via-transparent to-transparent",
    features: ["Starter kit & costs", "Step-by-step roadmap", "Beginner pitfalls"],
  },
  {
    id: "home",
    label: "Home",
    title: "Your next step, always clear",
    description:
      "One active hobby. One clear action. A weekly plan that adapts. No overwhelm, just momentum.",
    gradient: "from-rose-900/30 via-transparent to-transparent",
    features: ["Next step focus", "Weekly plan", "Progress tracking"],
  },
  {
    id: "coach",
    label: "Coach",
    title: "A coach that notices",
    description:
      "AI that knows your hobby, your progress, and when you're about to quit. It sends the right message at the right time.",
    gradient: "from-violet-900/30 via-transparent to-transparent",
    features: ["Context-aware AI", "Rescue mode", "Personalized nudges"],
  },
  {
    id: "session",
    label: "Session",
    title: "Immersive practice",
    description:
      "Full-screen focus mode with a guided timer. Reflect on what worked. Mark the step complete. Feel the progress.",
    gradient: "from-emerald-900/30 via-transparent to-transparent",
    features: ["Guided timer", "Reflection prompts", "Progress celebration"],
  },
];

export interface Testimonial {
  quote: string;
  name: string;
  hobby: string;
  duration: string;
}

export const testimonials: Testimonial[] = [
  {
    quote:
      "I\u2019d been meaning to try pottery for three years. TrySomething got me to a wheel in 48 hours.",
    name: "Mara K.",
    hobby: "Pottery",
    duration: "Week 4",
  },
  {
    quote:
      "The roadmap changed everything. I didn\u2019t have to figure out what to do next\u2014it was just there, waiting.",
    name: "Jonas R.",
    hobby: "Bouldering",
    duration: "Week 3",
  },
  {
    quote:
      "I almost quit watercolors after one bad session. The coach sent the exact message I needed to pick up the brush again.",
    name: "Lena S.",
    hobby: "Watercolor",
    duration: "Week 2",
  },
  {
    quote:
      "No app has ever understood that I have exactly 45 minutes on Tuesday evenings and CHF 30 to spare. This one does.",
    name: "David M.",
    hobby: "Sourdough",
    duration: "Week 6",
  },
  {
    quote:
      "I\u2019ve downloaded hobby apps before. This is the first one that helped me actually finish something.",
    name: "Sophie T.",
    hobby: "Guitar",
    duration: "Week 4",
  },
];

export const problemCards = [
  {
    number: "47",
    label: "hobbies saved",
    question: "How many have you started?",
    detail: "You\u2019ve bookmarked pottery, guitar, climbing, baking, drawing\u2026 and opened none of them.",
  },
  {
    number: "1",
    label: "attempt made",
    question: "What made you stop?",
    detail: "You bought supplies once. Tried once. Something felt off. The supplies are in a closet now.",
  },
  {
    number: "\u221E",
    label: "feeds scrolled",
    question: "When does it become doing?",
    detail: "Another video. Another listicle. Another \u201CYou should try this!\u201D that goes nowhere.",
  },
];

export const howItWorksSteps = [
  {
    step: "01",
    title: "Match",
    headline: "Find what fits your life",
    description:
      "Answer a few honest questions about your time, budget, and energy. We match you with one hobby that actually fits\u2014not 500 options to scroll through.",
    accent: "burgundy",
  },
  {
    step: "02",
    title: "Start",
    headline: "Begin in under an hour",
    description:
      "Get a starter kit with exact costs, a step-by-step first session, and answers to every beginner question. No research rabbit holes.",
    accent: "coral",
  },
  {
    step: "03",
    title: "Stay",
    headline: "Keep going for 30 days",
    description:
      "A weekly plan that adapts. An AI coach that notices when you stall. Reflection prompts that make progress visible. The quitting point never arrives.",
    accent: "burgundy",
  },
  {
    step: "04",
    title: "Grow",
    headline: "Make it part of your life",
    description:
      "Advanced roadmaps, community connections, and new challenges. What started as \u201Cmaybe\u201D becomes \u201Cthis is my thing.\u201D",
    accent: "coral",
  },
];
