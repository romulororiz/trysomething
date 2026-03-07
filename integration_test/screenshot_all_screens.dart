// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trysomething/theme/app_theme.dart';
import 'package:trysomething/providers/auth_provider.dart';
import 'package:trysomething/providers/user_provider.dart';
import 'package:trysomething/providers/repository_providers.dart';
import 'package:trysomething/providers/subscription_provider.dart';
import 'package:trysomething/core/analytics/analytics_provider.dart';
import 'package:trysomething/core/analytics/analytics_service.dart';
import 'package:trysomething/core/error/error_provider.dart';
import 'package:trysomething/core/error/error_reporter.dart';
import 'package:trysomething/core/notifications/notification_provider.dart';
import 'package:trysomething/core/notifications/notification_service.dart';
import 'package:trysomething/core/subscription/subscription_service.dart';
import 'package:trysomething/router.dart';

import 'package:trysomething/data/repositories/hobby_repository_impl.dart';
import 'package:trysomething/data/repositories/feature_repository.dart';
import 'package:trysomething/data/repositories/personal_tools_repository.dart';
import 'package:trysomething/data/repositories/social_repository.dart';
import 'package:trysomething/data/repositories/gamification_repository.dart';
import 'package:trysomething/data/repositories/user_progress_repository.dart';
import 'package:trysomething/data/repositories/auth_repository.dart';

import 'package:trysomething/models/auth.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/models/features.dart';
import 'package:trysomething/models/gamification.dart';
import 'package:trysomething/models/social.dart';
// Screen imports (same as router.dart)
import 'package:trysomething/screens/auth/login_screen.dart';
import 'package:trysomething/screens/auth/register_screen.dart';
import 'package:trysomething/screens/onboarding/onboarding_screen.dart';
import 'package:trysomething/screens/onboarding/trial_offer_screen.dart';
import 'package:trysomething/screens/main_shell.dart';
import 'package:trysomething/screens/feed/discover_feed_screen.dart';
import 'package:trysomething/screens/plan/plan_screen.dart';
import 'package:trysomething/screens/detail/hobby_detail_screen.dart';
import 'package:trysomething/screens/quickstart/quickstart_screen.dart';
import 'package:trysomething/screens/my_stuff/my_stuff_screen.dart';
import 'package:trysomething/screens/explore/explore_screen.dart';
import 'package:trysomething/screens/search/search_screen.dart';
import 'package:trysomething/screens/profile/profile_screen.dart';
import 'package:trysomething/screens/settings/settings_screen.dart';
import 'package:trysomething/screens/settings/pro_screen.dart';
import 'package:trysomething/screens/coach/hobby_coach_screen.dart';
import 'package:trysomething/screens/features/mood_match_screen.dart';
import 'package:trysomething/screens/features/seasonal_picks_screen.dart';
import 'package:trysomething/screens/features/beginner_faq_screen.dart';
import 'package:trysomething/screens/features/personal_notes_screen.dart';
import 'package:trysomething/screens/features/budget_alternatives_screen.dart';
import 'package:trysomething/screens/features/hobby_combos_screen.dart';
import 'package:trysomething/screens/features/cost_calculator_screen.dart';
import 'package:trysomething/screens/features/compare_mode_screen.dart';
import 'package:trysomething/screens/features/shopping_list_screen.dart';
import 'package:trysomething/screens/features/weekly_challenge_screen.dart';
import 'package:trysomething/screens/features/hobby_journal_screen.dart';
import 'package:trysomething/screens/features/hobby_scheduler_screen.dart';
import 'package:trysomething/screens/features/buddy_mode_screen.dart';
import 'package:trysomething/screens/features/community_stories_screen.dart';
import 'package:trysomething/screens/features/local_discovery_screen.dart';
import 'package:trysomething/screens/features/year_in_review_screen.dart';

