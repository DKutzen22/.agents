# State Directory Guide (for Maintainers)

This directory maintains ephemeral session memory and active project milestone tracking
to ensure seamless continuation between AI agent work sessions.

## What Belongs Here vs. What Doesn't
* **Belongs:** Overwrite-only session handoffs (`state/handoff.md`, hard-capped at 50 lines) and active milestone checklists (`state/active-roadmap.md`).
* **Doesn't Belong:** Historical session transcripts, permanent documentation, commit logs, or unpruned scratch files.

## File Templates & Lifecycle
Files in this directory are **overwrite-only** or actively pruned. They must not grow indefinitely.

```markdown
# Session Handoff State

## Active Repo & Branch
* **Repo:** /path/to/repo
* **Branch:** main

## Current Objective
High-level task description.

## Completed This Session
- Key deliverables landed.

## Blockers / Failing Checks
- None or active errors.

## Next Concrete Action
Immediate next step for the next turn.

## Modified Files
- File paths changed.
```

## How & When Agents Touch These Files
* Read on session initialization via `/resume` or `instructions/state-continuity.instructions.md`.
* Overwritten cleanly upon session completion via `/handoff`.
* **Important:** This folder is kept **repo-local** and is never symlinked globally.
