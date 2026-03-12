import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:trysomething/core/subscription/subscription_service.dart';
import 'package:trysomething/providers/subscription_provider.dart';

/// Mock SubscriptionService for testing ProStatusNotifier in isolation.
/// Does not call RevenueCat platform channels.
class MockSubscriptionService implements SubscriptionService {
  bool mockIsPro = false;
  bool mockIsTrialing = false;
  int mockTrialDays = 0;
  bool refreshCalled = false;

  @override
  bool get isPro => mockIsPro;

  @override
  bool get isTrialing => mockIsTrialing;

  @override
  int get trialDaysRemaining => mockTrialDays;

  @override
  Future<void> refresh() async {
    refreshCalled = true;
  }

  @override
  Future<void> init() async {}

  @override
  Future<Offerings?> getOfferings() async => null;

  @override
  Future<bool> purchase(Package package) async => false;

  @override
  Future<bool> restore() async => false;

  @override
  Future<void> setUserId(String userId) async {}

  @override
  Future<void> clearUser() async {}

  @override
  CustomerInfo? get customerInfo => null;
}

void main() {
  late MockSubscriptionService mockService;
  late ProStatusNotifier notifier;

  setUp(() {
    mockService = MockSubscriptionService();
    notifier = ProStatusNotifier(mockService);
  });

  group('initial state', () {
    test('isPro is false, isTrialing is false, trialDaysRemaining is 0, debugTier is none', () {
      expect(notifier.state.isPro, isFalse);
      expect(notifier.state.isTrialing, isFalse);
      expect(notifier.state.trialDaysRemaining, equals(0));
      expect(notifier.debugTier, DebugTier.none);
    });
  });

  group('setDebugTier(free)', () {
    test('sets state to isPro=false and debugTier=free', () {
      // Precondition: tests run in debug mode, so setDebugTier should work.
      expect(kDebugMode, isTrue);

      notifier.setDebugTier(DebugTier.free);

      expect(notifier.debugTier, DebugTier.free);
      expect(notifier.state.isPro, isFalse);
      expect(notifier.state.isTrialing, isFalse);
      expect(notifier.state.trialDaysRemaining, equals(0));
    });
  });

  group('setDebugTier(trial)', () {
    test('sets state to isPro=true, isTrialing=true, trialDaysRemaining=5, debugTier=trial', () {
      notifier.setDebugTier(DebugTier.trial);

      expect(notifier.debugTier, DebugTier.trial);
      expect(notifier.state.isPro, isTrue);
      expect(notifier.state.isTrialing, isTrue);
      expect(notifier.state.trialDaysRemaining, equals(5));
    });
  });

  group('setDebugTier(pro)', () {
    test('sets state to isPro=true, isTrialing=false, debugTier=pro', () {
      notifier.setDebugTier(DebugTier.pro);

      expect(notifier.debugTier, DebugTier.pro);
      expect(notifier.state.isPro, isTrue);
      expect(notifier.state.isTrialing, isFalse);
    });
  });

  group('setDebugTier(none) after trial', () {
    test('calls sync() and state reflects mock service values', () {
      mockService.mockIsPro = true;
      mockService.mockIsTrialing = false;
      mockService.mockTrialDays = 0;

      // First set to trial to get into a non-none debug tier
      notifier.setDebugTier(DebugTier.trial);
      expect(notifier.state.trialDaysRemaining, equals(5));

      // Now reset to none — should sync from service
      notifier.setDebugTier(DebugTier.none);

      expect(notifier.debugTier, DebugTier.none);
      expect(notifier.state.isPro, isTrue);
      expect(notifier.state.isTrialing, isFalse);
      expect(notifier.state.trialDaysRemaining, equals(0));
    });
  });

  group('sync()', () {
    test('reads from service and updates state correctly', () {
      mockService.mockIsPro = true;
      mockService.mockIsTrialing = true;
      mockService.mockTrialDays = 3;

      notifier.sync();

      expect(notifier.state.isPro, isTrue);
      expect(notifier.state.isTrialing, isTrue);
      expect(notifier.state.trialDaysRemaining, equals(3));
    });
  });

  group('sync() skipped when debugTier != none', () {
    test('state stays as pro=true even after service reports false', () {
      notifier.setDebugTier(DebugTier.pro);
      expect(notifier.state.isPro, isTrue);

      // Change the mock so service would return false
      mockService.mockIsPro = false;

      // sync() should be a no-op because debugTier is pro
      notifier.sync();

      expect(notifier.state.isPro, isTrue);
    });
  });

  group('refresh()', () {
    test('calls service.refresh() and updates state from service', () async {
      mockService.mockIsPro = true;
      mockService.mockIsTrialing = true;
      mockService.mockTrialDays = 7;

      await notifier.refresh();

      expect(mockService.refreshCalled, isTrue);
      expect(notifier.state.isPro, isTrue);
      expect(notifier.state.isTrialing, isTrue);
      expect(notifier.state.trialDaysRemaining, equals(7));
    });
  });

  group('refresh() skipped when debugTier != none', () {
    test('service.refresh() is not called when debug tier is set', () async {
      notifier.setDebugTier(DebugTier.pro);

      await notifier.refresh();

      expect(mockService.refreshCalled, isFalse);
      // State remains as forced by debug tier
      expect(notifier.state.isPro, isTrue);
    });
  });

  group('isProProvider', () {
    test('is false initially and true after setDebugTier(pro)', () {
      final container = ProviderContainer(overrides: [
        subscriptionProvider.overrideWithValue(mockService),
      ]);
      addTearDown(container.dispose);

      // Initially, service returns false
      expect(container.read(isProProvider), isFalse);

      // Trigger pro state via the notifier
      container.read(proStatusProvider.notifier).setDebugTier(DebugTier.pro);

      expect(container.read(isProProvider), isTrue);
    });
  });

  group('ProStatus equality', () {
    test('ProStatus(isPro: true) is not equal to ProStatus()', () {
      const statusPro = ProStatus(isPro: true);
      const statusDefault = ProStatus();

      expect(statusPro.isPro, isTrue);
      expect(statusDefault.isPro, isFalse);
      // They have different values for isPro
      expect(statusPro.isPro == statusDefault.isPro, isFalse);
    });
  });

  group('DebugTier.values', () {
    test('has exactly 4 values: none, free, trial, pro', () {
      expect(DebugTier.values, hasLength(4));
      expect(DebugTier.values, containsAll([
        DebugTier.none,
        DebugTier.free,
        DebugTier.trial,
        DebugTier.pro,
      ]));
    });
  });
}