// ═══════════════════════════════════════════════════════
//  MOCK REPOSITORIES
// ═══════════════════════════════════════════════════════

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthResponse> register(
          {required String email,
          required String password,
          required String displayName}) async =>
      throw UnimplementedError();
  @override
  Future<AuthResponse> login(
          {required String email, required String password}) async =>
      throw UnimplementedError();
  @override
  Future<AuthResponse> loginWithGoogle(
          {String? idToken, String? accessToken}) async =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> refreshToken(
          {required String refreshToken}) async =>
      {};
  @override
  Future<AuthUser> getMe() async => const AuthUser(
      id: 'test-user', email: 'test@test.com', displayName: 'Test User');
  @override
  Future<AuthUser> updateProfile(
          {String? displayName,
          String? bio,
          String? avatarUrl,
          String? fcmToken}) async =>
      const AuthUser(
          id: 'test-user', email: 'test@test.com', displayName: 'Test User');
  @override
  Future<UserPreferences> updatePreferences(
          {int? hoursPerWeek,
          int? budgetLevel,
          bool? preferSocial,
          Set<String>? vibes}) async =>
      const UserPreferences();
}

class MockFeatureRepository implements FeatureRepository {
  @override
  Future<List<FaqItem>> getFaqForHobby(String hobbyId) async => [
        const FaqItem(
            question: 'How do I get started?',
            answer: 'Start with the basics and work your way up.',
            upvotes: 5),
        const FaqItem(
            question: 'What equipment do I need?',
            answer: 'Check the starter kit section for recommendations.',
            upvotes: 3),
      ];
  @override
  Future<CostBreakdown?> getCostBreakdown(String hobbyId) async =>
      const CostBreakdown(
          starter: 50,
          threeMonth: 150,
          oneYear: 400,
          tips: ['Buy used equipment', 'Start with free tutorials']);
  @override
  Future<List<BudgetAlternative>> getBudgetAlternatives(
          String hobbyId) async =>
      [];
  @override
  Future<Map<String, List<String>>> getSeasonalHobbies() async => {
        'spring': ['pottery', 'bouldering'],
        'summer': ['bouldering', 'sourdough'],
        'autumn': ['pottery', 'sourdough'],
        'winter': ['pottery', 'sourdough'],
      };
  @override
  Future<Map<String, List<String>>> getMoodTags() async => {
        'relaxing': ['pottery', 'sourdough'],
        'energizing': ['bouldering'],
        'creative': ['pottery'],
      };
  @override
  Future<List<HobbyCombo>> getCombos() async => [];
}

class MockPersonalToolsRepository implements PersonalToolsRepository {
  @override
  Future<List<JournalEntry>> getJournalEntries() async => [];
  @override
  Future<JournalEntry> createJournalEntry(
          {required String hobbyId,
          required String text,
          String? photoUrl}) async =>
      JournalEntry(
          id: 'j1',
          hobbyId: hobbyId,
          text: text,
          createdAt: DateTime.now());
  @override
  Future<void> deleteJournalEntry(String entryId) async {}
  @override
  Future<Map<String, String>> getNotesForHobby(String hobbyId) async => {};
  @override
  Future<void> saveNote(
          {required String hobbyId,
          required String stepId,
          required String text}) async {}
  @override
  Future<void> deleteNote(
          {required String hobbyId, required String stepId}) async {}
  @override
  Future<List<ScheduleEvent>> getScheduleEvents() async => [];
  @override
  Future<ScheduleEvent> createScheduleEvent(
          {required String hobbyId,
          required int dayOfWeek,
          required String startTime,
          required int durationMinutes}) async =>
      ScheduleEvent(
          id: 's1',
          hobbyId: hobbyId,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          durationMinutes: durationMinutes);
  @override
  Future<void> deleteScheduleEvent(String eventId) async {}
  @override
  Future<Set<String>> getCheckedItems(String hobbyId) async => {};
  @override
  Future<void> toggleShoppingItem(
          {required String hobbyId,
          required String itemName,
          required bool checked}) async {}
}

