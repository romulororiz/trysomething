---
phase: 23-play-console-products
plan: 01
status: complete
started: 2026-03-27
completed: 2026-03-27
---

## Summary

Play Console app created, merchant account linked, AAB uploaded to internal testing, subscription products configured with 7-day free trials. RevenueCat Android products linked to entitlement.

## Tasks Completed

| # | Task | Status |
|---|------|--------|
| 1 | Create app in Play Console | ✓ Via Playwright (com.romulororiz.trysomething, app ID 4975977892322492689) |
| 2 | Set up merchant account | ✓ Linked existing Swiss payment profile (Rômulo Roriz) |
| 3 | Upload AAB to internal testing | ✓ Version 1.0.0 (1), 18.1MB install size, published |
| 4 | Create monthly subscription | ✓ monthly_subs, base plan monthly-base, CHF 4.99/month, 7-day free trial |
| 5 | Create annual subscription | ✓ yearly_subs, base plan yearly-base, CHF 39.99/year, 7-day free trial |
| 6 | RevenueCat products linked | ✓ Via MCP: 3 Android products attached to packages + pro entitlement |
| 7 | Lifetime removed from app | ✓ Pro screen now shows only Monthly + Annual |

## Key Results

- **Play Console App ID:** 4975977892322492689
- **Developer Account ID:** 7464480321113594114
- **Monthly:** `monthly_subs` → `monthly-base` (auto-renewal, CHF 4.99, 7-day trial)
- **Annual:** `yearly_subs` → `yearly-base` (auto-renewal, CHF 39.99, 7-day trial)
- **RevenueCat Google Key:** `goog_RgtnXfbwBvAPtNmHXtgLGHrkvqs`

## Commits

- `0861448` refactor: remove lifetime subscription, streamline Pro paywall to monthly/annual
