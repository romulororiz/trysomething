import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/hobby.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ── Data helper ──
class HobbyWithMeta {
  final Hobby hobby;
  final UserHobby userHobby;
  const HobbyWithMeta({required this.hobby, required this.userHobby});
}

// ── Streak helper ──
int computeStreak(UserHobby uh) => uh.streakDays;

// ── Collector Card ──
class CollectorCard extends StatelessWidget {
  final HobbyWithMeta meta;
  const CollectorCard({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final progress = totalSteps > 0 ? completedValid.length / totalSteps : 0.0;

    final startedAt = uh.startedAt ?? DateTime.now();
    final weekNum =
        (DateTime.now().difference(startedAt).inDays / 7).floor() + 1;

    return GestureDetector(
      onTap: () => context.go('/home?hobby=${hobby.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: 1.05,
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
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1A0A0A0F),
                      Color(0xF80A0A0F),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WEEK ${weekNum.toString().padLeft(2, '0')} / 04',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.35),
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CoralFirstWordTitle(
                            title: hobby.title,
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${(progress * 100).round()}',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'COMPLETE',
                              style: AppTypography.overline.copyWith(
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.3),
                                fontSize: 8,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 2,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Paused hobby card -- image bg + dark overlay + PAUSED chip ──
class PausedHobbyCard extends ConsumerWidget {
  final HobbyWithMeta meta;
  const PausedHobbyCard({super.key, required this.meta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = meta.hobby;
    final daysPaused = meta.userHobby.pausedAt != null
        ? DateTime.now().difference(meta.userHobby.pausedAt!).inDays
        : 0;
    final daysLabel = daysPaused == 0
        ? 'Paused today'
        : 'Paused for $daysPaused ${daysPaused == 1 ? "day" : "days"}';

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hobby image background
              CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceElevated),
              ),

              // Dark overlay
              Container(
                color: AppColors.background.withValues(alpha: 0.75),
              ),

              // Text content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PAUSED chip (same style as Home paused page)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.glassBorder, width: 0.5),
                      ),
                      child: Text('PAUSED',
                          style: AppTypography.overline.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              letterSpacing: 2)),
                    ),
                    const SizedBox(height: 8),

                    // Hobby title
                    Text(hobby.title,
                        style: AppTypography.body
                            .copyWith(color: AppColors.textPrimary)),

                    // Days paused
                    const SizedBox(height: 2),
                    Text(daysLabel,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),

              // Resume button -- bottom right
              Positioned(
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () => ref
                      .read(userHobbiesProvider.notifier)
                      .resumeHobby(hobby.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [AppColors.coral, Color(0xFFFF5252)],
                      ),
                    ),
                    child: Text('Resume',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
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

// ── Locked card overlay (sits on top of a hobby card for free users) ──
class LockedCardOverlay extends StatelessWidget {
  final int lockedCount;
  final Widget child;
  const LockedCardOverlay({super.key, required this.lockedCount, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: AppColors.background.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          color: AppColors.coral.withValues(alpha: 0.8),
                          size: 22),
                      const SizedBox(height: 8),
                      Text(
                        'Track $lockedCount more ${lockedCount == 1 ? 'hobby' : 'hobbies'} with Pro',
                        style: AppTypography.sansLabel.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.push('/pro'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Unlock Pro',
                              style: AppTypography.sansCaption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stats chip row ──
class StatsChipRow extends StatelessWidget {
  final HobbyWithMeta meta;
  const StatsChipRow({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final sessionsProxy = uh.completedStepIds.length;
    final streakDays = computeStreak(uh);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Chip(
          label: '${completedValid.length}/$totalSteps steps',
          bg: AppColors.surface,
          border: AppColors.border,
          textColor: AppColors.textMuted,
        ),
        _Chip(
          label: '$sessionsProxy sessions',
          bg: AppColors.surface,
          border: AppColors.border,
          textColor: AppColors.textMuted,
        ),
        if (streakDays > 0)
          _Chip(
            label: '\uD83D\uDD25 $streakDays days',
            bg: AppColors.accentMuted,
            border: AppColors.accent.withValues(alpha: 0.2),
            textColor: AppColors.accent,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color border;
  final Color textColor;
  const _Chip({
    required this.label,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.monoTiny.copyWith(color: textColor),
      ),
    );
  }
}

// ── Saved hobby swipe card -- matches CollectorCard dimensions exactly ──
class SavedHobbySwipeCard extends ConsumerWidget {
  final HobbyWithMeta meta;
  const SavedHobbySwipeCard({super.key, required this.meta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = meta.hobby;

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hobby image background
              CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceElevated),
              ),

              // Bottom gradient for text readability
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xE0000000)],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),

              // Text content -- bottom-left
              Positioned(
                left: 20,
                right: 50,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hobby.title,
                        style: AppTypography.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${hobby.costText} \u00B7 ${hobby.timeText}',
                      style: AppTypography.caption
                          .copyWith(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),

              // Heart unsave -- top right
              Positioned(
                right: 12,
                top: 12,
                child: GestureDetector(
                  onTap: () => ref
                      .read(userHobbiesProvider.notifier)
                      .unsaveHobby(hobby.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 16,
                      color: AppColors.accent,
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

// ── Tried hobby card ──
class TriedHobbyCard extends StatelessWidget {
  final HobbyWithMeta meta;
  const TriedHobbyCard({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    // Determine if hobby was fully completed vs stopped partway
    final totalSteps = hobby.roadmapSteps.length;
    final completedSteps = uh.completedStepIds.length;
    final isFullyCompleted = totalSteps > 0 && completedSteps >= totalSteps;

    // Status icon and label
    final statusIcon = isFullyCompleted
        ? const Icon(Icons.check_circle_rounded,
            size: 16, color: AppColors.success)
        : const Icon(Icons.stop_circle_outlined,
            size: 16, color: AppColors.textMuted);
    final statusLabel = isFullyCompleted ? 'Completed' : 'Stopped';
    final statusColor = isFullyCompleted ? AppColors.success : AppColors.textMuted;

    // Date label: prefer completedAt, fallback to existing weeks label
    String dateLabel = '';
    if (uh.completedAt != null) {
      final d = uh.completedAt!;
      dateLabel = '${_monthName(d.month)} ${d.day}, ${d.year}';
    } else if (uh.startedAt != null && uh.lastActivityAt != null) {
      final days = uh.lastActivityAt!.difference(uh.startedAt!).inDays;
      final weeks = (days / 7).ceil();
      dateLabel = weeks <= 1 ? '1 week' : '$weeks weeks';
      final month = _monthName(uh.lastActivityAt!.month);
      final year = uh.lastActivityAt!.year;
      dateLabel = '$dateLabel in $month $year';
    }

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hobby image background
              CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceElevated),
              ),

              // Dark overlay
              Container(
                color: AppColors.background.withValues(alpha: 0.75),
              ),

              // Text content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status icon + label row
                    Row(
                      children: [
                        statusIcon,
                        const SizedBox(width: 6),
                        Text(statusLabel,
                            style: AppTypography.caption
                                .copyWith(color: statusColor)),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Hobby title
                    Text(hobby.title,
                        style: AppTypography.body
                            .copyWith(color: AppColors.textPrimary)),

                    // Date + steps
                    if (dateLabel.isNotEmpty ||
                        hobby.roadmapSteps.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (dateLabel.isNotEmpty) dateLabel,
                          if (hobby.roadmapSteps.isNotEmpty)
                            '$completedSteps/$totalSteps steps',
                        ].join(' \u00B7 '),
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

// ── Coral first word title ──
class CoralFirstWordTitle extends StatelessWidget {
  final String title;
  final TextStyle style;
  const CoralFirstWordTitle({super.key, required this.title, required this.style});

  @override
  Widget build(BuildContext context) {
    final spaceIdx = title.indexOf(' ');
    if (spaceIdx <= 0) {
      return Text(
        title,
        style: style.copyWith(color: AppColors.coral),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: '${title.substring(0, spaceIdx)} ',
          style: style.copyWith(color: AppColors.coral),
        ),
        TextSpan(
          text: title.substring(spaceIdx + 1),
          style: style,
        ),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
