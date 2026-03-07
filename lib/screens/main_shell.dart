import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../components/curved_nav/curved_navigation_bar.dart';
import '../components/curved_nav/curved_navigation_bar_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/motion.dart';

/// Bottom navigation shell — wraps all tab screens.
/// 3 tabs: Home / Discover / You
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static final _tabs = [
    (icon: MdiIcons.homeVariant, label: 'Home'),
    (icon: MdiIcons.compass, label: 'Discover'),
    (icon: MdiIcons.accountCircleOutline, label: 'You'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/discover') || location.startsWith('/search')) return 1;
    if (location.startsWith('/you')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/discover');
      case 2:
        context.go('/you');
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
          final isCenter = i == 1;
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
        color: const Color(0xFF0E0E1A),
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
