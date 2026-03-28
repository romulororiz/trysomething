import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';

// ═══════════════════════════════════════════════════════
//  APP SHEET — Premium glass bottom sheet
// ═══════════════════════════════════════════════════════

/// Shows a premium glass bottom sheet with consistent styling.
///
/// [title] — optional header title
/// [builder] — builds the sheet content
/// [isScrollControlled] — true for full-height sheets (e.g. forms)
/// [enableDrag] — whether the sheet can be dismissed by dragging
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
  bool enableDrag = true,
  bool useSafeArea = true,
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    builder: (ctx) => _AppSheetWrapper(
      title: title,
      child: builder(ctx),
    ),
  );
}

class _AppSheetWrapper extends StatelessWidget {
  final String? title;
  final Widget child;

  const _AppSheetWrapper({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.5),
          left: BorderSide(color: AppColors.glassBorder, width: 0.5),
          right: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textWhisper,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Optional title
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title!,
                            style: AppTypography.title.copyWith(fontSize: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.glassBorder, width: 0.5),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Content
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  APP CONFIRM DIALOG — Premium confirmation dialog
// ═══════════════════════════════════════════════════════

/// Shows a premium confirmation dialog with consistent styling.
///
/// [title] — dialog title
/// [message] — descriptive message
/// [confirmLabel] — text for the confirm button (default: "Confirm")
/// [cancelLabel] — text for the cancel button (default: "Cancel")
/// [isDestructive] — if true, confirm button uses coral/red styling
/// [onConfirm] — callback when confirmed (dialog auto-closes after)
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  VoidCallback? onConfirm,
}) {
  HapticFeedback.mediumImpact();
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
    pageBuilder: (ctx, _, __) => _AppConfirmDialogContent(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      onConfirm: onConfirm,
    ),
  );
}

class _AppConfirmDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback? onConfirm;

  const _AppConfirmDialogContent({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(false),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GestureDetector(
              onTap: () {}, // absorb taps on the dialog itself
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder, width: 0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            title,
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Message
                          Text(
                            message,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              height: 1.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Buttons
                          Row(
                            children: [
                              // Cancel
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(false),
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBackground,
                                      borderRadius: BorderRadius.circular(
                                          Spacing.radiusButton),
                                      border: Border.all(
                                          color: AppColors.glassBorder,
                                          width: 0.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        cancelLabel,
                                        style: AppTypography.body.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Confirm
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                    onConfirm?.call();
                                  },
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDestructive
                                          ? AppColors.accent
                                          : AppColors.accent
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          Spacing.radiusButton),
                                      border: isDestructive
                                          ? null
                                          : Border.all(
                                              color: AppColors.accent
                                                  .withValues(alpha: 0.3),
                                              width: 0.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        confirmLabel,
                                        style: AppTypography.body.copyWith(
                                          color: isDestructive
                                              ? Colors.white
                                              : AppColors.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  APP SNACKBAR — Premium transient messages
// ═══════════════════════════════════════════════════════

enum AppSnackbarType { success, info, error, deleted }

/// Shows a premium toast notification anchored at the bottom of the screen.
///
/// Uses a custom overlay instead of Material SnackBar for full control
/// over positioning, animation, and glass styling.
///
/// [actionLabel] and [onAction] add a tappable action button (e.g. "Undo").
void showAppSnackbar(
  BuildContext context, {
  required String message,
  AppSnackbarType type = AppSnackbarType.info,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AppToast(
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: () {
        try { entry.remove(); } catch (_) {}
      },
    ),
  );
  overlay.insert(entry);
}

class _AppToast extends StatefulWidget {
  final String message;
  final AppSnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _AppToast({
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final (accentColor, iconData) = switch (widget.type) {
      AppSnackbarType.success => (AppColors.success, Icons.check_circle_rounded),
      AppSnackbarType.info => (AppColors.textSecondary, Icons.info_outline_rounded),
      AppSnackbarType.error => (AppColors.accent, Icons.error_outline_rounded),
      AppSnackbarType.deleted => (const Color(0xFFFF6B6B), Icons.delete_outline_rounded),
    };

    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomPadding + 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 40 * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        ),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dy > 100) _dismiss();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xDD141418),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(iconData, size: 20, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          widget.onAction?.call();
                          _dismiss();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: AppTypography.caption.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