class MockSocialRepository implements SocialRepository {
  @override
  Future<List<CommunityStory>> getStories() async => [];
  @override
  Future<CommunityStory> createStory(
          {required String quote, required String hobbyId}) async =>
      CommunityStory(
          id: 'cs1',
          authorName: 'Test',
          authorInitial: 'T',
          quote: quote,
          hobbyId: hobbyId);
  @override
  Future<void> deleteStory(String storyId) async {}
  @override
  Future<void> addReaction(
          {required String storyId, required String type}) async {}
  @override
  Future<void> removeReaction(
          {required String storyId, required String type}) async {}
  @override
  Future<Map<String, dynamic>> getBuddiesWithActivity() async =>
      {'profiles': <dynamic>[], 'activities': <dynamic>[]};
  @override
  Future<List<BuddyRequest>> getBuddyRequests() async => [];
  @override
  Future<BuddyRequest> sendBuddyRequest(
          {required String targetUserId, String? hobbyId}) async =>
      throw UnimplementedError();
  @override
  Future<void> respondToRequest(
          {required String requestId, required String status}) async {}
  @override
  Future<void> cancelRequest(String requestId) async {}
  @override
  Future<List<NearbyUser>> getSimilarUsers({String? hobbyId}) async => [];
}

class MockGamificationRepository implements GamificationRepository {
  @override
  Future<List<Challenge>> getChallenges() async => [];
  @override
  Future<List<Achievement>> getAchievements() async => [];
}

class MockUserProgressRepository implements UserProgressRepository {
  @override
  Future<List<UserHobby>> getHobbies() async => [];
  @override
  Future<UserHobby> saveHobby(String hobbyId) async =>
      UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved);
  @override
  Future<void> unsaveHobby(String hobbyId) async {}
  @override
  Future<UserHobby> updateStatus(String hobbyId, HobbyStatus status,
          {DateTime? startedAt, DateTime? completedAt}) async =>
      UserHobby(hobbyId: hobbyId, status: status);
  @override
  Future<UserHobby> toggleStep(String hobbyId, String stepId) async =>
      UserHobby(hobbyId: hobbyId, status: HobbyStatus.trying);
  @override
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies) async =>
      hobbies;
  @override
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365}) async =>
      [];
}

// ═══════════════════════════════════════════════════════
//  TEST ROUTER — same routes as app, NO redirect logic
// ═══════════════════════════════════════════════════════

GoRouter _createTestRouter({String initialLocation = '/feed'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // Auth screens (outside shell)
      GoRoute(
          path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(
          path: '/trial-offer',
          builder: (context, state) => const TrialOfferScreen()),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/feed',
              builder: (context, state) => const DiscoverFeedScreen()),
          GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen()),
          GoRoute(
              path: '/library',
              builder: (context, state) => const MyStuffScreen()),
          GoRoute(
              path: '/plan',
              builder: (context, state) => const PlanScreen()),
          GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen()),
          GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen()),
        ],
      ),

      // Screens pushed on top of shell
      GoRoute(
        path: '/hobby/:id',
        builder: (context, state) =>
            HobbyDetailScreen(hobbyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quickstart/:hobbyId',
        builder: (context, state) =>
            QuickstartScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
        path: '/coach/:hobbyId',
        builder: (context, state) =>
            HobbyCoachScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen()),
      GoRoute(
          path: '/pro', builder: (context, state) => const ProScreen()),
      GoRoute(
          path: '/mood-match',
          builder: (context, state) => const MoodMatchScreen()),
      GoRoute(
          path: '/seasonal',
          builder: (context, state) => const SeasonalPicksScreen()),
      GoRoute(
        path: '/faq/:hobbyId',
        builder: (context, state) =>
            BeginnerFaqScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
        path: '/notes/:hobbyId',
        builder: (context, state) =>
            PersonalNotesScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
        path: '/budget/:hobbyId',
        builder: (context, state) =>
            BudgetAlternativesScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
          path: '/combos',
          builder: (context, state) => const HobbyCombosScreen()),
      GoRoute(
        path: '/cost/:hobbyId',
        builder: (context, state) =>
            CostCalculatorScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
          path: '/compare',
          builder: (context, state) => const CompareModeScreen()),
      GoRoute(
        path: '/shopping/:hobbyId',
        builder: (context, state) =>
            ShoppingListScreen(hobbyId: state.pathParameters['hobbyId']!),
      ),
      GoRoute(
          path: '/challenge',
          builder: (context, state) => const WeeklyChallengeScreen()),
      GoRoute(
          path: '/journal',
          builder: (context, state) => const HobbyJournalScreen()),
      GoRoute(
          path: '/scheduler',
          builder: (context, state) => const HobbySchedulerScreen()),
      GoRoute(
          path: '/buddy',
          builder: (context, state) => const BuddyModeScreen()),
      GoRoute(
          path: '/stories',
          builder: (context, state) => const CommunityStoriesScreen()),
      GoRoute(
          path: '/local',
          builder: (context, state) => const LocalDiscoveryScreen()),
      GoRoute(
          path: '/year-review',
          builder: (context, state) => const YearInReviewScreen()),
    ],
  );
}

