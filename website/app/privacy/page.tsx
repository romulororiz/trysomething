import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy - TrySomething",
  description:
    "Privacy Policy for the TrySomething mobile application. Compliant with Swiss FADP and EU GDPR.",
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-bg">
      <nav className="max-w-3xl mx-auto px-6 pt-8">
        <a
          href="/"
          className="text-sm text-text-secondary hover:text-text-primary transition-colors"
        >
          &larr; Back to TrySomething
        </a>
      </nav>
      <main className="max-w-3xl mx-auto px-6 py-12 pb-24">
        <h1 className="text-3xl font-bold text-text-primary mb-2 font-serif">
          Privacy Policy
        </h1>
        <p className="text-sm text-text-muted mb-10">
          Effective date: 14 March 2026
        </p>

        {/* Intro paragraphs */}
        <p className="text-text-secondary leading-relaxed mb-4">
          This Privacy Policy explains how TrySomething (&ldquo;we&rdquo;,
          &ldquo;us&rdquo;, &ldquo;our&rdquo;) collects, uses, stores, and
          protects your personal data when you use the TrySomething mobile
          application (the &ldquo;App&rdquo;).
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          This policy complies with the Swiss Federal Act on Data Protection
          (FADP/nDSG), effective September 1, 2023, and is aligned with the
          principles of the EU General Data Protection Regulation (GDPR) for
          users in the European Economic Area.
        </p>

        {/* Section 1 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          1. Data Controller
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          The data controller responsible for your personal data is:
        </p>
        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
          <p className="mb-1">
            <span className="font-semibold text-text-primary">Name: </span>
            <span className="text-text-secondary">Romulo Roriz</span>
          </p>
          <p className="mb-1">
            <span className="font-semibold text-text-primary">Email: </span>
            <span className="text-text-secondary">
              support@trysomething.io
            </span>
          </p>
          <p>
            <span className="font-semibold text-text-primary">
              Location:{" "}
            </span>
            <span className="text-text-secondary">Zurich, Switzerland</span>
          </p>
        </div>

        {/* Section 2 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          2. Data We Collect
        </h2>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          2.1 Data You Provide Directly
        </h3>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Account information: email address, display name, password (stored
            as a bcrypt hash with 12 salt rounds), and optional bio and avatar
            URL.
          </li>
          <li className="marker:text-coral">
            Authentication tokens: if you sign in with Google or Apple, we
            receive and store your Google ID or Apple ID to link your account. We
            do not receive or store your Google or Apple password.
          </li>
          <li className="marker:text-coral">
            Onboarding preferences: hours per week available, budget level,
            social preference, and vibe tags (e.g., relaxing, creative).
          </li>
          <li className="marker:text-coral">
            Journal entries: text content and optional photos you create to
            document your hobby journey.
          </li>
          <li className="marker:text-coral">
            Personal notes: notes you attach to specific roadmap steps.
          </li>
          <li className="marker:text-coral">
            Community stories: quotes you share publicly within the App.
          </li>
          <li className="marker:text-coral">
            Coach conversations: messages you send to the AI hobby coach (sent
            to Anthropic&apos;s API for processing, not stored permanently on
            Anthropic&apos;s servers under their zero-retention API policy).
          </li>
          <li className="marker:text-coral">
            Schedule events: day of week, start time, and duration you set for
            hobby practice.
          </li>
          <li className="marker:text-coral">
            Shopping list interactions: which starter kit items you have checked
            off.
          </li>
        </ul>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          2.2 Data We Collect Automatically
        </h3>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Usage analytics: screen views and custom events (e.g., hobby saved,
            session completed), collected via PostHog. Your PostHog user ID is
            your internal account ID, not your name or email.
          </li>
          <li className="marker:text-coral">
            Crash reports: error stack traces, device model, and OS version,
            collected via Sentry to diagnose and fix bugs. Sentry data is
            associated with anonymous session IDs.
          </li>
          <li className="marker:text-coral">
            Push notification tokens: Firebase Cloud Messaging device tokens,
            used solely to deliver notifications you have opted into (e.g.,
            session reminders).
          </li>
          <li className="marker:text-coral">
            Activity logs: timestamped records of actions you take in the App
            (e.g., &ldquo;saved Pottery&rdquo;, &ldquo;completed Step
            3&rdquo;), stored server-side to power your progress tracking and
            streak calculations.
          </li>
        </ul>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          2.3 Data We Do NOT Collect
        </h3>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            We do not collect your precise GPS location.
          </li>
          <li className="marker:text-coral">
            We do not access your contacts, call logs, or SMS messages.
          </li>
          <li className="marker:text-coral">
            We do not collect biometric data.
          </li>
          <li className="marker:text-coral">
            We do not collect or process payment card information. All payments
            are handled by Apple App Store or Google Play Store via RevenueCat.
          </li>
          <li className="marker:text-coral">
            We do not use cookies (the App is a native mobile application, not a
            website).
          </li>
        </ul>

        {/* Section 3 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          3. How We Use Your Data
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          We process your personal data for the following purposes and legal
          bases (per Art. 6 FADP / Art. 6 GDPR):
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Contract performance: To provide the core App functionality:
            creating your account, saving hobbies, tracking progress, generating
            personalized hobby content, and powering the AI coach.
          </li>
          <li className="marker:text-coral">
            Legitimate interest: To improve the App through anonymized usage
            analytics (PostHog), fix bugs via crash reports (Sentry), and send
            you push notifications you have opted into (Firebase).
          </li>
          <li className="marker:text-coral">
            Consent: To display your Community Stories publicly to other users.
            You can delete any story at any time. To process your data via
            third-party services listed in Section 5.
          </li>
          <li className="marker:text-coral">
            Legal obligation: To comply with applicable Swiss law, including
            responding to lawful data access requests.
          </li>
        </ul>

        {/* Section 4 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          4. AI Data Processing
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          TrySomething uses Anthropic&apos;s Claude API to power AI features.
          Here is exactly what is sent to Anthropic:
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          4.1 Hobby Generation
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          When you search for a hobby that does not exist in our database, your
          search query is sent to Anthropic to generate hobby content (title,
          description, roadmap, kit items, cost estimates). No personal data
          beyond the search query is included.
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          4.2 AI Coach
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          When you send a message to the AI hobby coach, the following data is
          sent to Anthropic:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">Your message.</li>
          <li className="marker:text-coral">
            Up to 15 previous messages in the conversation for context
            continuity.
          </li>
          <li className="marker:text-coral">
            The hobby&apos;s title, category, difficulty, cost, time estimate,
            kit items, and roadmap steps.
          </li>
          <li className="marker:text-coral">
            Your hobby status (browsing, saved, or active) and progress (which
            roadmap steps you have completed).
          </li>
          <li className="marker:text-coral">
            Your last 5 journal entries (truncated to 100 characters each).
          </li>
          <li className="marker:text-coral">
            Your name, email, and account ID are NOT sent to Anthropic.
          </li>
        </ul>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          4.3 Anthropic&apos;s Data Handling
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          Under Anthropic&apos;s API data policy, inputs and outputs sent via
          the API are not used to train Anthropic&apos;s models. Anthropic may
          retain API inputs for up to 30 days for trust and safety purposes,
          after which they are deleted. For full details, refer to
          Anthropic&apos;s privacy policy at anthropic.com/privacy.
        </p>

        {/* Section 5 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          5. Third-Party Data Processors
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          We share your data with the following third-party services, each
          acting as a data processor under appropriate contractual safeguards:
        </p>

        {/* Data processor cards */}
        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Vercel</p>
          <p className="text-sm text-text-secondary">
            API hosting, serverless functions &bull; API requests, server logs
            &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Neon</p>
          <p className="text-sm text-text-secondary">
            PostgreSQL database &bull; All account and content data &bull; EU
            (Frankfurt)
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Anthropic</p>
          <p className="text-sm text-text-secondary">
            AI content generation, coaching &bull; Search queries, coach
            messages, hobby context &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">RevenueCat</p>
          <p className="text-sm text-text-secondary">
            Subscription management &bull; Anonymous user ID, purchase receipts
            &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">PostHog</p>
          <p className="text-sm text-text-secondary">
            Usage analytics &bull; Anonymous user ID, screen views, events
            &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Sentry</p>
          <p className="text-sm text-text-secondary">
            Crash reporting &bull; Error logs, device info, session IDs &bull;
            EU (Frankfurt)
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Firebase (Google)</p>
          <p className="text-sm text-text-secondary">
            Push notifications &bull; FCM device tokens &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Unsplash</p>
          <p className="text-sm text-text-secondary">
            Hobby images &bull; Search queries (no user data) &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-3">
          <p className="font-semibold text-text-primary">Google Sign-In</p>
          <p className="text-sm text-text-secondary">
            Authentication &bull; Google account ID &bull; USA
          </p>
        </div>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
          <p className="font-semibold text-text-primary">Apple Sign-In</p>
          <p className="text-sm text-text-secondary">
            Authentication &bull; Apple account ID, relay email &bull; USA
          </p>
        </div>

        <p className="text-text-secondary leading-relaxed mb-4">
          For transfers to the USA, we rely on the Swiss-US Data Privacy
          Framework (recognized by the Swiss Federal Council on August 14, 2024)
          and/or Standard Contractual Clauses (SCCs) as applicable.
        </p>

        {/* Section 6 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          6. Data Storage and Security
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          We implement the following security measures in accordance with the
          Privacy by Design and Privacy by Default principles required by the
          FADP:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Passwords are hashed using bcrypt with 12 salt rounds. We never
            store plaintext passwords.
          </li>
          <li className="marker:text-coral">
            Authentication uses short-lived JWT access tokens (15-minute expiry)
            and longer-lived refresh tokens (30-day expiry).
          </li>
          <li className="marker:text-coral">
            Sensitive tokens are stored on-device using Flutter Secure Storage
            (iOS Keychain / Android Keystore).
          </li>
          <li className="marker:text-coral">
            All API communication uses HTTPS/TLS encryption in transit.
          </li>
          <li className="marker:text-coral">
            The database is hosted on Neon PostgreSQL with encryption at rest.
          </li>
          <li className="marker:text-coral">
            API endpoints are rate-limited (20 hobby generations per user per 24
            hours) with content safety filters on all AI inputs and outputs.
          </li>
          <li className="marker:text-coral">
            Local caching uses Hive (encrypted on-device database) and
            SharedPreferences (non-sensitive UI state only).
          </li>
        </ul>

        {/* Section 7 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          7. Data Retention
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          We retain your data for the following periods:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Account data: retained for as long as your account is active.
            Deleted within 30 days of account deletion request.
          </li>
          <li className="marker:text-coral">
            Journal entries, notes, and schedule: retained until you delete them
            or delete your account.
          </li>
          <li className="marker:text-coral">
            Community stories: retained until you delete them. Reactions to
            deleted stories are also removed.
          </li>
          <li className="marker:text-coral">
            Activity logs: retained for 12 months for progress tracking, then
            automatically purged.
          </li>
          <li className="marker:text-coral">
            Generation logs: retained for 90 days for abuse prevention, then
            automatically purged.
          </li>
          <li className="marker:text-coral">
            Analytics data (PostHog): retained according to PostHog&apos;s data
            retention policy (default 1 year). Events are associated with
            anonymous IDs.
          </li>
          <li className="marker:text-coral">
            Crash reports (Sentry): retained for 90 days.
          </li>
          <li className="marker:text-coral">
            AI coach conversations: message history is passed per-request via
            the API and is not permanently stored on our servers beyond the
            conversation session. Anthropic may retain inputs for up to 30 days
            per their API policy.
          </li>
        </ul>

        {/* Section 8 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          8. Your Rights
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          Under the Swiss FADP (Art. 25-29) and, where applicable, the EU GDPR
          (Art. 15-22), you have the following rights:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Right of access: You may request a copy of all personal data we hold
            about you.
          </li>
          <li className="marker:text-coral">
            Right to rectification: You may correct inaccurate data via the
            App&apos;s profile settings, or by contacting us.
          </li>
          <li className="marker:text-coral">
            Right to deletion: You may request deletion of your account and all
            associated data by emailing support@trysomething.io. We will process
            your request within 30 days.
          </li>
          <li className="marker:text-coral">
            Right to data portability: You may request your data in a
            structured, machine-readable format (JSON export).
          </li>
          <li className="marker:text-coral">
            Right to object: You may object to processing based on legitimate
            interest. Contact us to exercise this right.
          </li>
          <li className="marker:text-coral">
            Right to withdraw consent: Where processing is based on consent, you
            may withdraw it at any time without affecting the lawfulness of
            prior processing.
          </li>
          <li className="marker:text-coral">
            Right to lodge a complaint: You may file a complaint with the Swiss
            Federal Data Protection and Information Commissioner (FDPIC) at
            edoeb.admin.ch, or with your local supervisory authority if you
            reside in the EU.
          </li>
        </ul>
        <p className="text-text-secondary leading-relaxed mb-4">
          To exercise any of these rights, contact us at
          support@trysomething.io. We will respond within 30 days.
        </p>

        {/* Section 9 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          9. Children&apos;s Privacy
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          TrySomething is not directed at children under 16. We do not knowingly
          collect personal data from children under 16. If we become aware that
          a child under 16 has provided personal data, we will take steps to
          delete that data promptly.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          If you are a parent or guardian and believe your child has provided us
          with personal data, please contact us at support@trysomething.io.
        </p>

        {/* Section 10 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          10. Changes to This Privacy Policy
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          We may update this Privacy Policy from time to time. When we make
          material changes, we will notify you through the App or via email at
          least 14 days before the changes take effect.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          The &ldquo;Effective date&rdquo; at the top of this document indicates
          when the current version took effect.
        </p>

        {/* Section 11 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          11. Contact
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          For any privacy-related questions, data access requests, or
          complaints:
        </p>
        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
          <p className="mb-1">
            <span className="font-semibold text-text-primary">Email: </span>
            <span className="text-text-secondary">
              support@trysomething.io
            </span>
          </p>
          <p className="mb-1">
            <span className="font-semibold text-text-primary">
              Data Controller:{" "}
            </span>
            <span className="text-text-secondary">Romulo Roriz</span>
          </p>
          <p>
            <span className="font-semibold text-text-primary">
              Location:{" "}
            </span>
            <span className="text-text-secondary">Zurich, Switzerland</span>
          </p>
        </div>

        <p className="text-text-secondary leading-relaxed mb-4">
          For complaints about data protection, you may also contact the Swiss
          Federal Data Protection and Information Commissioner (FDPIC):
        </p>
        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
          <p className="mb-1">
            <span className="font-semibold text-text-primary">
              Website:{" "}
            </span>
            <span className="text-text-secondary">
              https://www.edoeb.admin.ch
            </span>
          </p>
          <p>
            <span className="font-semibold text-text-primary">
              Address:{" "}
            </span>
            <span className="text-text-secondary">
              Feldeggweg 1, 3003 Bern, Switzerland
            </span>
          </p>
        </div>
      </main>
    </div>
  );
}
