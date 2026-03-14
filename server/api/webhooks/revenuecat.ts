import type { VercelRequest, VercelResponse } from "@vercel/node";
import { prisma } from "../../lib/db";

/**
 * RevenueCat Webhook Handler
 *
 * Receives subscription lifecycle events from RevenueCat and syncs
 * the user's subscription status in the database.
 *
 * Configure in RevenueCat Dashboard → Webhooks:
 *   URL: https://your-domain.vercel.app/api/webhooks/revenuecat
 *   Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  // Only accept POST
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  // Validate webhook secret
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  if (secret) {
    const auth = req.headers.authorization;
    if (!auth || auth !== `Bearer ${secret}`) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }
  }

  try {
    const body = req.body;
    const event = body?.event;

    if (!event) {
      res.status(400).json({ error: "Missing event data" });
      return;
    }

    const eventType: string = event.type;
    const appUserId: string | undefined = event.app_user_id;
    const expirationAtMs: number | undefined = event.expiration_at_ms;
    const productId: string | undefined = event.product_id;

    // Skip anonymous users (not linked to our auth system)
    if (!appUserId || appUserId.startsWith("$RCAnonymousID")) {
      res.status(200).json({ status: "skipped", reason: "anonymous_user" });
      return;
    }

    // Find user by ID (our app_user_id matches the User.id)
    const user = await prisma.user.findUnique({ where: { id: appUserId } });
    if (!user) {
      // Try finding by revenuecatId
      const byRcId = await prisma.user.findUnique({
        where: { revenuecatId: appUserId },
      });
      if (!byRcId) {
        res
          .status(200)
          .json({ status: "skipped", reason: "user_not_found" });
        return;
      }
    }

    const userId = user?.id ?? appUserId;
    const expiresAt = expirationAtMs
      ? new Date(expirationAtMs)
      : undefined;

    // Determine if this is a lifetime (non-renewing) purchase
    const isLifetimeProduct = productId?.includes("lifetime") ?? false;

    switch (eventType) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "UNCANCELLATION":
      case "PRODUCT_CHANGE": {
        await prisma.user.update({
          where: { id: userId },
          data: {
            subscriptionTier: isLifetimeProduct ? "lifetime" : "pro",
            proSince: user?.proSince ?? new Date(),
            proExpiresAt: isLifetimeProduct ? null : expiresAt,
            isLifetime: isLifetimeProduct,
            revenuecatId: appUserId,
          },
        });
        break;
      }

      case "NON_RENEWING_PURCHASE": {
        // Lifetime purchase
        await prisma.user.update({
          where: { id: userId },
          data: {
            subscriptionTier: "lifetime",
            proSince: user?.proSince ?? new Date(),
            proExpiresAt: null,
            isLifetime: true,
            revenuecatId: appUserId,
          },
        });
        break;
      }

      case "CANCELLATION":
      case "EXPIRATION": {
        // Only downgrade if not a lifetime user
        if (!user?.isLifetime) {
          await prisma.user.update({
            where: { id: userId },
            data: {
              subscriptionTier: "free",
              proExpiresAt: expiresAt,
            },
          });
        }
        break;
      }

      case "BILLING_ISSUE": {
        // Log but don't immediately downgrade — RevenueCat retries
        console.log(
          `[RC Webhook] Billing issue for user ${userId}, product: ${productId}`
        );
        break;
      }

      default: {
        // Log unknown events but return 200 so RC doesn't retry
        console.log(`[RC Webhook] Unhandled event type: ${eventType}`);
      }
    }

    res.status(200).json({ status: "ok", event: eventType, userId });
  } catch (error) {
    console.error("[RC Webhook] Error:", error);
    // Return 200 even on error to prevent RevenueCat from retrying indefinitely
    // Log the error for investigation
    res.status(200).json({ status: "error", message: "Internal error logged" });
  }
}
