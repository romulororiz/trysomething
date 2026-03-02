import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/page_transitions.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/feed/discover_feed_screen.dart';
import 'screens/detail/hobby_detail_screen.dart';
import 'screens/quickstart/quickstart_screen.dart';
import 'screens/my_stuff/my_stuff_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/features/mood_match_screen.dart';
import 'screens/features/seasonal_picks_screen.dart';
import 'screens/features/beginner_faq_screen.dart';
import 'screens/features/personal_notes_screen.dart';
import 'screens/features/budget_alternatives_screen.dart';
import 'screens/features/hobby_combos_screen.dart';
import 'screens/features/cost_calculator_screen.dart';
import 'screens/features/compare_mode_screen.dart';
import 'screens/features/shopping_list_screen.dart';
import 'screens/features/weekly_challenge_screen.dart';
import 'screens/features/hobby_journal_screen.dart';
import 'screens/features/hobby_scheduler_screen.dart';
import 'screens/features/buddy_mode_screen.dart';
import 'screens/features/community_stories_screen.dart';
import 'screens/features/local_discovery_screen.dart';
import 'screens/features/year_in_review_screen.dart';
import 'theme/motion.dart';

// ═══════════════════════════════════════════════════════
//  NAVIGATION KEYS
// ═══════════════════════════════════════════════════════

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ═══════════════════════════════════════════════════════
//  ROUTER PROVIDER
// ═══════════════════════════════════════════════════════

final routerProvider = Provider<GoRouter>((ref) {
  // Notifier that triggers GoRouter to re-evaluate its redirect
  // without recreating the entire router (which resets navigation state).
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refreshNotifier.value++);
  ref.listen(onboardingCompleteProvider, (_, __) => refreshNotifier.value++);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    refreshListenable: refreshNotifier,
    routes: [
      // Auth screens (outside shell)
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Motion.slow,
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Motion.slow,
        ),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Motion.slow,
        ),
      ),

      // Main shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExploreScreen(),
            ),
          ),
          GoRoute(
            path: '/my',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyStuffScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Hobby detail (pushed on top of shell)
      GoRoute(
        path: '/hobby/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            child: HobbyDetailScreen(hobbyId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return buildSlideRightTransition(animation, child);
            },
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),

      // Quickstart (pushed on top — bottom sheet style with backdrop blur)
      GoRoute(
        path: '/quickstart/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return modalSlideUpTransitionPage(
            child: QuickstartScreen(hobbyId: hobbyId),
          );
        },
      ),

      // Settings (pushed on top)
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return buildSlideRightTransition(animation, child);
            },
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),

      // ═══════════════════════════════════════════════════
      //  FEATURE SCREENS (pushed on top of shell)
      // ═══════════════════════════════════════════════════

      // Tier 1 — Discovery & Content
      GoRoute(
        path: '/mood-match',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const MoodMatchScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/seasonal',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SeasonalPicksScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/faq/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CustomTransitionPage(
            child: BeginnerFaqScreen(hobbyId: hobbyId),
            transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),
      GoRoute(
        path: '/notes/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CustomTransitionPage(
            child: PersonalNotesScreen(hobbyId: hobbyId),
            transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),
      GoRoute(
        path: '/budget/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CustomTransitionPage(
            child: BudgetAlternativesScreen(hobbyId: hobbyId),
            transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),

      // Tier 2 — Utility & Gamification
      GoRoute(
        path: '/combos',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HobbyCombosScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/cost/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CustomTransitionPage(
            child: CostCalculatorScreen(hobbyId: hobbyId),
            transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),
      GoRoute(
        path: '/compare',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CompareModeScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/shopping/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CustomTransitionPage(
            child: ShoppingListScreen(hobbyId: hobbyId),
            transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),
      GoRoute(
        path: '/challenge',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const WeeklyChallengeScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/journal',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HobbyJournalScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/scheduler',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HobbySchedulerScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),

      // Tier 3 — Social & Community
      GoRoute(
        path: '/buddy',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const BuddyModeScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/stories',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CommunityStoriesScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/local',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LocalDiscoveryScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
      GoRoute(
        path: '/year-review',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const YearInReviewScreen(),
          transitionsBuilder: (_, a, __, c) => buildSlideRightTransition(a, c),
          transitionDuration: Motion.navForward,
          reverseTransitionDuration: Motion.navBack,
        ),
      ),
    ],

    // Auth + onboarding redirect chain
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final onboarded = ref.read(onboardingCompleteProvider);
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final isOnboarding = path == '/onboarding';

      // While session is being restored or an auth request is in-flight, don't redirect
      if (auth.status == AuthStatus.unknown ||
          auth.status == AuthStatus.loading) {
        return null;
      }

      // Unauthenticated: must go to login/register
      if (auth.status == AuthStatus.unauthenticated) {
        if (!isAuthRoute) return '/login';
        return null;
      }

      // Authenticated: shouldn't be on auth routes
      if (isAuthRoute) {
        return onboarded ? '/feed' : '/onboarding';
      }

      // Onboarding guard (existing logic)
      if (!onboarded && !isOnboarding) return '/onboarding';
      if (onboarded && isOnboarding) return '/feed';

      return null;
    },
  );
});
