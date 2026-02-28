import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/curved_nav/curved_navigation_bar.dart';
import '../components/curved_nav/curved_navigation_bar_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../theme/motion.dart';

/// Bottom navigation shell — wraps all tab screens.
/// Uses a local fork of curved_navigation_bar with tighter button gap.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static final _tabs = [
    (icon: AppIcons.navDiscover, label: 'Discover'),
    (icon: AppIcons.navExplore, label: 'Explore'),
    (icon: AppIcons.navMyStuff, label: 'My Stuff'),
    (icon: AppIcons.navProfile, label: 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/my')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/my');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      extendBody: true,
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        items: _tabs
            .map((tab) => CurvedNavigationBarItem(
                  child: Icon(tab.icon, size: 24, color: Colors.white),
                  label: tab.label,
                  labelStyle: AppTypography.sansNav.copyWith(
                    color: AppColors.driftwood,
                  ),
                ))
            .toList(),
        color: AppColors.warmWhite,
        buttonBackgroundColor: AppColors.coral,
        backgroundColor: Colors.transparent,
        animationCurve: Motion.navNotchCurve,
        animationDuration: Motion.navNotchTravel,
        height: 85,
        buttonElevation: 115,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
