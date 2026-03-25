# Claude Brain Vault — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up a persistent global markdown vault with MCP integration that gives Claude "infinite" memory across sessions and context compressions.

**Architecture:** MCPVault MCP server exposes a `~/.claude/brain/` directory of markdown notes via 14 tools (read, write, search, tags). A SessionStart hook auto-injects project context, and CLAUDE.md instructions drive proactive read/write behavior.

**Tech Stack:** Node.js (npx), `@bitbonsai/mcpvault`, Claude Code hooks, markdown with YAML frontmatter.

**Spec:** `docs/superpowers/specs/2026-03-23-claude-brain-vault-design.md`

---

## File Map

| Action | Path | Purpose |
|--------|------|---------|
| Create | `~/.claude/brain/_index.md` | Master table of contents |
| Create | `~/.claude/brain/_inbox.md` | Quick-capture scratchpad |
| Create | `~/.claude/brain/user/profile.md` | User identity + tech stacks |
| Create | `~/.claude/brain/user/workflow.md` | Work preferences + rules |
| Create | `~/.claude/brain/projects/trysomething.md` | Migrated project context |
| Create | `~/.claude/brain/feedback/deploy-authorization.md` | Migrated feedback |
| Create | `~/.claude/brain/patterns/.gitkeep` | Empty dir placeholder |
| Create | `~/.claude/brain/decisions/.gitkeep` | Empty dir placeholder |
| Create | `~/.claude/brain/references/.gitkeep` | Empty dir placeholder |
| Create | `~/.claude/brain/sessions/.gitkeep` | Empty dir placeholder |
| Create | `~/.claude/hooks/brain-session-start.js` | SessionStart hook script |
| Modify | `~/.claude/settings.json` | Add hook + MCP permission |
| Modify | `~/.claude/CLAUDE.md` | Append Brain Vault section |

---

### Task 1: Create Vault Directory Structure

**Files:**
- Create: `~/.claude/brain/` and all subdirectories
- Create: `.gitkeep` files for empty directories

- [ ] **Step 1: Create all vault directories**

```bash
mkdir -p C:/Users/rmulororiz/.claude/brain/user
mkdir -p C:/Users/rmulororiz/.claude/brain/projects
mkdir -p C:/Users/rmulororiz/.claude/brain/patterns
mkdir -p C:/Users/rmulororiz/.claude/brain/decisions
mkdir -p C:/Users/rmulororiz/.claude/brain/feedback
mkdir -p C:/Users/rmulororiz/.claude/brain/references
mkdir -p C:/Users/rmulororiz/.claude/brain/sessions
```

- [ ] **Step 2: Create .gitkeep files for empty directories**

```bash
touch C:/Users/rmulororiz/.claude/brain/patterns/.gitkeep
touch C:/Users/rmulororiz/.claude/brain/decisions/.gitkeep
touch C:/Users/rmulororiz/.claude/brain/references/.gitkeep
touch C:/Users/rmulororiz/.claude/brain/sessions/.gitkeep
```

- [ ] **Step 3: Verify directory structure**

```bash
find C:/Users/rmulororiz/.claude/brain -type f -o -type d | sort
```

Expected: 10 directories + 4 `.gitkeep` files.

---

### Task 2: Create Seed Notes — _index.md and _inbox.md

**Files:**
- Create: `~/.claude/brain/_index.md`
- Create: `~/.claude/brain/_inbox.md`

- [ ] **Step 1: Create _index.md**

Write to `C:\Users\rmulororiz\.claude\brain\_index.md`:

```markdown
---
title: Brain Index
type: reference
tags: [index, brain, master-map]
updated: 2026-03-23
---

# Claude Brain — Index

## User
- [[user/profile]] — Role, goals, tech stacks, preferences
- [[user/workflow]] — How to collaborate, rules, what to avoid

## Projects
- [[projects/trysomething]] — Flutter hobby app, current main project

## Feedback
- [[feedback/deploy-authorization]] — Never push/deploy without asking

## Patterns
(none yet — grows organically)

## Decisions
(none yet)

## References
(none yet)
```

- [ ] **Step 2: Create _inbox.md**

Write to `C:\Users\rmulororiz\.claude\brain\_inbox.md`:

```markdown
---
title: Inbox
type: reference
tags: [inbox, triage]
created: 2026-03-23
updated: 2026-03-23
---

# Inbox

Quick-capture scratchpad. Items here should be triaged into proper folders.

---
```

---

### Task 3: Migrate Existing Memories — User Notes

