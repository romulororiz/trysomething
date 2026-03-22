import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
              isSelected: _selected == ReflectionChoice.lovedIt,
              dimmed: _selected != null && _selected != ReflectionChoice.lovedIt,
              onTap: () => _onSelect(ReflectionChoice.lovedIt),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 16),

            _ReflectionCard(
              choice: ReflectionChoice.okay,
              label: 'It was okay',
              description: 'Still figuring it out',
              isSelected: _selected == ReflectionChoice.okay,
              dimmed: _selected != null && _selected != ReflectionChoice.okay,
              onTap: () => _onSelect(ReflectionChoice.okay),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 16),

            _ReflectionCard(
              choice: ReflectionChoice.struggled,
              label: 'Struggled',
              description: 'Something felt off',
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
  final bool isSelected;
  final bool dimmed;
  final VoidCallback onTap;

  const _ReflectionCard({
    required this.choice,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.dimmed,
    required this.onTap,
  });

  IconData get _icon {
    switch (choice) {
      case ReflectionChoice.lovedIt:
        return PhosphorIconsRegular.heartStraight;
      case ReflectionChoice.okay:
        return PhosphorIconsRegular.minusCircle;
      case ReflectionChoice.struggled:
        return PhosphorIconsRegular.cloudRain;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: dimmed ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GlassCard(
        onTap: onTap,
        borderColor:
            isSelected ? AppColors.accent : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(
              _icon,
              size: 24,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(description, style: AppTypography.caption),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                PhosphorIconsBold.check,
                size: 18,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }
}

