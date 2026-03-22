# Phase 6: Restore Purchases - Research

**Researched:** 2026-03-22
**Domain:** RevenueCat Flutter SDK — restore purchases flow
**Confidence:** HIGH

---

## Summary

Phase 6 requires adding a "Restore Purchases" entry point in Settings to satisfy Apple App Store guideline 3.1.1 (SUB-01). The paywall screens already have working restore logic — `pro_screen.dart` and the fallback `_ProUpgradeSheet` both call `service.restore()` and handle the "no purchases found" case correctly. The RevenueCat native paywall (`RevenueCatUI.presentPaywallIfNeeded`) also handles restore internally (the `PaywallResult.restored` branch in `pro_upgrade_sheet.dart` is already wired up). The gap is Settings: `_ProSettingsRow` only offers the Customer Center or Pro screen, with no restore option.

The implementation is low-risk. `SubscriptionService.restore()` is already production-tested on two paywall surfaces. The only new code needed is: (1) a `_handleRestore` method on `_SettingsScreenState` that calls `service.restore()`, shows the appropriate snackbar, and optionally pops to home if Pro was restored, and (2) a "Restore Purchases" tile in the Settings screen's subscription section. No new service layer, no new provider, no new API.

One secondary finding: `MockSubscriptionService` in the existing test file is missing the `isLifetime` getter. This currently compiles because the interface only requires what it declares, but if `isLifetime` is added to the interface it will break. The test file needs `isLifetime` added to the mock.

**Primary recommendation:** Add `_handleRestore()` to `_SettingsScreenState` and insert a restore tile after `_ProSettingsRow`. Mirror the exact pattern from `_handleRestore()` in `pro_screen.dart` (already correct).

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SUB-01 | Restore Purchases button available on paywall screen and/or Settings (Apple guideline 3.1.1) | Paywall screens already have restore; Settings needs a new tile calling the existing `service.restore()` method. |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| purchases_flutter | 9.14.0 (locked) | RevenueCat SDK — `Purchases.restorePurchases()` | Already installed; project uses it for purchase and refresh flows |
| flutter_riverpod | 2.6.1 | State management for `proStatusProvider` | Project standard; `ProStatusNotifier.sync()` is the post-restore update call |

### No new dependencies required

This phase adds no packages. All required code exists in `SubscriptionService` and `ProStatusNotifier`.

---

## Architecture Patterns

### Existing Restore Pattern (already production-correct)

Both `pro_screen.dart` and `pro_upgrade_sheet.dart` use this pattern:

```dart
// Source: lib/screens/settings/pro_screen.dart lines 762–775
Future<void> _handleRestore() async {
  final service = ref.read(subscriptionProvider);
  final success = await service.restore();
  if (success) {
    ref.read(proStatusProvider.notifier).sync();
    if (mounted) context.pop();
  } else {
    if (mounted) {
      showAppSnackbar(context,
          message: 'No previous purchase found.',
          type: AppSnackbarType.info);
    }
  }
}
```

The Settings screen version should NOT pop (Settings is a push route, and restoring Pro should keep the user on Settings). Replace `context.pop()` with a success snackbar instead.

### RevenueCat API — What `restorePurchases()` Actually Does

```dart
// Source: pub cache purchases_flutter-9.14.0/lib/purchases_flutter.dart line 670
/// Restores a user's previous purchases and links their appUserIDs to any
/// user's also using those purchases.
/// Returns a [CustomerInfo] object, or throws a [PlatformException] if there
/// was a problem restoring transactions.
static Future<CustomerInfo> restorePurchases() async {
  final result = await _channel.invokeMethod('restorePurchases');
  return CustomerInfo.fromJson(Map<String, dynamic>.from(result));
}
```

`SubscriptionService.restore()` wraps this:
```dart
// Source: lib/core/subscription/subscription_service.dart lines 111–119
Future<bool> restore() async {
  try {
    _customerInfo = await Purchases.restorePurchases();
    return isPro;   // true = entitlements.active contains 'pro'
  } catch (e) {
    debugPrint('[Subscription] restore failed: $e');
    return false;
  }
}
```

**`restore()` return semantics:**
- `true` = restore completed AND the `pro` entitlement is now active
- `false` = two cases: (a) no purchases found (restore succeeded but `entitlements.active` is empty), or (b) SDK threw `PlatformException`

