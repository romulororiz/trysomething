# Testing Patterns

**Analysis Date:** 2026-03-02

## Test Framework

**Runner:**
- `flutter_test` (built-in, no separate runner package)
- Config: `pubspec.yaml` includes `flutter_test:` under `sdk: flutter`

**Assertion Library:**
- Dart `test` package assertions (provided by `flutter_test`)
- Common matchers: `expect()`, `isTrue`, `isFalse`, `isEmpty`, `isNotEmpty`, `isNull`, `isNotNull`, `contains()`, `lessThanOrEqualTo()`

**Run Commands:**
```bash
flutter test test/unit/                 # Run all unit tests
flutter test test/unit/providers/       # Run tests in specific directory
flutter test --watch                    # Watch mode (re-run on file change)
flutter test --coverage                 # Generate coverage data
```

## Test File Organization

**Location:**
- Co-located with source: Tests live in `test/unit/` directory parallel to `lib/`
- Not: Tests alongside source files

**Naming:**
- Test files: `*_test.dart` suffix (e.g., `user_hobbies_notifier_test.dart`, `hobby_repository_test.dart`)
- Match source directory structure: `test/unit/providers/`, `test/unit/repositories/`, `test/unit/models/`

**Structure:**
```
test/
└── unit/
    ├── models/
    │   ├── hobby_serialization_test.dart
    │   ├── features_serialization_test.dart
    │   └── social_serialization_test.dart
    ├── providers/
    │   └── user_hobbies_notifier_test.dart
    └── repositories/
        ├── hobby_repository_test.dart
        └── hobby_api_json_test.dart
```

## Test Structure

**Suite Organization:**
```dart
void main() {
  late SharedPreferences prefs;
  late MockUserProgressRepository mockRepo;
  late UserHobbiesNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockRepo = MockUserProgressRepository();
    notifier = UserHobbiesNotifier(prefs, mockRepo);
  });

  group('UserHobbiesNotifier', () {
    test('starts with empty state', () {
      expect(notifier.state, isEmpty);
    });

    group('optimistic rollback', () {
      test('saveHobby rolls back on API failure', () async {
        mockRepo.shouldFail = true;
        notifier.saveHobby('pottery');

        // Wait for async failure + rollback
        await Future.delayed(const Duration(milliseconds: 50));
        expect(notifier.state.containsKey('pottery'), isFalse);
      });
    });
  });
}
```

**Patterns:**
- `setUp()`: Initialize shared test fixtures (database, mocks, notifiers)
- `tearDown()`: Cleanup resources (dispose controllers, clear caches)
- `group()`: Organize related tests semantically
- `test()`: Individual test case with descriptive name starting with verb

**Async Testing Pattern:**
```dart
test('saveHobby fires API call', () async {
  notifier.saveHobby('pottery');
  // Wait for async API call to complete
  await Future.delayed(Duration.zero);
  expect(mockRepo.calls, contains('saveHobby:pottery'));
});
```

## Mocking

**Framework:** Hand-written mocks (no external mocking library)

**Pattern:**
```dart
/// Mock repository that tracks calls and can be configured to fail.
class MockUserProgressRepository implements UserProgressRepository {
  bool shouldFail = false;
  final List<String> calls = [];

  @override
  Future<List<UserHobby>> getHobbies() async {
    calls.add('getHobbies');
    if (shouldFail) throw Exception('mock failure');
    return [];
  }

  @override
  Future<UserHobby> saveHobby(String hobbyId) async {
    calls.add('saveHobby:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved);
  }
}
```

**What to Mock:**
- Repository interfaces (API calls, database calls)
- External services (SharedPreferences, secure storage)
- Time-dependent operations (via `Future.delayed()`)

**What NOT to Mock:**
- Model classes (use real instances)
- Freezed-generated code (fromJson/toJson)
- Pure functions and utility methods

## Fixtures and Factories

**Test Data:**
```dart
final hobby = Hobby(
  id: 'pottery',
  title: 'Pottery',
  hook: 'Shape clay into art',
  category: 'Creative',
  imageUrl: 'https://example.com/pottery.jpg',
  tags: ['relaxing', 'creative', 'hands-on'],
  costText: 'CHF 50',
  timeText: '3h/week',
  difficultyText: 'Beginner',
  whyLove: 'Mindful and meditative',
  difficultyExplain: 'Easy to start',
  starterKit: [
    KitItem(name: 'Clay', description: '2kg air-dry', cost: 15),
    KitItem(name: 'Tools', description: 'Basic set', cost: 25, isOptional: true),
  ],
  pitfalls: ['Drying too fast', 'Uneven thickness'],
  roadmapSteps: [
    RoadmapStep(
      id: 'step1',
      title: 'Pinch pot',
      description: 'Make your first pinch pot',
      estimatedMinutes: 30,
      milestone: 'First pot!',
    ),
  ],
);
```

