import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
import 'paused_hobby_page.dart';
import 'home_roadmap_section.dart';

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
        return _HobbyPageContent(hobby: hobby, userHobby: userHobby);
      },
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
              RoadmapJourney(
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

                return Column(
                  children: [
                    PlanFirstSessionCard(
                      hobbyId: hobby.id,
                      isLocked: false,
                      title: coachTitle,
                      subtitle: coachSubtitle,
                      coachMessage: coachMessage,
                      coachMode: coachMode,
                      autoSend: autoSend,
                    ),
                    const SizedBox(height: 8),
                    // Open coach freely — no pre-filled message
                    GestureDetector(
                      onTap: () => context.push('/coach/${hobby.id}'),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(Icons.auto_awesome,
                                size: 14,
                                color: AppColors.textMuted),
                            const SizedBox(width: 10),
                            Text(
                              'Ask anything about ${hobby.title}...',
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded,
                                size: 14, color: AppColors.textWhisper),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
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