Both `false` cases are user-visible as "No previous purchase found." — which is correct UX.

### Settings Tile Placement

The restore tile should go **inside** the `_ProSettingsRow` widget or **directly below it** in the settings list. Per Apple guideline 3.1.1, restore must be discoverable from a subscription management location. The settings screen already has a dedicated Pro row at line 228.

Pattern used in settings for secondary actions (after the existing Pro row):

```dart
// Settings screen line 228–233 (existing Pro row)
_ProSettingsRow(
  ref: ref,
  onTap: () => context.push('/pro'),
  onManage: () => _openCustomerCenter(context),
),
const SizedBox(height: 4),
// NEW: restore tile beneath the Pro row
_SettingsTile(
  icon: Icons.restore_outlined,
  title: 'Restore Purchases',
  subtitle: 'Recover a previous subscription',
  onTap: () => _handleRestore(context),
),
```

### `_SettingsTile` Widget

Used throughout settings for action rows. Accepts `icon`, `title`, `subtitle`, optional `trailing`, optional `onTap`.

```dart
// Source: lib/screens/settings/settings_screen.dart (pattern used ~10 times)
_SettingsTile(
  icon: Icons.info_outline_rounded,
  title: 'About',
  subtitle: 'TrySomething v1.0.0',
  onTap: () => _showAboutSheet(context),
),
```

### Loading State for Restore

The settings-based restore should show a loading indicator while the SDK call is in-flight. Pattern from `pro_screen.dart`: use a `bool _restoring` state variable, disable the tap and show `CircularProgressIndicator` while true. However, since the restore call in Settings is triggered from a `_SettingsTile` tap (not a full-screen CTA), the simpler approach is to use a `showAppSnackbar` with a loading message while working. The actual SDK call completes in ~2-5 seconds on a real device.

**Recommendation:** Mirror the existing simple approach — no loading state. The tap triggers the async call; the snackbar fires on completion. This matches project conventions (no loading state shown for restore in `pro_screen.dart` either).

### Anti-Patterns to Avoid

- **Don't use `Purchases.restorePurchases()` directly in the widget** — always go through `SubscriptionService.restore()`. The service handles `PlatformException` and keeps `_customerInfo` in sync.
- **Don't call `proStatusProvider.notifier.refresh()`** — call `.sync()` instead. `refresh()` triggers a new network call to RC; `sync()` reads from the already-updated `_customerInfo` returned by `restorePurchases()`. This is what both existing `_handleRestore()` implementations do.
- **Don't show "Restore Purchases" when user is already Pro** — hide the restore tile when `status.isPro`. The user has nothing to restore.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Restore purchases flow | Custom SKPaymentQueue / BillingClient restore | `SubscriptionService.restore()` wrapping `Purchases.restorePurchases()` | SDK handles cross-platform differences, receipt validation, entitlement sync |
| "Already purchased" detection | Custom receipt parsing | `customerInfo.entitlements.active.containsKey('pro')` via `isPro` getter | Entitlement model is already correct; active = not expired |
| Loading overlay during restore | Custom full-screen loader | None needed (or use a brief disable of the tap target) | RC restore completes in 1-5 seconds; heavy UX is overkill for a settings tile |

---

## Common Pitfalls

### Pitfall 1: Calling refresh() instead of sync() after restore
**What goes wrong:** `refresh()` makes a second network call to RevenueCat after `restorePurchases()` already fetched updated CustomerInfo.
**Why it happens:** `refresh()` and `sync()` look equivalent from the callsite but do different things. `restore()` in `SubscriptionService` already sets `_customerInfo` to the result of `restorePurchases()`.
**How to avoid:** Always call `.sync()` after restore, not `.refresh()`. `sync()` reads from the already-updated `_customerInfo` without a network round-trip.
**Warning signs:** Two RC API calls showing in Xcode console on restore.

### Pitfall 2: Pop after restore in Settings context
**What goes wrong:** `context.pop()` from Settings closes the Settings screen, not just a modal. The user loses their place.
**Why it happens:** Both existing `_handleRestore()` implementations call `context.pop()` because they live inside the Pro screen or bottom sheet — popping is correct there. Settings is a push route.
**How to avoid:** Use `showAppSnackbar(context, message: 'Pro restored!', type: AppSnackbarType.success)` instead of `context.pop()` in the Settings version.
**Warning signs:** Settings screen disappears after successful restore.

