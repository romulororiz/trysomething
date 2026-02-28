import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';

/// Bottom navigation shell — wraps all tab screens.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

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
      body: child,
      bottomNavigationBar: Container(
        height: Spacing.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.warmWhite,
          border: Border(
            top: BorderSide(color: AppColors.sand, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: AppIcons.navDiscover,
                label: 'Discover',
                isActive: currentIndex == 0,
                onTap: () => _onTap(context, 0),
              ),
              _NavItem(
                icon: AppIcons.navExplore,
                label: 'Explore',
                isActive: currentIndex == 1,
                onTap: () => _onTap(context, 1),
              ),
              _NavItem(
                icon: AppIcons.navMyStuff,
                label: 'My Stuff',
                isActive: currentIndex == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                icon: AppIcons.navProfile,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => _onTap(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: Motion.fast,
        opacity: isActive ? 1.0 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isActive ? 22 : 20,
                color: isActive ? AppColors.coral : AppColors.warmGray,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.sansNav.copyWith(
                  color: isActive ? AppColors.coral : AppColors.warmGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
