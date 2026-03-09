import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/glass_card.dart';
import '../../components/roadmap_step_tile.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Home tab — cinematic active hobby dashboard.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);

    final activeEntries = userHobbies.entries
        .where((e) =>
            e.value.status == HobbyStatus.trying ||
            e.value.status == HobbyStatus.active)
        .toList();

    if (activeEntries.isEmpty) {
      return _EmptyHomeState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page dots (if multiple)
            if (activeEntries.length > 1) ...[
              const SizedBox(height: 8),
              _PageDots(
                count: activeEntries.length,
                current: _currentPage,
              ),
            ],
            const SizedBox(height: 8),

            // Swipeable hobby pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: activeEntries.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final userHobby = activeEntries[i].value;
                  return _HobbyPage(
                    key: ValueKey(userHobby.hobbyId),
                    userHobby: userHobby,
                    greeting: _greeting(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE DOTS
// ═══════════════════════════════════════════════════════

class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.textPrimary : AppColors.textWhisper,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SINGLE HOBBY PAGE
// ═══════════════════════════════════════════════════════

class _HobbyPage extends ConsumerWidget {
  final UserHobby userHobby;
  final String greeting;

  const _HobbyPage({super.key, required this.userHobby, required this.greeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(userHobby.hobbyId));

    return hobbyAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => Center(
          child: Text('Failed to load hobby',
              style: TextStyle(color: AppColors.textMuted))),
      data: (hobby) {
        if (hobby == null) {
          return Center(
              child: Text('Hobby not found',
                  style: TextStyle(color: AppColors.textMuted)));
        }
        return _HobbyPageContent(
            hobby: hobby, userHobby: userHobby, greeting: greeting);
      },
    );
  }
}

class _HobbyPageContent extends ConsumerStatefulWidget {
  final Hobby hobby;
  final UserHobby userHobby;
  final String greeting;

  const _HobbyPageContent({
    required this.hobby,
    required this.userHobby,
    required this.greeting,
  });

  @override
  ConsumerState<_HobbyPageContent> createState() =>
      _HobbyPageContentState();
}

class _HobbyPageContentState extends ConsumerState<_HobbyPageContent> {
  bool _roadmapExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hobby = widget.hobby;
    final userHobby = widget.userHobby;
    final scheduleEvents = ref.watch(scheduleProvider);
    final journalEntries = ref.watch(journalProvider);

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid =
        userHobby.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final progress =
        totalSteps > 0 ? completedValid.length / totalSteps : 0.0;

    final hobbySchedule =
        scheduleEvents.where((e) => e.hobbyId == hobby.id).toList();
    final hobbyJournal =
        journalEntries.where((e) => e.hobbyId == hobby.id).toList();

    final daysSinceActivity = userHobby.lastActivityAt != null
        ? DateTime.now().difference(userHobby.lastActivityAt!).inDays
        : (userHobby.startedAt != null
            ? DateTime.now().difference(userHobby.startedAt!).inDays
            : 0);

    // Find current step
    RoadmapStep? nextStep;
    for (int i = 0; i < hobby.roadmapSteps.length; i++) {
      final step = hobby.roadmapSteps[i];
      if (!completedValid.contains(step.id)) {
        final prevDone = i == 0 ||
            completedValid.contains(hobby.roadmapSteps[i - 1].id);
        if (prevDone) {
          nextStep = step;
          break;
        }
      }
    }

    final startedAt = userHobby.startedAt ?? DateTime.now();
    final weekNum =
        (DateTime.now().difference(startedAt).inDays / 7).floor() + 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, Spacing.scrollBottomPadding),
      children: [
        // ── Hero image with gradient overlay ──
        GestureDetector(
          onTap: () => context.push('/hobby/${hobby.id}'),
          child: SizedBox(
            height: 220,
            width: double.infinity,
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
                // Gradient fade to background at bottom
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withAlpha(40),
                        AppColors.background,
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                ),
                // Category + streak badges
                Positioned(
                  top: 12,
                  left: 24,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

        // ── Content below image ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting + overline
              const SizedBox(height: 4),
              Text(
                'Week $weekNum of ${hobby.title}'.toUpperCase(),
                style:
                    AppTypography.overline.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(widget.greeting, style: AppTypography.hero),
              const SizedBox(height: 24),

              // Restart prompt (stalled 3+ days)
              if (daysSinceActivity >= 3) ...[
                _RestartCard(
                  hobbyTitle: hobby.title,
                  daysSince: daysSinceActivity,
                  onPickUp: () => context.push('/hobby/${hobby.id}'),
                  onSwitch: () => context.go('/discover'),
                ),
                const SizedBox(height: 20),
              ],

              // ── Your next step ──
              if (nextStep != null) ...[
                GlassCard(
                  blur: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR NEXT STEP',
                          style: AppTypography.overline
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 10),
                      Text(nextStep.title, style: AppTypography.display),
                      if (nextStep.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          nextStep.description,
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            '${completedValid.length}/$totalSteps steps',
                            style: AppTypography.data
                                .copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 3,
                                backgroundColor: AppColors.textWhisper,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(userHobbiesProvider.notifier)
                              .toggleStep(hobby.id, nextStep!.id);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text('Mark as done',
                                style: AppTypography.button
                                    .copyWith(color: AppColors.background)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Roadmap (collapsible) ──
              if (hobby.roadmapSteps.isNotEmpty) ...[
                GlassCard(
                  onTap: () =>
                      setState(() => _roadmapExpanded = !_roadmapExpanded),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('YOUR ROADMAP',
                              style: AppTypography.overline
                                  .copyWith(color: AppColors.textMuted)),
                          const Spacer(),
                          Text(
                            '${completedValid.length}/$totalSteps',
                            style: AppTypography.data
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _roadmapExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(MdiIcons.chevronDown,
                                size: 18, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      // Progress bar always visible
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: AppColors.textWhisper,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded roadmap steps
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children:
                          hobby.roadmapSteps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        final isCompleted =
                            completedValid.contains(step.id);
                        final previousDone = index == 0 ||
                            completedValid.contains(
                                hobby.roadmapSteps[index - 1].id);
                        final isCurrent = !isCompleted && previousDone;

                        return RoadmapStepTile(
                          step: step,
                          stepNumber: index + 1,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          onToggle: () {
                            ref
                                .read(userHobbiesProvider.notifier)
                                .toggleStep(hobby.id, step.id);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  crossFadeState: _roadmapExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
                const SizedBox(height: 16),
              ],

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
                          'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
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
                                style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary),
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
              GlassCard(
                onTap: () => context.push('/coach/${hobby.id}'),
                child: Row(
                  children: [
                    Icon(MdiIcons.chatProcessingOutline,
                        size: 22, color: AppColors.textSecondary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need help?',
                              style:
                                  AppTypography.title.copyWith(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Ask your coach for guidance',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(MdiIcons.chevronRight,
                        size: 20, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Recent progress ──
              Text('RECENT PROGRESS',
                  style: AppTypography.overline
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 10),
              if (hobbyJournal.isNotEmpty)
                _JournalPreviewCard(
                  entry: hobbyJournal.first,
                  onTap: () => context.push('/journal'),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: GlassCard(
                    child: Column(
                      children: [
                        Icon(MdiIcons.noteEditOutline,
                            size: 28, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        Text('No journal entries yet',
                            style: AppTypography.body
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          'After your first session, write down how it went.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
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
//  RESTART CARD (stalled 3+ days)
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
            style:
                AppTypography.caption.copyWith(color: AppColors.textMuted),
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
                          style: AppTypography.button
                              .copyWith(color: AppColors.background)),
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

class _JournalPreviewCard extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onTap;

  const _JournalPreviewCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt as DateTime;
    final daysAgo = DateTime.now().difference(date).inDays;
    final dateLabel = daysAgo == 0
        ? 'Today'
        : (daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago');

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.bookOpenPageVariantOutline,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('Journal',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
              const Spacer(),
              Text(dateLabel,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.text as String,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  EMPTY HOME STATE (no active hobby)
// ═══════════════════════════════════════════════════════

class _EmptyHomeState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.compassOutline,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 24),
              Text(
                'Ready to find\nyour thing?',
                textAlign: TextAlign.center,
                style: AppTypography.hero,
              ),
              const SizedBox(height: 12),
              Text(
                'Pick a hobby that fits your life.\nWe\'ll help you actually start it.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
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
                            .copyWith(color: AppColors.background)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
