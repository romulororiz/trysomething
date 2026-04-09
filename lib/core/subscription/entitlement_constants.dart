/// Single source of truth for all free/pro entitlement limits.
///
/// Every copy string, enforcement check, and paywall comparison must reference
/// these constants — never hardcode numbers.
class EntitlementConstants {
  EntitlementConstants._();

  /// Free-tier coach messages per rolling 30-day window.
  static const int freeCoachMessagesPerMonth = 5;

  /// Pro-tier hobby generations per 24-hour window.
  static const int proGenerationsPerDay = 10;

  /// Free-tier max simultaneous active hobbies.
  static const int freeActiveHobbies = 1;
}
