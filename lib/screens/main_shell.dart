import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../theme/app_colors.dart';

/// Bottom navigation shell — wraps all tab screens.
/// 3 tabs: Home / Discover / You
/// Rendered as a floating glass dock with blur, no labels.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  // (activeIcon, inactiveIcon)
  static final _tabs = [
    (active: MdiIcons.homeVariant, inactive: MdiIcons.homeVariantOutline),
    (active: MdiIcons.compass, inactive: MdiIcons.compassOutline),
    (active: MdiIcons.accountCircle, inactive: MdiIcons.accountCircleOutline),
  ];

  static const _routes = ['/home', '/discover', '/you'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/discover') || location.startsWith('/search')) {
      return 1;
    }
    if (location.startsWith('/you')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 40,
          right: 40,
          bottom: bottomPadding + 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabs.length, (i) {
                  final isActive = i == currentIndex;
                  final tab = _tabs[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go(_routes[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isActive ? tab.active : tab.inactive,
                          key: ValueKey('$i-$isActive'),
                          size: 26,
                          color: isActive
                              ? AppColors.textPrimary
                              : const Color(0xFF6B6360),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
