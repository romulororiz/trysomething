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
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
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
            padding: EdgeInsets.only(bottom: bottomInset),
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
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: child,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                      style: AppTypography.title.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    // Message
                    Text(
                      message,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.5,
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
                                borderRadius:
                                    BorderRadius.circular(Spacing.radiusButton),
                                border: Border.all(
                                    color: AppColors.glassBorder, width: 0.5),
                              ),
                              child: Center(
                                child: Text(
                                  cancelLabel,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                                    : AppColors.accent.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(Spacing.radiusButton),
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
    );
  }
}

// ═══════════════════════════════════════════════════════
//  APP SNACKBAR — Premium transient messages
// ═══════════════════════════════════════════════════════

enum AppSnackbarType { success, info, error }

/// Shows a premium snackbar with consistent styling.
void showAppSnackbar(
  BuildContext context, {
  required String message,
  AppSnackbarType type = AppSnackbarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final (bgColor, iconData, iconColor) = switch (type) {
    AppSnackbarType.success => (
        const Color(0xFF0A1A14),
        Icons.check_circle_rounded,
        AppColors.success,
      ),
    AppSnackbarType.info => (
        AppColors.surfaceElevated,
        Icons.info_outline_rounded,
        AppColors.textSecondary,
      ),
    AppSnackbarType.error => (
        const Color(0xFF1A0A0A),
        Icons.error_outline_rounded,
        AppColors.accent,
      ),
  };

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(iconData, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
      ),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      duration: duration,
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}
