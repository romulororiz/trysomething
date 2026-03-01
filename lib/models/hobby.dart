// ═══════════════════════════════════════════════════════
//  HOBBY MODEL
// ═══════════════════════════════════════════════════════

class Hobby {
  final String id;
  final String title;
  final String hook;
  final String category;
  final String imageUrl;
  final List<String> tags;
  final String costText;
  final String timeText;
  final String difficultyText;
  final String whyLove;
  final String difficultyExplain;
  final List<KitItem> starterKit;
  final List<String> pitfalls;
  final List<RoadmapStep> roadmapSteps;

  const Hobby({
    required this.id,
    required this.title,
    required this.hook,
    required this.category,
    required this.imageUrl,
    required this.tags,
    required this.costText,
    required this.timeText,
    required this.difficultyText,
    required this.whyLove,
    required this.difficultyExplain,
    required this.starterKit,
    required this.pitfalls,
    required this.roadmapSteps,
  });
}

// ═══════════════════════════════════════════════════════
//  KIT ITEM MODEL
// ═══════════════════════════════════════════════════════

class KitItem {
  final String name;
  final String description;
  final int cost;
  final bool isOptional;

  const KitItem({
    required this.name,
    required this.description,
    required this.cost,
    this.isOptional = false,
  });
}

// ═══════════════════════════════════════════════════════
//  ROADMAP STEP MODEL
// ═══════════════════════════════════════════════════════

class RoadmapStep {
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String? milestone;

  const RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    this.milestone,
  });
}

// ═══════════════════════════════════════════════════════
//  HOBBY CATEGORY MODEL
// ═══════════════════════════════════════════════════════

class HobbyCategory {
  final String id;
  final String name;
  final int count;
  final String imageUrl;

  const HobbyCategory({
    required this.id,
    required this.name,
    required this.count,
    required this.imageUrl,
  });
}

// ═══════════════════════════════════════════════════════
//  USER STATE MODELS
// ═══════════════════════════════════════════════════════

enum HobbyStatus { saved, trying, active, done }

class UserHobby {
  final String hobbyId;
  final HobbyStatus status;
  final Set<String> completedStepIds;
  final DateTime? startedAt;
  final DateTime? lastActivityAt;
  final int streakDays;

  const UserHobby({
    required this.hobbyId,
    required this.status,
    this.completedStepIds = const {},
    this.startedAt,
    this.lastActivityAt,
    this.streakDays = 0,
  });

  UserHobby copyWith({
    HobbyStatus? status,
    Set<String>? completedStepIds,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    int? streakDays,
  }) {
    return UserHobby(
      hobbyId: hobbyId,
      status: status ?? this.status,
      completedStepIds: completedStepIds ?? this.completedStepIds,
      startedAt: startedAt ?? this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  double progressPercent(int totalSteps) {
    if (totalSteps == 0) return 0;
    return completedStepIds.length / totalSteps;
  }
}

class UserPreferences {
  final int hoursPerWeek;
  final int budgetLevel; // 0 = low, 1 = medium, 2 = high
  final bool preferSocial;
  final Set<String> vibes; // creative, physical, relaxing, technical, outdoors, competitive

  const UserPreferences({
    this.hoursPerWeek = 3,
    this.budgetLevel = 1,
    this.preferSocial = false,
    this.vibes = const {},
  });

  UserPreferences copyWith({
    int? hoursPerWeek,
    int? budgetLevel,
    bool? preferSocial,
    Set<String>? vibes,
  }) {
    return UserPreferences(
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      preferSocial: preferSocial ?? this.preferSocial,
      vibes: vibes ?? this.vibes,
    );
  }
}
