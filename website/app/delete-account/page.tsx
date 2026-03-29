import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Delete Account - TrySomething",
  description:
    "Request deletion of your TrySomething account and all associated data.",
};

export default function DeleteAccountPage() {
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
          Delete Your Account
        </h1>
        <p className="text-sm text-text-muted mb-10">
          We&apos;re sorry to see you go.
        </p>

        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          How to Delete Your Account
        </h2>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          Option 1: From the App
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          The fastest way to delete your account is directly in the app:
        </p>
        <ol className="list-decimal list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Open TrySomething and go to the <strong className="text-text-primary">You</strong> tab.
          </li>
          <li className="marker:text-coral">
            Tap <strong className="text-text-primary">Settings</strong>.
          </li>
          <li className="marker:text-coral">
            Scroll to the bottom and tap <strong className="text-text-primary">Delete Account</strong>.
          </li>
          <li className="marker:text-coral">
            Confirm the deletion when prompted.
          </li>
        </ol>

        <h3 className="text-base font-bold text-text-primary mt-6 mb-3">
          Option 2: By Email
        </h3>
        <p className="text-text-secondary leading-relaxed mb-4">
          If you can&apos;t access the app, send an email to{" "}
          <a
            href="mailto:support@trysomething.io?subject=Account%20Deletion%20Request"
            className="text-coral hover:underline"
          >
            support@trysomething.io
          </a>{" "}
          with the subject line &ldquo;Account Deletion Request&rdquo; from the
          email address associated with your account. We will process your
          request within 30 days.
        </p>

        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          What Gets Deleted
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          When you delete your account, the following data is permanently removed:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Your profile information (name, email, preferences)
          </li>
          <li className="marker:text-coral">
            All saved hobbies, progress, and completed steps
          </li>
          <li className="marker:text-coral">
            Journal entries, personal notes, and photos
          </li>
          <li className="marker:text-coral">
            Schedule events and shopping lists
          </li>
          <li className="marker:text-coral">
            Community stories and reactions
          </li>
          <li className="marker:text-coral">
            Activity logs and generation history
          </li>
        </ul>

        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
          <p className="text-text-secondary leading-relaxed">
            <strong className="text-text-primary">Note:</strong> Your account is
            soft-deleted immediately and permanently purged within 30 days. During
            this period, your data is inaccessible. Active subscriptions are not
            automatically cancelled &mdash; please cancel your subscription through
            Google Play or the App Store before deleting your account.
          </p>
        </div>

        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          Data Retained by Third Parties
        </h2>
        <p className="text-text-secondary leading-relaxed mb-4">
          Some anonymized data may be retained by third-party services according
          to their own retention policies:
        </p>
        <ul className="list-disc list-outside ml-5 space-y-2 text-text-secondary leading-relaxed mb-4">
          <li className="marker:text-coral">
            Analytics events (PostHog) &mdash; associated with anonymous IDs, not
            your name or email
          </li>
          <li className="marker:text-coral">
            Crash reports (Sentry) &mdash; retained for 90 days with anonymous
            session IDs
          </li>
          <li className="marker:text-coral">
            Purchase records (Google Play / App Store) &mdash; retained by the
            platform per their policies
          </li>
        </ul>

        <p className="text-text-secondary leading-relaxed mb-4">
          For more details, see our{" "}
          <a href="/privacy" className="text-coral hover:underline">
            Privacy Policy
          </a>
          .
        </p>

        <h2 className="text-xl font-semibold text-coral mt-10 mb-4">
          Questions?
        </h2>
        <div className="bg-glass border border-glass-border rounded-xl p-4 mb-4">
          <p className="mb-1">
            <span className="font-semibold text-text-primary">Email: </span>
            <span className="text-text-secondary">
              <a
                href="mailto:support@trysomething.io"
                className="hover:text-coral transition-colors"
              >
                support@trysomething.io
              </a>
            </span>
          </p>
          <p>
            <span className="font-semibold text-text-primary">
              Response time:{" "}
            </span>
            <span className="text-text-secondary">Within 30 days</span>
          </p>
        </div>
      </main>
    </div>
  );
}
