/// Single source of truth for all free/pro entitlement limits.
///
/// Every copy string, enforcement check, and paywall comparison must reference
/// these constants — never hardcode numbers.
///
/// Server-side equivalents live in `server/lib/entitlement_constants.ts` and
/// must be kept in sync. The server is the authoritative enforcement layer;
/// client-side counts here are for UX only (instant feedback before the
/// server's 429 response).
class EntitlementConstants {
  EntitlementConstants._();

  /// Free-tier coach messages per rolling 24-hour window.
  ///
  /// Daily bucket of a dual-bucket limiter — prevents bursting and
  /// creates a daily-ritual rhythm. Soft-capped at
  /// [freeCoachMessagesPerMonth] over 30 days.
  static const int freeCoachMessagesPerDay = 3;

  /// Free-tier coach messages per rolling 30-day window.
  ///
  /// Monthly soft cap — even users who message daily can't exceed this.
  /// Caps total API cost and forces conversion for power users.
  static const int freeCoachMessagesPerMonth = 15;

  /// Free-tier max simultaneous active hobbies.
  static const int freeActiveHobbies = 1;
}
