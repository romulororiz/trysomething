import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';
import '../models/hobby.dart';

/// Timeline-journey step tile using timelines_plus.
/// Public constructor API is identical to the previous flat-card version.
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
  // ── Animation controllers (preserved from original) ──
  late AnimationController _checkController;
  late AnimationController _uncheckController;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkOpacityAnimation;
  late Animation<double> _uncheckScaleAnimation;
  late Animation<double> _uncheckOpacityAnimation;

  bool _isReversing = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: Motion.spring,
      vsync: this,
    );

    _checkmarkScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _checkmarkOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.3, curve: Curves.easeIn),
      ),
    );

    _uncheckController = AnimationController(
      duration: Motion.normal,
      vsync: this,
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

  double get _activeScale =>
      _isReversing ? _uncheckScaleAnimation.value : _checkmarkScaleAnimation.value;
  double get _activeOpacity =>
      _isReversing ? _uncheckOpacityAnimation.value : _checkmarkOpacityAnimation.value;

  // ── Connector colors ──
  // startConnector = segment entering this node (from tile above)
  // endConnector   = segment leaving this node (to tile below)
  // Known approximation: tile doesn't know its neighbor's state, so
  // consecutive done steps show accent connectors instead of success-colored.
  Color get _startConnectorColor {
    if (widget.isCompleted) return AppColors.success.withValues(alpha: 0.25);
    if (widget.isCurrent) return AppColors.accent.withValues(alpha: 0.25);
    return AppColors.border;
  }

  Color get _endConnectorColor {
    if (widget.isCompleted) return AppColors.accent.withValues(alpha: 0.25);
    if (widget.isCurrent) return AppColors.border;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator: GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedBuilder(
            animation: Listenable.merge([_checkController, _uncheckController]),
            builder: (context, _) => _buildNode(),
          ),
        ),
        startConnector: SolidLineConnector(
          color: _startConnectorColor,
          thickness: 1.5,
        ),
        endConnector: SolidLineConnector(
          color: _endConnectorColor,
          thickness: 1.5,
        ),
      ),
      contents: GestureDetector(
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12, top: 2),
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildNode() {
    if (widget.isCompleted) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.success, width: 1.5),
        ),
        child: Opacity(
          opacity: _activeOpacity,
          child: Transform.scale(
            scale: _activeScale,
            child: const Icon(Icons.check, size: 13, color: AppColors.success),
          ),
        ),
      );
    }

    if (widget.isCurrent) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.stepNumber}',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Future
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Center(
        child: Text(
          '${widget.stepNumber}',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhisper,
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    if (widget.isCompleted) {
      return Opacity(
        opacity: 0.45,
        child: Text(
          widget.step.title,
          style: AppTypography.sansLabel.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.textWhisper,
          ),
        ),
      );
    }

    if (widget.isCurrent) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.step.title,
              style: AppTypography.sansLabel.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.step.description,
              style: AppTypography.sansTiny.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            if (widget.step.milestone != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_outlined,
                        size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      widget.step.milestone!,
                      style: AppTypography.monoMilestone.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Future
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        widget.step.title,
        style: AppTypography.sansLabel.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
