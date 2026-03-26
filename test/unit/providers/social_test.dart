import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/data/repositories/social_repository.dart';
import 'package:trysomething/models/social.dart';
import 'package:trysomething/providers/feature_providers.dart';

/// Mock repository that tracks calls and can be configured to fail.
class MockSocialRepository implements SocialRepository {
  bool shouldFail = false;
  final List<String> calls = [];

  List<CommunityStory> serverStories = [];
  Map<String, dynamic> serverBuddyData = {'profiles': [], 'activities': []};
  List<BuddyRequest> serverRequests = [];
  List<NearbyUser> serverSimilarUsers = [];

  @override
  Future<List<CommunityStory>> getStories() async {
    calls.add('getStories');
    if (shouldFail) throw Exception('mock failure');
    return serverStories;
  }

  @override
  Future<CommunityStory> createStory({
    required String quote,
    required String hobbyId,
  }) async {
    calls.add('createStory:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return CommunityStory(
      id: 'server_story_1',
      authorName: 'TestUser',
      authorInitial: 'T',
      quote: quote,
      hobbyId: hobbyId,
      reactions: const {'heart': 0, 'fire': 0},
    );
  }

  @override
  Future<void> deleteStory(String storyId) async {
    calls.add('deleteStory:$storyId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<void> addReaction({
    required String storyId,
    required String type,
  }) async {
    calls.add('addReaction:$storyId:$type');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<void> removeReaction({
    required String storyId,
    required String type,
  }) async {
    calls.add('removeReaction:$storyId:$type');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<Map<String, dynamic>> getBuddiesWithActivity() async {
    calls.add('getBuddiesWithActivity');
    if (shouldFail) throw Exception('mock failure');
    return serverBuddyData;
  }

  @override
  Future<List<BuddyRequest>> getBuddyRequests() async {
    calls.add('getBuddyRequests');
    if (shouldFail) throw Exception('mock failure');
    return serverRequests;
  }

  @override
  Future<BuddyRequest> sendBuddyRequest({
    required String targetUserId,
    String? hobbyId,
  }) async {
    calls.add('sendBuddyRequest:$targetUserId');
    if (shouldFail) throw Exception('mock failure');
    return BuddyRequest(
      id: 'req_1',
      userId: targetUserId,
      name: 'Test Buddy',
      avatarInitial: 'T',
      hobbyId: hobbyId,
      status: 'pending',
      direction: 'sent',
      createdAt: DateTime(2026, 3, 2),
    );
  }

  @override
  Future<void> respondToRequest({
    required String requestId,
    required String status,
  }) async {
    calls.add('respondToRequest:$requestId:$status');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    calls.add('cancelRequest:$requestId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<List<NearbyUser>> getSimilarUsers({String? hobbyId}) async {
    calls.add('getSimilarUsers');
    if (shouldFail) throw Exception('mock failure');
    return serverSimilarUsers;
  }
}

void main() {
  // ═══════════════════════════════════════════════════════
  //  STORIES
  // ═══════════════════════════════════════════════════════

  group('StoriesNotifier', () {
    late MockSocialRepository repo;
    late StoriesNotifier notifier;

    setUp(() {
      repo = MockSocialRepository();
      notifier = StoriesNotifier(repo);
    });

    test('loadFromServer populates state', () async {
      repo.serverStories = [
        const CommunityStory(
          id: 's1',
          authorName: 'Alice',
          authorInitial: 'A',
          quote: 'I love painting!',
          hobbyId: 'painting',
          reactions: {'heart': 3, 'fire': 1},
        ),
      ];

      await notifier.loadFromServer();

      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, 's1');
      expect(notifier.state.first.authorName, 'Alice');
    });

    test('loadFromServer handles failure gracefully', () async {
      repo.shouldFail = true;
      await notifier.loadFromServer();
      expect(notifier.state, isEmpty);
    });

    test('createStory optimistically prepends then replaces with server response',
        () async {
      notifier.createStory('Great hobby!', 'cooking');

      // Optimistic: temp entry prepended
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.quote, 'Great hobby!');
      expect(notifier.state.first.id, startsWith('temp_'));

      // Wait for API call to complete
      await Future.delayed(Duration.zero);

      // Replaced with server response
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, 'server_story_1');
      expect(repo.calls, contains('createStory:cooking'));
    });

    test('deleteStory removes optimistically', () async {
      repo.serverStories = [
        const CommunityStory(
          id: 's1',
          authorName: 'Alice',
          authorInitial: 'A',
          quote: 'Test',
          hobbyId: 'h1',
        ),
      ];
      await notifier.loadFromServer();
      expect(notifier.state, hasLength(1));

      notifier.deleteStory('s1');
      expect(notifier.state, isEmpty);
      await Future.delayed(Duration.zero);
      expect(repo.calls, contains('deleteStory:s1'));
    });

    test('deleteStory rolls back on failure', () async {
      repo.serverStories = [
        const CommunityStory(
          id: 's1',
          authorName: 'Alice',
          authorInitial: 'A',
          quote: 'Test',
          hobbyId: 'h1',
        ),
      ];
      await notifier.loadFromServer();

      repo.shouldFail = true;
      notifier.deleteStory('s1');

      // Optimistically removed
      expect(notifier.state, isEmpty);

      // Wait for rollback
      await Future.delayed(Duration.zero);
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, 's1');
    });

    test('toggleReaction adds heart (increments count, adds to userReactions)',
        () async {
      repo.serverStories = [
        const CommunityStory(
          id: 's1',
          authorName: 'Alice',
          authorInitial: 'A',
          quote: 'Test',
          hobbyId: 'h1',
          reactions: {'heart': 2, 'fire': 1},
          userReactions: [],
        ),
      ];
      await notifier.loadFromServer();

      notifier.toggleReaction('s1', 'heart');

      final story = notifier.state.first;
      expect(story.reactions['heart'], 3);
      expect(story.userReactions, contains('heart'));
      await Future.delayed(Duration.zero);
      expect(repo.calls, contains('addReaction:s1:heart'));
    });

    test('toggleReaction removes heart (decrements count, removes from userReactions)',
        () async {
      repo.serverStories = [
        const CommunityStory(
          id: 's1',
          authorName: 'Alice',
          authorInitial: 'A',
          quote: 'Test',
          hobbyId: 'h1',
          reactions: {'heart': 3, 'fire': 1},
          userReactions: ['heart'],
        ),
      ];
      await notifier.loadFromServer();

      notifier.toggleReaction('s1', 'heart');

      final story = notifier.state.first;
      expect(story.reactions['heart'], 2);
      expect(story.userReactions, isNot(contains('heart')));
      await Future.delayed(Duration.zero);
      expect(repo.calls, contains('removeReaction:s1:heart'));
    });

    test('toggleReaction rolls back on API failure', () async {
      repo.serverStories = [
        const CommunityStory(
          id: 's1',
          authorName: 'Alice',
          authorInitial: 'A',
          quote: 'Test',
          hobbyId: 'h1',
          reactions: {'heart': 2, 'fire': 1},
          userReactions: [],
        ),
      ];
      await notifier.loadFromServer();

      repo.shouldFail = true;
      notifier.toggleReaction('s1', 'heart');

      // Optimistically updated
      expect(notifier.state.first.reactions['heart'], 3);

      // Wait for rollback
      await Future.delayed(Duration.zero);
      expect(notifier.state.first.reactions['heart'], 2);
      expect(notifier.state.first.userReactions, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  BUDDIES
  // ═══════════════════════════════════════════════════════

  group('BuddyNotifier', () {
    late MockSocialRepository repo;
    late BuddyNotifier notifier;

    setUp(() {
      repo = MockSocialRepository();
      notifier = BuddyNotifier(repo);
    });

    test('loadFromServer populates profiles, activities, and requests',
        () async {
      repo.serverBuddyData = {
        'profiles': [
          {
            'id': 'bp1',
            'name': 'Marco',
            'avatarInitial': 'M',
            'currentHobbyId': 'cooking',
            'progress': 0.6,
          },
        ],
        'activities': [
          {
            'userId': 'u1',
            'userName': 'Marco',
            'text': 'Started cooking!',
            'timestamp': '2026-03-01T10:00:00.000Z',
          },
        ],
      };
      repo.serverRequests = [
        BuddyRequest(
          id: 'req_1',
          userId: 'u2',
          name: 'Lisa',
          avatarInitial: 'L',
          status: 'pending',
          direction: 'received',
          createdAt: DateTime(2026, 3, 2),
        ),
      ];

      await notifier.loadFromServer();

      expect(notifier.state.profiles, hasLength(1));
      expect(notifier.state.profiles.first.name, 'Marco');
      expect(notifier.state.activities, hasLength(1));
      expect(notifier.state.activities.first.userName, 'Marco');
      expect(notifier.state.pendingRequests, hasLength(1));
      expect(notifier.state.pendingRequests.first.name, 'Lisa');
    });

    test('sendRequest adds request to pending list', () async {
      await notifier.sendRequest('user_123', hobbyId: 'painting');

      expect(notifier.state.pendingRequests, hasLength(1));
      expect(notifier.state.pendingRequests.first.userId, 'user_123');
      expect(repo.calls, contains('sendBuddyRequest:user_123'));
    });

    test('acceptRequest triggers reload', () async {
      repo.serverBuddyData = {'profiles': [], 'activities': []};
      repo.serverRequests = [];

      await notifier.acceptRequest('req_1');

      expect(repo.calls, contains('respondToRequest:req_1:active'));
      // loadFromServer called after accept
      expect(repo.calls, contains('getBuddiesWithActivity'));
    });

    test('rejectRequest removes from pending optimistically', () async {
      repo.serverRequests = [
        BuddyRequest(
          id: 'req_1',
          userId: 'u2',
          name: 'Lisa',
          avatarInitial: 'L',
          status: 'pending',
          direction: 'received',
          createdAt: DateTime(2026, 3, 2),
        ),
      ];
      repo.serverBuddyData = {'profiles': [], 'activities': []};
      await notifier.loadFromServer();
      expect(notifier.state.pendingRequests, hasLength(1));

      notifier.rejectRequest('req_1');
      expect(notifier.state.pendingRequests, isEmpty);

      await Future.delayed(Duration.zero);
      expect(repo.calls, contains('respondToRequest:req_1:rejected'));
    });

    test('rejectRequest rolls back on failure', () async {
      repo.serverRequests = [
        BuddyRequest(
          id: 'req_1',
          userId: 'u2',
          name: 'Lisa',
          avatarInitial: 'L',
          status: 'pending',
          direction: 'received',
          createdAt: DateTime(2026, 3, 2),
        ),
      ];
      repo.serverBuddyData = {'profiles': [], 'activities': []};
      await notifier.loadFromServer();

      repo.shouldFail = true;
      notifier.rejectRequest('req_1');

      // Optimistically removed
      expect(notifier.state.pendingRequests, isEmpty);

      // Wait for rollback
      await Future.delayed(Duration.zero);
      expect(notifier.state.pendingRequests, hasLength(1));
    });

    test('hasRequestFor checks pending requests', () async {
      await notifier.sendRequest('user_123');
      expect(notifier.hasRequestFor('user_123'), isTrue);
      expect(notifier.hasRequestFor('unknown'), isFalse);
    });
  });

}
