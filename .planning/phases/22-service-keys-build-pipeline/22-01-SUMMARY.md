---
phase: 22-service-keys-build-pipeline
plan: 01
status: complete
started: 2026-03-27
completed: 2026-03-27
---

## Summary

Collected all production API keys and configured Firebase release fingerprints. RevenueCat Android app created via MCP with 3 products (Monthly, Annual, Lifetime) attached to packages and `pro` entitlement.

## Tasks Completed

| # | Task | Status |
|---|------|--------|
| 1 | Firebase release SHA fingerprints | ✓ User added in console, google-services.json re-downloaded |
| 2 | RevenueCat Google Play SDK key | ✓ Created Android app + products via MCP |
| 3 | PostHog, Sentry, Google OAuth keys | ✓ User provided PostHog + Sentry DSN, Google OAuth from Firebase project |

## Key Results

- **RevenueCat**: Android app `app6a4877533d`, key `goog_RgtnXfbwBvAPtNmHXtgLGHrkvqs`
- **RevenueCat Products**: Monthly (`monthly_subs:monthly-base`), Annual (`yearly_subs:yearly-base`), Lifetime (`lifetime_subscription`) — all attached to `pro` entitlement
- **PostHog**: `phx_SpCXSj25r5eXIb6DuUh3AfQ8l9vj3R53dxzTYhxgC7RMeFG`
- **Sentry**: `https://2252d3e5f16817067a6b5adfc0be2789@o4510999049732096.ingest.de.sentry.io/4511116609192016`
- **Google OAuth**: `941963960338-mlgo5vgir324j8ctg47a2n319uocvnch.apps.googleusercontent.com` (from Firebase project, NOT user's separate GCP project)
- **Firebase**: Release SHA-1 added, google-services.json updated with OAuth clients

## Commits

- `68000b8` feat(22-02): create release build script with dart-define injection

## Deviations

- User provided Google OAuth client ID from a different GCP project (973949791990). Used the Firebase project's Web client ID (941963960338) instead for token verification consistency.