### Pitfall 3: Showing restore tile to already-Pro users
**What goes wrong:** A Pro user taps "Restore Purchases" and gets "No previous purchase found." because their current subscription is already active and `entitlements.active` already contains `pro`.
**Why it happens:** `restorePurchases()` syncs transactions. When already Pro, `isPro` returns true, so `restore()` returns true. The snackbar would say "Pro restored" for a user who was already Pro — confusing.
**How to avoid:** Wrap the restore tile in `if (!status.isPro)`. Show it only when the user is on the free plan. The Pro screen already does this (the entire `!status.isPro` section including the restore link is conditionally rendered).
**Warning signs:** Pro badge doesn't change, but "Pro restored!" snackbar fires.

### Pitfall 4: Treating PlatformException as "no purchases"
**What goes wrong:** A network error throws a `PlatformException`, which `SubscriptionService.restore()` catches and returns `false`. The user sees "No previous purchase found." when the real problem is network connectivity.
**Why it happens:** `restore()` catches all exceptions and returns `false`. Both `false` cases (no purchases + error) show the same message.
**How to avoid:** For Settings, this is acceptable behavior — the message is slightly misleading but does not cause user harm. If more granular error handling is desired in future: catch `PlatformException` in `restore()` and return a richer result type. For this phase, the existing behavior matches the paywall pattern.
**Warning signs:** User on airplane mode sees "No previous purchase found." instead of "No internet connection."

### Pitfall 5: MockSubscriptionService missing isLifetime
**What goes wrong:** The existing `MockSubscriptionService` in `subscription_provider_test.dart` does not implement `isLifetime`. If `SubscriptionService` interface is ever explicitly declared with that getter, the mock will fail to compile.
**Why it happens:** `isLifetime` was added to `SubscriptionService` without being added to the mock.
**How to avoid:** Add `@override bool get isLifetime => false;` to `MockSubscriptionService` during this phase (since the test file needs to be touched anyway for any new restore-related tests).
**Warning signs:** `dart test` fails with "Missing implementation of 'isLifetime'" if SubscriptionService is ever made abstract.

---

## Code Examples

### Full _handleRestore for Settings screen

```dart
// Pattern: mirrors pro_screen.dart but shows success snackbar instead of pop
Future<void> _handleRestore(BuildContext context) async {
  final service = ref.read(subscriptionProvider);
  final success = await service.restore();
  if (!mounted) return;
  if (success) {
    ref.read(proStatusProvider.notifier).sync();
    showAppSnackbar(context,
        message: 'Pro subscription restored!',
        type: AppSnackbarType.success);
  } else {
    showAppSnackbar(context,
        message: 'No previous purchase found.',
        type: AppSnackbarType.info);
  }
}
```

### Conditional restore tile

```dart
// Only show restore when not already Pro
final status = ref.watch(proStatusProvider);
if (!status.isPro) ...[
  const SizedBox(height: 4),
  _SettingsTile(
    icon: Icons.restore_outlined,
    title: 'Restore Purchases',
    subtitle: 'Recover a previous subscription',
    onTap: () => _handleRestore(context),
  ),
],
```

### CustomerInfo entitlement check (from SDK source)

```dart
// Source: purchases_flutter-9.14.0/lib/models/entitlement_infos_wrapper.dart
// entitlements.active is Map<String, EntitlementInfo>
// 'pro' key is present only when the entitlement is currently active (not expired)
bool get isPro =>
    _customerInfo?.entitlements.active.containsKey('pro') ?? false;
```

### Error code extraction (if richer error handling needed in future)

