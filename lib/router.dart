import 'package:flutter/cupertino.dart' show CupertinoPage;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/page_transitions.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/match_results_screen.dart';
import 'screens/onboarding/trial_offer_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'screens/feed/rail_feed_screen.dart';
import 'screens/you/you_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/detail/hobby_detail_screen.dart';
import 'screens/quickstart/quickstart_screen.dart';
import 'screens/coach/hobby_coach_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/pro_screen.dart';
import 'screens/settings/privacy_policy_screen.dart';
import 'screens/settings/terms_of_service_screen.dart';
import 'models/hobby.dart' show CompletionMode;
import 'screens/session/session_screen.dart';
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

/// Exposed for screens that need to push full-screen overlays above the shell.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = rootNavigatorKey;
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

      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Motion.slow,
        ),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const VerifyEmailScreen(),
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

      // Match results — shown once after onboarding, before trial offer
      GoRoute(
        path: '/match-results',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const MatchResultsScreen(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
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
        // Explicit page: with plain `builder:` the shell got the default
        // MaterialPage, whose iOS transition is a Cupertino slide — so the
        // login form visibly slid away when the shell entered after sign-in.
        // A fade here crossfades with the auth screens' fade-out instead.
        // Stable key so tab changes update the page in place (no re-transition).
        pageBuilder: (context, state, child) => CustomTransitionPage(
          key: const ValueKey('main-shell'),
          child: MainShell(child: child),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Motion.slow,
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HomeScreen(
                initialHobbyId: state.uri.queryParameters['hobby'],
              ),
            ),
          ),
          GoRoute(
            path: '/discover',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverScreen(),
            ),
          ),
          GoRoute(
            path: '/you',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: YouScreen(),
            ),
          ),
          // Rail feed — inside shell so navbar stays visible
          GoRoute(
            path: '/rail-feed/:railId',
            pageBuilder: (context, state) {
              final railId = state.pathParameters['railId']!;
              final title = state.uri.queryParameters['title'] ?? railId;
              return CupertinoPage(
                child: RailFeedScreen(railId: railId, railTitle: title),
              );
            },
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════
      //  PUSHED SCREENS (on top of shell)
      // ═══════════════════════════════════════════════════

      // Search — full-screen fade, covers shell for clean transition
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final initialQuery = state.uri.queryParameters['q'] ?? '';
          return CustomTransitionPage(
            child: SearchScreen(initialQuery: initialQuery),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Motion.slow,
            reverseTransitionDuration: Motion.slow,
          );
        },
      ),

      // Hobby detail
      GoRoute(
        path: '/hobby/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          // CupertinoPage: native slide + iOS interactive swipe-back gesture
          // (the gesture lives in the route type — a transitionsBuilder can
          // never provide it).
          return CupertinoPage(
            child: HobbyDetailScreen(hobbyId: id),
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

      // Session — full-screen immersive experience
      GoRoute(
        path: '/session/:hobbyId/:stepId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = (state.extra as Map<String, dynamic>?) ?? <String, dynamic>{};
          return CustomTransitionPage(
            child: SessionScreen(
              hobbyId: state.pathParameters['hobbyId']!,
              stepId: state.pathParameters['stepId']!,
              hobbyTitle: extra['hobbyTitle'] as String? ?? '',
              hobbyCategory: extra['hobbyCategory'] as String? ?? '',
              stepTitle: extra['stepTitle'] as String? ?? '',
              stepDescription: extra['stepDescription'] as String? ?? '',
              stepInstructions: extra['stepInstructions'] as String? ?? '',
              whatYouNeed: extra['whatYouNeed'] as String? ?? '',
              recommendedMinutes: extra['recommendedMinutes'] as int? ?? 15,
              completionMode: extra['completionMode'] as CompletionMode? ?? CompletionMode.timer,
              nextStepTitle: extra['nextStepTitle'] as String?,
              completionMessage: extra['completionMessage'] as String?,
              coachTip: extra['coachTip'] as String?,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Motion.hero,
            reverseTransitionDuration: Motion.slow,
          );
        },
      ),

      // AI Hobby Coach
      GoRoute(
        path: '/coach/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          final extra = state.extra as Map<String, dynamic>?;
          CoachEntryContext? entryContext;
          if (extra != null) {
            entryContext = CoachEntryContext(
              prefilledMessage: extra['message'] as String?,
              forceMode: extra['mode'] != null
                  ? CoachMode.values.firstWhere(
                      (m) => m.name == extra['mode'],
                      orElse: () => CoachMode.start,
                    )
                  : null,
              autoSend: (extra['autoSend'] as bool?) ?? false,
              focusEntryId: extra['focusEntryId'] as String?,
              quotedText: extra['quotedText'] as String?,
            );
          }
          return CupertinoPage(
            child: HobbyCoachScreen(hobbyId: hobbyId, entryContext: entryContext),
          );
        },
      ),

      // Settings
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: SettingsScreen(),
          );
        },
      ),

      // Pro screen
      GoRoute(
        path: '/pro',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const CupertinoPage(
            child: ProScreen(),
          );
        },
      ),

      // Privacy Policy
      GoRoute(
        path: '/privacy-policy',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: PrivacyPolicyScreen(),
        ),
      ),

      // Terms of Service
      GoRoute(
        path: '/terms-of-service',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: TermsOfServiceScreen(),
        ),
      ),

      // ═══════════════════════════════════════════════════
      //  FEATURE SCREENS (accessible from detail/home/you)
      // ═══════════════════════════════════════════════════

      GoRoute(
        path: '/faq/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CupertinoPage(
            child: BeginnerFaqScreen(hobbyId: hobbyId),
          );
        },
      ),
      GoRoute(
        path: '/notes/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CupertinoPage(
            child: PersonalNotesScreen(hobbyId: hobbyId),
          );
        },
      ),
      GoRoute(
        path: '/budget/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CupertinoPage(
            child: BudgetAlternativesScreen(hobbyId: hobbyId),
          );
        },
      ),
      GoRoute(
        path: '/cost/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CupertinoPage(
            child: CostCalculatorScreen(hobbyId: hobbyId),
          );
        },
      ),
      GoRoute(
        path: '/shopping/:hobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final hobbyId = state.pathParameters['hobbyId']!;
          return CupertinoPage(
            child: ShoppingListScreen(hobbyId: hobbyId),
          );
        },
      ),
      GoRoute(
        path: '/compare',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: CompareModeScreen(),
        ),
      ),
      GoRoute(
        path: '/journal',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CupertinoPage(
          child: HobbyJournalScreen(
            initialHobbyId: state.uri.queryParameters['hobby'],
          ),
        ),
      ),
      GoRoute(
        path: '/scheduler',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: HobbySchedulerScreen(),
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
      final isPublicRoute = path == '/terms-of-service' ||
          path == '/privacy-policy' ||
          path == '/forgot-password';

      if (auth.status == AuthStatus.unknown) {
        // Cold start: HOLD the current location while the session restore
        // runs. The splash overlay covers the app during unknown/loading, so
        // nothing leaks visually. Redirecting to /login here mounted the
        // login form beneath the splash, and a restored session then
        // navigated login → home — briefly crossfading the form on screen
        // for an already-logged-in user.
        return null;
      }

      if (auth.status == AuthStatus.loading) {
        // Active sign-in in progress — freeze navigation, let the current
        // screen show its own loading state (no flash)
        return null;
      }

      if (auth.status == AuthStatus.unauthenticated) {
        if (!isAuthRoute && !isPublicRoute) return '/login';
        return null;
      }

      final verified = auth.user?.emailVerified ?? false;
      final isVerifyRoute = path == '/verify-email';

      if (isAuthRoute) {
        if (!verified) return '/verify-email';
        return onboarded ? '/home' : '/onboarding';
      }

      // Email verification guard — blocks everything until verified
      if (!verified && !isVerifyRoute && !isPublicRoute) return '/verify-email';
      if (verified && isVerifyRoute) return onboarded ? '/home' : '/onboarding';

      if (!onboarded && !isOnboarding && !isVerifyRoute) return '/onboarding';
      if (onboarded && isOnboarding) return '/match-results';

      // Match results guard — show once after onboarding
      final isMatchResults = path == '/match-results';
      final matchResultsSeen = ref.read(sharedPreferencesProvider)
          .getBool('matchResultsSeen') ?? false;
      if (onboarded && !matchResultsSeen && !isMatchResults && !isOnboarding && !isAuthRoute) {
        return '/match-results';
      }
      if (isMatchResults) return null;

      // Trial offer is now triggered after first session completion,
      // not as a router guard. Keep the route accessible for debug nav.
      final isTrialOffer = path == '/trial-offer';
      final isDebugNav = state.uri.queryParameters.containsKey('debug');
      final trialOfferShown = ref.read(sharedPreferencesProvider).getBool('trialOfferShown') ?? false;
      if (trialOfferShown && isTrialOffer && !isDebugNav) return '/home';

      return null;
    },
  );
});
