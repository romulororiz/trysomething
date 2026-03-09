import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Warm Cinematic glass surface card.
///
/// Two variants:
/// - **Blur** (`blur: true`): Uses [BackdropFilter] for frosted glass.
///   Use for static/hero elements only (max 3-5 per screen).
/// - **Simple** (`blur: false`, default): Semi-transparent bg + border,
///   no [BackdropFilter]. Safe for scrollable lists at 60fps.
///
/// Includes scale-to-0.97 press animation when [onTap] is provided.
class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool blur;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.blur = false,
    this.borderRadius = 20,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_pressed) setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.glassBackground;
    final border = widget.borderColor ?? AppColors.glassBorder;

    Widget card = Container(
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: border, width: 0.5),
      ),
      child: widget.child,
    );

    // Wrap with BackdropFilter only when blur is requested
    if (widget.blur) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: card,
        ),
      );
    }

    // Press animation + tap handling
    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: card,
        ),
      );
    }

    return card;
  }
}
