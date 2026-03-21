# Testing Patterns

**Analysis Date:** 2026-03-21

## Test Framework

**Runner:**
- Flutter: `flutter_test` (built-in, configured in `pubspec.yaml`)
- Server: `vitest` v3.0.0 (see `server/package.json` lines 13-14)

**Assertion Library:**
- Dart: `test` package assertions from `flutter_test` — `expect()`, `isTrue`, `isFalse`, `isEmpty`, `isNotEmpty`, `isNull`, `isNotNull`, `contains()`, `lessThanOrEqualTo()`, `throwsException`
- TypeScript: `vitest` built-in `expect()` with matchers like `.toBe()`, `.toEqual()`, `.toBeDefined()`, `.toThrow()`

**Run Commands:**
```bash
# Flutter
flutter test test/unit/                 # Run all unit tests
flutter test test/unit/providers/       # Run tests in specific directory
flutter test --watch                    # Watch mode (re-run on file change)
flutter test --coverage                 # Generate coverage data

# Server
cd server && npm test                   # Run all Vitest tests
npm run test:watch                      # Watch mode
```

## Test File Organization

**Location — Flutter:**
- Separate `test/` directory parallel to `lib/`
- Structure mirrors `lib/` layout: `test/unit/providers/`, `test/unit/repositories/`, `test/unit/models/`, `test/widget/screens/`, `test/golden/components/`

**Location — Server:**
- `server/test/` directory alongside `server/api/`, `server/lib/`, `server/prisma/`
- Test files colocated by feature: `server/test/auth.test.ts`, `server/test/routes_users.test.ts`, `server/test/content_guard.test.ts`

**Naming:**
- Test files: `*_test.dart` suffix (Flutter) or `.test.ts` suffix (TypeScript)
- Examples: `user_hobbies_notifier_test.dart`, `hobby_repository_test.dart`, `auth.test.ts`, `middleware.test.ts`
- Match source directory structure

**Structure — Flutter:**
```
test/
├── unit/
│   ├── core/
│   │   ├── analytics_service_test.dart
│   │   ├── error_reporter_test.dart
│   │   ├── hobby_match_test.dart
│   │   └── notification_service_test.dart
│   ├── models/
│   │   ├── auth_serialization_test.dart
│   │   ├── hobby_serialization_test.dart
│   │   └── ...
│   ├── providers/
│   │   ├── auth_provider_test.dart
│   │   ├── session_provider_test.dart
│   │   └── ...
│   └── repositories/
│       ├── auth_repository_api_test.dart
│       └── hobby_repository_test.dart
├── widget/
│   ├── components/
│   │   ├── glass_card_test.dart
│   │   ├── spec_badge_test.dart
│   │   └── ...
│   └── screens/
│       ├── home_screen_test.dart
│       ├── discover_feed_screen_test.dart
│       └── ...
└── golden/
    ├── components/
    │   ├── glass_card_golden_test.dart
    │   ├── app_background_golden_test.dart
    │   └── ...
    └── golden_test_helpers.dart
```

**Structure — Server:**
```
server/test/
├── auth.test.ts              # Auth helper functions (hash, JWT)
├── content_guard.test.ts     # Input validation, blocklist
├── gamification.test.ts      # Challenge/achievement logic
├── mappers.test.ts           # DB → API response mappers
├── middleware.test.ts        # CORS, method checking
├── routes_health.test.ts     # Health check endpoint
├── routes_hobbies.test.ts    # Hobby endpoints
└── routes_users.test.ts      # User endpoints
```

## Test Structure

**Suite Organization — Dart:**
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

**Suite Organization — TypeScript:**
```typescript
import { describe, it, expect, beforeAll } from "vitest";
import { hashPassword, comparePassword, generateTokenPair } from "../lib/auth";

beforeAll(() => {
  process.env.JWT_SECRET = "test-jwt-secret";
  process.env.JWT_REFRESH_SECRET = "test-jwt-refresh-secret";
});

describe("hashPassword / comparePassword", () => {
  it("hashes a password and verifies it", async () => {
    const plain = "mySecret123";
    const hashed = await hashPassword(plain);
    expect(hashed).not.toBe(plain);
    expect(hashed.length).toBeGreaterThan(20);
    const match = await comparePassword(plain, hashed);
    expect(match).toBe(true);
  });

  it("produces different hashes for same input (salted)", async () => {
    const h1 = await hashPassword("same");
    const h2 = await hashPassword("same");
    expect(h1).not.toBe(h2);
  });
});
```

