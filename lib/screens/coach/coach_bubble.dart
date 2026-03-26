import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../components/coach_cards.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'coach_provider.dart';

// ═══════════════════════════════════════════════════════
//  COACH BUBBLE — Premium styled message
// ═══════════════════════════════════════════════════════

class CoachBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String action)? onCardAction;

  const CoachBubble({super.key, required this.message, this.onCardAction});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    if (isUser) {
      final hasImage = (message.imageUrl != null && message.imageUrl!.isNotEmpty) ||
          message.imageUploading;
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 48),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo (if attached) — rounded inside the bubble
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: message.imageUploading
                      ? ImageSkeleton()
                      : CachedNetworkImage(
                          imageUrl: message.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                          placeholder: (_, __) => ImageSkeleton(),
                        ),
                ),
              // Text
              if (message.content.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      10, hasImage ? 8 : 6, 10, 6),
                  child: Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: 30.ms)
          .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    // Assistant — try structured cards first, fall back to plain bubble
    final cards = parseCoachResponse(message.content);
    if (cards != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, right: 16),
        child: CoachCardList(cards: cards, onAction: onCardAction),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: 30.ms)
          .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    // Plain text fallback — render with markdown support
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: CoachMarkdownText(
          text: message.content,
          textColor: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 30.ms)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}

// ═══════════════════════════════════════════════════════
//  IMAGE SKELETON — shimmer placeholder while uploading
// ═══════════════════════════════════════════════════════

/// Shimmer skeleton placeholder for image while uploading.
class ImageSkeleton extends StatefulWidget {
  const ImageSkeleton({super.key});

  @override
  State<ImageSkeleton> createState() => _ImageSkeletonState();
}

class _ImageSkeletonState extends State<ImageSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-0.5 + 2.0 * _controller.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Center(
            child: Icon(Icons.photo_rounded,
                size: 28, color: Colors.white.withValues(alpha: 0.25)),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
//  TYPING INDICATOR — bouncing dots
// ═══════════════════════════════════════════════════════

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = (_controller.value - delay).clamp(0.0, 1.0);
                final y = math.sin(t * math.pi) * 4;
                return Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Transform.translate(
                    offset: Offset(0, -y),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted
                            .withValues(alpha: 0.4 + t * 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
