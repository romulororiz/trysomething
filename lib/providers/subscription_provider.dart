import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/subscription/subscription_service.dart';

/// Global subscription service singleton.
/// Override in main.dart with initialized instance.
final subscriptionProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Pro subscription status — refreshable.
class ProStatus {
  final bool isPro;
  final bool isTrialing;
  final bool isLifetime;
  final int trialDaysRemaining;

  const ProStatus({
    this.isPro = false,
    this.isTrialing = false,
    this.isLifetime = false,
    this.trialDaysRemaining = 0,
  });
}

/// Debug override for subscription tier.
/// null = use RevenueCat, "free"/"trial"/"pro" = force that state.
enum DebugTier { none, free, trial, pro }

class ProStatusNotifier extends StateNotifier<ProStatus> {
  final SubscriptionService _service;
  DebugTier _debugTier = DebugTier.none;
  DebugTier get debugTier => _debugTier;

  ProStatusNotifier(this._service) : super(const ProStatus());

  /// Debug-only: override subscription tier for testing.
  void setDebugTier(DebugTier tier) {
    if (!kDebugMode) return;
    _debugTier = tier;
    switch (tier) {
      case DebugTier.none:
        sync();
      case DebugTier.free:
        state = const ProStatus();
      case DebugTier.trial:
        state = const ProStatus(isPro: true, isTrialing: true, trialDaysRemaining: 5);
      case DebugTier.pro:
        state = const ProStatus(isPro: true);
    }
  }

  /// Refresh from RevenueCat and update state.
  Future<void> refresh() async {
    if (_debugTier != DebugTier.none) return; // skip if debug override active
    await _service.refresh();
    state = ProStatus(
      isPro: _service.isPro,
      isTrialing: _service.isTrialing,
      isLifetime: _service.isLifetime,
      trialDaysRemaining: _service.trialDaysRemaining,
    );
  }

  /// Update state from service (no network call).
  void sync() {
    if (_debugTier != DebugTier.none) return;
    state = ProStatus(
      isPro: _service.isPro,
      isTrialing: _service.isTrialing,
      isLifetime: _service.isLifetime,
      trialDaysRemaining: _service.trialDaysRemaining,
    );
  }
}

final proStatusProvider =
    StateNotifierProvider<ProStatusNotifier, ProStatus>((ref) {
  final service = ref.watch(subscriptionProvider);
  return ProStatusNotifier(service);
});

/// Convenience: whether the user has Pro access (paid or trial).
final isProProvider = Provider<bool>((ref) {
  return ref.watch(proStatusProvider).isPro;
});
