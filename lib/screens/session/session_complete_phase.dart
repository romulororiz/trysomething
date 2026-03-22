import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Phase 4: Complete — a brief celebration before returning to the app.
///
/// Shows the finished brushstroke, completed step title, next step
/// preview, and auto-exits after 3 seconds.
class SessionCompletePhase extends StatefulWidget {
  final SessionState session;
  final VoidCallback onExit;

  const SessionCompletePhase({
    super.key,
    required this.session,
    required this.onExit,
  });

  @override
  State<SessionCompletePhase> createState() => _SessionCompletePhaseState();
}

class _SessionCompletePhaseState extends State<SessionCompletePhase> {
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _exitTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) widget.onExit();
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),

          // "Step complete" overline
          Text(
            'STEP COMPLETE',
            style: AppTypography.overline,
          ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

          const SizedBox(height: 12),

          // Step title with checkmark
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.session.stepTitle,
                  style: AppTypography.title,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 700.ms),

          const SizedBox(height: 16),

          // Completion message (D-13)
          if (widget.session.completionMessage != null)
            Text(
              widget.session.completionMessage!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 800.ms),

          if (widget.session.completionMessage != null)
            const SizedBox(height: 16),

          // Next step preview
          if (widget.session.nextStepTitle != null)
            Text(
              'Next: ${widget.session.nextStepTitle}',
              style: AppTypography.body.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
                  duration: 300.ms,
                  delay: widget.session.completionMessage != null
                      ? 1000.ms
                      : 900.ms,
                ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
