---
phase: 1
slug: server-security-hardening
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | vitest (server/package.json) |
| **Config file** | `server/vitest.config.ts` |
| **Quick run command** | `cd server && npx vitest run --reporter=verbose` |
| **Full suite command** | `cd server && npm test` |
| **Estimated runtime** | ~15 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd server && npx vitest run --reporter=verbose`
- **After every plan wave:** Run `cd server && npm test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | SEC-01 | unit | `cd server && npx vitest run webhook` | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | SEC-01 | unit | `cd server && npx vitest run webhook` | ❌ W0 | ⬜ pending |
| 01-02-01 | 02 | 1 | SEC-02 | unit | `cd server && npx vitest run rate-limit` | ❌ W0 | ⬜ pending |
| 01-02-02 | 02 | 1 | SEC-02 | unit | `cd server && npx vitest run rate-limit` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `server/test/webhook-auth.test.ts` — stubs for SEC-01 webhook verification scenarios
- [ ] `server/test/rate-limit.test.ts` — stubs for SEC-02 coach rate limiting scenarios

*Existing vitest infrastructure covers framework setup — no additional install needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| RevenueCat webhook receives real events | SEC-01 | Requires RevenueCat dashboard configured | Set env var, trigger test event from RC dashboard |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
