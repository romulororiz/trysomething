import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

// ═══════════════════════════════════════════════════════
//  COACH CARD TYPES
// ═══════════════════════════════════════════════════════

enum CoachCardType {
  plan,       // "Tonight's plan" — session length, what to do, what to ignore
  budget,     // "Cheaper way" — what to buy, what to skip
  recovery,   // "Restart gently" — tiny restart action
  reflection, // "Reflect" — post-session prompts
  weekPlan,   // "Updated plan" — what changed, why
  plain,      // Plain text — fallback
}

/// Parsed structured response from the coach AI.
class CoachCard {
  final CoachCardType type;
  final String title;
  final List<String> items;
  final String? summary;

  const CoachCard({
    required this.type,
    required this.title,
    this.items = const [],
    this.summary,
  });
}

// ═══════════════════════════════════════════════════════
//  RESPONSE PARSER — Detects structure in AI text
// ═══════════════════════════════════════════════════════

/// Attempts to parse a coach response into structured cards.
/// Returns null if the response is plain text with no detectable structure.
List<CoachCard>? parseCoachResponse(String text) {
  final cards = <CoachCard>[];

  // Detect section headers marked with ** or ##
  final sectionPattern = RegExp(r'(?:\*\*|##)\s*(.+?)(?:\*\*|$)', multiLine: true);
  final matches = sectionPattern.allMatches(text).toList();

  if (matches.length < 2) return null; // Not enough structure

  // Extract sections between headers
  for (int i = 0; i < matches.length; i++) {
    final header = matches[i].group(1)?.trim() ?? '';
    final start = matches[i].end;
    final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
    final body = text.substring(start, end).trim();

    // Parse bullet points from the body
    final bullets = body
        .split(RegExp(r'\n'))
        .map((l) => l.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final type = _detectCardType(header);
    cards.add(CoachCard(
      type: type,
      title: header,
      items: bullets,
    ));
  }

  return cards.isEmpty ? null : cards;
}

CoachCardType _detectCardType(String header) {
  final h = header.toLowerCase();
  if (h.contains('plan') || h.contains('session') || h.contains('tonight')) {
    return CoachCardType.plan;
  }
  if (h.contains('cheap') || h.contains('budget') || h.contains('cost') ||
      h.contains('buy') || h.contains('skip')) {
    return CoachCardType.budget;
  }
  if (h.contains('restart') || h.contains('back') || h.contains('recover') ||
      h.contains('gentle')) {
    return CoachCardType.recovery;
  }
  if (h.contains('reflect') || h.contains('journal') || h.contains('think')) {
    return CoachCardType.reflection;
  }
  if (h.contains('week') || h.contains('adjust') || h.contains('change') ||
      h.contains('update')) {
    return CoachCardType.weekPlan;
  }
  return CoachCardType.plain;
}

// ═══════════════════════════════════════════════════════
//  CARD RENDERERS
// ═══════════════════════════════════════════════════════

/// Renders a list of parsed coach cards as premium UI blocks.
class CoachCardList extends StatelessWidget {
  final List<CoachCard> cards;
  final void Function(String action)? onAction;

  const CoachCardList({
    super.key,
    required this.cards,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards.map((card) => _buildCard(card)).toList(),
    );
  }

  Widget _buildCard(CoachCard card) {
    final (icon, color) = _cardMeta(card.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    card.title,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (card.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...card.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            // Action buttons for actionable card types
            if (card.type != CoachCardType.plain) ...[
              const SizedBox(height: 12),
              _buildActions(card),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(CoachCard card) {
    final actions = _actionsForType(card.type);
    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: actions.asMap().entries.map((entry) {
        final isPrimary = entry.key == 0;
        final label = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: entry.key < actions.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAction?.call(label);
              },
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPrimary
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : AppColors.glassBorder,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: isPrimary
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<String> _actionsForType(CoachCardType type) {
    switch (type) {
      case CoachCardType.plan:
        return ['Start this session', 'Adjust it'];
      case CoachCardType.budget:
        return ['Use this version', 'Show starter kit'];
      case CoachCardType.recovery:
        return ['Restart now', 'Maybe switch'];
      case CoachCardType.reflection:
        return ['Open reflection', 'Skip for now'];
      case CoachCardType.weekPlan:
        return ['Apply update', 'Keep original'];
      case CoachCardType.plain:
        return [];
    }
  }

  (IconData, Color) _cardMeta(CoachCardType type) {
    switch (type) {
      case CoachCardType.plan:
        return (Icons.event_note_rounded, AppColors.accent);
      case CoachCardType.budget:
        return (Icons.savings_outlined, const Color(0xFF06D6A0));
      case CoachCardType.recovery:
        return (Icons.support_rounded, const Color(0xFFFFB347));
      case CoachCardType.reflection:
        return (Icons.self_improvement_rounded, const Color(0xFF7B68EE));
      case CoachCardType.weekPlan:
        return (Icons.calendar_today_rounded, const Color(0xFF87CEEB));
      case CoachCardType.plain:
        return (Icons.chat_bubble_outline_rounded, AppColors.textMuted);
    }
  }
}
