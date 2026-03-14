import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/app_background.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(
        title,
        style: AppTypography.title.copyWith(color: AppColors.accent),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: AppTypography.body.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SelectableText(
        text,
        style: AppTypography.sansBodySmall.copyWith(
          color: AppColors.textSecondary,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              text,
              style: AppTypography.sansBodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBlock(Map<String, String> fields) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${e.key}: ',
                    style: AppTypography.sansBodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: e.value,
                    style: AppTypography.sansBodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('Terms of Service', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, Spacing.scrollBottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'TERMS OF SERVICE',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TrySomething',
                        style: AppTypography.display.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Effective date: 14 March 2026',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      ),

                      // Section 1
                      _buildSectionTitle('1. Agreement to Terms'),
                      _buildBody(
                        'By downloading, installing, or using the TrySomething mobile application (the "App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.',
                      ),
                      _buildBody(
                        'TrySomething is operated by Romulo Freires ("we", "us", "our"), based in Zurich, Switzerland.',
                      ),
                      _buildBody(
                        'These Terms are governed by Swiss law, specifically the Swiss Code of Obligations (OR) and the Swiss Federal Act on Data Protection (FADP/nDSG).',
                      ),

                      // Section 2
                      _buildSectionTitle('2. Eligibility'),
                      _buildBody(
                        'You must be at least 16 years old to use the App. By using TrySomething, you represent that you meet this age requirement. If you are under 18, you confirm that you have obtained the consent of a parent or legal guardian.',
                      ),

                      // Section 3
                      _buildSectionTitle('3. Your Account'),
                      _buildBody(
                        'To access certain features, you must create an account using an email address and password, or by signing in via Google or Apple.',
                      ),
                      _buildBody(
                        'You are responsible for:',
                      ),
                      _buildBulletPoint(
                        'Maintaining the confidentiality of your login credentials.',
                      ),
                      _buildBulletPoint(
                        'All activity that occurs under your account.',
                      ),
                      _buildBulletPoint(
                        'Notifying us immediately at romulo@trysomething.com if you suspect unauthorized access.',
                      ),
                      _buildBody(
                        'We reserve the right to suspend or terminate accounts that violate these Terms.',
                      ),

                      // Section 4
                      _buildSectionTitle('4. Description of Service'),
                      _buildBody(
                        'TrySomething is a hobby discovery and onboarding platform that helps users find, start, and stick with new hobbies. The App provides:',
                      ),
                      _buildBulletPoint(
                        'A curated catalog of 150+ hobbies with starter kits, cost estimates, and step-by-step roadmaps.',
                      ),
                      _buildBulletPoint(
                        'AI-powered hobby generation and an AI hobby coach, powered by Anthropic\'s Claude language model.',
                      ),
                      _buildBulletPoint(
                        'Personal tools including journal entries (text and photo), schedule planning, shopping lists, and progress tracking.',
                      ),
                      _buildBulletPoint(
                        'Community features including public stories, buddy matching, and reactions.',
                      ),
                      _buildBulletPoint(
                        'Affiliate links to third-party retailers for purchasing hobby materials.',
                      ),
                      _buildBody(
                        'The App is provided "as is". We do not guarantee uninterrupted or error-free operation. Features may change, be added, or removed at our discretion.',
                      ),

                      // Section 5
                      _buildSectionTitle('5. Subscriptions and Payments'),

                      _buildSubsectionTitle('5.1 Free Tier'),
                      _buildBody(
                        'The free tier includes access to the full hobby catalog, roadmaps, starter kits, one active hobby at a time, limited AI coach messages (3 per month), and text-based journal entries.',
                      ),

                      _buildSubsectionTitle('5.2 TrySomething Pro'),
                      _buildBody(
                        'TrySomething Pro is available as a monthly (CHF 4.99) or annual (CHF 39.99) subscription. Pro features include:',
                      ),
                      _buildBulletPoint('Unlimited AI coach conversations.'),
                      _buildBulletPoint('Photo journal entries.'),
                      _buildBulletPoint('Multi-hobby tracking.'),
                      _buildBulletPoint('30-day guided support with rescue mode.'),

                      _buildSubsectionTitle('5.3 Billing'),
                      _buildBody(
                        'Subscriptions are processed through Apple App Store or Google Play Store via RevenueCat. Billing, renewals, and cancellations are governed by the respective store\'s terms. We do not store or process payment card information directly.',
                      ),

                      _buildSubsectionTitle('5.4 Free Trial'),
                      _buildBody(
                        'New subscribers may receive a 7-day free trial. You will not be charged during the trial period. If you do not cancel before the trial ends, your subscription will automatically convert to a paid plan.',
                      ),

                      _buildSubsectionTitle('5.5 Cancellation'),
                      _buildBody(
                        'You may cancel your subscription at any time through the App Store or Google Play Store settings. Cancellation takes effect at the end of the current billing period. No refunds are provided for partial billing periods. Refund requests for extraordinary circumstances should be directed to the respective app store.',
                      ),

                      // Section 6
                      _buildSectionTitle('6. AI-Generated Content'),
                      _buildBody(
                        'TrySomething uses artificial intelligence (Anthropic Claude) to generate hobby descriptions, roadmaps, starter kit recommendations, cost estimates, FAQ content, and coaching responses.',
                      ),
                      _buildBody(
                        'Important disclaimers regarding AI-generated content:',
                      ),
                      _buildBulletPoint(
                        'AI-generated content is for informational and inspirational purposes only. It does not constitute professional advice (medical, financial, legal, or otherwise).',
                      ),
                      _buildBulletPoint(
                        'Cost estimates are approximate and reflect typical Swiss retail pricing at the time of generation. Actual costs may vary.',
                      ),
                      _buildBulletPoint(
                        'Kit item recommendations are general suggestions. We do not warrant the safety, quality, or suitability of any recommended equipment or materials.',
                      ),
                      _buildBulletPoint(
                        'Coaching responses are automated and not provided by a licensed professional. If you experience physical discomfort during any hobby activity, consult a healthcare professional.',
                      ),
                      _buildBulletPoint(
                        'We apply content safety filters to prevent the generation of harmful, illegal, or inappropriate hobby content, but no filter is perfect.',
                      ),

                      // Section 7
                      _buildSectionTitle('7. User Content'),
                      _buildBody(
                        '"User Content" means any text, photos, journal entries, community stories, notes, or other content you create or upload through the App.',
                      ),

                      _buildSubsectionTitle('7.1 Ownership'),
                      _buildBody(
                        'You retain ownership of your User Content. By posting User Content to public features (such as Community Stories), you grant us a non-exclusive, worldwide, royalty-free license to display that content within the App for the purpose of operating the service.',
                      ),

                      _buildSubsectionTitle('7.2 Responsibilities'),
                      _buildBody(
                        'You agree not to post User Content that:',
                      ),
                      _buildBulletPoint(
                        'Is illegal, harmful, threatening, abusive, defamatory, or discriminatory.',
                      ),
                      _buildBulletPoint(
                        'Infringes on any third party\'s intellectual property or privacy rights.',
                      ),
                      _buildBulletPoint(
                        'Contains malware, spam, or commercial solicitations.',
                      ),
                      _buildBulletPoint(
                        'Impersonates another person or entity.',
                      ),
                      _buildBody(
                        'We reserve the right to remove any User Content that violates these Terms without prior notice.',
                      ),

                      // Section 8
                      _buildSectionTitle('8. Affiliate Links and Third-Party Services'),
                      _buildBody(
                        'The App may contain affiliate links to third-party retailers. When you purchase products through these links, we may earn a commission at no additional cost to you.',
                      ),
                      _buildBody(
                        'We are not responsible for the products, services, pricing, availability, or practices of third-party retailers. Your purchases from third parties are governed by those retailers\' own terms and conditions.',
                      ),
                      _buildBody(
                        'The App integrates with the following third-party services:',
                      ),
                      _buildBulletPoint('Unsplash (hobby images, governed by the Unsplash License).'),
                      _buildBulletPoint('Google Sign-In and Apple Sign-In (authentication).'),
                      _buildBulletPoint('RevenueCat (subscription management).'),
                      _buildBulletPoint('PostHog (anonymized usage analytics).'),
                      _buildBulletPoint('Sentry (crash reporting and error tracking).'),
                      _buildBulletPoint('Firebase Cloud Messaging (push notifications).'),
                      _buildBulletPoint('Anthropic Claude API (AI content generation and coaching).'),
                      _buildBulletPoint('Neon PostgreSQL hosted on Vercel (database and API hosting).'),

                      // Section 9
                      _buildSectionTitle('9. Prohibited Uses'),
                      _buildBody(
                        'You agree not to:',
                      ),
                      _buildBulletPoint(
                        'Use the App for any unlawful purpose.',
                      ),
                      _buildBulletPoint(
                        'Attempt to reverse-engineer, decompile, or extract source code from the App.',
                      ),
                      _buildBulletPoint(
                        'Interfere with or disrupt the App\'s infrastructure (including the API).',
                      ),
                      _buildBulletPoint(
                        'Circumvent rate limits, content filters, or subscription restrictions.',
                      ),
                      _buildBulletPoint(
                        'Scrape, harvest, or collect data from the App through automated means.',
                      ),
                      _buildBulletPoint(
                        'Use the AI coach or generation features to produce content that is harmful, illegal, or violates Anthropic\'s Acceptable Use Policy.',
                      ),
                      _buildBulletPoint(
                        'Create multiple accounts to circumvent usage limits.',
                      ),

                      // Section 10
                      _buildSectionTitle('10. Intellectual Property'),
                      _buildBody(
                        'The App, including its design, code, branding, category stroke artwork, and curated hobby content, is the intellectual property of Romulo Roriz and is protected under Swiss and international copyright law.',
                      ),
                      _buildBody(
                        'AI-generated hobby content (descriptions, roadmaps, coaching responses) is provided for your personal use within the App. You may not reproduce, redistribute, or commercially exploit AI-generated content outside of the App without written permission.',
                      ),
                      _buildBody(
                        '"TrySomething" and the TrySomething logo are unregistered trademarks. Unauthorized use is prohibited.',
                      ),

                      // Section 11
                      _buildSectionTitle('11. Limitation of Liability'),
                      _buildBody(
                        'To the maximum extent permitted by Swiss law (Art. 100 OR):',
                      ),
                      _buildBulletPoint(
                        'The App is provided "as is" and "as available" without warranties of any kind, whether express or implied.',
                      ),
                      _buildBulletPoint(
                        'We do not warrant that hobby recommendations, AI-generated roadmaps, or cost estimates are accurate, complete, or suitable for your individual circumstances.',
                      ),
                      _buildBulletPoint(
                        'We are not liable for any injury, property damage, or financial loss arising from your participation in any hobby discovered through the App.',
                      ),
                      _buildBulletPoint(
                        'We are not liable for any indirect, incidental, special, or consequential damages arising from your use of the App.',
                      ),
                      _buildBulletPoint(
                        'Our total liability for any claim related to the App shall not exceed the amount you paid for TrySomething Pro in the 12 months preceding the claim, or CHF 50, whichever is greater.',
                      ),
                      _buildBody(
                        'Nothing in these Terms excludes liability for gross negligence or willful misconduct (Art. 100 para. 1 OR).',
                      ),

                      // Section 12
                      _buildSectionTitle('12. Indemnification'),
                      _buildBody(
                        'You agree to indemnify and hold harmless Romulo Roriz from any claims, damages, losses, or expenses (including reasonable legal fees) arising from your use of the App, your violation of these Terms, or your violation of any rights of a third party.',
                      ),

                      // Section 13
                      _buildSectionTitle('13. Modifications to Terms'),
                      _buildBody(
                        'We may update these Terms from time to time. When we make material changes, we will notify you through the App or via email at least 14 days before the changes take effect.',
                      ),
                      _buildBody(
                        'Your continued use of the App after the effective date constitutes acceptance of the updated Terms. If you do not agree, you should stop using the App and delete your account.',
                      ),

                      // Section 14
                      _buildSectionTitle('14. Termination'),
                      _buildBody(
                        'You may stop using the App and request account deletion at any time by contacting romulo@trysomething.com.',
                      ),
                      _buildBody(
                        'We may terminate or suspend your account at our discretion if you violate these Terms, with or without notice.',
                      ),
                      _buildBody(
                        'Upon termination, your right to use the App ceases immediately. We will delete your personal data in accordance with our Privacy Policy, subject to any legal retention obligations.',
                      ),

                      // Section 15
                      _buildSectionTitle('15. Governing Law and Jurisdiction'),
                      _buildBody(
                        'These Terms are governed by and construed in accordance with the laws of Switzerland, without regard to conflict-of-law principles.',
                      ),
                      _buildBody(
                        'Any disputes arising from or in connection with these Terms shall be subject to the exclusive jurisdiction of the courts of Zurich, Switzerland.',
                      ),
                      _buildBody(
                        'For consumers residing in the European Union, nothing in these Terms restricts your rights under mandatory consumer protection laws of your country of residence.',
                      ),

                      // Section 16
                      _buildSectionTitle('16. Contact'),
                      _buildBody(
                        'If you have questions about these Terms, please contact us at:',
                      ),
                      _buildContactBlock({
                        'Email': 'romulo@trysomething.com',
                        'Location': 'Zurich, Switzerland',
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
