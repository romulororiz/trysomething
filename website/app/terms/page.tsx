import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service - TrySomething",
  description:
    "Terms of Service for the TrySomething mobile application.",
};

export default function TermsPage() {
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
        <h1 className="text-3xl font-bold text-text-primary mb-2">
          Terms of Service
        </h1>
        <p className="text-sm text-text-muted mb-10">
          Effective date: 14 March 2026
        </p>

        {/* Section 1 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          1. Agreement to Terms
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          By downloading, installing, or using the TrySomething mobile
          application (the &ldquo;App&rdquo;), you agree to be bound by these
          Terms of Service (&ldquo;Terms&rdquo;). If you do not agree to these
          Terms, do not use the App.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          TrySomething is operated by Romulo Roriz (&ldquo;we&rdquo;,
          &ldquo;us&rdquo;, &ldquo;our&rdquo;), based in Zurich, Switzerland.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          These Terms are governed by Swiss law, specifically the Swiss Code of
          Obligations (OR) and the Swiss Federal Act on Data Protection
          (FADP/nDSG).
        </p>

        {/* Section 2 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          2. Eligibility
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          You must be at least 16 years old to use the App. By using
          TrySomething, you represent that you meet this age requirement. If you
          are under 18, you confirm that you have obtained the consent of a
          parent or legal guardian.
        </p>

        {/* Section 3 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          3. Your Account
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          To access certain features, you must create an account using an email
          address and password, or by signing in via Google or Apple.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          You are responsible for:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Maintaining the confidentiality of your login credentials.
          </li>
          <li className="marker:text-coral">
            All activity that occurs under your account.
          </li>
          <li className="marker:text-coral">
            Notifying us immediately at support@trysomething.io if you suspect
            unauthorized access.
          </li>
        </ul>
        <p className="text-text-secondary leading-relaxed mb-4">
          We reserve the right to suspend or terminate accounts that violate
          these Terms.
        </p>

        {/* Section 4 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          4. Description of Service
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          TrySomething is a hobby discovery and onboarding platform that helps
          users find, start, and stick with new hobbies. The App provides:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            A curated catalog of 150+ hobbies with starter kits, cost estimates,
            and step-by-step roadmaps.
          </li>
          <li className="marker:text-coral">
            AI-powered hobby generation and an AI hobby coach, powered by
            Anthropic&apos;s Claude language model.
          </li>
          <li className="marker:text-coral">
            Personal tools including journal entries (text and photo), schedule
            planning, shopping lists, and progress tracking.
          </li>
          <li className="marker:text-coral">
            Community features including public stories, buddy matching, and
            reactions.
          </li>
          <li className="marker:text-coral">
            Affiliate links to third-party retailers for purchasing hobby
            materials.
          </li>
        </ul>
        <p className="text-text-secondary leading-relaxed mb-4">
          The App is provided &ldquo;as is&rdquo;. We do not guarantee
          uninterrupted or error-free operation. Features may change, be added,
          or removed at our discretion.
        </p>

        {/* Section 5 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          5. Subscriptions and Payments
        </h2>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          5.1 Free Tier
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          The free tier includes access to the full hobby catalog, roadmaps,
          one active hobby at a time, limited AI coach messages, and text-based journal entries.
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          5.2 TrySomething Pro
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          TrySomething Pro is available as a monthly (CHF 4.99) or annual (CHF
          39.99) subscription. Pro features include:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">Unlimited AI coach conversations.</li>
          <li className="marker:text-coral">Speech-to-text input and image recognition for AI coaching.</li>
          <li className="marker:text-coral">AI hobby generation to discover new hobbies.</li>
          <li className="marker:text-coral">Photo journal entries.</li>
          <li className="marker:text-coral">Multi-hobby tracking.</li>
          <li className="marker:text-coral">Pause hobbies and resume without losing progress.</li>
          <li className="marker:text-coral">Cost breakdowns for hobby materials.</li>
          <li className="marker:text-coral">Exclusive starter kits tailored to each hobby.</li>
          <li className="marker:text-coral">Early access to new features and content.</li>
        </ul>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          5.3 Billing
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          Subscriptions are processed through Apple App Store or Google Play
          Store via RevenueCat. Billing, renewals, and cancellations are governed
          by the respective store&apos;s terms. We do not store or process
          payment card information directly.
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          5.4 Free Trial
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          New subscribers may receive a 7-day free trial. You will not be
          charged during the trial period. If you do not cancel before the trial
          ends, your subscription will automatically convert to a paid plan.
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          5.5 Cancellation
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          You may cancel your subscription at any time through the App Store or
          Google Play Store settings. Cancellation takes effect at the end of the
          current billing period. No refunds are provided for partial billing
          periods. Refund requests for extraordinary circumstances should be
          directed to the respective app store.
        </p>

        {/* Section 6 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          6. AI-Generated Content
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          TrySomething uses artificial intelligence (Anthropic Claude) to
          generate hobby descriptions, roadmaps, starter kit recommendations,
          cost estimates, FAQ content, and coaching responses.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          Important disclaimers regarding AI-generated content:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            AI-generated content is for informational and inspirational purposes
            only. It does not constitute professional advice (medical, financial,
            legal, or otherwise).
          </li>
          <li className="marker:text-coral">
            Cost estimates are approximate and reflect typical Swiss retail
            pricing at the time of generation. Actual costs may vary.
          </li>
          <li className="marker:text-coral">
            Kit item recommendations are general suggestions. We do not warrant
            the safety, quality, or suitability of any recommended equipment or
            materials.
          </li>
          <li className="marker:text-coral">
            Coaching responses are automated and not provided by a licensed
            professional. If you experience physical discomfort during any hobby
            activity, consult a healthcare professional.
          </li>
          <li className="marker:text-coral">
            We apply content safety filters to prevent the generation of
            harmful, illegal, or inappropriate hobby content, but no filter is
            perfect.
          </li>
        </ul>

        {/* Section 7 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          7. User Content
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          &ldquo;User Content&rdquo; means any text, photos, journal entries,
          community stories, notes, or other content you create or upload
          through the App.
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          7.1 Ownership
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          You retain ownership of your User Content. By posting User Content to
          public features (such as Community Stories), you grant us a
          non-exclusive, worldwide, royalty-free license to display that content
          within the App for the purpose of operating the service.
        </p>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          7.2 Responsibilities
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          You agree not to post User Content that:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Is illegal, harmful, threatening, abusive, defamatory, or
            discriminatory.
          </li>
          <li className="marker:text-coral">
            Infringes on any third party&apos;s intellectual property or privacy
            rights.
          </li>
          <li className="marker:text-coral">
            Contains malware, spam, or commercial solicitations.
          </li>
          <li className="marker:text-coral">
            Impersonates another person or entity.
          </li>
        </ul>
        <p className="text-text-secondary leading-relaxed mb-4">
          We reserve the right to remove any User Content that violates these
          Terms without prior notice.
        </p>

        {/* Section 8 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          8. Affiliate Links and Third-Party Services
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          The App may contain affiliate links to third-party retailers. When you
          purchase products through these links, we may earn a commission at no
          additional cost to you.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          We are not responsible for the products, services, pricing,
          availability, or practices of third-party retailers. Your purchases
          from third parties are governed by those retailers&apos; own terms and
          conditions.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          The App integrates with the following third-party services:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Unsplash (hobby images, governed by the Unsplash License).
          </li>
          <li className="marker:text-coral">
            Google Sign-In and Apple Sign-In (authentication).
          </li>
          <li className="marker:text-coral">
            RevenueCat (subscription management).
          </li>
          <li className="marker:text-coral">
            PostHog (anonymized usage analytics).
          </li>
          <li className="marker:text-coral">
            Sentry (crash reporting and error tracking).
          </li>
          <li className="marker:text-coral">
            Firebase Cloud Messaging (push notifications).
          </li>
          <li className="marker:text-coral">
            Anthropic Claude API (AI content generation and coaching).
          </li>
          <li className="marker:text-coral">
            Neon PostgreSQL hosted on Vercel (database and API hosting).
          </li>
        </ul>

        {/* Section 9 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          9. Prohibited Uses
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          You agree not to:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Use the App for any unlawful purpose.
          </li>
          <li className="marker:text-coral">
            Attempt to reverse-engineer, decompile, or extract source code from
            the App.
          </li>
          <li className="marker:text-coral">
            Interfere with or disrupt the App&apos;s infrastructure (including
            the API).
          </li>
          <li className="marker:text-coral">
            Circumvent rate limits, content filters, or subscription
            restrictions.
          </li>
          <li className="marker:text-coral">
            Scrape, harvest, or collect data from the App through automated
            means.
          </li>
          <li className="marker:text-coral">
            Use the AI coach or generation features to produce content that is
            harmful, illegal, or violates Anthropic&apos;s Acceptable Use
            Policy.
          </li>
          <li className="marker:text-coral">
            Create multiple accounts to circumvent usage limits.
          </li>
        </ul>

        {/* Section 10 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          10. Intellectual Property
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          The App, including its design, code, branding, category stroke
          artwork, and curated hobby content, is the intellectual property of
          Romulo Roriz and is protected under Swiss and international copyright
          law.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          AI-generated hobby content (descriptions, roadmaps, coaching
          responses) is provided for your personal use within the App. You may
          not reproduce, redistribute, or commercially exploit AI-generated
          content outside of the App without written permission.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          &ldquo;TrySomething&rdquo; and the TrySomething logo are unregistered
          trademarks. Unauthorized use is prohibited.
        </p>

        {/* Section 11 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          11. Limitation of Liability
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          To the maximum extent permitted by Swiss law (Art. 100 OR):
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            The App is provided &ldquo;as is&rdquo; and &ldquo;as
            available&rdquo; without warranties of any kind, whether express or
            implied.
          </li>
          <li className="marker:text-coral">
            We do not warrant that hobby recommendations, AI-generated roadmaps,
            or cost estimates are accurate, complete, or suitable for your
            individual circumstances.
          </li>
          <li className="marker:text-coral">
            We are not liable for any injury, property damage, or financial loss
            arising from your participation in any hobby discovered through the
            App.
          </li>
          <li className="marker:text-coral">
            We are not liable for any indirect, incidental, special, or
            consequential damages arising from your use of the App.
          </li>
          <li className="marker:text-coral">
            Our total liability for any claim related to the App shall not
            exceed the amount you paid for TrySomething Pro in the 12 months
            preceding the claim, or CHF 50, whichever is greater.
          </li>
        </ul>
        <p className="text-text-secondary leading-relaxed mb-4">
          Nothing in these Terms excludes liability for gross negligence or
          willful misconduct (Art. 100 para. 1 OR).
        </p>

        {/* Section 12 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          12. Indemnification
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          You agree to indemnify and hold harmless Romulo Roriz from any claims,
          damages, losses, or expenses (including reasonable legal fees) arising
          from your use of the App, your violation of these Terms, or your
          violation of any rights of a third party.
        </p>

        {/* Section 13 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          13. Modifications to Terms
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          We may update these Terms from time to time. When we make material
          changes, we will notify you through the App or via email at least 14
          days before the changes take effect.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          Your continued use of the App after the effective date constitutes
          acceptance of the updated Terms. If you do not agree, you should stop
          using the App and delete your account.
        </p>

        {/* Section 14 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          14. Termination
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          You may stop using the App and request account deletion at any time by
          contacting support@trysomething.io.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          We may terminate or suspend your account at our discretion if you
          violate these Terms, with or without notice.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          Upon termination, your right to use the App ceases immediately. We
          will delete your personal data in accordance with our Privacy Policy,
          subject to any legal retention obligations.
        </p>

        {/* Section 15 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          15. Governing Law and Jurisdiction
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          These Terms are governed by and construed in accordance with the laws
          of Switzerland, without regard to conflict-of-law principles.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          Any disputes arising from or in connection with these Terms shall be
          subject to the exclusive jurisdiction of the courts of Zurich,
          Switzerland.
        </p>
        <p className="text-text-secondary leading-relaxed mb-4">
          For consumers residing in the European Union, nothing in these Terms
          restricts your rights under mandatory consumer protection laws of your
          country of residence.
        </p>

        {/* Section 16 */}
        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          16. Contact
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          If you have questions about these Terms, please contact us at:
        </p>
        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
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
      </main>
    </div>
  );
}
