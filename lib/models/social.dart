// ═══════════════════════════════════════════════════════
//  SOCIAL & COMMUNITY MODELS
// ═══════════════════════════════════════════════════════

class JournalEntry {
  final String id;
  final String hobbyId;
  final String text;
  final String? photoUrl;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.hobbyId,
    required this.text,
    this.photoUrl,
    required this.createdAt,
  });
}

class BuddyProfile {
  final String id;
  final String name;
  final String avatarInitial;
  final String currentHobbyId;
  final double progress;

  const BuddyProfile({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.currentHobbyId,
    required this.progress,
  });
}

class BuddyActivity {
  final String userId;
  final String text;
  final DateTime timestamp;

  const BuddyActivity({
    required this.userId,
    required this.text,
    required this.timestamp,
  });
}

class CommunityStory {
  final String id;
  final String authorName;
  final String authorInitial;
  final String quote;
  final String hobbyId;
  final Map<String, int> reactions;

  const CommunityStory({
    required this.id,
    required this.authorName,
    required this.authorInitial,
    required this.quote,
    required this.hobbyId,
    this.reactions = const {},
  });
}

class NearbyUser {
  final String name;
  final String avatarInitial;
  final String hobbyId;
  final String distance;
  final String startedText;

  const NearbyUser({
    required this.name,
    required this.avatarInitial,
    required this.hobbyId,
    required this.distance,
    required this.startedText,
  });
}
