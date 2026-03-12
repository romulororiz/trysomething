import { describe, it, expect } from "vitest";
import { validateInput, validateOutput } from "../lib/content_guard";

// ---------------------------------------------------------------------------
// Helper: returns a fresh valid hobby object that passes validateOutput.
// Tests can spread/mutate copies without affecting other tests.
// ---------------------------------------------------------------------------
function validHobby(): Record<string, unknown> {
  return {
    title: "Watercolor Painting",
    hook: "Express yourself with paint and paper in just 20 minutes a session.",
    categoryId: "creative",
    costText: "CHF 20-60",
    timeText: "1-2h/week",
    difficultyText: "Easy",
    whyLove: "Calming, portable, and endlessly creative.",
    difficultyExplain: "You only need basic supplies and simple techniques to start.",
    tags: ["creative", "relaxing", "indoor"],
    pitfalls: [
      "Buying too much paint before you know what you like.",
      "Expecting professional results in the first week.",
    ],
    kitItems: [
      { name: "Watercolor set", description: "Student-grade 12-colour pan set", cost: 15 },
      { name: "Watercolor paper", description: "A5 cold-press pad, 300gsm", cost: 10 },
    ],
    roadmapSteps: [
      { title: "First washes", description: "Practice flat and graded washes.", estimatedMinutes: 20 },
      { title: "Simple shapes", description: "Paint basic geometric forms.", estimatedMinutes: 30 },
      { title: "Your first scene", description: "Paint a simple landscape or still life.", estimatedMinutes: 45 },
    ],
  };
}

// ===========================================================================
// validateInput
// ===========================================================================

describe("validateInput", () => {
  it("rejects an empty string", () => {
    const result = validateInput("");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toBe("Query is required");
  });

  it("rejects a whitespace-only string (trims to empty → too short)", () => {
    const result = validateInput("  ");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/too short/i);
  });

  it("rejects a single character", () => {
    const result = validateInput("a");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/too short/i);
  });

  it("accepts exactly 2 characters", () => {
    const result = validateInput("hi");
    expect(result.ok).toBe(true);
  });

  it("accepts exactly 60 characters", () => {
    const query = "a".repeat(60);
    const result = validateInput(query);
    expect(result.ok).toBe(true);
  });

  it("rejects 61 characters", () => {
    const query = "a".repeat(61);
    const result = validateInput(query);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/too long/i);
  });

  it("rejects a query with an exclamation mark", () => {
    const result = validateInput("hello!");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/invalid characters/i);
  });

  it("rejects a query starting with @", () => {
    const result = validateInput("@test");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/invalid characters/i);
  });

  it("accepts a normal multi-word query", () => {
    const result = validateInput("cheap creative hobby");
    expect(result.ok).toBe(true);
  });

  it("accepts hyphens, apostrophes, parentheses, slashes, and commas", () => {
    const result = validateInput("low-key, easy (beginner's) art/craft");
    expect(result.ok).toBe(true);
  });

  it("blocks the word 'gun'", () => {
    const result = validateInput("gun hobby");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/prohibited/i);
  });

  it("blocks the word 'hacking'", () => {
    const result = validateInput("hacking for fun");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/prohibited/i);
  });

  it("blocks blocked terms case-insensitively (GUN)", () => {
    const result = validateInput("GUN collector");
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/prohibited/i);
  });

  it("does NOT block 'knitting' (no whole-word match for any blocked term)", () => {
    const result = validateInput("knitting for beginners");
    expect(result.ok).toBe(true);
  });

  it("does NOT block 'guns' (whole-word boundary: \\bgun\\b won't match 'guns')", () => {
    const result = validateInput("guns hobby");
    expect(result.ok).toBe(true);
  });
});

// ===========================================================================
// validateOutput
// ===========================================================================

describe("validateOutput", () => {
  it("accepts a fully valid hobby object", () => {
    const result = validateOutput(validHobby());
    expect(result.ok).toBe(true);
  });

  it("rejects a hobby missing a required string field (title)", () => {
    const hobby = validHobby();
    delete hobby.title;
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/title/i);
  });

  it("rejects a hobby where a required string field is blank (title = '  ')", () => {
    const hobby = { ...validHobby(), title: "   " };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/title/i);
  });

  it("rejects a title longer than 80 characters", () => {
    const hobby = { ...validHobby(), title: "T".repeat(81) };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/title too long/i);
  });

  it("rejects a hook longer than 150 characters", () => {
    const hobby = { ...validHobby(), hook: "H".repeat(151) };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/hook too long/i);
  });

  it("rejects an invalid categoryId", () => {
    const hobby = { ...validHobby(), categoryId: "extreme-sports" };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/invalid category/i);
  });

  it("rejects an empty tags array", () => {
    const hobby = { ...validHobby(), tags: [] };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/tags/i);
  });

  it("rejects pitfalls with only 1 item (too few)", () => {
    const hobby = { ...validHobby(), pitfalls: ["Only one pitfall."] };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/pitfalls/i);
  });

  it("rejects pitfalls with 6 items (too many)", () => {
    const hobby = {
      ...validHobby(),
      pitfalls: ["p1", "p2", "p3", "p4", "p5", "p6"],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/pitfalls/i);
  });

  it("rejects kitItems with only 1 item (too few)", () => {
    const hobby = {
      ...validHobby(),
      kitItems: [{ name: "Brush", description: "A brush", cost: 5 }],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/kit items/i);
  });

  it("rejects a kit item missing the name field", () => {
    const hobby = {
      ...validHobby(),
      kitItems: [
        { description: "No name here", cost: 5 },
        { name: "Paper", description: "Nice paper", cost: 10 },
      ],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/kit item missing/i);
  });

  it("rejects a kit item with a negative cost", () => {
    const hobby = {
      ...validHobby(),
      kitItems: [
        { name: "Brush", description: "A brush", cost: -1 },
        { name: "Paper", description: "Nice paper", cost: 10 },
      ],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/cost/i);
  });

  it("rejects roadmapSteps with only 2 items (too few)", () => {
    const hobby = {
      ...validHobby(),
      roadmapSteps: [
        { title: "Step 1", description: "Do this.", estimatedMinutes: 20 },
        { title: "Step 2", description: "Do that.", estimatedMinutes: 30 },
      ],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/roadmap/i);
  });

  it("rejects a roadmap step with estimatedMinutes below 15", () => {
    const hobby = {
      ...validHobby(),
      roadmapSteps: [
        { title: "Step 1", description: "Quick intro.", estimatedMinutes: 10 },
        { title: "Step 2", description: "Practice.", estimatedMinutes: 30 },
        { title: "Step 3", description: "Review.", estimatedMinutes: 20 },
      ],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/estimatedMinutes/i);
  });

  it("rejects a roadmap step with estimatedMinutes above 240", () => {
    const hobby = {
      ...validHobby(),
      roadmapSteps: [
        { title: "Step 1", description: "Marathon session.", estimatedMinutes: 241 },
        { title: "Step 2", description: "Follow up.", estimatedMinutes: 30 },
        { title: "Step 3", description: "Review.", estimatedMinutes: 20 },
      ],
    };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/estimatedMinutes/i);
  });

  it("rejects a hobby whose title contains a blocked term", () => {
    const hobby = { ...validHobby(), title: "How to commit fraud for artists" };
    const result = validateOutput(hobby);
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.reason).toMatch(/prohibited/i);
  });
});
