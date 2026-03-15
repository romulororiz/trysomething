import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Phase 1: Prepare — the calm invitation before the timer starts.
///
/// Shows hobby/step context, a duration selector, and "I'm ready" CTA.
/// Every element staggers in with flutter_animate for a breathing feel.
class SessionPreparePhase extends StatelessWidget {
  final SessionState session;
  final ValueChanged<int> onSelectDuration;
  final VoidCallback onReady;
  final VoidCallback onCancel;

  const SessionPreparePhase({
    super.key,
    required this.session,
    required this.onSelectDuration,
    required this.onReady,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Category overline
          Text(
            session.hobbyCategory.toUpperCase(),
            style: AppTypography.overline,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: 12),

          // Hobby title
          Text(
            session.hobbyTitle,
            style: AppTypography.display,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: 12),

          // Step title
          Text(
            session.stepTitle,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: 8),

          // What you need
          Text(
            session.whatYouNeed,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 48),

          // Duration selector
          _DurationSelector(
            selected: session.selectedMinutes,
            recommended: session.recommendedMinutes,
            onSelect: onSelectDuration,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms),

          const Spacer(flex: 2),

          // CTA: "I'm ready"
          SizedBox(
            width: double.infinity,
            child: _CoralButton(label: "I'm ready", onTap: onReady),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: 16),

          // Cancel link
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'Not now',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 600.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Duration selector pills
// ─────────────────────────────────────────────────

class _DurationSelector extends StatelessWidget {
  final int selected;
  final int recommended;
  final ValueChanged<int> onSelect;

  const _DurationSelector({
    required this.selected,
    required this.recommended,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final options = _computeOptions();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((mins) {
        final isSelected = mins == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onSelect(mins),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Text(
                '$mins min',
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build 3 duration options around the recommended time.
  List<int> _computeOptions() {
    if (recommended <= 10) return [5, 10, 15];
    if (recommended <= 15) return [10, 15, 30];
    if (recommended <= 30) return [15, 30, 45];
    return [15, 30, 60];
  }
}

// ─────────────────────────────────────────────────
//  Coral CTA button (reused across phases)
// ─────────────────────────────────────────────────

class _CoralButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CoralButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
