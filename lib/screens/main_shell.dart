import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/curved_nav/curved_navigation_bar.dart';
import '../components/curved_nav/curved_navigation_bar_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../theme/motion.dart';

/// Bottom navigation shell — wraps all tab screens.
/// 5 tabs: Discover / Explore / Library (center, elevated) / Plan / Profile
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static final _tabs = [
    (icon: AppIcons.navDiscover, label: 'Discover'),
    (icon: AppIcons.navExplore, label: 'Explore'),
    (icon: AppIcons.navLibrary, label: 'Library'),
    (icon: AppIcons.navPlan, label: 'Plan'),
    (icon: AppIcons.navProfile, label: 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/plan')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/feed');
      case 1:
        context.go('/explore');
      case 2:
        context.go('/library');
      case 3:
        context.go('/plan');
      case 4:
        context.go('/profile');
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
        items: _tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final tab = entry.value;
          final isCenter = i == 2;
          return CurvedNavigationBarItem(
            child: isCenter
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(tab.icon, size: 24, color: Colors.white),
                  )
                : Icon(tab.icon, size: 24, color: Colors.white),
            label: tab.label,
            labelStyle: AppTypography.sansNav.copyWith(
              color: AppColors.driftwood,
            ),
          );
        }).toList(),
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
