---
created: 2026-03-24T06:15:58.790Z
title: AI coach image awareness for journal entries
area: api
files:
  - server/api/generate/[action].ts
  - server/lib/ai_generator.ts
  - lib/screens/coach/hobby_coach_screen.dart
---

## Problem

The AI coach currently only sees text from journal entries when building conversation context. If a journal entry has a photo attached (`photoUrl` field), the coach has no awareness of it. Users who photograph their hobby progress (e.g., a painting, a planted garden, a cooked dish) can't get feedback on what they made.

## Solution

Pass the journal entry's `photoUrl` to the Claude API as an image content block alongside the text context. The coach system prompt builder (`buildCoachSystemPrompt()`) already injects recent journal entries — extend it to include image URLs for entries that have photos. Use Claude's vision capability to let the coach reference and comment on the user's photos.

Key changes:
- Modify `buildCoachSystemPrompt()` to include `[Photo attached: {url}]` annotation for entries with photos
- In the chat endpoint, when the user's message references a journal entry with a photo, include it as an `image` content block in the API call
- Consider cost: only send the most recent photo (not all 5 journal entries' photos) to keep token usage reasonable
