import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../components/glass_card.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import 'coach_provider.dart';

// ═══════════════════════════════════════════════════════
//  SHARED HELPER — actions for each mode
// ═══════════════════════════════════════════════════════

/// Returns `(label, icon, description)` tuples for the given [mode].
List<(String, IconData, String)> getActionsForMode(CoachMode mode) {
  switch (mode) {
    case CoachMode.start:
      return [
        ('Help me start tonight', Icons.play_circle_outline_rounded,
            'A 15-min plan you can start tonight'),
        ('Make this cheaper', Icons.savings_outlined,
            'Find the lowest-cost way to begin'),
        ('What do I need to buy?', Icons.shopping_bag_outlined,
            'Essential starter kit only'),
      ];
    case CoachMode.momentum:
      return [
        ('What should I do next?', Icons.arrow_circle_right_outlined,
            'Specific to where you are now'),
        ('Make this easier', Icons.tune_rounded,
            'Simplify your current approach'),
        ('I\'m losing motivation', Icons.battery_2_bar_rounded,
            'Small wins to rebuild momentum'),
      ];
    case CoachMode.rescue:
      return [
        ('I skipped a few days', Icons.replay_rounded,
            'One tiny action to break the gap'),
        ('I\'m losing motivation', Icons.battery_2_bar_rounded,
            'Find what made it fun at first'),
        ('Maybe this hobby isn\'t for me', Icons.swap_horiz_rounded,
            'Let\'s figure out what fits better'),
      ];
  }
}

// ═══════════════════════════════════════════════════════
//  COACH HEADER
// ═══════════════════════════════════════════════════════

class CoachHeader extends StatelessWidget {
  final String hobbyTitle;
  final String modeName;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const CoachHeader({
    super.key,
    required this.hobbyTitle,
    required this.modeName,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hobbyTitle,
                    style: AppTypography.title.copyWith(fontSize: 16)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$modeName Mode',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COACH CONTEXT HERO
// ═══════════════════════════════════════════════════════

class CoachContextHero extends ConsumerWidget {
  final String hobbyId;
  final CoachMode mode;

  const CoachContextHero({
    super.key,
    required this.hobbyId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final userHobby = userHobbies[hobbyId];
    final stepsCompleted = userHobby?.completedStepIds.length ?? 0;
    final totalSteps = ref
            .watch(hobbyByIdProvider(hobbyId))
            .valueOrNull
            ?.roadmapSteps
            .length ??
        0;

    String contextLine;
    if (mode == CoachMode.start) {
      contextLine = 'Ready to help you begin. No experience needed.';
    } else if (mode == CoachMode.rescue) {
      final lastActive = userHobby?.lastActivityAt ?? userHobby?.startedAt;
      final days = lastActive != null
          ? DateTime.now().difference(lastActive).inDays
          : 0;
      contextLine = 'It\'s been $days days. Let\'s find an easy way back in.';
    } else {
      contextLine = '$stepsCompleted of $totalSteps steps complete. Keep going!';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(mode.icon, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  mode.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              contextLine,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (mode == CoachMode.momentum && totalSteps > 0) ...[
              const SizedBox(height: 12),
              // Mini progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: totalSteps > 0 ? stepsCompleted / totalSteps : 0,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: -0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ═══════════════════════════════════════════════════════
//  COACH MODE SELECTOR
// ═══════════════════════════════════════════════════════

class CoachModeSelector extends StatelessWidget {
  final CoachMode currentMode;
  final void Function(CoachMode) onModeChanged;

  const CoachModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: CoachMode.values.map((mode) {
          final isActive = currentMode == mode;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: mode != CoachMode.rescue ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => onModeChanged(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? AppColors.accent.withValues(alpha: 0.4)
                          : AppColors.glassBorder,
                      width: isActive ? 1 : 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        mode.icon,
                        size: 16,
                        color: isActive
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        mode.label,
                        style: AppTypography.caption.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ).animate(key: ValueKey(currentMode)).fadeIn(duration: 200.ms),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }
}

// ═══════════════════════════════════════════════════════
//  COACH REMAINING BANNER
// ═══════════════════════════════════════════════════════

class CoachRemainingBanner extends ConsumerWidget {
  final String hobbyId;

  const CoachRemainingBanner({super.key, required this.hobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(coachRemainingProvider(hobbyId));
    return remaining.when(
      data: (value) {
        if (value == null) return const SizedBox.shrink();
        final isLow = value <= 1;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isLow
                ? AppColors.accent.withValues(alpha: 0.08)
                : AppColors.glassBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLow
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                value == 0
                    ? 'Upgrade to keep your momentum going'
                    : '$value free ${value == 1 ? 'message' : 'messages'} left — Pro gives you unlimited support',
                style: AppTypography.caption.copyWith(
                  color: isLow ? AppColors.accent : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (isLow && value <= 1) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/pro'),
                  child: Text(
                    'Upgrade to Pro',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COACH EMPTY STATE — locked vs guided actions
// ═══════════════════════════════════════════════════════

class CoachEmptyState extends ConsumerWidget {
  final String hobbyId;
  final CoachMode mode;
  final void Function(String) onChipTap;

  const CoachEmptyState({
    super.key,
    required this.hobbyId,
    required this.mode,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(coachRemainingProvider(hobbyId));
    return remaining.when(
      data: (value) =>
          value == 0 ? _buildLockedState(context) : _buildGuidedActions(),
      loading: () => _buildGuidedActions(),
      error: (_, __) => _buildGuidedActions(),
    );
  }

  Widget _buildLockedState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome,
                size: 24, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Your coach is waiting',
            style: AppTypography.title.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve used your free messages this month. Upgrade to keep the momentum going.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/pro');
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Continue with Pro',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildGuidedActions() {
    final actions = getActionsForMode(mode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT DO YOU NEED?',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              mode == CoachMode.rescue
                  ? 'No judgment. Just the easiest way back in.'
                  : mode == CoachMode.momentum
                      ? 'Guidance tied to your actual progress.'
                      : 'No experience needed. Just start small.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
          ...actions.asMap().entries.map((entry) {
            final action = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onChipTap(action.$1),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(action.$2,
                            size: 18, color: AppColors.accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.$1,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              action.$3,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: AppColors.textWhisper),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: (entry.key * 80).ms)
                .slideX(
                  begin: 0.03,
                  end: 0,
                  duration: 350.ms,
                  delay: (entry.key * 80).ms,
                );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COACH QUICK ACTIONS STRIP
// ═══════════════════════════════════════════════════════

class CoachQuickActionsStrip extends StatelessWidget {
  final CoachMode mode;
  final void Function(String) onChipTap;

  const CoachQuickActionsStrip({
    super.key,
    required this.mode,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = getActionsForMode(mode);

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChipTap(action.$1),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  border:
                      Border.all(color: AppColors.glassBorder, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action.$2, size: 13, color: AppColors.accent),
                    const SizedBox(width: 5),
                    Text(
                      action.$1,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
