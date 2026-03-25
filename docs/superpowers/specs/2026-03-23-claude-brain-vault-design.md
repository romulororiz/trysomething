# Claude Brain Vault — Design Spec

> Persistent, global knowledge vault that gives Claude "infinite" memory across sessions and context compressions.

**Date:** 2026-03-23
**Status:** Approved
**Scope:** Global (all projects, user-level)

---

## Problem

Claude Code loses all context when:
1. Context compression kicks in during long sessions (most common)
2. Sessions end (terminal closed, new `claude` command)

The current auto-memory system (`~/.claude/projects/*/memory/`) is project-scoped, has a 200-line index limit, and relies on in-context instructions to trigger reads/writes. It helps across sessions but doesn't survive mid-session compression well.

## Solution

An external markdown vault at `~/.claude/brain/` exposed to Claude via MCPVault MCP server, with a SessionStart hook for automatic context loading and CLAUDE.md instructions for proactive write-through behavior.

### Design Principles

- **Write-through, not write-back** — Claude persists knowledge as it happens, not at session end
- **Search, don't load** — Claude searches for relevant notes, never loads the entire vault
- **Atomic notes** — One topic per note, well-tagged, for precise retrieval
- **Human-readable** — Plain markdown with YAML frontmatter, browsable in any editor or Obsidian
- **Additive** — Doesn't replace existing memory system; works alongside it

---

## Architecture

```
┌──────────────────────┐
│  Claude Code Session │
│                      │
│  SessionStart Hook   │──► Injects vault awareness + project name
│         │            │
│         ▼            │
│  Claude loads        │──► mcp__brain__read_note(_index.md)
│  relevant context    │    mcp__brain__search_notes(project tags)
│         │            │
│         ▼            │
│  Normal work         │──► Reads/writes vault as needed via MCP
│                      │
│  Context compresses  │──► Vault notes survive (external files)
│         │            │
│  Claude re-reads     │──► mcp__brain__search_notes(topic)
│  vault as needed     │    Recovers compressed-away context
└──────────────────────┘
         │
         ▼  mcp__brain__* tools
┌──────────────────────────────────────────┐
│  C:\Users\rmulororiz\.claude\brain\      │
│                                          │
│  _index.md            Master map         │
│  _inbox.md            Quick capture      │
│  user/profile.md      User identity      │
│  user/workflow.md     Work preferences   │
│  projects/*.md        Per-project state  │
│  patterns/*.md        Reusable knowledge │
│  decisions/*.md       ADRs               │
│  feedback/*.md        Corrections        │
│  references/*.md      External pointers  │
│  sessions/*.md        Session summaries  │
└──────────────────────────────────────────┘
```

---

## Components

### 1. Vault Directory (`~/.claude/brain/`)

Plain markdown files with YAML frontmatter:

```markdown
---
title: Note Title
type: user|project|pattern|decision|feedback|reference|session
tags: [tag1, tag2, project-name]
created: 2026-03-23
updated: 2026-03-23
---

Content here...
```

#### Folder Structure

| Folder | Purpose | Example |
|--------|---------|---------|
| `user/` | Identity, preferences, workflow rules | `profile.md`, `workflow.md` |
| `projects/` | Per-project state, decisions, blockers | `trysomething.md` |
| `patterns/` | Reusable technical knowledge | `flutter-riverpod-gotcha.md` |
| `decisions/` | Architecture Decision Records | `2026-03-auth-jwt.md` |
| `feedback/` | Corrections and confirmed approaches | `deploy-authorization.md` |
| `references/` | External resource pointers | `neon-dashboard.md` |
| `sessions/` | Optional date-stamped session summaries | `2026-03-23.md` |

#### Special Files

- `_index.md` — Master table of contents with `[[wikilinks]]`. Claude reads this first every session.
- `_inbox.md` — Quick-capture scratchpad for mid-session dumps when a note doesn't fit a category yet.

### 2. MCP Server (MCPVault)

**Package:** `@bitbonsai/mcpvault` (npm, runs via npx)
**Scope:** User-level (global, all projects)
**Registration:** `claude mcp add brain --scope user npx @bitbonsai/mcpvault C:\Users\rmulororiz\.claude\brain`

**14 tools exposed:**

| Tool | Use |
|------|-----|
| `read_note` | Read specific note by path |
| `write_note` | Create/overwrite (modes: overwrite, append, prepend) |
| `patch_note` | Surgical edits |
| `search_notes` | BM25 keyword search across vault |
| `get_frontmatter` | Read metadata without full content |
| `update_frontmatter` | Update tags, dates, type |
| `manage_tags` | Add/remove/list tags |
| `list_directory` | Browse folders |
| `read_multiple_notes` | Batch read |
| `get_vault_stats` | Note count, size overview |
| `get_notes_info` | Metadata overview of multiple notes |
| `delete_note` | Remove (requires confirmation) |
| `move_note` | Rename/relocate |
| `move_file` | Move non-markdown files |

**Permission:** `mcp__brain__*` added to settings.json allow list.

### 3. SessionStart Hook (`~/.claude/hooks/brain-session-start.js`)

Node.js script that:
1. Reads `process.cwd()` to detect current project directory name
2. Outputs instructions for Claude to load vault context
3. Runs alongside existing GSD hooks — added as a second entry in the `SessionStart` array

**Exact settings.json change:**

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

A separate entry (not nested inside the GSD hook entry) ensures error isolation — if one hook fails, the other still runs.

Output format:
```
[Brain Vault] Project: trysomething
Load context: search brain for "trysomething", read _index.md, user/profile.md, user/workflow.md
```

