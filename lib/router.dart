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
import 'screens/onboarding/trial_offer_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/feed/discover_feed_screen.dart';
import 'screens/you/you_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/detail/hobby_detail_screen.dart';
import 'screens/quickstart/quickstart_screen.dart';
import 'screens/coach/hobby_coach_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/pro_screen.dart';
import 'screens/features/beginner_faq_screen.dart';
import 'screens/features/personal_notes_screen.dart';
import 'screens/features/budget_alternatives_screen.dart';
import 'screens/features/cost_calculator_screen.dart';
import 'screens/features/shopping_list_screen.dart';
import 'screens/features/hobby_journal_screen.dart';
import 'screens/features/hobby_scheduler_screen.dart';
import 'screens/features/compare_mode_screen.dart';
import 'theme/motion.dart';
import 'core/analytics/analytics_provider.dart';

// ═══════════════════════════════════════════════════════
//  NAVIGATION KEYS
// ═══════════════════════════════════════════════════════

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ═══════════════════════════════════════════════════════
//  ROUTER PROVIDER
// ═══════════════════════════════════════════════════════

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refreshNotifier.value++);
  ref.listen(onboardingCompleteProvider, (_, __) => refreshNotifier.value++);

  final analytics = ref.watch(analyticsProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: refreshNotifier,
    observers: [AnalyticsObserver(analytics)],
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

      // Trial offer (post-onboarding, one-time)
      GoRoute(
        path: '/trial-offer',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const TrialOfferScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Motion.slow,
        ),
      ),

      // ═══════════════════════════════════════════════════
      //  MAIN SHELL — 3 TABS: Home / Discover / You
      // ═══════════════════════════════════════════════════
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/discover',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/you',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: YouScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════
      //  PUSHED SCREENS (on top of shell)
      // ═══════════════════════════════════════════════════

      // Hobby detail
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

      // Quickstart (bottom sheet style)
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

      // AI Hobby Coach
      GoRoute(
        path: '/coach/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CustomTransitionPage(
            child: HobbyCoachScreen(hobbyId: hobbyId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return buildSlideRightTransition(animation, child);
            },
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),

      // Settings
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

      // Pro screen
      GoRoute(
        path: '/pro',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const ProScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return buildSlideRightTransition(animation, child);
            },
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),

      // ═══════════════════════════════════════════════════
      //  FEATURE SCREENS (accessible from detail/home/you)
      // ═══════════════════════════════════════════════════

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

      // ═══════════════════════════════════════════════════
      //  HIDDEN FEATURES — routes removed from nav (B.2)
      //  Code kept in codebase, routes commented out.
      //  Screens: buddy, stories, local, year-review,
      //  challenge, mood-match, seasonal, combos
      // ═══════════════════════════════════════════════════
    ],

    // Auth + onboarding redirect chain
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final onboarded = ref.read(onboardingCompleteProvider);
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final isOnboarding = path == '/onboarding';

      if (auth.status == AuthStatus.unknown ||
          auth.status == AuthStatus.loading) {
        return null;
      }

      if (auth.status == AuthStatus.unauthenticated) {
        if (!isAuthRoute) return '/login';
        return null;
      }

      if (isAuthRoute) {
        return onboarded ? '/home' : '/onboarding';
      }

      if (!onboarded && !isOnboarding) return '/onboarding';
      if (onboarded && isOnboarding) return '/home';

      // Trial offer guard — show once after onboarding
      final isTrialOffer = path == '/trial-offer';
      final trialOfferShown = ref.read(sharedPreferencesProvider).getBool('trialOfferShown') ?? false;
      if (onboarded && !trialOfferShown && !isTrialOffer && !isAuthRoute && !isOnboarding) {
        return '/trial-offer';
      }
      if (trialOfferShown && isTrialOffer) return '/home';

      return null;
    },
  );
});
