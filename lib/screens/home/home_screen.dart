import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../router.dart' show rootNavigatorKey;
import '../session/hobby_completion_screen.dart';
import '../../components/app_background.dart';
import '../../components/app_overlays.dart';
import '../../components/glass_card.dart';
import '../../components/hobby_quick_links.dart';
import '../../components/logo_loader.dart';
import '../../components/plan_first_session_card.dart';
import '../../components/page_dots.dart';
import '../../components/starter_kit_card.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

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

    // Check for completed hobbies to show completed state when no active hobbies
    final doneEntries = userHobbies.entries
        .where((e) => e.value.status == HobbyStatus.done)
        .toList()
      ..sort((a, b) {
        final aTime = a.value.completedAt ?? DateTime(0);
        final bTime = b.value.completedAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

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
                    return _PausedHobbyPage(
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
        return _HobbyPageContent(hobby: hobby, userHobby: userHobby);
      },
    );
  }
}

// ===============================================
//  PAUSED HOBBY PAGE
// ===============================================

class _PausedHobbyPage extends ConsumerWidget {
  final UserHobby userHobby;
  final VoidCallback? onResume;
  const _PausedHobbyPage({super.key, required this.userHobby, this.onResume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(userHobby.hobbyId));
    return hobbyAsync.when(
      data: (hobby) {
        if (hobby == null) return const SizedBox.shrink();
        final daysPaused = userHobby.pausedAt != null
            ? DateTime.now().difference(userHobby.pausedAt!).inDays
            : 0;
        // Full-screen blurred hobby image with centered pause overlay
        return Stack(
          fit: StackFit.expand,
          children: [
            // Blurred hobby image fills entire screen
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceElevated),
              ),
            ),

            // Dark overlay
            Container(color: AppColors.background.withValues(alpha: 0.75)),

            // Centered pause info + Resume CTA
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "PAUSED" chip (top)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: Text('PAUSED',
                            style: AppTypography.overline
                                .copyWith(color: AppColors.textMuted, letterSpacing: 2)),
                      ),
                      const SizedBox(height: 20),

                      // Hobby title
                      Text(
                        hobby.title,
                        style: AppTypography.display,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Days counter
                      Text(
                        daysPaused == 0
                            ? 'Paused today'
                            : 'Paused for $daysPaused ${daysPaused == 1 ? "day" : "days"}',
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),

                      // Progress note
                      Text(
                        'Your progress is saved.',
                        style: AppTypography.sansTiny
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 32),

                      // Coral "Resume" CTA
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(userHobbiesProvider.notifier)
                              .resumeHobby(hobby.id);
                          onResume?.call();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [AppColors.coral, Color(0xFFFF5252)],
                            ),
                          ),
                          child: Center(
                            child: Text('Resume',
                                style: AppTypography.button
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // View detail link
                      GestureDetector(
                        onTap: () => context.push('/hobby/${hobby.id}'),
                        child: Text(
                          'View hobby details',
                          style: AppTypography.sansTiny.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: LogoLoader()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HobbyPageContent extends ConsumerStatefulWidget {
  final Hobby hobby;
  final UserHobby userHobby;

  const _HobbyPageContent({
    required this.hobby,
    required this.userHobby,
  });

  @override
  ConsumerState<_HobbyPageContent> createState() => _HobbyPageContentState();
}

class _HobbyPageContentState extends ConsumerState<_HobbyPageContent> {
  bool _restartDismissed = false;

  /// Confirmation sheet before stopping/abandoning a hobby.
  void _showStopConfirmation(
      BuildContext context, WidgetRef ref, Hobby hobby) {
    showAppSheet(
      context: context,
      title: 'Stop ${hobby.title}?',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your progress won\'t be saved. ${hobby.title} will move to your Tried tab.',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(userHobbiesProvider.notifier)
                      .stopHobby(hobby.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Stop hobby', style: AppTypography.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirmation sheet before pausing a hobby (Pro only).
  void _showPauseConfirmation(
      BuildContext context, WidgetRef ref, Hobby hobby) {
    showAppSheet(
      context: context,
      title: 'Pause ${hobby.title}?',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your progress will be saved. Resume anytime.',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                ref
                    .read(userHobbiesProvider.notifier)
                    .pauseHobby(hobby.id);
                // Jump PageView to this hobby's new position (end of list)
                context.go('/home?hobby=${hobby.id}');
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, Color(0xFFFF5252)],
                  ),
                ),
                child: Center(
                  child: Text('Pause hobby',
                      style: AppTypography.button
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Cancel',
                    style: AppTypography.button
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hobby = widget.hobby;
    final userHobby = widget.userHobby;
    final scheduleEvents = ref.watch(scheduleProvider);
    final journalEntries = ref.watch(journalProvider);

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid =
        userHobby.completedStepIds.intersection(validStepIds);
    final hobbySchedule =
        scheduleEvents.where((e) => e.hobbyId == hobby.id).toList();
    final hobbyJournal =
        journalEntries.where((e) => e.hobbyId == hobby.id).toList();

    final daysSinceActivity = userHobby.lastActivityAt != null
        ? DateTime.now().difference(userHobby.lastActivityAt!).inDays
        : (userHobby.startedAt != null
            ? DateTime.now().difference(userHobby.startedAt!).inDays
            : 0);

    // Default active step = first non-completed in order
    String? defaultActiveStepId;
    for (int i = 0; i < hobby.roadmapSteps.length; i++) {
      final step = hobby.roadmapSteps[i];
      if (!completedValid.contains(step.id)) {
        defaultActiveStepId = step.id;
        break;
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, Spacing.scrollBottom(context)),
      children: [
        // ── Hero image with gradient overlay ──
        GestureDetector(
          onTap: () => context.push('/hobby/${hobby.id}'),
          child: SizedBox(
            height: 250,
            width: double.infinity,
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.25, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: hobby.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceElevated),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceElevated,
                      child: Icon(AppIcons.categoryIcon(hobby.category),
                          size: 48, color: AppColors.textMuted),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background.withAlpha(180),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hobby.category.toUpperCase(),
                        style: AppTypography.overline
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  if (userHobby.streakDays > 0)
                    Positioned(
                      top: 12,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background.withAlpha(180),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(MdiIcons.fire,
                                size: 14, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${userHobby.streakDays}d streak',
                              style: AppTypography.data
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── Content below image ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Builder(builder: (_) {
                      final words = hobby.title.split(' ');
                      if (words.length <= 1) {
                        return Text(hobby.title, style: AppTypography.hero);
                      }
                      return Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: words.first,
                            style: AppTypography.hero
                                .copyWith(color: AppColors.coral),
                          ),
                          TextSpan(
                            text: ' ${words.skip(1).join(' ')}',
                            style: AppTypography.hero,
                          ),
                        ]),
                      );
                    }),
                  ),
                  // 3-dot menu for hobby actions
                  Builder(builder: (context) {
                    final isPro = ref.watch(isProProvider);
                    return PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded,
                          color: AppColors.textMuted, size: 20),
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: AppColors.glassBorder, width: 0.5),
                      ),
                      onSelected: (value) {
                        if (value == 'pause') {
                          _showPauseConfirmation(context, ref, hobby);
                        } else if (value == 'stop') {
                          _showStopConfirmation(context, ref, hobby);
                        }
                      },
                      itemBuilder: (_) => [
                        if (isPro)
                          PopupMenuItem(
                            value: 'pause',
                            child: Row(
                              children: [
                                Icon(Icons.pause_circle_outline,
                                    size: 16,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 10),
                                Text('Pause hobby',
                                    style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'stop',
                          child: Row(
                            children: [
                              Icon(Icons.stop_circle_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary),
                              const SizedBox(width: 10),
                              Text('Stop hobby',
                                  style: AppTypography.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Restart prompt (stalled 3+ days)
              if (daysSinceActivity >= 3)
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _restartDismissed
                        ? const SizedBox.shrink(key: ValueKey('empty'))
                        : Padding(
                            key: const ValueKey('restart'),
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _RestartCard(
                              hobbyTitle: hobby.title,
                              daysSince: daysSinceActivity,
                              onPickUp: () =>
                                  context.push('/hobby/${hobby.id}'),
                              onSwitch: () =>
                                  setState(() => _restartDismissed = true),
                            ),
                          ),
                  ),
                ),

              // ── Roadmap Journey ──
              _RoadmapJourney(
                hobby: hobby,
                completedStepIds: completedValid,
                defaultActiveStepId: defaultActiveStepId,
              ),
              const SizedBox(height: 16),

              // ── This week's plan ──
              if (hobbySchedule.isNotEmpty) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THIS WEEK',
                          style: AppTypography.overline
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 10),
                      ...hobbySchedule.map((event) {
                        final dayNames = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        final dayName =
                            event.dayOfWeek >= 1 && event.dayOfWeek <= 7
                                ? dayNames[event.dayOfWeek - 1]
                                : '?';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                child: Text(dayName,
                                    style: AppTypography.data.copyWith(
                                        color: AppColors.textPrimary)),
                              ),
                              Text(
                                '${event.startTime} · ${event.durationMinutes} min',
                                style: AppTypography.body
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Coach entry ──
              Builder(builder: (context) {
                final stepsCompleted = completedValid.length;
                final totalSteps = hobby.roadmapSteps.length;

                String coachTitle;
                String coachSubtitle;
                String coachMessage;
                String coachMode;
                bool autoSend;

                if (daysSinceActivity >= 7) {
                  coachTitle = 'Get back on track';
                  coachSubtitle =
                      'It\'s been $daysSinceActivity days \u2014 let\'s restart gently';
                  coachMessage =
                      'I skipped $daysSinceActivity days of ${hobby.title}. Help me restart gently.';
                  coachMode = 'rescue';
                  autoSend = false;
                } else if (stepsCompleted == 0) {
                  coachTitle = 'Plan your first session';
                  coachSubtitle = 'Get a tiny first-session plan, no experience needed.';
                  coachMessage =
                      'Help me start tonight. I want a tiny first session plan for ${hobby.title}.';
                  coachMode = 'start';
                  autoSend = false;
                } else {
                  coachTitle = 'What should I do next?';
                  coachSubtitle = '$stepsCompleted of $totalSteps steps done';
                  coachMessage =
                      'What should I do next? I\'ve completed $stepsCompleted of $totalSteps steps.';
                  coachMode = 'momentum';
                  autoSend = true;
                }

                return PlanFirstSessionCard(
                  hobbyId: hobby.id,
                  isLocked: false,
                  title: coachTitle,
                  subtitle: coachSubtitle,
                  coachMessage: coachMessage,
                  coachMode: coachMode,
                  autoSend: autoSend,
                );
              }),
              const SizedBox(height: 16),

              // ── Starter kit ──
              if (hobby.starterKit.isNotEmpty) ...[
                StarterKitCard(hobby: hobby),
                const SizedBox(height: 16),
              ],

              // ── Cost breakdown & Beginner FAQ ──
              HobbyQuickLinks(hobbyId: hobby.id),
              const SizedBox(height: 16),

              // ── Journal ──
              Row(
                children: [
                  Text('JOURNAL',
                      style: AppTypography.overline
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/journal'),
                    child: const Icon(Icons.add_circle_outline_rounded,
                        size: 18, color: AppColors.coral),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(
                        '/journal?hobby=${hobby.id}'),
                    child: Text('View all',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recent entries (up to 3)
              if (hobbyJournal.isNotEmpty)
                ...hobbyJournal.take(3).map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _JournalEntryTile(
                        entry: entry,
                        onTap: () => context.push(
                            '/journal?hobby=${hobby.id}'),
                      ),
                    ))
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('No entries yet',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  RESTART CARD
// ═══════════════════════════════════════════════════════

class _RestartCard extends StatelessWidget {
  final String hobbyTitle;
  final int daysSince;
  final VoidCallback onPickUp;
  final VoidCallback onSwitch;

  const _RestartCard({
    required this.hobbyTitle,
    required this.daysSince,
    required this.onPickUp,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'It\'s been $daysSince days since your last session.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'No pressure. Pick up where you left off, or try something different.',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPickUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text("Let's go",
                          style: AppTypography.button.copyWith(
                              color: const Color.fromARGB(255, 255, 255, 255))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onSwitch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.glassBorder, width: 0.5),
                    ),
                    child: Center(
                      child: Text('Maybe later',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  JOURNAL PREVIEW CARD
// ═══════════════════════════════════════════════════════

class _JournalEntryTile extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onTap;

  const _JournalEntryTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt as DateTime;
    final daysAgo = DateTime.now().difference(date).inDays;
    final dateLabel = daysAgo == 0
        ? 'Today'
        : (daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago');
    final hasPhoto = (entry.photoUrl as String?) != null &&
        (entry.photoUrl as String).isNotEmpty;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo thumbnail or icon
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: entry.photoUrl as String,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                memCacheWidth: 88,
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(MdiIcons.noteEditOutline,
                  size: 18, color: AppColors.textMuted),
            ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.text as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(dateLabel,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COMPLETED HOME STATE
// ═══════════════════════════════════════════════════════

class _CompletedHomeState extends ConsumerWidget {
  final String hobbyId;
  final UserHobby userHobby;

  const _CompletedHomeState({
    required this.hobbyId,
    required this.userHobby,
  });

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(hobbyId));
    final hobby = hobbyAsync.valueOrNull;

    final completedSteps = userHobby.completedStepIds.length;
    final daysActive = userHobby.startedAt != null
        ? DateTime.now().difference(userHobby.startedAt!).inDays
        : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _greetingText(),
                  style: AppTypography.body
                      .copyWith(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Completed hobby glass card
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated checkmark
                      Icon(Icons.check_circle_rounded,
                              size: 48, color: AppColors.success)
                          .animate()
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 300.ms),
                      const SizedBox(height: 16),

                      // Hobby title
                      Text(
                        hobby?.title ?? 'Hobby',
                        style: AppTypography.title
                            .copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // "Completed" label
                      Text(
                        'Completed',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.success),
                      ),
                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CompletedStat(
                            value: '$completedSteps',
                            label: 'steps',
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: AppColors.glassBorder,
                          ),
                          _CompletedStat(
                            value: '${daysActive}d',
                            label: 'active',
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: AppColors.glassBorder,
                          ),
                          _CompletedStat(
                            value: '${userHobby.streakDays}d',
                            label: 'streak',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Coral CTA — discover next hobby
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.go('/discover'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('Find your next hobby',
                        style: AppTypography.button),
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

class _CompletedStat extends StatelessWidget {
  final String value;
  final String label;
  const _CompletedStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: AppTypography.title
                .copyWith(color: AppColors.textPrimary, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textMuted)),
      ],
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

// ═══════════════════════════════════════════════════════
//  ROADMAP JOURNEY
// ═══════════════════════════════════════════════════════

const _tealBg = Color(0x0A068BA8);
const _tealBgActive = Color(0x14068BA8);
const _tealBorder = Color(0x14068BA8);
const _tealBorderActive = Color(0x33068BA8);
const _tealText = Color(0x805CB8C9);
const _tealTextBright = Color(0xFF5CB8C9);
const _tealBar = Color(0x995CB8C9);

class _RoadmapJourney extends ConsumerStatefulWidget {
  final Hobby hobby;
  final Set<String> completedStepIds;
  final String? defaultActiveStepId;

  const _RoadmapJourney({
    required this.hobby,
    required this.completedStepIds,
    this.defaultActiveStepId,
  });

  @override
  ConsumerState<_RoadmapJourney> createState() => _RoadmapJourneyState();
}

class _RoadmapJourneyState extends ConsumerState<_RoadmapJourney> {
  String? _expandedTipStepId;
  String? _focusedStepId;

  @override
  void initState() {
    super.initState();
    _focusedStepId = widget.defaultActiveStepId;
  }

  @override
  void didUpdateWidget(covariant _RoadmapJourney old) {
    super.didUpdateWidget(old);
    if (_focusedStepId != null &&
        widget.completedStepIds.contains(_focusedStepId) &&
        !old.completedStepIds.contains(_focusedStepId!)) {
      for (final step in widget.hobby.roadmapSteps) {
        if (!widget.completedStepIds.contains(step.id)) {
          setState(() {
            _focusedStepId = step.id;
            _expandedTipStepId = null;
          });
          return;
        }
      }
      setState(() => _focusedStepId = null);
    }
  }

  void _setFocusedStep(String stepId) {
    if (_focusedStepId == stepId) return;
    HapticFeedback.selectionClick();
    setState(() {
      _focusedStepId = stepId;
      _expandedTipStepId = null;
    });
  }

  /// Confirmation sheet before uncompleting a step.
  void _showUncompleteConfirmation(BuildContext context, RoadmapStep step) {
    showAppSheet(
      context: context,
      title: 'Mark as incomplete?',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will remove your progress for this step. Are you sure?',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.glassBackground,
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusButton),
                        border: Border.all(
                            color: AppColors.glassBorder, width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final hobbyCompleted = await ref
                          .read(userHobbiesProvider.notifier)
                          .toggleStep(widget.hobby.id, step.id);
                      if (hobbyCompleted && context.mounted) {
                        rootNavigatorKey.currentState?.push(
                          HobbyCompletionScreen.route(
                            hobbyId: widget.hobby.id,
                            hobbyTitle: widget.hobby.title,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusButton),
                        border: Border.all(
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                            width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          'Mark Incomplete',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet for marking an incomplete step complete without a session.
  void _showMarkCompleteSheet(BuildContext context, RoadmapStep step) {
    showAppSheet(
      context: context,
      title: 'Mark as complete?',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You can mark this step done if you\'ve already completed it outside the app.',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Primary CTA: Start Session (coral)
            GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                HapticFeedback.lightImpact();
                final i = widget.hobby.roadmapSteps
                    .indexWhere((s) => s.id == step.id);
                final followingTitle = i + 1 < widget.hobby.roadmapSteps.length
                    ? widget.hobby.roadmapSteps[i + 1].title
                    : null;
                context.push(
                  '/session/${widget.hobby.id}/${step.id}',
                  extra: <String, dynamic>{
                    'hobbyTitle': widget.hobby.title,
                    'hobbyCategory': widget.hobby.category,
                    'stepTitle': step.title,
                    'stepDescription': step.description,
                    'stepInstructions': '',
                    'whatYouNeed': '',
                    'recommendedMinutes': step.estimatedMinutes,
                    'completionMode': step.effectiveMode,
                    'nextStepTitle': followingTitle,
                    'completionMessage': step.completionMessage,
                    'coachTip': step.coachTip,
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Start Session',
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Secondary: Mark Complete (text-style)
            GestureDetector(
              onTap: () async {
                Navigator.of(ctx).pop();
                final hobbyCompleted = await ref
                    .read(userHobbiesProvider.notifier)
                    .toggleStep(widget.hobby.id, step.id);
                if (hobbyCompleted && context.mounted) {
                  rootNavigatorKey.currentState?.push(
                    HobbyCompletionScreen.route(
                      hobbyId: widget.hobby.id,
                      hobbyTitle: widget.hobby.title,
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                ),
                child: Center(
                  child: Text(
                    'Mark Complete',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.hobby.roadmapSteps;
    final completed = widget.completedStepIds;
    final total = steps.length;
    final doneCount = completed.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('YOUR JOURNEY',
                style: AppTypography.overline
                    .copyWith(color: AppColors.textMuted)),
            const Spacer(),
            Text('$doneCount / $total',
                style: AppTypography.monoBadge
                    .copyWith(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: total > 0 ? doneCount / total : 0,
            backgroundColor: AppColors.textWhisper,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          final isCompleted = completed.contains(step.id);
          final isFocused = step.id == _focusedStepId && !isCompleted;
          final isLast = i == steps.length - 1;
          Color lineColor = AppColors.textWhisper;
          if (!isLast && isCompleted && completed.contains(steps[i + 1].id)) {
            lineColor = AppColors.success;
          }
          return _StepItem(
            key: ValueKey('step_${step.id}'),
            step: step,
            stepNumber: i + 1,
            isCompleted: isCompleted,
            isFocused: isFocused,
            isLast: isLast,
            lineColor: lineColor,
            hobby: widget.hobby,
            tipExpanded: _expandedTipStepId == step.id,
            onToggleTip: () => setState(() {
              _expandedTipStepId =
                  _expandedTipStepId == step.id ? null : step.id;
            }),
            onTap: () {
              if (isCompleted) {
                _showUncompleteConfirmation(context, step);
              } else if (!isFocused) {
                _setFocusedStep(step.id);
              } else {
                _showMarkCompleteSheet(context, step);
              }
            },
            staggerIndex: i,
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STEP ITEM
//
//  Architecture:
//  - IntrinsicHeight + CrossAxisAlignment.stretch so the
//    left rail line ALWAYS fills the full row height
//  - Right side: a single Column. Each expandable section
//    uses AnimatedSize → SizedBox.shrink() when hidden.
//    NO SizedBox(width: double.infinity) — that causes
//    layout conflicts during animation.
//  - Card background: AnimatedContainer wrapping the Column,
//    transitions decoration from BoxDecoration() to the coral card.
//  - Title row: simple. No nested Rows that can overflow.
//    "UP NEXT" + milestone shown ABOVE the title when focused.
// ═══════════════════════════════════════════════════════

class _StepItem extends ConsumerWidget {
  final RoadmapStep step;
  final int stepNumber;
  final bool isCompleted;
  final bool isFocused;
  final bool isLast;
  final Color lineColor;
  final Hobby hobby;
  final bool tipExpanded;
  final VoidCallback onToggleTip;
  final VoidCallback onTap;
  final int staggerIndex;

  const _StepItem({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.isCompleted,
    required this.isFocused,
    required this.isLast,
    required this.lineColor,
    required this.hobby,
    required this.tipExpanded,
    required this.onToggleTip,
    required this.onTap,
    required this.staggerIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachTip = step.coachTip;
    final completionMessage = step.completionMessage;
    final isFuture = !isCompleted && !isFocused;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        if (!isLast)
          Positioned(
            left: 19,
            top: (isFocused ? 4.0 : 8.0) +
                (isFocused ? 36.0 : (isCompleted ? 26.0 : 22.0)),
            bottom: 2,
            width: 2,
            child: Container(color: lineColor),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ LEFT RAIL ═══
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  SizedBox(height: isFocused ? 4 : 8),
                  // Node — instant color/size change (150ms)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    width: isFocused ? 36 : (isCompleted ? 26 : 22),
                    height: isFocused ? 36 : (isCompleted ? 26 : 22),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : isFocused
                              ? AppColors.accent
                              : Colors.transparent,
                      border: !isCompleted && !isFocused
                          ? Border.all(color: AppColors.textWhisper, width: 1.5)
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 12)
                            ]
                          : isCompleted
                              ? [
                                  BoxShadow(
                                      color: AppColors.success
                                          .withValues(alpha: 0.2),
                                      blurRadius: 6)
                                ]
                              : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                fontSize: isFocused ? 14 : 10,
                                fontWeight: FontWeight.w800,
                                color: isFocused
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ═══ RIGHT CONTENT — single AnimatedSize wraps everything ═══
            // ═══ RIGHT CONTENT ═══
            Expanded(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment: Alignment.topLeft,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  padding: isFocused
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(vertical: 8),
                  margin: isFocused
                      ? const EdgeInsets.only(top: 4, bottom: 8)
                      : EdgeInsets.zero,
                  decoration: isFocused
                      ? BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.18),
                              width: 1),
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // UP NEXT (focused only)
                      if (isFocused) ...[
                        Row(
                          children: [
                            Text('UP NEXT',
                                style: AppTypography.overline
                                    .copyWith(color: AppColors.accent)),
                            if (step.milestone != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '\u{1F3C6} ${step.milestone}',
                                  style: AppTypography.monoBadge.copyWith(
                                      color: AppColors.accent, fontSize: 9),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Title (always)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: isCompleted
                                  ? AppTypography.body.copyWith(
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: AppColors.textWhisper)
                                  : isFocused
                                      ? AppTypography.title
                                          .copyWith(fontSize: 17)
                                      : AppTypography.body.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (!isFocused &&
                              !isCompleted &&
                              step.milestone != null)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text('\u{1F3C6}',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          if (!isFocused && isFuture && coachTip != null)
                            GestureDetector(
                              onTap: onToggleTip,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                                child: Text('\u2726',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: tipExpanded
                                          ? _tealTextBright
                                          : const Color(0x665CB8C9),
                                    )),
                              ),
                            ),
                        ],
                      ),

                      // Description (focused only)
                      if (isFocused && step.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(step.description,
                            style: AppTypography.sansBodySmall
                                .copyWith(color: AppColors.textSecondary)),
                      ],

                      // Coach tip (focused only)
                      if (isFocused) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onToggleTip,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: tipExpanded ? _tealBgActive : _tealBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: tipExpanded
                                      ? _tealBorderActive
                                      : _tealBorder,
                                  width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Text('\u2726',
                                      style: TextStyle(
                                          fontSize: 15, color: _tealText)),
                                  const SizedBox(width: 8),
                                  Text(
                                    tipExpanded
                                        ? 'Coach tip'
                                        : (coachTip != null
                                            ? 'Tap for a coach tip'
                                            : 'Coach tip coming soon'),
                                    style: AppTypography.sansTiny.copyWith(
                                      color: _tealText,
                                      fontWeight: tipExpanded
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ]),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment.topLeft,
                                  clipBehavior: Clip.hardEdge,
                                  child: tipExpanded && coachTip != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 2.5,
                                                height: 40,
                                                margin: const EdgeInsets.only(
                                                    left: 6, right: 14),
                                                decoration: BoxDecoration(
                                                    color: _tealBar,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2)),
                                              ),
                                              Expanded(
                                                child: Text(coachTip,
                                                    style: AppTypography
                                                        .sansBodySmallThinItalic
                                                        .copyWith(
                                                            color: AppColors
                                                                .textSecondary)),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(
                                          width: double.infinity, height: 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Start session CTA (focused only)
                      if (isFocused) ...[
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final i = hobby.roadmapSteps
                                .indexWhere((s) => s.id == step.id);
                            final followingTitle =
                                i + 1 < hobby.roadmapSteps.length
                                    ? hobby.roadmapSteps[i + 1].title
                                    : null;
                            context.push(
                              '/session/${hobby.id}/${step.id}',
                              extra: <String, dynamic>{
                                'hobbyTitle': hobby.title,
                                'hobbyCategory': hobby.category,
                                'stepTitle': step.title,
                                'stepDescription': step.description,
                                'stepInstructions': '',
                                'whatYouNeed': '',
                                'recommendedMinutes': step.estimatedMinutes,
                                'completionMode': step.effectiveMode,
                                'nextStepTitle': followingTitle,
                                'completionMessage': completionMessage,
                                'coachTip': step.coachTip,
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow_rounded,
                                      size: 18, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('Start session',
                                      style: AppTypography.sansLabel.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Ask more (focused + tip open) — slides in smoothly
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topLeft,
                        clipBehavior: Clip.hardEdge,
                        child: isFocused && tipExpanded && coachTip != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 4),
                                child: GestureDetector(
                                  onTap: () => context.push(
                                    '/coach/${hobby.id}',
                                    extra: {
                                      'message':
                                          'Tell me more about "${step.title}" — any tips?',
                                      'mode': 'momentum',
                                      'autoSend': true,
                                    },
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _tealBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: _tealBorder, width: 1),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('\u2726',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: _tealText)),
                                          const SizedBox(width: 6),
                                          Text('Ask more about this step',
                                              style: AppTypography.sansTiny
                                                  .copyWith(color: _tealText)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(width: double.infinity, height: 0),
                      ),

                      // Inline tip (compact future only)
                      if (isFuture &&
                          !isFocused &&
                          tipExpanded &&
                          coachTip != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 2,
                              height: 32,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  color: _tealBar,
                                  borderRadius: BorderRadius.circular(1)),
                            ),
                            Expanded(
                              child: Text(coachTip,
                                  style: AppTypography.sansTiny.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    ).animate().fadeIn(
          duration: 500.ms,
          curve: Curves.easeOutCubic,
          delay: (80 * staggerIndex).ms,
        );
  }

  // ── Single widget with accordion reveal ──
  Widget _buildStepContent(BuildContext context, bool isFocused, bool isFuture,
      String? coachTip, String? completionMessage) {
    const dur = Duration(milliseconds: 350);
    const curve = Curves.easeOutCubic;

    return AnimatedContainer(
      duration: dur,
      curve: curve,
      padding: isFocused
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(vertical: 8),
      margin: isFocused
          ? const EdgeInsets.only(top: 4, bottom: 8)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isFocused
            ? AppColors.accent.withValues(alpha: 0.07)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(isFocused ? 18 : 0),
        border: isFocused
            ? Border.all(
                color: AppColors.accent.withValues(alpha: 0.18), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── UP NEXT + milestone (revealed when focused) ──
          AnimatedSize(
            duration: dur,
            curve: curve,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            child: isFocused
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text('UP NEXT',
                            style: AppTypography.overline
                                .copyWith(color: AppColors.accent)),
                        if (step.milestone != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '\u{1F3C6} ${step.milestone}',
                              style: AppTypography.monoBadge.copyWith(
                                  color: AppColors.accent, fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),

          // ── Title row (ALWAYS visible) ──
          Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: isCompleted
                      ? AppTypography.body.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textWhisper)
                      : isFocused
                          ? AppTypography.title.copyWith(fontSize: 17)
                          : AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                  child: Text(step.title),
                ),
              ),
              // Compact-only badges (fade out when focused)
              if (!isFocused && !isCompleted && step.milestone != null)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('\u{1F3C6}', style: TextStyle(fontSize: 12)),
                ),
              if (!isFocused && isFuture && coachTip != null)
                GestureDetector(
                  onTap: onToggleTip,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text('\u2726',
                        style: TextStyle(
                          fontSize: 13,
                          color: tipExpanded
                              ? _tealTextBright
                              : const Color(0x665CB8C9),
                        )),
                  ),
                ),
            ],
          ),

          // ── Description (revealed when focused) ──
          AnimatedSize(
            duration: dur,
            curve: curve,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            child: isFocused && step.description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(step.description,
                        style: AppTypography.sansBodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),

          // ── Coach tip block (revealed when focused) ──
          AnimatedSize(
            duration: dur,
            curve: curve,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            child: isFocused
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: onToggleTip,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tipExpanded ? _tealBgActive : _tealBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  tipExpanded ? _tealBorderActive : _tealBorder,
                              width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('\u2726',
                                  style: TextStyle(
                                      fontSize: 15, color: _tealText)),
                              const SizedBox(width: 8),
                              Text(
                                tipExpanded
                                    ? 'Coach tip'
                                    : (coachTip != null
                                        ? 'Tap for a coach tip'
                                        : 'Coach tip coming soon'),
                                style: AppTypography.sansTiny.copyWith(
                                  color: _tealText,
                                  fontWeight: tipExpanded
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ]),
                            // Tip text
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: curve,
                              alignment: Alignment.topLeft,
                              clipBehavior: Clip.hardEdge,
                              child: tipExpanded && coachTip != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 2.5,
                                            height: 40,
                                            margin: const EdgeInsets.only(
                                                left: 6, right: 14),
                                            decoration: BoxDecoration(
                                                color: _tealBar,
                                                borderRadius:
                                                    BorderRadius.circular(2)),
                                          ),
                                          Expanded(
                                            child: Text(coachTip,
                                                style: AppTypography
                                                    .sansBodySmall
                                                    .copyWith(
                                                        color: AppColors
                                                            .textSecondary)),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(
                                      width: double.infinity, height: 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),

          // ── Start session CTA (revealed when focused) ──
          AnimatedSize(
            duration: dur,
            curve: curve,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            child: isFocused
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final i = hobby.roadmapSteps
                            .indexWhere((s) => s.id == step.id);
                        final followingTitle = i + 1 < hobby.roadmapSteps.length
                            ? hobby.roadmapSteps[i + 1].title
                            : null;
                        context.push(
                          '/session/${hobby.id}/${step.id}',
                          extra: <String, dynamic>{
                            'hobbyTitle': hobby.title,
                            'hobbyCategory': hobby.category,
                            'stepTitle': step.title,
                            'stepDescription': step.description,
                            'stepInstructions': '',
                            'whatYouNeed': '',
                            'recommendedMinutes': step.estimatedMinutes,
                            'completionMode': step.effectiveMode,
                            'nextStepTitle': followingTitle,
                            'completionMessage': completionMessage,
                            'coachTip': step.coachTip,
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow_rounded,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('Start session',
                                  style: AppTypography.sansLabel.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),

          // ── Ask more link (focused + tip open) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: curve,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            child: isFocused && tipExpanded && coachTip != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: GestureDetector(
                      onTap: () => context.push(
                        '/coach/${hobby.id}',
                        extra: {
                          'message':
                              'Tell me more about "${step.title}" — any tips?',
                          'mode': 'momentum',
                          'autoSend': true,
                        },
                      ),
                      child: Center(
                        child: Text('Ask more about this step',
                            style: AppTypography.sansCaption.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textSecondary,
                            )),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),

          // ── Inline tip for compact future steps ──
          AnimatedSize(
            duration: dur,
            curve: curve,
            alignment: Alignment.topLeft,
            clipBehavior: Clip.hardEdge,
            child: isFuture && !isFocused && tipExpanded && coachTip != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2,
                          height: 32,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: _tealBar,
                              borderRadius: BorderRadius.circular(1)),
                        ),
                        Expanded(
                          child: Text(coachTip,
                              style: AppTypography.sansTiny
                                  .copyWith(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element, unused_element_parameter
  Widget _buildExpandedCard(
      BuildContext context, String? coachTip, String? completionMessage) {
    return Container(
      key: const ValueKey('expanded'),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UP NEXT + milestone
          Row(
            children: [
              Text('UP NEXT',
                  style:
                      AppTypography.overline.copyWith(color: AppColors.accent)),
              if (step.milestone != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '\u{1F3C6} ${step.milestone}',
                    style: AppTypography.monoBadge
                        .copyWith(color: AppColors.accent, fontSize: 9),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // Title
          Text(step.title, style: AppTypography.title.copyWith(fontSize: 17)),
          // Description
          if (step.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(step.description,
                style: AppTypography.sansBodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
          // Coach tip block
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onToggleTip,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tipExpanded ? _tealBgActive : _tealBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: tipExpanded ? _tealBorderActive : _tealBorder,
                    width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('\u2726',
                        style: TextStyle(fontSize: 15, color: _tealText)),
                    const SizedBox(width: 8),
                    Text(
                      tipExpanded
                          ? 'Coach tip'
                          : (coachTip != null
                              ? 'Tap for a coach tip'
                              : 'Coach tip coming soon'),
                      style: AppTypography.sansTiny.copyWith(
                        color: _tealText,
                        fontWeight:
                            tipExpanded ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ]),
                  if (tipExpanded && coachTip != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2.5,
                          height: 40,
                          margin: const EdgeInsets.only(left: 6, right: 14),
                          decoration: BoxDecoration(
                              color: _tealBar,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        Expanded(
                          child: Text(coachTip,
                              style: AppTypography.sansBodySmall
                                  .copyWith(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Start session CTA
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              final i = hobby.roadmapSteps.indexWhere((s) => s.id == step.id);
              final followingTitle = i + 1 < hobby.roadmapSteps.length
                  ? hobby.roadmapSteps[i + 1].title
                  : null;
              context.push(
                '/session/${hobby.id}/${step.id}',
                extra: <String, dynamic>{
                  'hobbyTitle': hobby.title,
                  'hobbyCategory': hobby.category,
                  'stepTitle': step.title,
                  'stepDescription': step.description,
                  'stepInstructions': '',
                  'whatYouNeed': '',
                  'recommendedMinutes': step.estimatedMinutes,
                  'completionMode': step.effectiveMode,
                  'nextStepTitle': followingTitle,
                  'completionMessage': completionMessage,
                  'coachTip': step.coachTip,
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Start session',
                        style: AppTypography.sansLabel.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          // Ask more link
          if (tipExpanded && coachTip != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: GestureDetector(
                onTap: () => context.push(
                  '/coach/${hobby.id}',
                  extra: {
                    'message': 'Tell me more about "${step.title}" — any tips?',
                    'mode': 'momentum',
                    'autoSend': true,
                  },
                ),
                child: Center(
                  child: Text('Ask more about this step',
                      style: AppTypography.sansCaption.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSecondary,
                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element, unused_element_parameter
  Widget _buildCompactRow(String? coachTip, bool isFuture) {
    return Padding(
      key: const ValueKey('compact'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: isCompleted
                      ? AppTypography.body.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textWhisper)
                      : AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                ),
              ),
              if (!isCompleted && step.milestone != null)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('\u{1F3C6}', style: TextStyle(fontSize: 12)),
                ),
              if (isFuture && coachTip != null)
                GestureDetector(
                  onTap: onToggleTip,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text('\u2726',
                        style: TextStyle(
                          fontSize: 13,
                          color: tipExpanded
                              ? _tealTextBright
                              : const Color(0x665CB8C9),
                        )),
                  ),
                ),
            ],
          ),
          // Inline tip for future steps
          if (isFuture && tipExpanded && coachTip != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: _tealBar, borderRadius: BorderRadius.circular(1)),
                ),
                Expanded(
                  child: Text(coachTip,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
