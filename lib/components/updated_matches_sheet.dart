import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/match_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import 'app_overlays.dart';

/// Shows a bottom sheet with updated hobby matches after preference changes.
Future<void> showUpdatedMatchesSheet(BuildContext context, WidgetRef ref) async {
  final matches = ref.read(matchedHobbiesProvider).take(3).toList();
  if (matches.isEmpty) return;

  final maxScore = _maxPossibleScore(ref);

  await showAppSheet(
    context: context,
    title: 'Updated matches',
    builder: (context) => _UpdatedMatchesContent(
      matches: matches,
      maxScore: maxScore,
    ),
  );
}

int _maxPossibleScore(WidgetRef ref) {
  final prefs = ref.read(userPreferencesProvider);
  return 8 + prefs.vibes.length;
}

class _UpdatedMatchesContent extends StatelessWidget {
  final List<MatchResult> matches;
  final int maxScore;

  const _UpdatedMatchesContent({
    required this.matches,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'Based on your new preferences',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ),

        // Match tiles
        for (int i = 0; i < matches.length; i++) ...[
          _MatchTile(
            match: matches[i],
            maxScore: maxScore,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: i * 80))
              .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: Duration(milliseconds: i * 80)),
          if (i < matches.length - 1) const SizedBox(height: 8),
        ],

        const SizedBox(height: 20),

        // "See all recommendations" link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              context.go('/discover');
            },
            child: Text(
              'See all recommendations →',
              style: AppTypography.sansLabel.copyWith(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchResult match;
  final int maxScore;

  const _MatchTile({
    required this.match,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    final hobby = match.hobby;
    final percent = maxScore > 0 ? (match.score / maxScore * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          context.push('/hobby/${hobby.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(Spacing.radiusTile),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              // Circular image thumbnail
              ClipOval(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CachedNetworkImage(
                    imageUrl: hobby.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.surfaceElevated,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceElevated,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hobby.title,
                      style: AppTypography.sansLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${hobby.costText} · ${hobby.timeText}',
                      style: AppTypography.monoCaption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (match.reasons.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '✦ ${match.reasons.first}',
                        style: AppTypography.sansTiny.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Score indicator
              _MiniScoreRing(percent: percent),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact score ring for the sheet tiles (34px).
class _MiniScoreRing extends StatelessWidget {
  final int percent;

  const _MiniScoreRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(
        painter: _MiniScoreRingPainter(
          percent: percent,
          trackColor: AppColors.textWhisper,
          fillColor: AppColors.accent,
        ),
        child: Center(
          child: Text(
            '$percent',
            style: AppTypography.monoBadge.copyWith(
              fontSize: 10,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniScoreRingPainter extends CustomPainter {
  final int percent;
  final Color trackColor;
  final Color fillColor;

  _MiniScoreRingPainter({
    required this.percent,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    const strokeWidth = 3.0;
    const pi = 3.14159265359;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Fill
    final sweep = (percent / 100) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniScoreRingPainter old) => old.percent != percent;
}
