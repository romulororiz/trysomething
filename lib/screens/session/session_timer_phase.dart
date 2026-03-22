import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../components/app_overlays.dart';

/// Phase 2: Timer — the sacred core of the session.
///
/// Ring-centric layout: the BreathingRing is rendered by session_screen.dart
/// (Layer 4 of the 5-layer Stack). This widget positions content AROUND
/// the ring's known location (~42% from top, 270dp ring).
///
/// Shows: overline (hobby + step), rolling timer inside ring area,
/// step instructions below ring, coach tip icon, glass pause/play button,
/// and an elegant completion celebration.
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
    final screenHeight = MediaQuery.of(context).size.height;
    final safeTop = MediaQuery.of(context).padding.top;
    // Ring center is at screenHeight * 0.42 (absolute).
    // SafeArea shifts content down by safeTop, so subtract it.
    final ringCenterY = screenHeight * 0.42 - safeTop;

    return Stack(
      children: [
        // Overline at top
        Positioned(
          top: 24,
          left: 32,
          right: 32,
          child: Text(
            '${session.hobbyTitle.toUpperCase()} \u00b7 ${session.stepTitle}',
            style: AppTypography.overline,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Timer/completion centered EXACTLY at ring center
        Positioned(
          top: _isCompleting ? ringCenterY - 60 : ringCenterY - 40,
          left: 32,
          right: 32,
          child: _isCompleting
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      PhosphorIconsBold.checkCircle,
                      size: 48,
                      color: AppColors.success,
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Session complete',
                      style: AppTypography.display,
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    if (session.completionMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        session.completionMessage!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                    ],
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RollingTimer(
                      remaining: _remaining,
                      isWarm: _remaining < 60,
                    ),
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: session.isPaused ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text('Paused', style: AppTypography.caption),
                    ),
                  ],
                ),
        ),

        // Step instructions + coach tip below ring
        if (!_isCompleting)
          Positioned(
            top: ringCenterY + 160, // below the ring (ring radius ~135)
            left: 32,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                if (session.coachTip != null) ...[
                  const SizedBox(height: 12),
                  _CoachTipButton(coachTip: session.coachTip!),
                ],
              ],
            ),
          ),

        // Pause/play button at bottom
        if (!_isCompleting)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GlassPausePlayButton(
                  isPaused: session.isPaused,
                  onToggle: session.isPaused ? onResume : onPause,
                ),
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
            ),
          ),
      ],
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

  // D-22: IBM Plex Mono 72pt inside the ring
  TextStyle get _style => GoogleFonts.ibmPlexMono(
        fontSize: 72,
        fontWeight: FontWeight.w200,
        color: widget.color,
        height: 1.0,
      );

  @override
  Widget build(BuildContext context) {
    // D-22: Updated dimensions for 72pt font
    const digitWidth = 44.0;
    const digitHeight = 80.0;

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
      height: 80, // Match updated digitHeight
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, _) => Center(
          child: Text(
            ':',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 56,
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

// ═══════════════════════════════════════════════════════
//  GLASS PAUSE/PLAY BUTTON — Phosphor icons in glass circle (D-20)
// ═══════════════════════════════════════════════════════

class _GlassPausePlayButton extends StatefulWidget {
  final bool isPaused;
  final VoidCallback onToggle;

  const _GlassPausePlayButton({
    required this.isPaused,
    required this.onToggle,
  });

  @override
  State<_GlassPausePlayButton> createState() => _GlassPausePlayButtonState();
}

class _GlassPausePlayButtonState extends State<_GlassPausePlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassBackground,
            border: Border.all(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isPaused
                    ? PhosphorIconsBold.play
                    : PhosphorIconsBold.pause,
                key: ValueKey(widget.isPaused),
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COACH TIP BUTTON — subtle lightbulb icon (D-19)
// ═══════════════════════════════════════════════════════

class _CoachTipButton extends StatelessWidget {
  final String coachTip;

  const _CoachTipButton({required this.coachTip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCoachTip(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassBackground,
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: const Center(
          child: Icon(
            PhosphorIconsLight.lightbulb,
            color: AppColors.textMuted,
            size: 18,
          ),
        ),
      ),
    );
  }

  void _showCoachTip(BuildContext context) {
    showAppSheet(
      context: context,
      title: 'Coach Tip',
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Text(
          coachTip,
          style: AppTypography.body,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  END EARLY LINK + CONFIRMATION DIALOG
// ═══════════════════════════════════════════════════════

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
