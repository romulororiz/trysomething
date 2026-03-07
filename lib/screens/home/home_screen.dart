import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/roadmap_step_tile.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Home tab — active hobby dashboard with swipeable hobbies.
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

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);

    // All active/trying hobbies
    final activeEntries = userHobbies.entries
        .where((e) =>
            e.value.status == HobbyStatus.trying ||
            e.value.status == HobbyStatus.active)
        .toList();

    if (activeEntries.isEmpty) {
      return _EmptyHomeState();
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Your Hobby', style: AppTypography.serifHeading),
                  if (activeEntries.length > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_currentPage + 1}/${activeEntries.length}',
                        style: AppTypography.monoBadgeSmall
                            .copyWith(color: AppColors.driftwood),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sand,
                      ),
                      child: Icon(MdiIcons.cogOutline,
                          size: 18, color: AppColors.driftwood),
                    ),
                  ),
                ],
              ),
            ),

            // Page dots
            if (activeEntries.length > 1) ...[
              const SizedBox(height: 12),
              _PageDots(
                count: activeEntries.length,
                current: _currentPage,
              ),
            ],

            const SizedBox(height: 16),

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
//  PAGE DOTS INDICATOR
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
            color: isActive ? AppColors.coral : AppColors.sand,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SINGLE HOBBY PAGE (loaded per-hobby)
// ═══════════════════════════════════════════════════════

class _HobbyPage extends ConsumerWidget {
  final UserHobby userHobby;

  const _HobbyPage({super.key, required this.userHobby});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(userHobby.hobbyId));

    return hobbyAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.coral)),
      error: (_, __) => const Center(
          child: Text('Failed to load hobby', style: TextStyle(color: AppColors.warmGray))),
      data: (hobby) {
        if (hobby == null) {
          return const Center(
              child: Text('Hobby not found', style: TextStyle(color: AppColors.warmGray)));
        }
        return _HobbyPageContent(hobby: hobby, userHobby: userHobby);
      },
    );
  }
}

class _HobbyPageContent extends ConsumerWidget {
  final Hobby hobby;
  final UserHobby userHobby;

  const _HobbyPageContent({required this.hobby, required this.userHobby});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleEvents = ref.watch(scheduleProvider);
    final journalEntries = ref.watch(journalProvider);

    // Only count completed steps that exist in current roadmap
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        // ── Active Hobby Card ──
        _HobbyCard(
          hobby: hobby,
          progress: progress,
          stepsCompleted: completedValid.length,
          totalSteps: totalSteps,
          streakDays: userHobby.streakDays,
          onTap: () => context.push('/hobby/${hobby.id}'),
        ),
        const SizedBox(height: 20),

        // ── Restart prompt (if stalled 3+ days) ──
        if (daysSinceActivity >= 3) ...[
          _RestartCard(
            hobbyTitle: hobby.title,
            daysSince: daysSinceActivity,
            onPickUp: () => context.push('/hobby/${hobby.id}'),
            onSwitch: () => context.go('/discover'),
          ),
          const SizedBox(height: 20),
        ],

        // ── Roadmap ──
        if (hobby.roadmapSteps.isNotEmpty) ...[
          Row(
            children: [
              Text('Your Roadmap', style: AppTypography.sansSection),
              const Spacer(),
              Text(
                '$totalSteps steps',
                style: AppTypography.monoCaption,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...hobby.roadmapSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = completedValid.contains(step.id);
            final previousDone = index == 0 ||
                completedValid.contains(hobby.roadmapSteps[index - 1].id);
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
          }),
          const SizedBox(height: 20),
        ],

        // ── This Week ──
        if (hobbySchedule.isNotEmpty) ...[
          Text('This Week', style: AppTypography.sansSection),
          const SizedBox(height: 10),
          ...hobbySchedule.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child:
                    _ScheduleCard(event: event, hobbyTitle: hobby.title),
              )),
          const SizedBox(height: 12),
        ],

        // ── Coach Entry ──
        _CoachCard(hobbyId: hobby.id),
        const SizedBox(height: 20),

        // ── Recent Progress ──
        Text('Recent Progress', style: AppTypography.sansSection),
        const SizedBox(height: 10),
        if (hobbyJournal.isNotEmpty)
          _JournalPreviewCard(
            entry: hobbyJournal.first,
            onTap: () => context.push('/journal'),
          )
        else
          _EmptyProgressCard(hobbyId: hobby.id),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  HOBBY CARD
// ═══════════════════════════════════════════════════════

class _HobbyCard extends StatelessWidget {
  final Hobby hobby;
  final double progress;
  final int stepsCompleted;
  final int totalSteps;
  final int streakDays;
  final VoidCallback onTap;

