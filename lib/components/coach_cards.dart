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
  guide,      // "How to Do It" — instructional, no action buttons
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
///
/// Only detects **headers** that appear at the START of a line (not inline bold).
/// This avoids splitting numbered lists like "1. **Google** something" into cards.
List<CoachCard>? parseCoachResponse(String text) {
  final cards = <CoachCard>[];

  // Only match **text** or ## text at the START of a line (^)
  final sectionPattern = RegExp(
    r'^(?:\*\*(.+?)\*\*|##\s*(.+))$',
    multiLine: true,
  );
  final matches = sectionPattern.allMatches(text).toList();

  if (matches.length < 2) return null; // Not enough structure

  // Extract sections between headers
  for (int i = 0; i < matches.length; i++) {
    final header = (matches[i].group(1) ?? matches[i].group(2))?.trim() ?? '';
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
  if (h.contains('plan') || h.contains('session') || h.contains('tonight') ||
      h.contains('next step') || h.contains('your next')) {
    return CoachCardType.plan;
  }
  if (h.contains('cheap') || h.contains('budget') || h.contains('cost') ||
      h.contains('alternative') || h.contains('save money')) {
    return CoachCardType.budget;
  }
  if (h.contains('restart') || h.contains('back') || h.contains('recover') ||
      h.contains('gentle') || h.contains('stuck')) {
    return CoachCardType.recovery;
  }
  if (h.contains('reflect') || h.contains('journal') || h.contains('think') ||
      h.contains('good looks like') || h.contains('what good')) {
    return CoachCardType.reflection;
  }
  if (h.contains('week') || h.contains('adjust') || h.contains('change') ||
      h.contains('update')) {
    return CoachCardType.weekPlan;
  }
  // Avoidance cards — "What to Skip", "What to Avoid"
  // Uses guide type (no CTAs) — icon differentiated below
  if (h.contains('skip') || h.contains('avoid') || h.contains('don\'t') ||
      h.contains('mistake') || h.contains('warning')) {
    return CoachCardType.guide;
  }
  // Instructional cards — "How to Do It", "What You Need", "Tips", "Easier"
  if (h.contains('how to') || h.contains('what you need') || h.contains('tip') ||
      h.contains('do it') || h.contains('guide') || h.contains('step') ||
      h.contains('easier') || h.contains('simplif') || h.contains('technique') ||
      h.contains('try this') || h.contains('here\'s') || h.contains('focus') ||
      h.contains('practice') || h.contains('start with') || h.contains('instead')) {
    return CoachCardType.guide;
  }
  // Catch-all: anything with a header is at least a guide, not "plain"
  return CoachCardType.guide;
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
    var (icon, color) = _cardMeta(card.type);
    // Override icons for specific card titles within guide/reflection types
    final h = card.title.toLowerCase();
    if (h.contains('skip') || h.contains('avoid') || h.contains('don\'t') || h.contains('warning')) {
      icon = Icons.block_rounded;
      color = const Color(0xFFFF6B6B);
    } else if (h.contains('good looks like') || h.contains('what good')) {
      icon = Icons.thumb_up_rounded;
      color = const Color(0xFF06D6A0);
    }

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
                          child: CoachMarkdownText(
                            text: item,
                            textColor: AppColors.textSecondary,
                            fontSize: 13,
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
      case CoachCardType.guide:
        return [];
      case CoachCardType.budget:
        return ['Show budget alternatives', 'Show starter kit'];
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
        return (Icons.checklist_rounded, AppColors.accent);
      case CoachCardType.guide:
        return (Icons.lightbulb_outline_rounded, const Color(0xFFFFB347));
      case CoachCardType.budget:
        return (Icons.attach_money_rounded, const Color(0xFF06D6A0));
      case CoachCardType.recovery:
        return (Icons.support_rounded, const Color(0xFFFFB347));
      case CoachCardType.reflection:
        return (Icons.self_improvement_rounded, const Color(0xFF7B68EE));
      case CoachCardType.weekPlan:
        return (Icons.calendar_today_rounded, const Color(0xFF87CEEB));
      case CoachCardType.plain:
        return (Icons.auto_awesome_rounded, AppColors.accent);
    }
  }
}

