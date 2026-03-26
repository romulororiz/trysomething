import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// About sheet content — app info, tagline, version, legal links.
class AboutSheetContent extends StatelessWidget {
  final void Function(String url) onOpenLegal;

  const AboutSheetContent({super.key, required this.onOpenLegal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          RichText(
            text: TextSpan(
              style: AppTypography.display,
              children: [
                TextSpan(
                    text: 'Try', style: TextStyle(color: AppColors.accent)),
                TextSpan(
                    text: 'Something',
                    style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Stop scrolling. Start something.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TrySomething helps you find a hobby that fits your life \u2014 '
            'your budget, your schedule, your energy \u2014 and gives you a '
            'simple plan to actually start it. No pressure. No hustle culture. '
            'Just one good hobby, tried for 30 days.',
            textAlign: TextAlign.center,
            style: AppTypography.sansBodySmall
                .copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 20),
          Text(
            'Version 1.0.0 (build 1)',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onOpenLegal('https://trysomething.io/privacy'),
                child: Text('Privacy Policy',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.accent)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('\u00b7',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              GestureDetector(
                onTap: () => onOpenLegal('https://trysomething.io/terms'),
                child: Text('Terms of Service',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Made with \u2665 in Zurich',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Shared deletion warning shown in both email and OAuth delete flows.
Widget buildDeletionWarning({required VoidCallback onManageSubscriptions}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Your account will be scheduled for deletion. Your data will be permanently removed after 30 days.',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Active subscriptions are not automatically cancelled.',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onManageSubscriptions,
        child: Text(
          'Manage Subscriptions',
          style: AppTypography.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

/// Opens platform subscription management.
Future<void> openSubscriptionManagement() async {
  final String url;
  if (Platform.isIOS) {
    url = 'https://apps.apple.com/account/subscriptions';
  } else {
    url = 'https://play.google.com/store/account/subscriptions';
  }
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Bottom sheet content for email users — includes password field.
class DeleteAccountSheetContent extends StatefulWidget {
  final Future<void> Function(String password) onDelete;

  const DeleteAccountSheetContent({super.key, required this.onDelete});

  @override
  State<DeleteAccountSheetContent> createState() =>
      _DeleteAccountSheetContentState();
}

class _DeleteAccountSheetContentState
    extends State<DeleteAccountSheetContent> {
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDeletionWarning(
              onManageSubscriptions: openSubscriptionManagement),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.glassBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GestureDetector(
              onTap: _isDeleting
                  ? null
                  : () async {
                      final password = _passwordController.text.trim();
                      if (password.isEmpty) {
                        setState(() => _errorText = 'Password is required');
                        return;
                      }
                      setState(() => _isDeleting = true);
                      Navigator.of(context).pop();
                      await widget.onDelete(password);
                    },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Delete Account',
                        style:
                            AppTypography.button.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet content for OAuth users — no password field.
class DeleteAccountDialogContent extends StatefulWidget {
  final Future<void> Function() onDelete;

  const DeleteAccountDialogContent({super.key, required this.onDelete});

  @override
  State<DeleteAccountDialogContent> createState() =>
      _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState
    extends State<DeleteAccountDialogContent> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDeletionWarning(
              onManageSubscriptions: openSubscriptionManagement),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.button
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _isDeleting
                      ? null
                      : () async {
                          setState(() => _isDeleting = true);
                          Navigator.of(context).pop();
                          await widget.onDelete();
                        },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Delete Account',
                            style: AppTypography.button
                                .copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
