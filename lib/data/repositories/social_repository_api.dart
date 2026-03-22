import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../models/social.dart';
import 'social_repository.dart';

/// API-backed social repository.
class SocialRepositoryApi implements SocialRepository {
  final Dio _dio = ApiClient.instance;

  // ── Stories ────────────────────────────────────

  @override
  Future<List<CommunityStory>> getStories() async {
    final response = await _dio.get(ApiConstants.usersStories);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => CommunityStory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CommunityStory> createStory({
    required String quote,
    required String hobbyId,
  }) async {
    final response = await _dio.post(
      ApiConstants.usersStories,
      data: {'quote': quote, 'hobbyId': hobbyId},
    );
    return CommunityStory.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    await _dio.delete(ApiConstants.usersStory(storyId));
  }

  @override
  Future<void> addReaction({
    required String storyId,
    required String type,
  }) async {
    await _dio.post(ApiConstants.usersStoryReact(storyId, type));
  }

  @override
  Future<void> removeReaction({
    required String storyId,
    required String type,
  }) async {
    await _dio.delete(ApiConstants.usersStoryReact(storyId, type));
  }

  // ── Buddies ────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getBuddiesWithActivity() async {
    final response = await _dio.get(ApiConstants.usersBuddies);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<BuddyRequest>> getBuddyRequests() async {
    final response = await _dio.get(ApiConstants.usersBuddyRequests);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => BuddyRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BuddyRequest> sendBuddyRequest({
    required String targetUserId,
    String? hobbyId,
  }) async {
    final response = await _dio.post(
      ApiConstants.usersBuddyRequests,
      data: {
        'targetUserId': targetUserId,
        if (hobbyId != null) 'hobbyId': hobbyId,
      },
    );
    return BuddyRequest.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> respondToRequest({
    required String requestId,
    required String status,
  }) async {
    await _dio.put(
      ApiConstants.usersBuddyRequest(requestId),
      data: {'status': status},
    );
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    await _dio.delete(ApiConstants.usersBuddyRequest(requestId));
  }
}