  const _HobbyCard({
    required this.hobby,
    required this.progress,
    required this.stepsCompleted,
    required this.totalSteps,
    required this.streakDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.warmWhite,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hobby image
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hobby.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.sand,
                      child: const Icon(Icons.image_outlined,
                          size: 40, color: AppColors.warmGray),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.warmWhite.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cream.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hobby.category.toUpperCase(),
                        style: AppTypography.categoryLabel
                            .copyWith(color: AppColors.coral),
                      ),
                    ),
                  ),
                  if (streakDays > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cream.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(MdiIcons.fire,
                                size: 14, color: AppColors.coral),
                            const SizedBox(width: 4),
                            Text(
                              '$streakDays days',
                              style: AppTypography.monoBadge
                                  .copyWith(color: AppColors.coral),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hobby.title, style: AppTypography.serifSubheading),
                  const SizedBox(height: 4),
                  Text(
                    hobby.hook,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sansBodySmall,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: AppColors.sand,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppColors.coral),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$stepsCompleted of $totalSteps steps',
                              style: AppTypography.monoCaption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                        style: AppTypography.monoMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SCHEDULE CARD
// ═══════════════════════════════════════════════════════

class _ScheduleCard extends StatelessWidget {
  final dynamic event;
  final String hobbyTitle;

  const _ScheduleCard({required this.event, required this.hobbyTitle});

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final dayName = event.dayOfWeek >= 1 && event.dayOfWeek <= 7
        ? _dayNames[event.dayOfWeek - 1]
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.coralPale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                dayName,
                style:
                    AppTypography.monoBadge.copyWith(color: AppColors.coral),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hobbyTitle, style: AppTypography.sansLabel),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(MdiIcons.clockOutline,
                        size: 13, color: AppColors.warmGray),
                    const SizedBox(width: 4),
                    Text(
                      '${event.startTime} · ${event.durationMinutes} min',
                      style: AppTypography.sansCaption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COACH CARD
// ═══════════════════════════════════════════════════════

class _CoachCard extends StatelessWidget {
  final String hobbyId;

  const _CoachCard({required this.hobbyId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/coach/$hobbyId'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.coralPale, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.coralPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(MdiIcons.robotHappyOutline,
                  size: 22, color: AppColors.coral),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Need help?', style: AppTypography.sansLabel),
                  const SizedBox(height: 2),
                  Text(
                    'Ask your AI coach for guidance',
                    style: AppTypography.sansCaption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.driftwood, size: 22),
          ],
        ),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.bookOpenPageVariantOutline,
                    size: 16, color: AppColors.coral),
                const SizedBox(width: 8),
                Text('Journal Entry', style: AppTypography.sansCaption),
                const Spacer(),
                Text(dateLabel, style: AppTypography.sansTiny),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.text as String,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sansBodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  EMPTY PROGRESS CARD
// ═══════════════════════════════════════════════════════

class _EmptyProgressCard extends StatelessWidget {
  final String hobbyId;

  const _EmptyProgressCard({required this.hobbyId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(MdiIcons.noteEditOutline, size: 32, color: AppColors.warmGray),
          const SizedBox(height: 10),
          Text('No journal entries yet', style: AppTypography.sansCaption),
          const SizedBox(height: 4),
          Text(
            'After your first session, write down how it went.',
            textAlign: TextAlign.center,
            style: AppTypography.sansTiny,
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amberPale, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.clockAlertOutline,
                  size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              Text(
                'It\'s been $daysSince days',
                style:
                    AppTypography.sansLabel.copyWith(color: AppColors.amber),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'No pressure. Pick up where you left off, or try something different.',
            style: AppTypography.sansBodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPickUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Pick up where I left off',
                        style: AppTypography.sansCta.copyWith(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onSwitch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Try something new',
                        style: AppTypography.sansLabel.copyWith(
                            color: AppColors.driftwood, fontSize: 12),
                      ),
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
//  EMPTY HOME STATE (no active hobby)
// ═══════════════════════════════════════════════════════

class _EmptyHomeState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.coralPale,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.explore_rounded,
                    size: 40, color: AppColors.coral),
              ),
              const SizedBox(height: 24),
              Text(
                'Ready to find\nyour thing?',
                textAlign: TextAlign.center,
                style: AppTypography.serifHeading,
              ),
              const SizedBox(height: 12),
              Text(
                'Pick a hobby that fits your life.\nWe\'ll help you actually start it.',
                textAlign: TextAlign.center,
                style: AppTypography.sansBodySmall,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => context.go('/discover'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Discover Hobbies',
                            style: AppTypography.sansCta),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: Colors.white),
                      ],
                    ),
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