**Patterns:**
- `setUp()`: Initialize shared test fixtures (database, mocks, notifiers)
- `setUpAll()` (golden tests): Load fonts once before all tests
- `tearDown()`: Cleanup resources (dispose controllers, clear caches)
- `group()`: Organize related tests semantically
- `test()` / `it()`: Individual test case with descriptive name starting with verb

**Async Testing Pattern — Dart:**
```dart
test('saveHobby fires API call', () async {
  notifier.saveHobby('pottery');
  // Wait for async API call to complete
  await Future.delayed(Duration.zero);
  expect(mockRepo.calls, contains('saveHobby:pottery'));
});
```

**Async Testing Pattern — TypeScript:**
```typescript
it("refreshes JWT token on 401", async () => {
  process.env.JWT_SECRET = "old-secret";
  const { refreshToken } = generateTokenPair("user_123");

  process.env.JWT_SECRET = "new-secret";
  const response = await handler(req, res);
  expect(response.status).toBe(401);
});
```

## Mocking

**Framework — Dart:**
- Hand-written mocks (no external mocking library like `mockito`)
- See `test/unit/providers/auth_provider_test.dart` lines 7-100 for `MockAuthRepository` example

**Framework — TypeScript:**
- No external mocking library
- Manual object creation for stubs
- `vitest` provides spies via `vi.spyOn()` if needed

**Pattern — Dart:**
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

**Pattern — TypeScript:**
```typescript
describe("verifyAccessToken", () => {
  it("verifies a valid access token", () => {
    const { accessToken } = generateTokenPair("user_789");
    const { sub } = verifyAccessToken(accessToken);
    expect(sub).toBe("user_789");
  });

  it("throws on invalid token", () => {
    expect(() => verifyAccessToken("garbage.token.here")).toThrow();
  });
});
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

**Test Data — Dart:**
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
- Inline in test file (small datasets) — see `test/unit/providers/auth_provider_test.dart` lines 13-17
- Helper classes in same file (see `test/widget/screens/home_screen_test.dart` lines 19-95)
- Not extracted to separate fixtures/ directory (none in codebase)

## Coverage

**Requirements:** None enforced (no CI check)

**View Coverage — Flutter:**
```bash
flutter test --coverage
lcov --list coverage/lcov.info  # If lcov installed
```

**Current State:**
- 37 test files across unit, widget, golden tests
- Coverage: not measured/enforced
- Key areas tested: Serialization, repositories, state management, components
- Focus: Critical user flows (auth, hobby save, session)

## Test Types

**Unit Tests — Dart:**
- Scope: Single class in isolation
- Approach: Mock dependencies, test state transitions
- Files: `test/unit/providers/`, `test/unit/repositories/`, `test/unit/models/`, `test/unit/core/`
- Examples:
  - `test/unit/providers/auth_provider_test.dart` — Tests `AuthNotifier` state management
  - `test/unit/repositories/hobby_repository_test.dart` — Tests hobby repository methods
  - `test/unit/models/auth_serialization_test.dart` — Tests Freezed `fromJson`/`toJson`

**Widget Tests — Dart:**
- Scope: Single widget or screen with mocked dependencies
- Approach: Use `WidgetTester`, pump widgets, verify UI state
- Files: `test/widget/components/`, `test/widget/screens/`
- Examples:
  - `test/widget/components/glass_card_test.dart` — Tests glass card render and tap behavior
  - `test/widget/screens/home_screen_test.dart` — Tests home screen rendering with mocked providers

**Golden Tests — Dart:**
- Scope: Visual regression testing via screenshot comparison
- Approach: Use `golden_toolkit`, render widget, compare against baseline
- Files: `test/golden/components/`, `test/golden/golden_test_helpers.dart`
- Examples:
  - `test/golden/components/glass_card_golden_test.dart` — Compares glass card variants
  - `test/golden/components/spec_badge_golden_test.dart` — Compares spec badge rendering
- Setup: `setUpAll()` loads fonts via `loadFonts()` helper

**Unit Tests — TypeScript (Server):**
- Scope: Single function/module in isolation
- Approach: Test JWT generation, password hashing, validation, error handling
- Files: `server/test/auth.test.ts`, `server/test/content_guard.test.ts`, `server/test/middleware.test.ts`
- Examples:
  - `server/test/auth.test.ts` lines 16-37 — Tests password hashing with salting
  - `server/test/auth.test.ts` lines 39-54 — Tests JWT token generation and claims

**Integration Tests:**
- Not used in this codebase
- Would test: API client + repository + notifier together, or endpoint + database

**E2E Tests:**
- Not used in this codebase
- Would use: `flutter_test` with `WidgetTester` to test full app flow from login to session completion

## Common Patterns

**Async Testing — Dart:**
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

**Error Testing (Throwing Exceptions) — Dart:**
```dart
test('getHobbies throws on repository failure', () async {
  mockRepo.shouldFail = true;
  expect(
    () => mockRepo.getHobbies(),
    throwsException,
  );
});
```

**Error Testing — TypeScript:**
```typescript
it("throws on invalid token", () => {
  expect(() => verifyAccessToken("garbage.token.here")).toThrow();
});

