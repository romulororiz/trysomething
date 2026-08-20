import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Auto-renewal disclosure + legal links shown at the bottom of paywalls.
/// App Store Review 3.1.2 requires this next to any subscription purchase UI.
class SubscriptionLegalFooter extends StatelessWidget {
  const SubscriptionLegalFooter({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = AppTypography.sansTiny.copyWith(
      color: AppColors.textSecondary,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textMuted,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'Subscriptions renew automatically unless canceled at least '
            '24 hours before the period ends. Manage or cancel anytime '
            'in your app store account settings.',
            style: AppTypography.sansTiny.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _open('https://trysomething.io/terms'),
                child: Text('Terms of Service', style: linkStyle),
              ),
              Text(
                '  ·  ',
                style: AppTypography.sansTiny
                    .copyWith(color: AppColors.textWhisper),
              ),
              GestureDetector(
                onTap: () => _open('https://trysomething.io/privacy'),
                child: Text('Privacy Policy', style: linkStyle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
