---
created: 2026-03-24T06:15:58.790Z
title: Photo upload content moderation
area: api
files:
  - lib/core/media/image_upload.dart
  - server/lib/content_guard.ts
---

## Problem

Photo uploads (journal entries + profile photos) go directly to Cloudinary with no content screening. Users could upload NSFW, pornographic, violent, or policy-violating images. This is a safety and app store compliance risk — both Apple and Google require content moderation for user-generated images.

## Solution

Add AI-powered image screening before allowing the upload to complete. Two possible approaches:

**Option A — Client-side screening (preferred for latency):**
- After picking the image but before uploading to Cloudinary, send a low-res version to a moderation endpoint (`POST /api/moderate/image`)
- Server sends image to Claude vision with a moderation-only prompt (safe/unsafe classification)
- If unsafe: reject upload, show warning toast ("This image can't be uploaded"), return null
- If safe: proceed with Cloudinary upload

**Option B — Cloudinary webhook:**
- Use Cloudinary's moderation add-on (Google Vision AI or AWS Rekognition)
- Auto-moderate on upload, flag/remove violations
- Slower feedback loop, but no custom endpoint needed

Prefer Option A for instant user feedback. Use a small/fast model (Haiku) for cost efficiency. The existing `content_guard.ts` blocklist pattern can be extended with an `imageGuard` function.
