// ═══════════════════════════════════════════════════════
//  FEATURE MODELS (Gamification, Utility, Content)
// ═══════════════════════════════════════════════════════

class UserProfile {
  final String username;
  final String bio;
  final String? avatarUrl;

  const UserProfile({
    this.username = 'Your Name',
    this.bio = '',
    this.avatarUrl,
  });

  UserProfile copyWith({String? username, String? bio, String? avatarUrl}) {
    return UserProfile(
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 999);
}

class ScheduleEvent {
  final String id;
  final String hobbyId;
  final int dayOfWeek; // 1=Mon, 7=Sun
  final String startTime; // "19:00"
  final int durationMinutes;

  const ScheduleEvent({
    required this.id,
    required this.hobbyId,
    required this.dayOfWeek,
    required this.startTime,
    required this.durationMinutes,
  });
}

class HobbyCombo {
  final String hobbyId1;
  final String hobbyId2;
  final String reason;
  final List<String> sharedTags;

  const HobbyCombo({
    required this.hobbyId1,
    required this.hobbyId2,
    required this.reason,
    required this.sharedTags,
  });
}

class FaqItem {
  final String question;
  final String answer;
  final int upvotes;

  const FaqItem({
    required this.question,
    required this.answer,
    this.upvotes = 0,
  });
}

class CostBreakdown {
  final int starter;
  final int threeMonth;
  final int oneYear;
  final List<String> tips;

  const CostBreakdown({
    required this.starter,
    required this.threeMonth,
    required this.oneYear,
    this.tips = const [],
  });
}

class BudgetAlternative {
  final String itemName;
  final String diyOption;
  final int diyCost;
  final String budgetOption;
  final int budgetCost;
  final String premiumOption;
  final int premiumCost;

  const BudgetAlternative({
    required this.itemName,
    required this.diyOption,
    required this.diyCost,
    required this.budgetOption,
    required this.budgetCost,
    required this.premiumOption,
    required this.premiumCost,
  });
}