// ═══════════════════════════════════════════════════════
//  HELPER: build test app with all mocked providers
// ═══════════════════════════════════════════════════════

Widget _buildTestApp(SharedPreferences prefs, GoRouter router) {
  return ProviderScope(
    overrides: [
      // Core infra
      sharedPreferencesProvider.overrideWithValue(prefs),
      errorReporterProvider.overrideWithValue(ErrorReporter()),
      analyticsProvider.overrideWithValue(AnalyticsService()),
      notificationProvider.overrideWithValue(NotificationService()),
      subscriptionProvider.overrideWithValue(SubscriptionService()),

      // Auth — force authenticated state
      authProvider.overrideWith((ref) {
        final notifier = AuthNotifier(MockAuthRepository());
        // Immediately set authenticated state
        notifier.state = const AuthState(
          status: AuthStatus.authenticated,
          user: AuthUser(
            id: 'test-user',
            email: 'test@test.com',
            displayName: 'Test User',
          ),
        );
        return notifier;
      }),
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),

      // Repositories — all mocked
      hobbyRepositoryProvider.overrideWithValue(HobbyRepositoryImpl()),
      featureRepositoryProvider.overrideWithValue(MockFeatureRepository()),
      personalToolsRepositoryProvider
          .overrideWithValue(MockPersonalToolsRepository()),
      socialRepositoryProvider.overrideWithValue(MockSocialRepository()),
      gamificationRepositoryProvider
          .overrideWithValue(MockGamificationRepository()),
      userProgressRepositoryProvider
          .overrideWithValue(MockUserProgressRepository()),

      // Router — use test router without redirect guards
      routerProvider.overrideWithValue(router),
    ],
    child: MaterialApp.router(
      title: 'TrySomething — Screenshot Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    ),
  );
}

// ═══════════════════════════════════════════════════════
//  SCREENSHOT HELPER
// ═══════════════════════════════════════════════════════

Future<void> takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // Let all animations and futures settle
  await tester.pumpAndSettle(const Duration(seconds: 2));
  // convertFlutterSurfaceToImage is only needed on web
  if (kIsWeb) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(name);
  print('  ✓ Screenshot: $name');
}

