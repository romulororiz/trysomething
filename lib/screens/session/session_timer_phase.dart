import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../components/brushstroke_timer_painter.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Phase 2: Timer — the sacred core of the session.
///
/// Full-screen focus: brushstroke timer, countdown, step instructions,
/// and a minimal pause button. No nav, no back, no distractions.
///
/// Also renders the "completing" moment (brushstroke at 1.0 + celebration
/// text) when [session.phase] is [SessionPhase.completing].
class SessionTimerPhase extends StatelessWidget {
  final SessionState session;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEndEarly;
  final VoidCallback onEndEarlyExit;

  const SessionTimerPhase({
    super.key,
    required this.session,
    required this.onPause,
    required this.onResume,
    required this.onEndEarly,
    required this.onEndEarlyExit,
  });

  bool get _isCompleting => session.phase == SessionPhase.completing;
  int get _totalSeconds => session.selectedMinutes * 60;
  int get _remaining => (_totalSeconds - session.elapsedSeconds).clamp(0, _totalSeconds);
  double get _targetProgress =>
      _totalSeconds > 0 ? session.elapsedSeconds / _totalSeconds : 0.0;

  String get _formattedTime {
    if (_isCompleting) {
      return '${session.selectedMinutes} minutes';
    }
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Overline: "POTTERY · STEP 1"
          Text(
            '${session.hobbyTitle.toUpperCase()} · ${session.stepTitle.toUpperCase()}',
            style: AppTypography.overline,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // Brushstroke timer — smooth interpolation via TweenAnimationBuilder
          TweenAnimationBuilder<double>(
            tween: Tween(end: _isCompleting ? 1.0 : _targetProgress),
            duration: _isCompleting
                ? const Duration(milliseconds: 300)
                : const Duration(seconds: 1),
            curve: Curves.linear,
            builder: (context, progress, _) {
              return BrushstrokeTimer(
                progress: progress.clamp(0.0, 1.0),
                size: _isCompleting ? 260 : 240,
              );
            },
          ),

          const SizedBox(height: 32),

          // Time remaining — crossfade on change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _formattedTime,
              key: ValueKey(_formattedTime),
              style: _isCompleting
                  ? AppTypography.display
                  : AppTypography.dataLarge.copyWith(
                      color: _remaining < 60
                          ? const Color(0xFFF5E6D8) // Warmer at <1min
                          : AppColors.textPrimary,
                    ),
            ),
          ),

          // "Session complete" text during completing phase
          if (_isCompleting) ...[
            const SizedBox(height: 8),
            Text(
              'Session complete',
              style: AppTypography.display,
            ).animate().fadeIn(duration: 400.ms),
          ],

          // Paused label — always reserves space to avoid layout shift
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: session.isPaused && !_isCompleting ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Paused',
              style: AppTypography.caption,
            ),
          ),

          const SizedBox(height: 24),

          // Step instructions (hidden during completing)
          if (!_isCompleting)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 72),
              child: SingleChildScrollView(
                child: Text(
                  session.stepInstructions,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          const Spacer(),

          // Pause/play button (hidden during completing)
          if (!_isCompleting) ...[
            _PausePlayButton(
              isPaused: session.isPaused,
              onToggle: session.isPaused ? onResume : onPause,
            ),

            // "End session early" — always reserves space, fades in when paused
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: session.isPaused ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !session.isPaused,
                child: _EndEarlyLink(
                  onEndEarly: onEndEarly,
                  onEndEarlyExit: onEndEarlyExit,
                ),
              ),
            ),
          ],

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Pause / Play button (custom-drawn, not Material)
// ─────────────────────────────────────────────────

class _PausePlayButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onToggle;

  const _PausePlayButton({required this.isPaused, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: CustomPaint(
            key: ValueKey(isPaused),
            size: const Size(20, 20),
            painter: isPaused ? _PlayIconPainter() : _PauseIconPainter(),
          ),
        ),
      ),
    );
  }
}

/// Two vertical rounded rectangles.
class _PauseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final x1 = size.width * 0.35;
    final x2 = size.width * 0.65;
    final top = size.height * 0.2;
    final bottom = size.height * 0.8;

    canvas.drawLine(Offset(x1, top), Offset(x1, bottom), paint);
    canvas.drawLine(Offset(x2, top), Offset(x2, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Single triangle pointing right.
class _PlayIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.15)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.85)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────
//  End early link + confirmation dialog
// ─────────────────────────────────────────────────

class _EndEarlyLink extends StatelessWidget {
  final VoidCallback onEndEarly;
  final VoidCallback onEndEarlyExit;

  const _EndEarlyLink({
    required this.onEndEarly,
    required this.onEndEarlyExit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showConfirmation(context),
      child: Text(
        'End session early',
        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End without completing this step?',
          style: AppTypography.title.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No', style: AppTypography.body.copyWith(color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              onEndEarly();
              onEndEarlyExit();
            },
            child: Text('Yes', style: AppTypography.body.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

