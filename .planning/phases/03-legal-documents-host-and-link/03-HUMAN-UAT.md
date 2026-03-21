---
status: partial
phase: 03-legal-documents-host-and-link
source: [03-VERIFICATION.md]
started: 2026-03-21T20:50:00Z
updated: 2026-03-21T20:50:00Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. Visit https://trysomething.app/terms in a browser
expected: Publicly accessible HTML page with all 16 sections of Terms of Service, no redirect to login, crawlable
result: [pending]

### 2. Visit https://trysomething.app/privacy in a browser
expected: Publicly accessible HTML page with all 11 sections of Privacy Policy and all 10 processor cards, no redirect to login, crawlable
result: [pending]

### 3. In the deployed website footer, click 'Terms of Service'
expected: Navigates to /terms page without a login redirect
result: [pending]

### 4. Tap 'Terms of Service' and 'Privacy Policy' in the app Settings About sheet
expected: Each opens https://trysomething.app/terms or /privacy in the device browser
result: [pending]

### 5. Tap 'Terms of Service' and 'Privacy Policy' on the Register screen
expected: Each opens the correct hosted URL in the device browser via LaunchMode.externalApplication
result: [pending]

### 6. Tap 'Terms of Service' and 'Privacy Policy' on the Login screen
expected: Each opens the correct hosted URL in the device browser via LaunchMode.externalApplication
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0
blocked: 0

## Gaps