// ═══════════════════════════════════════════════════════
//  MAIN TEST
// ═══════════════════════════════════════════════════════

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testHobbyId = 'pottery'; // From seed data

  group('Screenshot all screens', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'trialOfferShown': true,
      });
      prefs = await SharedPreferences.getInstance();
    });

    // ─────────────────────────────────────────────────
    //  AUTH SCREENS (login, register)
    // ─────────────────────────────────────────────────
    testWidgets('01 - Login screen', (tester) async {
      final router = _createTestRouter(initialLocation: '/login');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '01_login');
    });

    testWidgets('02 - Register screen', (tester) async {
      final router = _createTestRouter(initialLocation: '/register');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '02_register');
    });

    // ─────────────────────────────────────────────────
    //  ONBOARDING
    // ─────────────────────────────────────────────────
    testWidgets('03 - Onboarding screen', (tester) async {
      final router = _createTestRouter(initialLocation: '/onboarding');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '03_onboarding_page1');
    });

    testWidgets('04 - Trial offer screen', (tester) async {
      final router = _createTestRouter(initialLocation: '/trial-offer');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '04_trial_offer');
    });

    // ─────────────────────────────────────────────────
    //  MAIN TABS
    // ─────────────────────────────────────────────────
    testWidgets('05 - Discover feed (Home)', (tester) async {
      final router = _createTestRouter(initialLocation: '/feed');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '05_discover_feed');
    });

    testWidgets('06 - Explore', (tester) async {
      final router = _createTestRouter(initialLocation: '/explore');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '06_explore');
    });

    testWidgets('07 - Library / My Stuff', (tester) async {
      final router = _createTestRouter(initialLocation: '/library');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '07_library');
    });

    testWidgets('08 - Plan', (tester) async {
      final router = _createTestRouter(initialLocation: '/plan');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '08_plan');
    });

    testWidgets('09 - Search', (tester) async {
      final router = _createTestRouter(initialLocation: '/search');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '09_search');
    });

    testWidgets('10 - Profile', (tester) async {
      final router = _createTestRouter(initialLocation: '/profile');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '10_profile');
    });

    // ─────────────────────────────────────────────────
    //  HOBBY DETAIL + RELATED
    // ─────────────────────────────────────────────────
    testWidgets('11 - Hobby detail', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/hobby/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '11_hobby_detail');
    });

    testWidgets('12 - Quickstart sheet', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/quickstart/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '12_quickstart');
    });

    testWidgets('13 - AI Coach', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/coach/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '13_coach');
    });

    // ─────────────────────────────────────────────────
    //  SETTINGS + PRO
    // ─────────────────────────────────────────────────
    testWidgets('14 - Settings', (tester) async {
      final router = _createTestRouter(initialLocation: '/settings');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '14_settings');
    });

    testWidgets('15 - Pro / Upgrade', (tester) async {
      final router = _createTestRouter(initialLocation: '/pro');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '15_pro');
    });

    // ─────────────────────────────────────────────────
    //  FEATURE SCREENS — Tier 1 (Discovery & Content)
    // ─────────────────────────────────────────────────
    testWidgets('16 - Mood match', (tester) async {
      final router = _createTestRouter(initialLocation: '/mood-match');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '16_mood_match');
    });

    testWidgets('17 - Seasonal picks', (tester) async {
      final router = _createTestRouter(initialLocation: '/seasonal');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '17_seasonal_picks');
    });

    testWidgets('18 - Beginner FAQ', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/faq/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '18_beginner_faq');
    });

    testWidgets('19 - Personal notes', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/notes/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '19_personal_notes');
    });

    testWidgets('20 - Budget alternatives', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/budget/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '20_budget_alternatives');
    });

    // ─────────────────────────────────────────────────
    //  FEATURE SCREENS — Tier 2 (Utility & Gamification)
    // ─────────────────────────────────────────────────
    testWidgets('21 - Hobby combos', (tester) async {
      final router = _createTestRouter(initialLocation: '/combos');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '21_hobby_combos');
    });

    testWidgets('22 - Cost calculator', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/cost/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '22_cost_calculator');
    });

    testWidgets('23 - Compare mode', (tester) async {
      final router = _createTestRouter(initialLocation: '/compare');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '23_compare_mode');
    });

    testWidgets('24 - Shopping list', (tester) async {
      final router =
          _createTestRouter(initialLocation: '/shopping/$testHobbyId');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '24_shopping_list');
    });

    testWidgets('25 - Weekly challenge', (tester) async {
      final router = _createTestRouter(initialLocation: '/challenge');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '25_weekly_challenge');
    });

    testWidgets('26 - Journal', (tester) async {
      final router = _createTestRouter(initialLocation: '/journal');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '26_journal');
    });

    testWidgets('27 - Scheduler', (tester) async {
      final router = _createTestRouter(initialLocation: '/scheduler');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '27_scheduler');
    });

    // ─────────────────────────────────────────────────
    //  FEATURE SCREENS — Tier 3 (Social & Community)
    // ─────────────────────────────────────────────────
    testWidgets('28 - Buddy mode', (tester) async {
      final router = _createTestRouter(initialLocation: '/buddy');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '28_buddy_mode');
    });

    testWidgets('29 - Community stories', (tester) async {
      final router = _createTestRouter(initialLocation: '/stories');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '29_community_stories');
    });

    testWidgets('30 - Local discovery', (tester) async {
      final router = _createTestRouter(initialLocation: '/local');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '30_local_discovery');
    });

    testWidgets('31 - Year in review', (tester) async {
      final router = _createTestRouter(initialLocation: '/year-review');
      await tester.pumpWidget(_buildTestApp(prefs, router));
      await takeScreenshot(binding, tester, '31_year_in_review');
    });
  });
}