// ═══════════════════════════════════════════════════════
//  COACH MARKDOWN TEXT — lightweight inline markdown
// ═══════════════════════════════════════════════════════

/// Renders coach AI text with basic markdown support:
/// **bold**, *italic*, `code`, - bullets, ## headers, numbered lists.
/// No external dependencies — purpose-built for coach bubble styling.
class CoachMarkdownText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double fontSize;

  const CoachMarkdownText({
    super.key,
    required this.text,
    this.textColor = AppColors.textSecondary,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }

  List<Widget> _parseBlocks(String raw) {
    final lines = raw.split('\n');
    final widgets = <Widget>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();

      // Skip empty lines — add small spacing
      if (line.isEmpty) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 8));
        }
        i++;
        continue;
      }

      // ## Header
      final headerMatch = RegExp(r'^##\s+(.+)$').firstMatch(line);
      if (headerMatch != null) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: widgets.isNotEmpty ? 12 : 0, bottom: 4),
          child: Text(
            headerMatch.group(1)!.trim(),
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: fontSize + 1,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ));
        i++;
        continue;
      }

      // **Bold header line** (standalone bold — not inline)
      final boldLineMatch = RegExp(r'^\*\*(.+?)\*\*\s*$').firstMatch(line);
      if (boldLineMatch != null) {
        widgets.add(Padding(
          padding: EdgeInsets.only(top: widgets.isNotEmpty ? 10 : 0, bottom: 4),
          child: Text(
            boldLineMatch.group(1)!.trim(),
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ));
        i++;
        continue;
      }

      // Bullet line: - text or • text or * text (but not **bold**)
      final bulletMatch = RegExp(r'^[-•]\s+(.+)$').firstMatch(line);
      final starBulletMatch =
          bulletMatch ?? RegExp(r'^\*\s+(?!\*)(.+)$').firstMatch(line);
      if (starBulletMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7, left: 4),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRichLine(starBulletMatch.group(1)!.trim()),
              ),
            ],
          ),
        ));
        i++;
        continue;
      }

      // Numbered list: 1. text, 2. text, etc.
      final numberedMatch = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '${numberedMatch.group(1)}.',
                  style: AppTypography.body.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: fontSize,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildRichLine(numberedMatch.group(2)!.trim()),
              ),
            ],
          ),
        ));
        i++;
        continue;
      }

      // Regular paragraph text
      widgets.add(_buildRichLine(line));
      i++;
    }

    return widgets;
  }

  /// Renders a single line with inline **bold**, *italic*, and `code`.
  Widget _buildRichLine(String line) {
    return RichText(
      text: TextSpan(
        style: AppTypography.body.copyWith(
          color: textColor,
          fontSize: fontSize,
          height: 1.6,
        ),
        children: _parseInlineSpans(line),
      ),
    );
  }

  /// Parses inline markdown: **bold**, *italic*, `code`
  List<InlineSpan> _parseInlineSpans(String text) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(
      r'(\*\*(.+?)\*\*'  // **bold**
      r'|\*(.+?)\*'       // *italic*
      r'|`(.+?)`'         // `code`
      r')',
    );

    var lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      // Plain text before this match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      if (match.group(2) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ));
      } else if (match.group(3) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(3),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(4) != null) {
        // `code`
        spans.add(TextSpan(
          text: match.group(4),
          style: TextStyle(
            fontFamily: 'IBM Plex Mono',
            fontSize: fontSize - 1,
            color: AppColors.textPrimary,
            backgroundColor: AppColors.glassBackground,
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Remaining plain text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }
}
