import '../../models/social.dart';

/// Repository interface for social features: stories, buddies, similar users.
abstract class SocialRepository {
  // Stories
  Future<List<CommunityStory>> getStories();
  Future<CommunityStory> createStory({required String quote, required String hobbyId});
  Future<void> deleteStory(String storyId);
  Future<void> addReaction({required String storyId, required String type});
  Future<void> removeReaction({required String storyId, required String type});

  // Buddies
  Future<Map<String, dynamic>> getBuddiesWithActivity();
  Future<List<BuddyRequest>> getBuddyRequests();
  Future<BuddyRequest> sendBuddyRequest({required String targetUserId, String? hobbyId});
  Future<void> respondToRequest({required String requestId, required String status});
  Future<void> cancelRequest(String requestId);

  // Similar users
  Future<List<NearbyUser>> getSimilarUsers({String? hobbyId});
}
