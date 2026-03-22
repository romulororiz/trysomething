import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../components/glass_card.dart';
import '../../models/session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Phase 3: Reflect — quick, warm, not a chore.
///
/// Three reflection cards (Loved it / It was okay / Struggled),
/// optional journal text, optional photo (Pro), then "Save & finish".
class SessionReflectPhase extends StatefulWidget {
  final SessionState session;
  final void Function(
    ReflectionChoice choice, {
    String? journalText,
    String? photoPath,
  }) onSubmit;
  final VoidCallback onSkip;

  const SessionReflectPhase({
    super.key,
    required this.session,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  State<SessionReflectPhase> createState() => _SessionReflectPhaseState();
}

class _SessionReflectPhaseState extends State<SessionReflectPhase> {
  ReflectionChoice? _selected;
  final _journalController = TextEditingController();

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _onSelect(ReflectionChoice choice) {
    HapticFeedback.selectionClick();
    setState(() => _selected = choice);
  }

  void _onSave() {
    if (_selected == null) return;
    widget.onSubmit(
      _selected!,
      journalText: _journalController.text.isNotEmpty
          ? _journalController.text
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),

            // Headline
            Text(
              'How was that?',
              style: AppTypography.display,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 40),

            // Reflection cards
            _ReflectionCard(
              choice: ReflectionChoice.lovedIt,
              label: 'Loved it',
              description: 'I could do this again',
              symbol: const _LovedItSymbol(),
              isSelected: _selected == ReflectionChoice.lovedIt,
              dimmed: _selected != null && _selected != ReflectionChoice.lovedIt,
              onTap: () => _onSelect(ReflectionChoice.lovedIt),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 16),

            _ReflectionCard(
              choice: ReflectionChoice.okay,
              label: 'It was okay',
              description: 'Still figuring it out',
              symbol: const _OkaySymbol(),
              isSelected: _selected == ReflectionChoice.okay,
              dimmed: _selected != null && _selected != ReflectionChoice.okay,
              onTap: () => _onSelect(ReflectionChoice.okay),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 16),

            _ReflectionCard(
              choice: ReflectionChoice.struggled,
              label: 'Struggled',
              description: 'Something felt off',
              symbol: const _StruggledSymbol(),
              isSelected: _selected == ReflectionChoice.struggled,
              dimmed: _selected != null && _selected != ReflectionChoice.struggled,
              onTap: () => _onSelect(ReflectionChoice.struggled),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            // Journal input (appears after selection)
            if (_selected != null) ...[
              const SizedBox(height: 32),
              Text(
                'Want to remember anything?',
                style: AppTypography.caption,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _journalController,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'What went well? What was tricky?',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
            ],

            const SizedBox(height: 40),

            // Save & finish CTA
            if (_selected != null)
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _onSave,
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
                      'Save & finish',
                      textAlign: TextAlign.center,
                      style: AppTypography.button,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // Skip link
            GestureDetector(
              onTap: widget.onSkip,
              child: Text(
                'Skip',
                style: AppTypography.body.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Reflection card
// ─────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  final ReflectionChoice choice;
  final String label;
  final String description;
  final Widget symbol;
  final bool isSelected;
  final bool dimmed;
  final VoidCallback onTap;

  const _ReflectionCard({
    required this.choice,
    required this.label,
    required this.description,
    required this.symbol,
    required this.isSelected,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GlassCard(
        onTap: onTap,
        borderColor:
            isSelected ? AppColors.textPrimary : AppColors.glassBorder,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(width: 48, height: 48, child: symbol),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(description, style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Reflection symbols — abstract brushstroke marks
// ─────────────────────────────────────────────────

/// "Loved it" — upward flowing curves.
class _LovedItSymbol extends StatelessWidget {
  const _LovedItSymbol();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LovedItPainter());
  }
}

class _LovedItPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Three curves sweeping upward
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.8)
      ..cubicTo(
        size.width * 0.25, size.height * 0.3,
        size.width * 0.35, size.height * 0.5,
        size.width * 0.45, size.height * 0.2,
      );
    canvas.drawPath(path, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.35, size.height * 0.85)
      ..cubicTo(
        size.width * 0.45, size.height * 0.35,
        size.width * 0.55, size.height * 0.45,
        size.width * 0.65, size.height * 0.15,
      );
    canvas.drawPath(path2, paint);

    final path3 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.9)
      ..cubicTo(
        size.width * 0.65, size.height * 0.4,
        size.width * 0.75, size.height * 0.5,
        size.width * 0.85, size.height * 0.2,
      );
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// "It was okay" — gentle sine wave.
class _OkaySymbol extends StatelessWidget {
  const _OkaySymbol();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OkayPainter());
  }
}

class _OkayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(size.width * 0.1, size.height * 0.5);

    // Smooth sine wave — 2 periods
    const steps = 60;
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final x = size.width * (0.1 + 0.8 * t);
      final y = size.height * 0.5 +
          size.height * 0.2 *
              _sin(t * 2 * 3.14159265 * 2); // ~2 periods
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  double _sin(double x) {
    // Simple inline sin (avoids importing dart:math for one call)
    double result = x;
    double term = x;
    for (int i = 1; i <= 7; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// "Struggled" — soft figure-8 knot.
class _StruggledSymbol extends StatelessWidget {
  const _StruggledSymbol();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StruggledPainter());
  }
}

class _StruggledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Figure-8 / infinity loop
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.3;
    final ry = size.height * 0.2;

    final path = Path();
    const steps = 80;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps * 2 * 3.14159265;
      // Lemniscate of Bernoulli approximation
      final denom = 1 + _sin(t) * _sin(t);
      final x = cx + rx * _cos(t) / denom;
      final y = cy + ry * _sin(t) * _cos(t) / denom;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  double _sin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 7; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _cos(double x) => _sin(x + 1.5707963);

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
