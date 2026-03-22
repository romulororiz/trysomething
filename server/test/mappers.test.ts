import { describe, it, expect } from "vitest";
import {
  mapHobby,
  mapCategory,
  mapFaqItem,
  mapCostBreakdown,
  mapBudgetAlternative,
  mapCombo,
  groupByField,
} from "../lib/mappers";

describe("mapHobby", () => {
  const prismaHobby = {
    id: "pottery",
    title: "Pottery",
    hook: "Get your hands dirty.",
    categoryId: "creative",
    imageUrl: "https://example.com/img.jpg",
    tags: ["creative", "relaxing"],
    costText: "CHF 40–120",
    timeText: "2h/week",
    difficultyText: "Moderate",
    whyLove: "Satisfying.",
    difficultyExplain: "Takes practice.",
    pitfalls: ["Impatience"],
    sortOrder: 0,
    kitItems: [
      {
        id: "kit1",
        hobbyId: "pottery",
        name: "Clay",
        description: "Air-dry clay",
        cost: 10,
        isOptional: false,
        sortOrder: 1,
      },
      {
        id: "kit2",
        hobbyId: "pottery",
        name: "Tools",
        description: "Basic set",
        cost: 15,
        isOptional: true,
        sortOrder: 0,
      },
    ],
    roadmapSteps: [
      {
        id: "step1",
        hobbyId: "pottery",
        title: "First pot",
        description: "Make a pinch pot",
        estimatedMinutes: 60,
        milestone: "First piece",
        coachTip: "Cut the clay in half to check for air bubbles.",
        completionMessage: "Your first pinch pot! The shape doesn't matter.",
        sortOrder: 0,
      },
    ],
  };

  it("renames categoryId to category", () => {
    const result = mapHobby(prismaHobby);
    expect(result.category).toBe("creative");
    expect((result as any).categoryId).toBeUndefined();
  });

  it("renames kitItems to starterKit", () => {
    const result = mapHobby(prismaHobby);
    expect(result.starterKit).toBeDefined();
    expect((result as any).kitItems).toBeUndefined();
    expect(result.starterKit).toHaveLength(2);
  });

  it("sorts starterKit by sortOrder", () => {
    const result = mapHobby(prismaHobby);
    expect(result.starterKit[0].name).toBe("Tools"); // sortOrder 0
    expect(result.starterKit[1].name).toBe("Clay"); // sortOrder 1
  });

  it("strips id, hobbyId, sortOrder from kit items", () => {
    const result = mapHobby(prismaHobby);
    const kit = result.starterKit[0] as any;
    expect(kit.id).toBeUndefined();
    expect(kit.hobbyId).toBeUndefined();
    expect(kit.sortOrder).toBeUndefined();
    expect(kit.name).toBeDefined();
    expect(kit.cost).toBeDefined();
  });

  it("strips hobbyId, sortOrder from roadmap steps but keeps id", () => {
    const result = mapHobby(prismaHobby);
    const step = result.roadmapSteps[0] as any;
    expect(step.id).toBe("step1");
    expect(step.hobbyId).toBeUndefined();
    expect(step.sortOrder).toBeUndefined();
  });

  it("strips sortOrder from hobby", () => {
    const result = mapHobby(prismaHobby) as any;
    expect(result.sortOrder).toBeUndefined();
  });
});

describe("mapCategory", () => {
  it("strips sortOrder and adds count", () => {
    const result = mapCategory({
      id: "creative",
      name: "Creative",
      imageUrl: "https://example.com/img.jpg",
      sortOrder: 0,
      _count: { hobbies: 5 },
    });
    expect(result.count).toBe(5);
    expect((result as any).sortOrder).toBeUndefined();
    expect((result as any)._count).toBeUndefined();
  });

  it("defaults count to 0 when _count missing", () => {
    const result = mapCategory({
      id: "creative",
      name: "Creative",
      imageUrl: "https://example.com/img.jpg",
      sortOrder: 0,
    });
    expect(result.count).toBe(0);
  });
});

describe("mapFaqItem", () => {
  it("includes id, strips hobbyId, includes helpfulCount", () => {
    const result = mapFaqItem({
      id: "faq1",
      hobbyId: "pottery",
      question: "How?",
      answer: "Like this.",
      upvotes: 42,
      helpfulCount: 7,
    }) as any;
    expect(result.id).toBe("faq1");
    expect(result.question).toBe("How?");
    expect(result.upvotes).toBe(42);
    expect(result.helpfulCount).toBe(7);
    expect(result.hobbyId).toBeUndefined();
  });
});

describe("mapCostBreakdown", () => {
  it("strips id and hobbyId", () => {
    const result = mapCostBreakdown({
      id: "cb1",
      hobbyId: "pottery",
      starter: 35,
      threeMonth: 125,
      oneYear: 380,
      tips: ["Tip 1"],
    }) as any;
    expect(result.starter).toBe(35);
    expect(result.tips).toEqual(["Tip 1"]);
    expect(result.id).toBeUndefined();
    expect(result.hobbyId).toBeUndefined();
  });
});

describe("mapBudgetAlternative", () => {
  it("strips id, hobbyId, sortOrder", () => {
    const result = mapBudgetAlternative({
      id: "ba1",
      hobbyId: "pottery",
      itemName: "Clay",
      diyOption: "Flour dough",
      diyCost: 2,
      budgetOption: "DAS clay",
      budgetCost: 8,
      premiumOption: "Amaco",
      premiumCost: 25,
      sortOrder: 0,
    }) as any;
    expect(result.itemName).toBe("Clay");
    expect(result.id).toBeUndefined();
    expect(result.hobbyId).toBeUndefined();
    expect(result.sortOrder).toBeUndefined();
  });
});

describe("mapCombo", () => {
  it("strips id", () => {
    const result = mapCombo({
      id: "c1",
      hobbyId1: "pottery",
      hobbyId2: "calligraphy",
      reason: "Both creative",
      sharedTags: ["creative"],
    }) as any;
    expect(result.hobbyId1).toBe("pottery");
    expect(result.id).toBeUndefined();
  });
});

describe("groupByField", () => {
  it("groups rows by key field", () => {
    const rows = [
      { id: "1", mood: "Stressed", hobbyId: "pottery" },
      { id: "2", mood: "Stressed", hobbyId: "hiking" },
      { id: "3", mood: "Bored", hobbyId: "chess" },
    ];
    const result = groupByField(rows, "mood", "hobbyId");
    expect(result).toEqual({
      Stressed: ["pottery", "hiking"],
      Bored: ["chess"],
    });
  });
});
