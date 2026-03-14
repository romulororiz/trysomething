import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../components/app_overlays.dart';

/// Phase 2: Timer — the sacred core of the session.
///
/// Full-screen focus with a premium rolling-digit countdown,
/// step instructions, and a minimal pause button.
///
/// Also renders the "completing" moment when
/// [session.phase] is [SessionPhase.completing].
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
  int get _remaining =>
      (_totalSeconds - session.elapsedSeconds).clamp(0, _totalSeconds);

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

          // Premium rolling-digit timer or completion message
          if (_isCompleting) ...[
            Text(
              '${session.selectedMinutes} minutes',
              style: AppTypography.display,
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Session complete',
              style: AppTypography.display,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ] else
            _RollingTimer(
              remaining: _remaining,
              isWarm: _remaining < 60,
            ),

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

// ═══════════════════════════════════════════════════════
//  ROLLING DIGIT TIMER — individual digits animate
// ═══════════════════════════════════════════════════════

class _RollingTimer extends StatelessWidget {
  final int remaining;
  final bool isWarm;

  const _RollingTimer({required this.remaining, this.isWarm = false});

  @override
  Widget build(BuildContext context) {
    final m = remaining ~/ 60;
    final s = remaining % 60;

    final m1 = m ~/ 10; // tens of minutes
    final m2 = m % 10; // ones of minutes
    final s1 = s ~/ 10; // tens of seconds
    final s2 = s % 10; // ones of seconds

    final color =
        isWarm ? const Color(0xFFF5E6D8) : AppColors.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RollingDigit(digit: m1, color: color),
        _RollingDigit(digit: m2, color: color),
        _Separator(color: color),
        _RollingDigit(digit: s1, color: color),
        _RollingDigit(digit: s2, color: color),
      ],
    );
  }
}

/// Single digit that slides vertically when its value changes.
/// Clips to a fixed height so only the current digit is visible.
class _RollingDigit extends StatefulWidget {
  final int digit;
  final Color color;

  const _RollingDigit({required this.digit, required this.color});

  @override
  State<_RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<_RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _outgoing;
  late Animation<Offset> _incoming;
  late Animation<double> _outgoingOpacity;
  late Animation<double> _incomingOpacity;

  int _currentDigit = 0;
  int _previousDigit = 0;

  static const _duration = Duration(milliseconds: 350);
  static const _curve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _previousDigit = widget.digit;
    _controller = AnimationController(vsync: this, duration: _duration);
    _setupAnimations();
  }

  void _setupAnimations() {
    _outgoing = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));

    _incoming = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));

    _outgoingOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _incomingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != _currentDigit) {
      _previousDigit = _currentDigit;
      _currentDigit = widget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get _style => GoogleFonts.ibmPlexMono(
        fontSize: 64,
        fontWeight: FontWeight.w200,
        color: widget.color,
        height: 1.0,
      );

  @override
  Widget build(BuildContext context) {
    // Measure digit height for clipping
    const digitWidth = 40.0;
    const digitHeight = 72.0;

    return SizedBox(
      width: digitWidth,
      height: digitHeight,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (!_controller.isAnimating && _controller.isDismissed) {
              // Static — no animation needed
              return Center(
                child: Text(
                  '$_currentDigit',
                  style: _style,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Stack(
              children: [
                // Outgoing digit — slides up and fades
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: _outgoing.value,
                    child: Opacity(
                      opacity: _outgoingOpacity.value,
                      child: Center(
                        child: Text(
                          '$_previousDigit',
                          style: _style,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                // Incoming digit — slides in from below
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: _incoming.value,
                    child: Opacity(
                      opacity: _incomingOpacity.value,
                      child: Center(
                        child: Text(
                          '$_currentDigit',
                          style: _style,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The colon separator between minutes and seconds.
/// Gently pulses opacity to feel alive.
class _Separator extends StatefulWidget {
  final Color color;
  const _Separator({required this.color});

  @override
  State<_Separator> createState() => _SeparatorState();
}

class _SeparatorState extends State<_Separator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 72,
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, _) => Center(
          child: Text(
            ':',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 52,
              fontWeight: FontWeight.w200,
              color: widget.color.withValues(alpha: _opacity.value),
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
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
    showAppConfirmDialog(
      context: context,
      title: 'End without completing this step?',
      message: 'Your progress for this step won\'t be saved.',
      confirmLabel: 'End session',
      cancelLabel: 'Keep going',
      isDestructive: true,
      onConfirm: () {
        onEndEarly();
        onEndEarlyExit();
      },
    );
  }
}
