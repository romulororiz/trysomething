import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
import '../../components/logo_loader.dart';
import '../../components/page_dots.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'active_hobby_page.dart';
import 'paused_hobby_page.dart';

/// Home tab — cinematic active hobby dashboard.
class HomeScreen extends ConsumerStatefulWidget {
  final String? initialHobbyId;

  const HomeScreen({super.key, this.initialHobbyId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  NavigatorState? _navigator;

  @override
  void initState() {
    super.initState();
    final initialIndex = _findHobbyIndex(widget.initialHobbyId);
    _currentPage = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the navigator while the context is fully mounted.
    // Used in deactivate() to dismiss popup menus on tab switch.
    _navigator = Navigator.maybeOf(context);
  }

  @override
  void didUpdateWidget(covariant HomeScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialHobbyId != null &&
        widget.initialHobbyId != old.initialHobbyId) {
      final targetIndex = _findHobbyIndex(widget.initialHobbyId);
      if (targetIndex != _currentPage) {
        setState(() => _currentPage = targetIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(targetIndex);
          }
        });
      }
    }
  }

  @override
  void deactivate() {
    // Dismiss open popup menus when switching tabs.
    // Uses the cached _navigator — Navigator.of(context) is unreliable
    // during ShellRoute transitions because the ancestor chain is
    // being restructured.
    _navigator?.popUntil((route) => route is! PopupRoute);
    super.deactivate();
  }

  /// Find the index of [hobbyId] in the sorted display entries list.
  /// Uses the same sort order as build() — active first, then paused.
  int _findHobbyIndex(String? hobbyId) {
    if (hobbyId == null) return 0;
    final userHobbies = ref.read(userHobbiesProvider);
    final activeEntries = userHobbies.entries
        .where((e) =>
            e.value.status == HobbyStatus.trying ||
            e.value.status == HobbyStatus.active)
        .toList()
      ..sort((a, b) {
        final aTime = a.value.lastActivityAt ?? a.value.startedAt;
        final bTime = b.value.lastActivityAt ?? b.value.startedAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
    final pausedEntries = userHobbies.entries
        .where((e) => e.value.status == HobbyStatus.paused)
        .toList()
      ..sort((a, b) {
        final aTime = a.value.pausedAt ?? DateTime(0);
        final bTime = b.value.pausedAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
    final allDisplayEntries = [...activeEntries, ...pausedEntries];
    final idx = allDisplayEntries.indexWhere((e) => e.key == hobbyId);
    return idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final isPro = ref.watch(isProProvider);

    // DEBUG: log all hobby statuses on every rebuild
    for (final e in userHobbies.entries) {
      debugPrint('[Home] hobby=${e.key} status=${e.value.status} completedAt=${e.value.completedAt}');
    }

    final activeEntries = userHobbies.entries
        .where((e) =>
            e.value.status == HobbyStatus.trying ||
            e.value.status == HobbyStatus.active)
        .toList()
      ..sort((a, b) {
        final aTime = a.value.lastActivityAt ?? a.value.startedAt;
        final bTime = b.value.lastActivityAt ?? b.value.startedAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

    final pausedEntries = userHobbies.entries
        .where((e) => e.value.status == HobbyStatus.paused)
        .toList()
      ..sort((a, b) {
        final aTime = a.value.pausedAt ?? DateTime(0);
        final bTime = b.value.pausedAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

    final allDisplayEntries = [...activeEntries, ...pausedEntries];

    if (allDisplayEntries.isEmpty) {
      Future.microtask(
          () => ref.read(shellLoadingProvider.notifier).state = false);
      // No completed home state — celebration is a one-time overlay.
      // Home goes straight to empty state when no active hobbies.
      return _EmptyHomeState();
    }

    final anyLoading = allDisplayEntries.any(
      (e) => ref.watch(hobbyByIdProvider(e.value.hobbyId)).isLoading,
    );
    if (anyLoading) {
      Future.microtask(
          () => ref.read(shellLoadingProvider.notifier).state = true);
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(tintTopLeft: false, child: LogoLoader()),
      );
    }

    Future.microtask(
        () => ref.read(shellLoadingProvider.notifier).state = false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        tintTopLeft: false,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                itemCount: isPro
                    ? allDisplayEntries.length
                    : allDisplayEntries.length.clamp(0, 2),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final entry = allDisplayEntries[i];
                  final userHobby = entry.value;
                  if (userHobby.status == HobbyStatus.paused) {
                    return PausedHobbyPage(
                      key: ValueKey('paused_${userHobby.hobbyId}'),
                      userHobby: userHobby,
                      onResume: () {
                        // After state update, jump PageView to the hobby's
                        // new index (it moves from paused → active section).
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final idx = _findHobbyIndex(userHobby.hobbyId);
                          if (_pageController.hasClients) {
                            setState(() => _currentPage = idx);
                            _pageController.jumpToPage(idx);
                          }
                        });
                      },
                    );
                  }
                  final isLocked = !isPro && i > 0;
                  final page = _HobbyPage(
                    key: ValueKey(userHobby.hobbyId),
                    userHobby: userHobby,
                  );
                  if (!isLocked) return page;
                  return _ProLockedOverlay(child: page);
                },
              ),
              if (allDisplayEntries.length > 1)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: PageDots(
                    count: allDisplayEntries.length,
                    current: _currentPage,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PRO LOCKED OVERLAY
// ═══════════════════════════════════════════════════════

class _ProLockedOverlay extends StatelessWidget {
  final Widget child;
  const _ProLockedOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: AppColors.background.withValues(alpha: 0.98),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.coral.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: AppColors.coral, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text('Multi-Hobby Tracking',
                      style: AppTypography.title
                          .copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(
                    'Free accounts support one active hobby.\nUpgrade to Pro to track multiple hobbies at once.',
                    style: AppTypography.sansBodySmall
                        .copyWith(color: AppColors.textSecondary, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.push('/pro'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('Unlock Pro', style: AppTypography.button),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SINGLE HOBBY PAGE
// ═══════════════════════════════════════════════════════

class _HobbyPage extends ConsumerWidget {
  final UserHobby userHobby;

  const _HobbyPage({super.key, required this.userHobby});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(userHobby.hobbyId));

    return hobbyAsync.when(
      loading: () => const LogoLoader(),
      error: (_, __) => const Center(
          child: Text('Failed to load hobby',
              style: TextStyle(color: AppColors.textMuted))),
      data: (hobby) {
        if (hobby == null) {
          // Stale local entry — hobby was deleted from DB.
          // Auto-remove so it doesn't block the Home screen.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(userHobbiesProvider.notifier).removeHobby(userHobby.hobbyId);
          });
          return const SizedBox.shrink();
        }
        return ActiveHobbyPage(hobby: hobby, userHobby: userHobby);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
//  EMPTY HOME STATE
// ═══════════════════════════════════════════════════════

class _EmptyHomeState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.compassOutline,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 24),
                Text('Ready to find\nyour thing?',
                    textAlign: TextAlign.center, style: AppTypography.hero),
                const SizedBox(height: 12),
                Text(
                  'Pick a hobby that fits your life.\nWe\'ll help you actually start it.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: () => context.go('/discover'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text('Discover hobbies',
                          style: AppTypography.button
                              .copyWith(color: AppColors.textPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