```dart
// Source: purchases_flutter-9.14.0/lib/errors.dart
// For any PlatformException from the SDK:
} catch (e) {
  if (e is PlatformException) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.networkError) {
      // Show "Check your internet connection"
    } else if (code == PurchasesErrorCode.receiptAlreadyInUseError) {
      // Apple: receipt belongs to a different Apple ID
    } else {
      // Generic error
    }
  }
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Calling `Purchases.restorePurchases()` directly in widget | Wrapped in `SubscriptionService.restore()` | Already in codebase | Service handles catch, keeps `_customerInfo` in sync |
| Custom paywall sheet only | `RevenueCatUI.presentPaywallIfNeeded` first, custom sheet as fallback | Already in codebase | RC native paywall has built-in restore; `PaywallResult.restored` already handled |

**What already works (no changes needed):**
- `pro_screen.dart`: Has "Restore purchase" text link. Calls `_handleRestore()` correctly. Handles both success and no-purchase-found cases.
- `pro_upgrade_sheet.dart`: Has "Restore purchase" text link in the fallback custom sheet. Same pattern.
- `RevenueCatUI.presentPaywallIfNeeded`: Built-in restore flow; `PaywallResult.restored` sync is handled.

**What is missing (the gap this phase fills):**
- Settings screen has no restore option. `_ProSettingsRow` only shows `onManage` (Customer Center) or `onTap` (Pro screen). Phase SUB-01 requires restore to be reachable from Settings.

---

## Open Questions

1. **Should the restore tile be hidden when the user is Pro?**
   - What we know: The Pro screen hides its entire non-Pro section (including restore) when `status.isPro`. Apple guideline 3.1.1 does not require restore to be visible when already subscribed — it requires it to be accessible before purchase.
   - Recommendation: Hide with `if (!status.isPro)`. Simplifies UX and avoids confusing "Pro restored!" for already-Pro users.

2. **Should Settings restore show a loading indicator?**
   - What we know: No loading indicator is shown in the existing `_handleRestore()` on Pro screen or upgrade sheet. Matches project convention.
   - Recommendation: No loading indicator. Show nothing during the async call. The user sees the snackbar when done.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (bundled with Flutter 3.6.0) |
| Config file | `analysis_options.yaml` |
| Quick run command | `flutter test test/unit/providers/subscription_provider_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SUB-01 | `service.restore()` returns true when entitlement active after restore | unit | `flutter test test/unit/providers/subscription_provider_test.dart` | Yes (extend existing) |
| SUB-01 | `service.restore()` returns false when no purchases found | unit | `flutter test test/unit/providers/subscription_provider_test.dart` | Yes (extend existing) |
| SUB-01 | Snackbar message = "No previous purchase found." when restore returns false | manual | Tap Restore on physical device with no prior purchase | N/A |
| SUB-01 | Settings screen has restore tile when user is not Pro | widget | `flutter test test/widget/` | No — Wave 0 gap |

### Sampling Rate
- **Per task commit:** `flutter test test/unit/providers/subscription_provider_test.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Add `restorePurchases` unit tests to `test/unit/providers/subscription_provider_test.dart` — extend `MockSubscriptionService` with `mockRestore` flag and add `isLifetime` getter, then test restore success/failure paths via `ProStatusNotifier`
- [ ] Add `@override bool get isLifetime => false;` to `MockSubscriptionService` (currently missing)

---

## Sources

### Primary (HIGH confidence)
- `purchases_flutter-9.14.0` pub cache at `C:/Users/41783/AppData/Local/Pub/Cache/hosted/pub.dev/purchases_flutter-9.14.0/` — verified `restorePurchases()` signature, return type `Future<CustomerInfo>`, exception type `PlatformException`
- `purchases_flutter-9.14.0/lib/errors.dart` — verified full `PurchasesErrorCode` enum and `PurchasesErrorHelper.getErrorCode()`
- `purchases_flutter-9.14.0/lib/models/entitlement_infos_wrapper.dart` — verified `active` map structure
- `lib/core/subscription/subscription_service.dart` — verified existing `restore()` implementation
- `lib/screens/settings/pro_screen.dart` — verified existing `_handleRestore()` pattern
- `lib/components/pro_upgrade_sheet.dart` — verified fallback sheet restore pattern and `PaywallResult.restored` handling
- `lib/screens/settings/settings_screen.dart` — confirmed missing restore tile in `_ProSettingsRow`
- `test/unit/providers/subscription_provider_test.dart` — confirmed `MockSubscriptionService` missing `isLifetime`

### Secondary (MEDIUM confidence)
- Apple App Store guideline 3.1.1 (from training knowledge, verified against requirement text in REQUIREMENTS.md): "In-app purchases must include a restore mechanism accessible in-app"

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified from locked pub cache source files
- Architecture: HIGH — patterns read directly from existing working code
- Pitfalls: HIGH — derived from reading the actual SDK return types and existing implementations
- Test map: HIGH — test file read directly, gap verified by grepping for `isLifetime` in mock

**Research date:** 2026-03-22
**Valid until:** 2026-06-22 (RevenueCat SDK stable; update if upgrading `purchases_flutter`)