it("throws on refresh token (wrong secret)", () => {
  const { refreshToken } = generateTokenPair("user_789");
  expect(() => verifyAccessToken(refreshToken)).toThrow();
});
```

**State Transition Testing — Dart:**
```dart
test('startTrying changes status to trying', () {
  notifier.saveHobby('pottery');
  notifier.startTrying('pottery');
  expect(notifier.state['pottery']!.status, HobbyStatus.trying);
  expect(notifier.state['pottery']!.startedAt, isNotNull);
});
```

**Collection Testing — Dart:**
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

**JSON Serialization Testing (Round-trip) — Dart:**
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

**API Response Shape Testing — Dart:**
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

**Golden Test Pattern — Dart:**
```dart
void main() {
  setUpAll(() async => await loadFonts());

  testGoldens('GlassCard — default (no blur)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const GlassCard(
        child: Text('Hello', style: TextStyle(color: Colors.white)),
      )),
      surfaceSize: const Size(300, 120),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'glass_card_default');
  });
}
```

## Test Coverage Gaps

**Currently Tested Areas:**
- Auth serialization and notifier state management
- Hobby model parsing and JSON round-trips
- Repository interfaces and implementations
- Core service logic (analytics, error reporting, notifications)
- Session state machine transitions
- Component rendering (glass card, spec badge, shimmer)
- Subscription and gamification logic

**Currently Untested Areas:**
- Widget navigation and GoRouter redirect behavior
- Full screen integration (e.g., home_screen + discover_feed interactions)
- Dio interceptor and token refresh flow in live API calls
- Hive caching layer implementation
- Feature providers (journal, scheduler, notes, challenge)
- Personal tools screen interactions
- Session timer animation and particle painter
- Search screen NLP matching and results
- Pro paywall and RevenueCat entitlements

**Priority for Future Testing:**
1. **Critical flows:** Auth login/register, hobby save/unsave, status transitions, session start-to-complete
2. **API integration:** Real response parsing, error handling, token refresh
3. **Data persistence:** SharedPreferences and Hive sync, offline functionality
4. **Feature state:** Journal CRUD, scheduler persistence, shopping list toggles
5. **UI flows:** Search results, category filtering, detail page conversions

## Running Tests

**All tests — Dart:**
```bash
flutter test
```

**Specific test file — Dart:**
```bash
flutter test test/unit/providers/user_hobbies_notifier_test.dart
```

**Verbose output — Dart:**
```bash
flutter test -v
```

**Stop on first failure — Dart:**
```bash
flutter test --bail
```

**All tests — Server (TypeScript):**
```bash
cd server && npm test
```

**Watch mode — Server:**
```bash
cd server && npm run test:watch
```

**Golden tests update baseline — Dart:**
```bash
flutter test --update-goldens test/golden/
```

---

*Testing analysis: 2026-03-21*
