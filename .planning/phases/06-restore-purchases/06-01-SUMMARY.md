---
phase: 06-restore-purchases
plan: 01
subsystem: settings-subscription
tags: [restore-purchases, settings, apple-compliance, revenucat]
dependency_graph:
  requires: []
  provides: [restore-purchases-settings-tile]
  affects: [settings-screen, subscription-provider-tests]
tech_stack:
  added: []
  patterns: [conditional-widget-visibility, service-sync-after-restore]
key_files:
  created: []
  modified:
    - lib/screens/settings/settings_screen.dart
    - test/unit/providers/subscription_provider_test.dart
decisions:
  - Used sync() not refresh() after restore to avoid redundant network call
  - Tile hidden reactively via ref.watch(proStatusProvider).isPro inline check
  - No context.pop() since Settings is a push route, not a modal
metrics:
  duration: 3min
  completed: "2026-03-22"
---

# Phase 6 Plan 1: Restore Purchases in Settings Summary

**Add "Restore Purchases" tile to Settings for non-Pro users, calling SubscriptionService.restore() with success/info snackbar feedback and reactive hide on Pro activation.**

## What Was Done

### Task 1: Extend unit tests -- restore paths and isLifetime mock fix
- Added `isLifetime` getter override to `MockSubscriptionService` (was missing, caused compile-time mismatch with production `SubscriptionService`)
- Added `mockRestoreResult` field for configurable restore behavior in tests
- Updated `restore()` override to use `mockRestoreResult` flag and simulate RevenueCat internal state update
- Added `restore flow` test group with two tests:
  - `restore returns true and sync updates state to isPro` -- verifies successful restore path
  - `restore returns false and state remains not Pro` -- verifies no-purchase-found path
- **Commit:** `cb4dae4`

### Task 2: Add Restore Purchases tile to Settings screen
- Added `_handleRestore()` async method to `_SettingsScreenState`:
  - Calls `ref.read(subscriptionProvider).restore()`
  - Checks `mounted` before UI operations
  - On success: calls `proStatusProvider.notifier.sync()` + success snackbar
  - On failure: shows info snackbar "No previous purchase found."
- Added conditional restore tile between `_ProSettingsRow` and Preferences section:
  - Uses `if (!ref.watch(proStatusProvider).isPro)` for reactive visibility
  - Icon: `Icons.restore_outlined`
  - Title: "Restore Purchases"
  - Subtitle: "Recover a previous subscription"
- **Commit:** `adf21ee`

## Verification Results

| Check | Result |
|-------|--------|
| `flutter test test/unit/providers/subscription_provider_test.dart` | 14/14 passed |
| `dart analyze lib/screens/settings/settings_screen.dart` | 0 errors (21 pre-existing info warnings) |
| `_handleRestore` exists in settings_screen.dart | 2 matches (definition + onTap) |
| `Restore Purchases` tile text exists | 1 match |
| `proStatusProvider.notifier).sync()` used (not refresh) | 1 match |
| `!ref.watch(proStatusProvider).isPro` conditional | 1 match |
| No `context.pop` in `_handleRestore` | Confirmed |

## Deviations from Plan

None -- plan executed exactly as written.

## Known Stubs

None -- all functionality is fully wired to production SubscriptionService.

## Decisions Made

1. **sync() over refresh() after restore** -- `restore()` already updates RevenueCat's internal `_customerInfo`, so `sync()` reads the already-updated service state without a redundant network call. This matches the pattern used in `pro_screen.dart` line 766.

2. **Inline ref.watch for conditional visibility** -- Rather than using a local variable, the `ref.watch(proStatusProvider).isPro` is called inline in the `if` spread to ensure correct reactive rebuild scoping.

3. **SizedBox(height: 4) spacing** -- Tight spacing (4px) between Pro row and restore tile since they are visually related, while the 20px gap before Preferences section is preserved.

## Self-Check: PASSED

- All modified files exist on disk
- All commit hashes (cb4dae4, adf21ee) found in git log
- SUMMARY.md created at expected path