**Files:**
- Create: `~/.claude/brain/user/profile.md`
- Create: `~/.claude/brain/user/workflow.md`
- Source: `~/.claude/CLAUDE.md` (sections: "About Me", "Tech Stacks I Use", "General Coding Preferences", "Do NOT")

- [ ] **Step 1: Create user/profile.md**

Write to `C:\Users\rmulororiz\.claude\brain\user\profile.md`:

```markdown
---
title: Romulo — User Profile
type: user
tags: [user, profile, identity]
created: 2026-03-23
updated: 2026-03-23
---

# User Profile

## About
- Data Center Technician at Microsoft (ZRH24/ZRH26, Zurich area)
- Side projects: app development, automation, generative content
- Based in Niederglatt ZH, Switzerland

## Tech Stacks
- **Web**: Next.js 14+, TypeScript, Tailwind, Supabase
- **Mobile**: Flutter, Dart
- **Automation**: Python, Claude API, Make.com
- **Data/Tooling**: Python, openpyxl, pandas
```

- [ ] **Step 2: Create user/workflow.md**

Write to `C:\Users\rmulororiz\.claude\brain\user\workflow.md`:

```markdown
---
title: Workflow Preferences
type: user
tags: [user, workflow, preferences, rules]
created: 2026-03-23
updated: 2026-03-23
---

# Workflow Preferences

## Coding Style
- TypeScript strict mode preferred
- Tailwind CSS for styling (no CSS modules)
- Functional components with hooks (React)
- Small, focused files — one component per file
- Descriptive variable names, minimal comments (code should be self-explanatory)
- Always handle errors explicitly

## Git Conventions
- Conventional commits: feat:, fix:, chore:, docs:, refactor:
- One logical change per commit
- Never force push, never push to main directly

## Do NOT
- git push (user pushes manually after review)
- Modify migration files unless explicitly asked
- Install new major dependencies without mentioning it
- Over-engineer — keep it simple, ship it, iterate later
```

---

### Task 4: Migrate Existing Memories — Project + Feedback Notes

**Files:**
- Create: `~/.claude/brain/projects/trysomething.md`
- Create: `~/.claude/brain/feedback/deploy-authorization.md`
- Source: `~/.claude/projects/C--dev-trysomething/memory/MEMORY.md`
- Source: `~/.claude/projects/C--dev-trysomething/memory/feedback_deploy_authorization.md`

- [ ] **Step 1: Create projects/trysomething.md**

Write to `C:\Users\rmulororiz\.claude\brain\projects\trysomething.md`:

```markdown
---
title: TrySomething Project Context
type: project
tags: [trysomething, flutter, mobile, revenuecat, hobby-app]
created: 2026-03-23
updated: 2026-03-23
---

# TrySomething

Flutter hobby discovery app for overwhelmed adults. 30-day guided start.

## Stack
Flutter + Node.js/Express (TS) on Vercel + Neon Postgres + Prisma

## Auth
Email + password + Google sign-in (JWT)

## Production Roadmap (approved Feb 2026)
See full plan: `.claude/plans/elegant-tickling-yao.md`
8 Batches: Foundation > Auth > Content API > User Progress > Tools > Social > Gamification > Polish

### Current Phase: Batch 1 — Foundation
- Server project scaffolding (trysomething-api/, Prisma, Neon)
- Flutter repository pattern + Dio/Hive init
- Model serialization (fromJson/toJson)
- Extract IconData/Color from models → category_ui_mapping.dart

## UI Patterns
- Category pills: sand bg, no border, driftwood text, icon keeps catColor
- Image overlay badges (my_stuff cards): colored bg + white text (for contrast on photos)
- Bottom nav: local fork of curved_navigation_bar in `lib/components/curved_nav/`, height=85px
- **ALWAYS account for 85px nav bar height** when positioning bottom elements (CTAs, FABs, content shelves). Use bottom offsets of at least 100px+ for elements that must clear the nav. Bottom sheets need `viewInsets.bottom + 100` padding. Scroll content uses `Spacing.scrollBottomPadding` (120px).
- Dark theme: "Warm Cinematic Minimalism" — background=#0A0A0F, textPrimary=#F5F0EB (warm cream), textSecondary=#B0A89E, textMuted=#6B6360
- Glass surfaces: glassBackground (white 8%), glassBorder (white 12%)
- ONE accent: coral (#FF6B6B) for CTAs ONLY. All category colors neutralized to textMuted.
- Typography: hero 36pt / display 28pt / title 20pt / body 15pt / caption 12pt / overline 11pt / data 13pt / dataLarge 48pt / button 16pt
- Legacy color/typography names preserved as aliases — use new semantic names for new code
- `defaultTargetPlatform` used instead of `dart:io Platform` for web compatibility
- v3 nav: 3 tabs — Home/Discover/You (Sprint B restructure)

## Key Files
- `lib/theme/app_colors.dart` — All color tokens
- `lib/models/seed_data.dart` — Current data source (will become offline fallback)
- `lib/providers/hobby_provider.dart` — Central provider (will become async in Batch 3)
- `lib/providers/user_provider.dart` — User state (SharedPrefs, will sync to server in Batch 2)

## Workflow
- After each task: stage + commit using /commit-master, but ALWAYS ask user before committing
- For UI/UX work: always invoke /flutter-expert and /ui-ux-pro-max skills
- Current sprint: C (Visual Overhaul — Warm Cinematic Minimalism)
```

