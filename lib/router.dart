import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/user_provider.dart';
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
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingComplete ? '/feed' : '/onboarding',
    routes: [
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
              return _buildSlideRightTransition(animation, child);
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
          return CustomTransitionPage(
            opaque: false,
            barrierColor: Colors.transparent,
            child: QuickstartScreen(hobbyId: hobbyId),
            transitionsBuilder: (context, animation, _, child) {
              final slideUp = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Motion.normalCurve,
              ));

              // Backdrop blur + scrim that fades in with the animation
              final scrimOpacity = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              );

              return Stack(
                children: [
                  // Scrim + blur behind the sheet
                  FadeTransition(
                    opacity: scrimOpacity,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: const Color(0x60000000)),
                    ),
                  ),
                  // Sliding sheet
                  SlideTransition(position: slideUp, child: child),
                ],
              );
            },
            transitionDuration: Motion.bottomSheet,
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
              return _buildSlideRightTransition(animation, child);
            },
            transitionDuration: Motion.navForward,
            reverseTransitionDuration: Motion.navBack,
          );
        },
      ),
    ],

    // Redirect to onboarding if not complete
    redirect: (context, state) {
      final isOnboarding = state.uri.path == '/onboarding';
      if (!onboardingComplete && !isOnboarding) {
        return '/onboarding';
      }
      if (onboardingComplete && isOnboarding) {
        return '/feed';
      }
      return null;
    },
  );
});

// ═══════════════════════════════════════════════════════
//  TRANSITION HELPERS
// ═══════════════════════════════════════════════════════

/// Slide-from-right transition with backdrop scrim that dims the old page.
/// Forward: new page slides in from right, scrim dims old page to 95% opacity
///          + old page shifts left by 30%.
/// Back: reverses automatically.
Widget _buildSlideRightTransition(Animation<double> animation, Widget child) {
  // New page slides in from right
  final slideIn = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  ));

  // Scrim that sits behind the new page, dimming the old page
  final scrimOpacity = Tween<double>(begin: 0, end: 0.05).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
  );

  return Stack(
    children: [
      // Dim scrim over old page (visible through the gap as new page slides in)
      FadeTransition(
        opacity: scrimOpacity,
        child: Container(color: Colors.black),
      ),
      // New page sliding in
      SlideTransition(position: slideIn, child: child),
    ],
  );
}