### 4. Global CLAUDE.md Section (Exact Text)

The following section is appended to `~/.claude/CLAUDE.md`. This is the core behavioral driver — it tells Claude when and how to use the vault:

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

## Compression Recovery

Context compression is the most common memory-loss event. The brain vault mitigates it, but Claude needs to **know when and how** to recover.

### How Claude Detects Compression

There is no programmatic "compression happened" hook. Instead, the CLAUDE.md instructions tell Claude to search the vault in these situations:

1. **User says "I already told you" / "we discussed this" / "remember when"** — immediate vault search
2. **Claude notices a gap** — if it can't recall details about a topic it should know, search the vault
3. **User re-explains something** — signal that context was lost, search vault for prior notes
4. **Claude is uncertain about a prior decision** — search `decisions/` and `feedback/`

### Why This Is Best-Effort, Not Guaranteed

- The SessionStart hook fires once per session, not on compression
- After compression, Claude retains a summary — if the summary mentions the vault, Claude is more likely to use it
- The CLAUDE.md instructions survive compression (they're re-injected by the system)
- Worst case: user says "check the brain" and Claude recovers

This is an honest limitation. The vault ensures knowledge is **never truly lost** — but Claude may need a nudge to look for it after heavy compression.

---

## Vault Maintenance

### Growth Management

Over months, the vault will accumulate notes. Guidelines to keep it performant:

| Folder | Retention | Action |
|--------|-----------|--------|
| `sessions/` | Last 30 days | Claude or user prunes older entries periodically |
| `_inbox.md` | Triage weekly | Move items to proper folders or delete |
| `projects/` | Active projects only | Archive completed projects to `projects/_archive/` |
| All others | Indefinite | These are knowledge — keep them |

### `_index.md` Size Limit

- Keep `_index.md` under 150 lines (~50 notes listed)
- If it grows beyond that, split into sub-indices: `_index-projects.md`, `_index-patterns.md`
- Claude should use `search_notes` for discovery rather than relying solely on the index

### BM25 Search Performance

MCPVault's BM25 search scans all files on each query. Practical ceiling is ~500-1000 notes before search latency becomes noticeable. For a single developer's knowledge vault, this is unlikely to be reached for years.

### Vault Integrity

- MCPVault's `delete_note` requires confirmation — accidental deletion is unlikely
- No automatic backup is configured. **Recommendation:** the user can optionally `git init` the brain directory for version history

---

## Concurrency

### Multiple Simultaneous Sessions

If two Claude Code sessions are open (e.g., two terminals, two projects), both connect to the same vault via separate MCPVault instances.

**Risk:** Two sessions writing to the same note simultaneously could cause data loss (last write wins).

**Mitigation:**
- MCPVault operates on the filesystem with standard file I/O — no file locking
- **Atomic notes reduce collision probability** — two sessions working on different projects write to different `projects/` files
- `user/profile.md` and `user/workflow.md` are read-heavy, rarely written simultaneously
- `_inbox.md` uses append mode, which is lower-risk for concurrent writes

**Accepted limitation:** Simultaneous writes to the same note file may cause last-write-wins. This is an edge case for a single developer workflow and is not worth the complexity of a locking mechanism.

---

## Migration Plan

One-time migration of existing memories into the vault:

| Source | Destination |
|--------|-------------|
| `memory/MEMORY.md` (TrySomething context) | `brain/projects/trysomething.md` |
| `memory/feedback_deploy_authorization.md` | `brain/feedback/deploy-authorization.md` |
| Global CLAUDE.md "About Me" + "Tech Stacks I Use" | `brain/user/profile.md` |
| Global CLAUDE.md "General Coding Preferences" + "Do NOT" | `brain/user/workflow.md` |

**Note:** Only 2 files exist in the current `memory/` directory (`MEMORY.md` and `feedback_deploy_authorization.md`). Both are migrated. The Glob scan confirms no other memory files exist.

Existing memory system continues to work in parallel. No breaking changes.

---

## What This Doesn't Solve

| Gap | Why | Existing Mitigation |
|-----|-----|---------------------|
| Active task state ("I'm editing file X line 47") | Real-time working memory, not knowledge | GSD plans + TaskCreate |
| Multi-step refactor progress | Sequential task state | GSD execute-phase |
| Conversation flow nuance | Compression summarizes | Claude re-reads vault notes (best-effort) |

---

## Files Changed

| File | Change |
|------|--------|
| `~/.claude/settings.json` | Add `brain` MCP server config + `mcp__brain__*` permission |
| `~/.claude/CLAUDE.md` | Append "Brain Vault" section |
| `~/.claude/hooks/brain-session-start.js` | New file — SessionStart hook |
| `~/.claude/brain/` | New directory — full vault structure with seed notes |

## Files NOT Changed

- Project-scoped `memory/` directories
- Project CLAUDE.md files
- Existing hooks (GSD)
- Existing MCP servers (Neon, Vercel, RevenueCat, Playwright, etc.)

---

## Success Criteria

1. `claude mcp list` shows `brain` server with 14 tools
2. Starting a new Claude Code session in any directory → hook fires → Claude reads vault
3. Claude can `search_notes("trysomething")` and find the migrated project note
4. Claude can `write_note("patterns/test.md", ...)` and the file appears on disk
5. In a new session (simulating full context loss), Claude can recover project-specific details by searching the vault without any prior conversation context
6. Brain vault works identically whether in `C:\dev\trysomething\` or any other project directory
