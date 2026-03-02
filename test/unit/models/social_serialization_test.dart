import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/social.dart';

void main() {
  group('JournalEntry serialization', () {
    test('round-trips through JSON', () {
      final entry = JournalEntry(
        id: 'j1',
        hobbyId: 'pottery',
        text: 'Made my first pot!',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime(2026, 2, 15, 14, 30),
      );
      final json = entry.toJson();
      final restored = JournalEntry.fromJson(json);

      expect(restored.id, 'j1');
      expect(restored.text, 'Made my first pot!');
      expect(restored.photoUrl, 'https://example.com/photo.jpg');
    });

    test('handles null photoUrl', () {
      final entry = JournalEntry(
        id: 'j2',
        hobbyId: 'guitar',
        text: 'First chords',
        createdAt: DateTime(2026, 3, 1),
      );
      final json = entry.toJson();
      final restored = JournalEntry.fromJson(json);

      expect(restored.photoUrl, isNull);
    });
  });

  group('BuddyProfile serialization', () {
    test('round-trips through JSON', () {
      final buddy = BuddyProfile(
        id: 'b1',
        name: 'Alice',
        avatarInitial: 'A',
        currentHobbyId: 'pottery',
        progress: 0.65,
      );
      final json = buddy.toJson();
      final restored = BuddyProfile.fromJson(json);

      expect(restored.name, 'Alice');
      expect(restored.progress, 0.65);
    });
  });

  group('BuddyActivity serialization', () {
    test('round-trips through JSON', () {
      final activity = BuddyActivity(
        userId: 'user1',
        text: 'Completed step 3',
        timestamp: DateTime(2026, 2, 20, 10, 0),
      );
      final json = activity.toJson();
      final restored = BuddyActivity.fromJson(json);

      expect(restored.userId, 'user1');
      expect(restored.text, 'Completed step 3');
    });
  });

  group('CommunityStory serialization', () {
    test('round-trips through JSON with reactions map', () {
      final story = CommunityStory(
        id: 's1',
        authorName: 'Bob',
        authorInitial: 'B',
        quote: 'Pottery changed my life',
        hobbyId: 'pottery',
        reactions: {'heart': 12, 'fire': 5},
      );
      final json = story.toJson();
      final restored = CommunityStory.fromJson(json);

      expect(restored.authorName, 'Bob');
      expect(restored.reactions['heart'], 12);
      expect(restored.reactions['fire'], 5);
    });

    test('defaults to empty reactions', () {
      final story = CommunityStory(
        id: 's2',
        authorName: 'Eve',
        authorInitial: 'E',
        quote: 'Love it',
        hobbyId: 'guitar',
      );
      expect(story.reactions, isEmpty);
    });
  });

  group('NearbyUser serialization', () {
    test('round-trips through JSON', () {
      final user = NearbyUser(
        name: 'Charlie',
        avatarInitial: 'C',
        hobbyId: 'bouldering',
        distance: '1.2 km',
        startedText: '3 weeks ago',
      );
      final json = user.toJson();
      final restored = NearbyUser.fromJson(json);

      expect(restored.name, 'Charlie');
      expect(restored.distance, '1.2 km');
    });
  });
}