**Location:**
- Inline in test file (small datasets)
- Helper classes in same file (see `_ServerDataRepo` in `user_hobbies_notifier_test.dart`)
- Not extracted to separate fixtures/ directory (none in codebase)

## Coverage

**Requirements:** None enforced

**View Coverage:**
```bash
flutter test --coverage
lcov --list coverage/lcov.info  # If lcov installed
```

**Current State:**
- 6 test files with ~897 lines total
- Coverage: not measured/enforced
- Key areas tested: Serialization, repositories, state management

## Test Types

**Unit Tests:**
- Scope: Single class in isolation
- Approach: Mock dependencies, test state transitions
- Examples:
  - `user_hobbies_notifier_test.dart` — Tests `UserHobbiesNotifier` state management
  - `hobby_repository_test.dart` — Tests `HobbyRepositoryImpl` methods
  - Model serialization tests — Test Freezed `fromJson`/`toJson`

**Integration Tests:**
- Not used in this codebase
- Would test: API client + repository + notifier together

**E2E Tests:**
- Not used in this codebase
- Would use: `flutter_test` with `WidgetTester` to test full app flow

## Common Patterns

**Async Testing:**
```dart
test('saveHobby rolls back on API failure', () async {
  mockRepo.shouldFail = true;
  notifier.saveHobby('pottery');
  expect(notifier.state.containsKey('pottery'), isTrue);

  // Wait for async failure + rollback
  await Future.delayed(const Duration(milliseconds: 50));
  expect(notifier.state.containsKey('pottery'), isFalse);
});
```

**Error Testing (Throwing Exceptions):**
```dart
test('getHobbies throws on repository failure', () async {
  mockRepo.shouldFail = true;
  expect(
    () => mockRepo.getHobbies(),
    throwsException,
  );
});
```

**State Transition Testing:**
```dart
test('startTrying changes status to trying', () {
  notifier.saveHobby('pottery');
  notifier.startTrying('pottery');
  expect(notifier.state['pottery']!.status, HobbyStatus.trying);
  expect(notifier.state['pottery']!.startedAt, isNotNull);
});
```

**Collection Testing:**
```dart
test('getByStatus filters correctly', () {
  notifier.saveHobby('pottery');
  notifier.saveHobby('bouldering');
  notifier.startTrying('pottery');

  final saved = notifier.getByStatus(HobbyStatus.saved);
  final trying = notifier.getByStatus(HobbyStatus.trying);
  expect(saved.length, 1);
  expect(saved.first.hobbyId, 'bouldering');
  expect(trying.length, 1);
  expect(trying.first.hobbyId, 'pottery');
});
```

**JSON Serialization Testing (Round-trip):**
```dart
test('round-trips through JSON', () {
  final hobby = Hobby(
    id: 'pottery',
    title: 'Pottery',
    // ... fields
  );

  final json = hobby.toJson();
  final restored = Hobby.fromJson(json);

  expect(restored.id, hobby.id);
  expect(restored.title, hobby.title);
  expect(restored.tags, hobby.tags);
  expect(restored.starterKit.length, 2);
});
```

**API Response Shape Testing:**
```dart
test('parses hobby with category (not categoryId)', () {
  final json = {
    'id': 'pottery',
    'title': 'Pottery',
    'category': 'creative',  // Field name from API mapper
    'starterKit': [          // Field name from API mapper
      {
        'name': 'Clay',
        'description': 'Air-dry clay',
        'cost': 10,
        'isOptional': false,
      },
    ],
    // ... other fields
  };

  final hobby = Hobby.fromJson(json);
  expect(hobby.id, 'pottery');
  expect(hobby.category, 'creative');
  expect(hobby.starterKit.length, 1);
});
```

**Helper Repository (for Server Data Scenarios):**
```dart
class _ServerDataRepo implements UserProgressRepository {
  final List<UserHobby> _serverHobbies;
  _ServerDataRepo(this._serverHobbies);

  @override
  Future<List<UserHobby>> getHobbies() async => _serverHobbies;

  @override
  Future<UserHobby> saveHobby(String hobbyId) async =>
      UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved);

  // ... other methods
}
```

## Test Coverage Gaps

**Current Untested Areas:**
- Widget tests (no integration tests)
- GoRouter redirect behavior
- Dio interceptor and token refresh flow
- Hive caching layer
- Feature providers (journal, scheduler, notes, challenge)
- Habit detail screen interactions
- Search and filter behavior

**Priority for Future Testing:**
1. Critical flows: Auth login/register, hobby save/unsave, status transitions
2. API integration: Responses, error handling, token refresh
3. Data persistence: SharedPreferences and Hive sync
4. Feature state: Journal, scheduler, shopping list CRUD

## Running Tests

**All tests:**
```bash
flutter test
```

**Specific test file:**
```bash
flutter test test/unit/providers/user_hobbies_notifier_test.dart
```

**Verbose output:**
```bash
flutter test -v
```

**Stop on first failure:**
```bash
flutter test --bail
```

---

*Testing analysis: 2026-03-02*
