import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Subscription service powered by RevenueCat.
class SubscriptionService {
  bool _initialized = false;
  CustomerInfo? _customerInfo;

  static const _entitlement = 'pro';

  // Platform-specific RevenueCat public API keys
  static const _appleKey = 'appl_SkiBGKbnsWiBfFNnLWfPfFqYJXC';
  static const _googleKey = 'goog_REPLACE_WITH_GOOGLE_KEY'; // TODO: add after Google Play setup
  static const _testKey = 'test_ceXHQvrREruGuOQFaseoFYZANVo';

  /// Initialize RevenueCat SDK.
  Future<void> init() async {
    if (_initialized) return;

    final apiKey = const String.fromEnvironment('REVENUECAT_API_KEY').isNotEmpty
        ? const String.fromEnvironment('REVENUECAT_API_KEY')
        : defaultTargetPlatform == TargetPlatform.iOS
            ? _appleKey
            : defaultTargetPlatform == TargetPlatform.android
                ? _googleKey
                : _testKey;

    if (apiKey.isEmpty) {
      debugPrint('[Subscription] No RevenueCat API key — running in free mode');
      _initialized = true;
      return;
    }

    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _initialized = true;

    // Fetch initial customer info
    await refresh();

    if (kDebugMode) {
      debugPrint('[Subscription] Initialized. isPro=$isPro');
    }
  }

  /// Refresh customer info from RevenueCat.
  Future<void> refresh() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[Subscription] refresh failed: $e');
    }
  }

  /// Whether the user has an active Pro entitlement.
  bool get isPro {
    return _customerInfo?.entitlements.active.containsKey(_entitlement) ?? false;
  }

  /// Whether the user has a lifetime (non-expiring) purchase.
  bool get isLifetime {
    final entitlement = _customerInfo?.entitlements.active[_entitlement];
    if (entitlement == null) return false;
    // Lifetime purchases have no expiration date
    return entitlement.expirationDate == null;
  }

  /// Whether the user is in a free trial period.
  bool get isTrialing {
    final entitlement = _customerInfo?.entitlements.active[_entitlement];
    if (entitlement == null) return false;
    return entitlement.periodType == PeriodType.trial;
  }

  /// Days remaining in trial (0 if not trialing).
  int get trialDaysRemaining {
    final entitlement = _customerInfo?.entitlements.active[_entitlement];
    if (entitlement == null) return 0;
    if (entitlement.periodType != PeriodType.trial) return 0;
    final expires = entitlement.expirationDate;
    if (expires == null) return 0;
    final expiresAt = DateTime.tryParse(expires);
    if (expiresAt == null) return 0;
    return expiresAt.difference(DateTime.now()).inDays;
  }

  /// Get available offerings (packages/plans).
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[Subscription] getOfferings failed: $e');
      return null;
    }
  }

  /// Purchase a package (monthly, annual, or lifetime).
  Future<bool> purchase(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _customerInfo = result.customerInfo;
      return isPro;
    } catch (e) {
      debugPrint('[Subscription] purchase failed: $e');
      return false;
    }
  }

  /// Restore previous purchases (e.g. after reinstall).
  Future<bool> restore() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      return isPro;
    } catch (e) {
      debugPrint('[Subscription] restore failed: $e');
      return false;
    }
  }

  /// Set the user ID for attribution (call after login).
  Future<void> setUserId(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
    } catch (e) {
      debugPrint('[Subscription] setUserId failed: $e');
    }
  }

  /// Clear user on logout.
  Future<void> clearUser() async {
    try {
      _customerInfo = await Purchases.logOut();
    } catch (e) {
      debugPrint('[Subscription] clearUser failed: $e');
    }
  }

  /// Raw customer info for debugging.
  CustomerInfo? get customerInfo => _customerInfo;
}