- [ ] **Step 2: Create feedback/deploy-authorization.md**

Note: The source file uses `name:` and `description:` frontmatter fields. We deliberately convert to the vault's `title:` / `type:` / `tags:` convention. Content is preserved 1:1.

Write to `C:\Users\rmulororiz\.claude\brain\feedback\deploy-authorization.md`:

```markdown
---
title: Deploy Authorization Required
type: feedback
tags: [feedback, git, deploy, authorization]
created: 2026-03-23
updated: 2026-03-23
---

# Deploy Authorization

Never push to git remote or deploy to Vercel without explicit user authorization.

**Why:** User explicitly requested this to avoid accidental deploys breaking production.

**How to apply:** After finishing code changes, stage and commit locally, then ASK before running `git push` or `vercel --prod`.
```

---

### Task 5: Create SessionStart Hook

**Files:**
- Create: `~/.claude/hooks/brain-session-start.js`

- [ ] **Step 1: Write the hook script**

Write to `C:\Users\rmulororiz\.claude\hooks\brain-session-start.js`:

```javascript
#!/usr/bin/env node

// Brain Vault — SessionStart Hook
// Outputs project context for Claude to load vault notes

const path = require("path");

const cwd = process.cwd();
const projectName = path.basename(cwd);

const output = [
  `[Brain Vault] Project directory: ${projectName}`,
  `Working path: ${cwd}`,
  "",
  "You have a persistent brain vault. At session start:",
  `1. Read _index.md for your memory map`,
  `2. Read user/profile.md and user/workflow.md for user preferences`,
  `3. Search for notes tagged with "${projectName}"`,
  "4. Briefly tell the user what context you loaded",
].join("\n");

process.stdout.write(output);
```

- [ ] **Step 2: Verify the hook runs**

```bash
node C:/Users/rmulororiz/.claude/hooks/brain-session-start.js
```

Expected output:
```
[Brain Vault] Project directory: trysomething
Working path: C:\dev\trysomething
...
```

---

### Task 6: Install MCPVault MCP Server

**Dependencies:** `@bitbonsai/mcpvault` (npm, via npx — no global install needed)

- [ ] **Step 1: Verify mcpvault package is accessible**

```bash
npm view @bitbonsai/mcpvault version
```

Expected: A version number (e.g., `0.11.x`). If this fails, check npm registry access.

- [ ] **Step 2: Back up settings.json before any modifications**

```bash
cp C:/Users/rmulororiz/.claude/settings.json C:/Users/rmulororiz/.claude/settings.json.bak
```

- [ ] **Step 3: Register MCPVault as user-scoped MCP server**

```bash
claude mcp add brain --scope user -- npx @bitbonsai/mcpvault "C:\Users\rmulororiz\.claude\brain"
```

Note: `--` separates `claude mcp add` flags from the MCP server command. No `@latest` tag — npx resolves latest by default.

- [ ] **Step 4: Verify MCP server is registered**

```bash
claude mcp list
```

Expected: `brain` server listed.

- [ ] **Step 5: Read settings.json to see what `claude mcp add` changed**

Read `C:\Users\rmulororiz\.claude\settings.json` to check:
- Whether an `mcpServers` key was added (and its exact structure)
- Whether any permissions were auto-added for `mcp__brain__*`

This informs what Task 7 still needs to do.

---

### Task 7: Update settings.json — Hook + Permissions

**Files:**
- Modify: `~/.claude/settings.json`

**Important:** Read settings.json first (after Task 6 modified it) to avoid duplicating anything `claude mcp add` already wrote.

- [ ] **Step 1: Add brain-session-start.js to SessionStart hooks**

