import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
import '../../components/shimmer_skeleton.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../providers/match_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Full-screen match results shown once after onboarding completes.
/// Displays top matched hobbies based on user preferences.
class MatchResultsScreen extends ConsumerStatefulWidget {
  const MatchResultsScreen({super.key});

  @override
  ConsumerState<MatchResultsScreen> createState() => _MatchResultsScreenState();
}

class _MatchResultsScreenState extends ConsumerState<MatchResultsScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ringControllers;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    if (_controllersInitialized) {
      for (final c in _ringControllers) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _initRingControllers(int count) {
    if (_controllersInitialized) return;
    _ringControllers = List.generate(count, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      Future.delayed(Duration(milliseconds: 800 + i * 150), () {
        if (mounted) ctrl.forward();
      });
      return ctrl;
    });
    _controllersInitialized = true;
  }

  void _markSeen() {
    ref.read(sharedPreferencesProvider).setBool('matchResultsSeen', true);
  }

  void _onHobbyTap(String hobbyId, int position) {
    ref.read(analyticsProvider).trackEvent('match_results_hobby_tapped', {
      'hobby_id': hobbyId,
      'position': position,
    });
    _markSeen();
    context.push('/hobby/$hobbyId');
  }

  void _onExploreAll() {
    ref.read(analyticsProvider).trackEvent('match_results_explore_tapped');
    _markSeen();
    context.go('/discover');
  }

  void _onSkipToHome() {
    ref.read(analyticsProvider).trackEvent('match_results_skipped');
    _markSeen();
    context.go('/home');
  }

  int _maxPossibleScore() {
    final prefs = ref.read(userPreferencesProvider);
    // vibe(5 per vibe) + budget(2) + time(2) + solo(1)
    return 5 * prefs.vibes.length + 5;
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(matchedHobbiesProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider).trackEvent('match_results_viewed', {
        'match_count': matches.length,
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: matches.isEmpty
              ? _buildLoading()
              : _buildContent(matches, bottomPad),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const ShimmerSkeleton(
      child: Padding(
        padding: Spacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 48),
            ShimmerBone(width: 140, height: 28, borderRadius: 8),
            SizedBox(height: 12),
            ShimmerBone(height: 16, borderRadius: 4),
            SizedBox(height: 32),
            // Large card skeleton
            ShimmerBone(height: 320, borderRadius: Spacing.radiusCard),
            SizedBox(height: 24),
            // Secondary card skeletons
            ShimmerBone(height: 110, borderRadius: Spacing.radiusTile),
            SizedBox(height: 12),
            ShimmerBone(height: 110, borderRadius: Spacing.radiusTile),
            SizedBox(height: 12),
            ShimmerBone(height: 110, borderRadius: Spacing.radiusTile),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<MatchResult> matches, double bottomPad) {
    final maxScore = _maxPossibleScore();
    _initRingControllers(matches.length.clamp(0, 4));

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPad + 32),
      child: Padding(
        padding: Spacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ── HEADER ──
            _buildHeader(),

            const SizedBox(height: 28),

            // ── #1 MATCH — LARGE CARD ──
            if (matches.isNotEmpty)
              _buildTopMatchCard(matches[0], maxScore)
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic, delay: 400.ms)
                  .slideY(begin: 0.06, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 400.ms),

            if (matches.length > 1) ...[
              const SizedBox(height: 28),

              // ── ALSO FOR YOU ── divider
              _buildDivider()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms),

              const SizedBox(height: 16),

              // ── SECONDARY MATCHES ──
              for (int i = 1; i < matches.length.clamp(0, 4); i++) ...[
                _buildSecondaryCard(matches[i], i, maxScore)
                    .animate()
                    .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic, delay: Duration(milliseconds: 550 + (i - 1) * 150))
                    .slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutCubic, delay: Duration(milliseconds: 550 + (i - 1) * 150)),
                if (i < matches.length.clamp(0, 4) - 1)
                  const SizedBox(height: 12),
              ],
            ],

            const SizedBox(height: 36),

            // ── CTA SECTION ──
            _buildCtaSection()
                .animate()
                .fadeIn(duration: 500.ms, delay: 1200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overline badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(Spacing.radiusBadge),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'CURATED FOR YOU',
                style: AppTypography.monoBadge.copyWith(
                  color: AppColors.accent,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Hero text
        Text(
          'Your matches',
          style: AppTypography.hero.copyWith(fontSize: 36),
        ),
        const SizedBox(height: 8),

        // Body text
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Based on your time, budget, and energy. ',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: 'Tap any to explore.',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    ).animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, duration: 800.ms, curve: Curves.easeOutCubic, delay: 100.ms);
  }

  Widget _buildTopMatchCard(MatchResult match, int maxScore) {
    final hobby = match.hobby;
    final percent = maxScore > 0 ? (match.score / maxScore * 100).round() : 0;

    return GlassCard(
      blur: true,
      padding: EdgeInsets.zero,
      onTap: () => _onHobbyTap(hobby.id, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Hobby image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                // Gradient overlay
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: Spacing.cardOverlayGradient,
                    ),
                  ),
                ),
                // BEST MATCH badge — top-left
                Positioned(
                  top: 16,
                  left: 16,
                  child: _BestMatchBadge(),
                ),
                // Score ring — top-right
                Positioned(
                  top: 16,
                  right: 16,
                  child: _ScoreRing(
                    percent: percent,
                    size: 48,
                    controller: _controllersInitialized && _ringControllers.isNotEmpty
                        ? _ringControllers[0]
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category overline
                Text(
                  hobby.category.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  hobby.title,
                  style: AppTypography.display.copyWith(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                // Hook
                Text(
                  hobby.hook,
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Spec line
                Text(
                  '${hobby.costText} · ${hobby.timeText} · ${hobby.difficultyText}',
                  style: AppTypography.monoCaption,
                ),
                const SizedBox(height: 14),
                // Match reasons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: match.reasons.asMap().entries.map((entry) {
                    final isFirst = entry.key == 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? AppColors.accent.withValues(alpha: 0.12)
                            : AppColors.glassBackground,
                        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                        border: Border.all(
                          color: isFirst
                              ? AppColors.accent.withValues(alpha: 0.25)
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        entry.value,
                        style: AppTypography.sansTiny.copyWith(
                          color: isFirst ? AppColors.accent : AppColors.textSecondary,
                          fontWeight: isFirst ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard(MatchResult match, int index, int maxScore) {
    final hobby = match.hobby;
    final percent = maxScore > 0 ? (match.score / maxScore * 100).round() : 0;

    return GlassCard(
      blur: false,
      padding: EdgeInsets.zero,
      onTap: () => _onHobbyTap(hobby.id, index + 1),
      child: SizedBox(
        height: 110,
        child: Row(
          children: [
            // Image thumbnail
            SizedBox(
              width: 110,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: hobby.imageUrl,
                  fit: BoxFit.cover,
                  height: 110,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceElevated,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceElevated,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category overline
                    Text(
                      hobby.category.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Title
                    Text(
                      hobby.title,
                      style: AppTypography.sansLabel.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Spec line
                    Text(
                      '${hobby.costText} · ${hobby.timeText}',
                      style: AppTypography.monoCaption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Top match reason
                    if (match.reasons.isNotEmpty)
                      Text(
                        match.reasons.first,
                        style: AppTypography.sansTiny.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            // Score ring
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _ScoreRing(
                percent: percent,
                size: 34,
                controller: _controllersInitialized && index < _ringControllers.length
                    ? _ringControllers[index]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 0.5, color: AppColors.textWhisper),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ALSO FOR YOU',
            style: AppTypography.overline.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 0.5, color: AppColors.textWhisper),
        ),
      ],
    );
  }

  Widget _buildCtaSection() {
    return Column(
      children: [
        // Coral CTA
        GestureDetector(
          onTap: _onExploreAll,
          child: Container(
            width: double.infinity,
            height: Spacing.buttonCtaHeight,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(Spacing.radiusCta),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Explore all hobbies',
                style: AppTypography.sansLabel.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Skip link
        GestureDetector(
          onTap: _onSkipToHome,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Skip to home',
              style: AppTypography.sansCaption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Social proof
        Text(
          'Join 10,000+ people discovering hobbies they love',
          style: AppTypography.sansTiny.copyWith(
            color: AppColors.textWhisper,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  BEST MATCH BADGE — pulsing coral dot + label
// ═══════════════════════════════════════════════════════

class _BestMatchBadge extends StatefulWidget {
  @override
  State<_BestMatchBadge> createState() => _BestMatchBadgeState();
}

class _BestMatchBadgeState extends State<_BestMatchBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.6 + 0.4 * _pulseCtrl.value,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'BEST MATCH',
            style: AppTypography.monoBadge.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SCORE RING — animated circular progress
// ═══════════════════════════════════════════════════════

class _ScoreRing extends StatelessWidget {
  final int percent;
  final double size;
  final AnimationController? controller;

  const _ScoreRing({
    required this.percent,
    required this.size,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return _buildRing(1.0);
    }
    return AnimatedBuilder(
      animation: controller!,
      builder: (_, __) => _buildRing(
        Curves.easeOutCubic.transform(controller!.value),
      ),
    );
  }

  Widget _buildRing(double progress) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScoreRingPainter(
          percent: percent,
          progress: progress,
          trackColor: AppColors.textWhisper,
          fillColor: AppColors.accent,
        ),
        child: Center(
          child: Text(
            '${(percent * progress).round()}',
            style: AppTypography.monoBadge.copyWith(
              fontSize: size < 40 ? 10 : 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int percent;
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _ScoreRingPainter({
    required this.percent,
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    const strokeWidth = 3.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Fill arc
    final sweep = (percent / 100) * 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
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
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.percent != percent || old.progress != progress;
}
