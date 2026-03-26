import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/app_overlays.dart';
import '../../components/glass_card.dart';
import '../../components/hobby_quick_links.dart';
import '../../components/plan_first_session_card.dart';
import '../../components/starter_kit_card.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import 'home_journal_section.dart';
import 'home_roadmap_section.dart';

// ═══════════════════════════════════════════════════════
//  ACTIVE HOBBY PAGE CONTENT
// ═══════════════════════════════════════════════════════

class ActiveHobbyPage extends ConsumerStatefulWidget {
  final Hobby hobby;
  final UserHobby userHobby;

  const ActiveHobbyPage({
    super.key,
    required this.hobby,
    required this.userHobby,
  });

  @override
  ConsumerState<ActiveHobbyPage> createState() => _ActiveHobbyPageState();
}

class _ActiveHobbyPageState extends ConsumerState<ActiveHobbyPage> {
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
                      child: JournalEntryTile(
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