In `C:\Users\rmulororiz\.claude\settings.json`, add a second entry to the `SessionStart` array:

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "node \"C:/Users/rmulororiz/.claude/hooks/brain-session-start.js\""
    }
  ]
}
```

The full `SessionStart` array should be:
```json
"SessionStart": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "node \"C:/Users/rmulororiz/.claude/hooks/gsd-check-update.js\""
      }
    ]
  },
  {
    "hooks": [
      {
        "type": "command",
        "command": "node \"C:/Users/rmulororiz/.claude/hooks/brain-session-start.js\""
      }
    ]
  }
]
```

- [ ] **Step 2: Add mcp__brain__* permission to allow list (if not already present)**

Check if `claude mcp add` already added brain permissions. If not, add `"mcp__brain__*"` to the `permissions.allow` array in settings.json. Do not create duplicates.

- [ ] **Step 3: Verify settings.json is valid JSON**

```bash
node -e "JSON.parse(require('fs').readFileSync('C:/Users/rmulororiz/.claude/settings.json','utf8')); console.log('Valid JSON')"
```

Expected: `Valid JSON`

---

### Task 8: Append Brain Vault Section to Global CLAUDE.md

**Files:**
- Modify: `~/.claude/CLAUDE.md`

- [ ] **Step 1: Append the Brain Vault section**

Append the following to the end of `C:\Users\rmulororiz\.claude\CLAUDE.md`:

```markdown

## Brain Vault — Persistent Memory

You have a persistent brain vault at `C:\Users\rmulororiz\.claude\brain\` accessible via `mcp__brain__*` tools.
This vault survives context compression and session boundaries. USE IT.

### Session Start Protocol
At the START of every session, before doing anything else:
1. Use `mcp__brain__read_note` to read `_index.md` — this is your memory map
2. Use `mcp__brain__read_note` to read `user/profile.md` and `user/workflow.md`
3. Use `mcp__brain__search_notes` to find notes tagged with the current project name
4. Briefly mention to the user what context you loaded

### When to Read the Vault
- **After context compression** — if you notice gaps in your memory, or the user says "I already told you" / "we discussed this", IMMEDIATELY search the vault. Compression deletes your in-context memory but the vault is untouched.
- **Before making architectural decisions** — search `decisions/` and `patterns/` first
- **When the user asks "do you remember" / "recall" / "what do you know about"** — search the vault
- **When working in an unfamiliar area** — search vault for related patterns or prior context

### When to Write to the Vault
Write IMMEDIATELY when the event happens — do not batch or defer:
- **User corrects your approach** → `mcp__brain__write_note` to `feedback/<topic>.md`
- **You discover a reusable pattern** → `patterns/<topic>.md`
- **An architecture decision is made** → `decisions/<date>-<topic>.md`
- **You learn new project context** → update existing `projects/<name>.md` or create new
- **User shares a preference or workflow rule** → update `user/profile.md` or `user/workflow.md`
- **You find a useful external resource** → `references/<topic>.md`
- **Anything else worth remembering** → append to `_inbox.md` for later triage

### Frontmatter Convention
Every note MUST have this YAML frontmatter:
```
---
title: Descriptive Title
type: user|project|pattern|decision|feedback|reference|session
tags: [relevant, keywords, project-name]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### Writing Rules
- One topic per note (atomic notes)
- Always tag with the current project name
- Update existing notes rather than creating duplicates — search first
- Update `_index.md` when adding new notes
- Keep notes concise — facts and decisions, not conversation transcripts
- Use `write_note` with mode "append" to add to existing notes
- Update the `updated` date in frontmatter when modifying notes
```

---

### Task 9: Smoke Test

- [ ] **Step 1: Verify vault files exist**

```bash
find C:/Users/rmulororiz/.claude/brain -name "*.md" | sort
```

Expected: `_inbox.md`, `_index.md`, `feedback/deploy-authorization.md`, `projects/trysomething.md`, `user/profile.md`, `user/workflow.md`

- [ ] **Step 2: Verify hook outputs correctly**

```bash
cd C:/dev/trysomething && node C:/Users/rmulororiz/.claude/hooks/brain-session-start.js
```

Expected: Output containing `Project directory: trysomething`

- [ ] **Step 3: Verify MCP server starts**

```bash
claude mcp list
```

Expected: `brain` server listed

- [ ] **Step 4: Verify settings.json is valid**

```bash
node -e "const s = JSON.parse(require('fs').readFileSync('C:/Users/rmulororiz/.claude/settings.json','utf8')); console.log('hooks:', s.hooks.SessionStart.length, 'perms:', s.permissions.allow.includes('mcp__brain__*'))"
```

Expected: `hooks: 2 perms: true`

- [ ] **Step 5: Verify CLAUDE.md has brain section**

```bash
grep -c "Brain Vault" C:/Users/rmulororiz/.claude/CLAUDE.md
```

Expected: `1` or more matches
