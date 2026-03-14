import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/app_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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

  Widget _buildDataProcessorRow(String service, String purpose, String data, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(Spacing.radiusSmall),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            service,
            style: AppTypography.sansBodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            '$purpose \u2022 $data \u2022 $location',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
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
                    Text('Privacy Policy', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
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
                        'PRIVACY POLICY',
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
                      const SizedBox(height: 16),
                      _buildBody(
                        'This Privacy Policy explains how TrySomething ("we", "us", "our") collects, uses, stores, and protects your personal data when you use the TrySomething mobile application (the "App").',
                      ),
                      _buildBody(
                        'This policy complies with the Swiss Federal Act on Data Protection (FADP/nDSG), effective September 1, 2023, and is aligned with the principles of the EU General Data Protection Regulation (GDPR) for users in the European Economic Area.',
                      ),

                      // Section 1
                      _buildSectionTitle('1. Data Controller'),
                      _buildBody(
                        'The data controller responsible for your personal data is:',
                      ),
                      _buildContactBlock({
                        'Name': 'Romulo Roriz',
                        'Email': 'romulo@trysomethingapp.com',
                        'Location': 'Zurich, Switzerland',
                      }),

                      // Section 2
                      _buildSectionTitle('2. Data We Collect'),

                      _buildSubsectionTitle('2.1 Data You Provide Directly'),
                      _buildBulletPoint(
                        'Account information: email address, display name, password (stored as a bcrypt hash with 12 salt rounds), and optional bio and avatar URL.',
                      ),
                      _buildBulletPoint(
                        'Authentication tokens: if you sign in with Google or Apple, we receive and store your Google ID or Apple ID to link your account. We do not receive or store your Google or Apple password.',
                      ),
                      _buildBulletPoint(
                        'Onboarding preferences: hours per week available, budget level, social preference, and vibe tags (e.g., relaxing, creative).',
                      ),
                      _buildBulletPoint(
                        'Journal entries: text content and optional photos you create to document your hobby journey.',
                      ),
                      _buildBulletPoint(
                        'Personal notes: notes you attach to specific roadmap steps.',
                      ),
                      _buildBulletPoint(
                        'Community stories: quotes you share publicly within the App.',
                      ),
                      _buildBulletPoint(
                        'Coach conversations: messages you send to the AI hobby coach (sent to Anthropic\'s API for processing, not stored permanently on Anthropic\'s servers under their zero-retention API policy).',
                      ),
                      _buildBulletPoint(
                        'Schedule events: day of week, start time, and duration you set for hobby practice.',
                      ),
                      _buildBulletPoint(
                        'Shopping list interactions: which starter kit items you have checked off.',
                      ),

                      _buildSubsectionTitle('2.2 Data We Collect Automatically'),
                      _buildBulletPoint(
                        'Usage analytics: screen views and custom events (e.g., hobby saved, session completed), collected via PostHog. Your PostHog user ID is your internal account ID, not your name or email.',
                      ),
                      _buildBulletPoint(
                        'Crash reports: error stack traces, device model, and OS version, collected via Sentry to diagnose and fix bugs. Sentry data is associated with anonymous session IDs.',
                      ),
                      _buildBulletPoint(
                        'Push notification tokens: Firebase Cloud Messaging device tokens, used solely to deliver notifications you have opted into (e.g., session reminders).',
                      ),
                      _buildBulletPoint(
                        'Activity logs: timestamped records of actions you take in the App (e.g., "saved Pottery", "completed Step 3"), stored server-side to power your progress tracking and streak calculations.',
                      ),

                      _buildSubsectionTitle('2.3 Data We Do NOT Collect'),
                      _buildBulletPoint(
                        'We do not collect your precise GPS location.',
                      ),
                      _buildBulletPoint(
                        'We do not access your contacts, call logs, or SMS messages.',
                      ),
                      _buildBulletPoint(
                        'We do not collect biometric data.',
                      ),
                      _buildBulletPoint(
                        'We do not collect or process payment card information. All payments are handled by Apple App Store or Google Play Store via RevenueCat.',
                      ),
                      _buildBulletPoint(
                        'We do not use cookies (the App is a native mobile application, not a website).',
                      ),

                      // Section 3
                      _buildSectionTitle('3. How We Use Your Data'),
                      _buildBody(
                        'We process your personal data for the following purposes and legal bases (per Art. 6 FADP / Art. 6 GDPR):',
                      ),
                      _buildBulletPoint(
                        'Contract performance: To provide the core App functionality: creating your account, saving hobbies, tracking progress, generating personalized hobby content, and powering the AI coach.',
                      ),
                      _buildBulletPoint(
                        'Legitimate interest: To improve the App through anonymized usage analytics (PostHog), fix bugs via crash reports (Sentry), and send you push notifications you have opted into (Firebase).',
                      ),
                      _buildBulletPoint(
                        'Consent: To display your Community Stories publicly to other users. You can delete any story at any time. To process your data via third-party services listed in Section 5.',
                      ),
                      _buildBulletPoint(
                        'Legal obligation: To comply with applicable Swiss law, including responding to lawful data access requests.',
                      ),

                      // Section 4
                      _buildSectionTitle('4. AI Data Processing'),
                      _buildBody(
                        'TrySomething uses Anthropic\'s Claude API to power AI features. Here is exactly what is sent to Anthropic:',
                      ),

                      _buildSubsectionTitle('4.1 Hobby Generation'),
                      _buildBody(
                        'When you search for a hobby that does not exist in our database, your search query is sent to Anthropic to generate hobby content (title, description, roadmap, kit items, cost estimates). No personal data beyond the search query is included.',
                      ),

                      _buildSubsectionTitle('4.2 AI Coach'),
                      _buildBody(
                        'When you send a message to the AI hobby coach, the following data is sent to Anthropic:',
                      ),
                      _buildBulletPoint('Your message.'),
                      _buildBulletPoint(
                        'Up to 15 previous messages in the conversation for context continuity.',
                      ),
                      _buildBulletPoint(
                        'The hobby\'s title, category, difficulty, cost, time estimate, kit items, and roadmap steps.',
                      ),
                      _buildBulletPoint(
                        'Your hobby status (browsing, saved, or active) and progress (which roadmap steps you have completed).',
                      ),
                      _buildBulletPoint(
                        'Your last 5 journal entries (truncated to 100 characters each).',
                      ),
                      _buildBulletPoint(
                        'Your name, email, and account ID are NOT sent to Anthropic.',
                      ),

                      _buildSubsectionTitle('4.3 Anthropic\'s Data Handling'),
                      _buildBody(
                        'Under Anthropic\'s API data policy, inputs and outputs sent via the API are not used to train Anthropic\'s models. Anthropic may retain API inputs for up to 30 days for trust and safety purposes, after which they are deleted. For full details, refer to Anthropic\'s privacy policy at anthropic.com/privacy.',
                      ),

                      // Section 5
                      _buildSectionTitle('5. Third-Party Data Processors'),
                      _buildBody(
                        'We share your data with the following third-party services, each acting as a data processor under appropriate contractual safeguards:',
                      ),
                      _buildDataProcessorRow(
                        'Vercel',
                        'API hosting, serverless functions',
                        'API requests, server logs',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'Neon',
                        'PostgreSQL database',
                        'All account and content data',
                        'EU (Frankfurt)',
                      ),
                      _buildDataProcessorRow(
                        'Anthropic',
                        'AI content generation, coaching',
                        'Search queries, coach messages, hobby context',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'RevenueCat',
                        'Subscription management',
                        'Anonymous user ID, purchase receipts',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'PostHog',
                        'Usage analytics',
                        'Anonymous user ID, screen views, events',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'Sentry',
                        'Crash reporting',
                        'Error logs, device info, session IDs',
                        'EU (Frankfurt)',
                      ),
                      _buildDataProcessorRow(
                        'Firebase (Google)',
                        'Push notifications',
                        'FCM device tokens',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'Unsplash',
                        'Hobby images',
                        'Search queries (no user data)',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'Google Sign-In',
                        'Authentication',
                        'Google account ID',
                        'USA',
                      ),
                      _buildDataProcessorRow(
                        'Apple Sign-In',
                        'Authentication',
                        'Apple account ID, relay email',
                        'USA',
                      ),
                      const SizedBox(height: 8),
                      _buildBody(
                        'For transfers to the USA, we rely on the Swiss-US Data Privacy Framework (recognized by the Swiss Federal Council on August 14, 2024) and/or Standard Contractual Clauses (SCCs) as applicable.',
                      ),

                      // Section 6
                      _buildSectionTitle('6. Data Storage and Security'),
                      _buildBody(
                        'We implement the following security measures in accordance with the Privacy by Design and Privacy by Default principles required by the FADP:',
                      ),
                      _buildBulletPoint(
                        'Passwords are hashed using bcrypt with 12 salt rounds. We never store plaintext passwords.',
                      ),
                      _buildBulletPoint(
                        'Authentication uses short-lived JWT access tokens (15-minute expiry) and longer-lived refresh tokens (30-day expiry).',
                      ),
                      _buildBulletPoint(
                        'Sensitive tokens are stored on-device using Flutter Secure Storage (iOS Keychain / Android Keystore).',
                      ),
                      _buildBulletPoint(
                        'All API communication uses HTTPS/TLS encryption in transit.',
                      ),
                      _buildBulletPoint(
                        'The database is hosted on Neon PostgreSQL with encryption at rest.',
                      ),
                      _buildBulletPoint(
                        'API endpoints are rate-limited (20 hobby generations per user per 24 hours) with content safety filters on all AI inputs and outputs.',
                      ),
                      _buildBulletPoint(
                        'Local caching uses Hive (encrypted on-device database) and SharedPreferences (non-sensitive UI state only).',
                      ),

                      // Section 7
                      _buildSectionTitle('7. Data Retention'),
                      _buildBody(
                        'We retain your data for the following periods:',
                      ),
                      _buildBulletPoint(
                        'Account data: retained for as long as your account is active. Deleted within 30 days of account deletion request.',
                      ),
                      _buildBulletPoint(
                        'Journal entries, notes, and schedule: retained until you delete them or delete your account.',
                      ),
                      _buildBulletPoint(
                        'Community stories: retained until you delete them. Reactions to deleted stories are also removed.',
                      ),
                      _buildBulletPoint(
                        'Activity logs: retained for 12 months for progress tracking, then automatically purged.',
                      ),
                      _buildBulletPoint(
                        'Generation logs: retained for 90 days for abuse prevention, then automatically purged.',
                      ),
                      _buildBulletPoint(
                        'Analytics data (PostHog): retained according to PostHog\'s data retention policy (default 1 year). Events are associated with anonymous IDs.',
                      ),
                      _buildBulletPoint(
                        'Crash reports (Sentry): retained for 90 days.',
                      ),
                      _buildBulletPoint(
                        'AI coach conversations: message history is passed per-request via the API and is not permanently stored on our servers beyond the conversation session. Anthropic may retain inputs for up to 30 days per their API policy.',
                      ),

                      // Section 8
                      _buildSectionTitle('8. Your Rights'),
                      _buildBody(
                        'Under the Swiss FADP (Art. 25-29) and, where applicable, the EU GDPR (Art. 15-22), you have the following rights:',
                      ),
                      _buildBulletPoint(
                        'Right of access: You may request a copy of all personal data we hold about you.',
                      ),
                      _buildBulletPoint(
                        'Right to rectification: You may correct inaccurate data via the App\'s profile settings, or by contacting us.',
                      ),
                      _buildBulletPoint(
                        'Right to deletion: You may request deletion of your account and all associated data by emailing romulo@trysomething.com. We will process your request within 30 days.',
                      ),
                      _buildBulletPoint(
                        'Right to data portability: You may request your data in a structured, machine-readable format (JSON export).',
                      ),
                      _buildBulletPoint(
                        'Right to object: You may object to processing based on legitimate interest. Contact us to exercise this right.',
                      ),
                      _buildBulletPoint(
                        'Right to withdraw consent: Where processing is based on consent, you may withdraw it at any time without affecting the lawfulness of prior processing.',
                      ),
                      _buildBulletPoint(
                        'Right to lodge a complaint: You may file a complaint with the Swiss Federal Data Protection and Information Commissioner (FDPIC) at edoeb.admin.ch, or with your local supervisory authority if you reside in the EU.',
                      ),
                      const SizedBox(height: 8),
                      _buildBody(
                        'To exercise any of these rights, contact us at romulo@trysomething.com. We will respond within 30 days.',
                      ),

                      // Section 9
                      _buildSectionTitle('9. Children\'s Privacy'),
                      _buildBody(
                        'TrySomething is not directed at children under 16. We do not knowingly collect personal data from children under 16. If we become aware that a child under 16 has provided personal data, we will take steps to delete that data promptly.',
                      ),
                      _buildBody(
                        'If you are a parent or guardian and believe your child has provided us with personal data, please contact us at romulo@trysomething.com.',
                      ),

                      // Section 10
                      _buildSectionTitle('10. Changes to This Privacy Policy'),
                      _buildBody(
                        'We may update this Privacy Policy from time to time. When we make material changes, we will notify you through the App or via email at least 14 days before the changes take effect.',
                      ),
                      _buildBody(
                        'The "Effective date" at the top of this document indicates when the current version took effect.',
                      ),

                      // Section 11
                      _buildSectionTitle('11. Contact'),
                      _buildBody(
                        'For any privacy-related questions, data access requests, or complaints:',
                      ),
                      _buildContactBlock({
                        'Email': 'romulo@trysomething.com',
                        'Data Controller': 'Romulo Roriz',
                        'Location': 'Zurich, Switzerland',
                      }),
                      const SizedBox(height: 12),
                      _buildBody(
                        'For complaints about data protection, you may also contact the Swiss Federal Data Protection and Information Commissioner (FDPIC):',
                      ),
                      _buildContactBlock({
                        'Website': 'https://www.edoeb.admin.ch',
                        'Address': 'Feldeggweg 1, 3003 Bern, Switzerland',
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
