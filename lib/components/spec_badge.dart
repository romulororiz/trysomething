import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Badge type for spec display
enum SpecBadgeType { cost, time, difficulty }

// ═══════════════════════════════════════════════════════
//  SPEC BADGE — Now renders as plain warm gray text
// ═══════════════════════════════════════════════════════

/// Single spec value. Renders as warm gray text (no pill, no icon).
/// Kept for API compatibility — screens that used SpecBadge still compile.
class SpecBadge extends StatelessWidget {
  final SpecBadgeType type;
  final String text;
  final bool small;
  final bool onDark;

  const SpecBadge({
    super.key,
    required this.type,
    required this.text,
    this.small = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.data.copyWith(
        fontSize: small ? 11 : 13,
        color: onDark ? AppColors.textSecondary : AppColors.textMuted,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SPEC BAR — Middot-separated warm gray text line
// ═══════════════════════════════════════════════════════

/// Row of specs as a single warm gray middot-separated line.
/// Replaces the old 3-pill colored badge row.
class SpecBar extends StatelessWidget {
  final String cost;
  final String time;
  final String difficulty;
  final bool small;
  final bool onDark;
  final bool withContainer;

  const SpecBar({
    super.key,
    required this.cost,
    required this.time,
    required this.difficulty,
    this.small = false,
    this.onDark = false,
    this.withContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.data.copyWith(
      fontSize: small ? 11 : 13,
      color: onDark ? AppColors.textSecondary : AppColors.textMuted,
    );

    final line = Text(
      '$cost · $time · $difficulty',
      style: style,
      overflow: TextOverflow.ellipsis,
    );

    if (!withContainer) return line;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: line,
    );
  }
}
