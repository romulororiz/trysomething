import 'package:freezed_annotation/freezed_annotation.dart';

part 'social.freezed.dart';
part 'social.g.dart';

// ═══════════════════════════════════════════════════════
//  SOCIAL & COMMUNITY MODELS
// ═══════════════════════════════════════════════════════

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String hobbyId,
    required String text,
    String? photoUrl,
    required DateTime createdAt,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}

@freezed
class BuddyProfile with _$BuddyProfile {
  const factory BuddyProfile({
    required String id,
    required String name,
    required String avatarInitial,
    required String currentHobbyId,
    required double progress,
  }) = _BuddyProfile;

  factory BuddyProfile.fromJson(Map<String, dynamic> json) =>
      _$BuddyProfileFromJson(json);
}

@freezed
class BuddyActivity with _$BuddyActivity {
  const factory BuddyActivity({
    required String userId,
    required String text,
    required DateTime timestamp,
  }) = _BuddyActivity;

  factory BuddyActivity.fromJson(Map<String, dynamic> json) =>
      _$BuddyActivityFromJson(json);
}

@freezed
class CommunityStory with _$CommunityStory {
  const factory CommunityStory({
    required String id,
    required String authorName,
    required String authorInitial,
    required String quote,
    required String hobbyId,
    @Default({}) Map<String, int> reactions,
  }) = _CommunityStory;

  factory CommunityStory.fromJson(Map<String, dynamic> json) =>
      _$CommunityStoryFromJson(json);
}

@freezed
class NearbyUser with _$NearbyUser {
  const factory NearbyUser({
    required String name,
    required String avatarInitial,
    required String hobbyId,
    required String distance,
    required String startedText,
  }) = _NearbyUser;

  factory NearbyUser.fromJson(Map<String, dynamic> json) =>
      _$NearbyUserFromJson(json);
}
