---
title: Wire up quickstart flow with real data persistence
area: feature
created: 2026-03-27
---

The quickstart screen (budget choice, session length, schedule day/time) collects data but never saves it. Currently bypassed — "Start hobby" goes directly to home.

To restore:
1. Save session length preference → use as default timer duration
2. Save budget choice → filter starter kit (minimum vs best value)
3. Save schedule → create ScheduleEvent for reminders
4. Wire week 1 plan summary to actual roadmap steps

Files: `lib/screens/quickstart/quickstart_screen.dart`, router.dart route still exists at `/quickstart/:hobbyId`
