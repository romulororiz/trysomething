import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';
import '../models/hobby.dart';

/// Editorial checklist step with animated checkbox (elastic spring),
/// milestone badges, time estimates, and completion states.
class RoadmapStepTile extends StatefulWidget {
  final RoadmapStep step;
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback? onToggle;

  const RoadmapStepTile({
    super.key,
    required this.step,
    required this.stepNumber,
    this.isCompleted = false,
    this.isCurrent = false,
    this.onToggle,
  });

  @override
  State<RoadmapStepTile> createState() => _RoadmapStepTileState();
}

class _RoadmapStepTileState extends State<RoadmapStepTile>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _uncheckController;
  late Animation<double> _fillAnimation;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkOpacityAnimation;
  late Animation<double> _uncheckFillAnimation;
  late Animation<double> _uncheckScaleAnimation;
  late Animation<double> _uncheckOpacityAnimation;

  bool _isReversing = false;

  @override
  void initState() {
    super.initState();
    // Check ON — 400ms with elastic spring
    _checkController = AnimationController(
      duration: Motion.spring,
      vsync: this,
    );

    // Phase 1: Circle fill (0–200ms of 400ms)
    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Phase 2: Checkmark scale (0–240ms of 400ms) with elastic
    _checkmarkScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Phase 3: Checkmark opacity (0–120ms of 400ms)
    _checkmarkOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Check OFF — 250ms with easeInOut (no elastic)
    _uncheckController = AnimationController(
      duration: Motion.normal,
      vsync: this,
    );

    _uncheckFillAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _uncheckController, curve: Curves.easeInOut),
    );
    _uncheckScaleAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _uncheckController, curve: Curves.easeInOut),
    );
    _uncheckOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _uncheckController, curve: Curves.easeInOut),
    );

    if (widget.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RoadmapStepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _isReversing = false;
      _uncheckController.reset();
      _checkController.forward();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _isReversing = true;
      _checkController.value = 1.0;
      _uncheckController.forward().then((_) {
        if (mounted) {
          _checkController.reset();
          _isReversing = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _uncheckController.dispose();
    super.dispose();
  }

  // Active animation values — pick from the correct controller
  double get _activeFill =>
      _isReversing ? _uncheckFillAnimation.value : _fillAnimation.value;
  double get _activeScale =>
      _isReversing ? _uncheckScaleAnimation.value : _checkmarkScaleAnimation.value;
  double get _activeOpacity =>
      _isReversing ? _uncheckOpacityAnimation.value : _checkmarkOpacityAnimation.value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Motion.normal,
      curve: Motion.normalCurve,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isCurrent
            ? AppColors.coralPale
            : AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusButton),
        // No border — dark mode uses bg color contrast
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated checkbox
          GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedBuilder(
              animation: Listenable.merge([_checkController, _uncheckController]),
              builder: (context, _) => _buildCheckbox(),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: Spacing.checkboxSize,
      height: Spacing.checkboxSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(
          Colors.transparent,
          widget.isCurrent ? AppColors.coral : AppColors.sage,
          _activeFill,
        ),
        border: Border.all(
          color: widget.isCompleted ? AppColors.sage : (widget.isCurrent ? AppColors.coral : AppColors.sandDark),
          width: 1.5,
        ),
      ),
      child: widget.isCompleted || _checkController.isAnimating || _isReversing
          ? Opacity(
              opacity: _activeOpacity,
              child: Transform.scale(
                scale: _activeScale,
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            )
          : Center(
              child: Text(
                '${widget.stepNumber}',
                style: AppTypography.monoTiny.copyWith(
                  color: AppColors.warmGray,
                ),
              ),
            ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.step.title,
                style: AppTypography.sansLabel.copyWith(
                  decoration: widget.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: widget.isCompleted
                      ? AppColors.warmGray
                      : AppColors.nearBlack,
                ),
              ),
            ),
            // Time badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? AppColors.sand.withValues(alpha: 0.5)
                    : AppColors.sand,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${widget.step.estimatedMinutes}min',
                style: AppTypography.monoTiny.copyWith(
                  color: widget.isCompleted
                      ? AppColors.stone
                      : AppColors.driftwood,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.step.description,
          style: AppTypography.sansTiny.copyWith(
            color: widget.isCompleted ? AppColors.stone : AppColors.warmGray,
          ),
        ),
        // Milestone badge
        if (widget.step.milestone != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.amberPale,
              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
              // No border — dark mode milestone pill
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.trophy, size: 12, color: AppColors.amberDeep),
                const SizedBox(width: 4),
                Text(
                  widget.step.milestone!,
                  style: AppTypography.monoMilestone.copyWith(
                    color: AppColors.amberDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
