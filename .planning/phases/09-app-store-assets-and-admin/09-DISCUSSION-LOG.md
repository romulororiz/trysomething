# Phase 9: App Store Assets and Admin - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.

**Date:** 2026-03-22
**Phase:** 09-app-store-assets-and-admin
**Areas discussed:** Privacy manifests, Screenshots strategy, Store metadata

---

## Privacy manifests

### Q1: Have you checked if SDK versions include bundled privacy manifests?

| Option | Description | Selected |
|--------|-------------|----------|
| No, haven't checked | Claude should verify | ✓ |
| Yes, some are missing | User knows specifics | |
| You decide | Claude handles investigation | |

### Q2: Does app declare iPad support?

| Option | Description | Selected |
|--------|-------------|----------|
| iPhone only | No iPad support | |
| Universal | iPhone + iPad | |
| Not sure | Claude should check | ✓ |

**Finding:** `TARGETED_DEVICE_FAMILY = "1,2"` — both iPhone and iPad. User chose to restrict to iPhone only.

---

## Screenshots strategy

### Q1: How to capture screenshots?

| Option | Description | Selected |
|--------|-------------|----------|
| Real device | Nothing Phone 3a | |
| iOS Simulator | iPhone 16 Pro Max | |
| Both needed | Sim for iOS, device for Android | |
| You decide | Claude recommends | ✓ |

### Q2: Which screens? (multiSelect)

- [x] Home (active hobby)
- [x] Discover feed
- [x] Hobby detail
- [x] Session timer

---

## Store metadata

### Q1: App Store category?

| Option | Description | Selected |
|--------|-------------|----------|
| Lifestyle | Most hobby apps | |
| Health & Fitness | Wellness angle | |
| Education | Learning angle | |
| You decide | Claude picks | ✓ |

### Q2: Language?

- English only ✓

### Q3: Demo account?

User noted they only have `support@trysomething.io` — will use that as the review account.

---

## Claude's Discretion

- App Store category, screenshot composition, description/keywords, privacy manifest data types

## Deferred Ideas

None
