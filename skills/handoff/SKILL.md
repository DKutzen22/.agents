---
name: handoff
description: >
  Concludes work session: inspects git diff, overwrites state/handoff.md,
  updates state/active-roadmap.md, and prompts for memory logging.
  Trigger with /handoff or ask to end session / hand off context.
---

# /handoff

Capture session progress cleanly into ephemeral working memory for seamless continuation.

> [!NOTE]
> **Trigger:** Invoke directly via `/handoff` or ask to save session handoff.

## Execution Steps

### 1. Resolve Target Repo Root & Inspect Session Work
Always determine the target repository root first using git to ensure edits stay repo-local:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"
git status -sb
git diff --stat
```
Read and write session state exclusively to the consumer workspace:
- **Primary (APM):** `$REPO_ROOT/.synapse/state.json`, `$REPO_ROOT/.synapse/handoff.md`, `$REPO_ROOT/.synapse/active-roadmap.md`, `$REPO_ROOT/.synapse/memory/`
- **Fallback (Legacy Mount):** `$REPO_ROOT/.agents/state/handoff.md`, `$REPO_ROOT/.agents/state/active-roadmap.md`, `$REPO_ROOT/.agents/memory/`

**Never follow symlinks back to central templates or write to `apm_modules/`.**

### 2. Overwrite Local State (`state.json` / `handoff.md`)
**Completely overwrite** (do NOT append to) `.synapse/handoff.md` (or `.agents/state/handoff.md`) using the exact fixed schema (under 50 lines):
- `## Active Repo & Branch`: Current directory basename/relative path and `git rev-parse --abbrev-ref HEAD`.
- `## Current Objective`: High-level goal addressed during this session.
- `## Completed This Session`: Concrete tasks finished (e.g., rules written, tests passing).
- `## Blockers / Failing Checks`: Any unresolved bugs, lint errors, or failing tests.
- `## Next Concrete Action`: The single most specific, actionable next step for the next turn.
- `## Modified Files`: List of files modified or created during this session.

If `.synapse/state.json` exists, update its `last_session`, `objective`, `current_blockers`, and `next_action` properties synchronously.

### 3. Update Roadmap Checklist
- Inspect `.synapse/active-roadmap.md` (or `.agents/state/active-roadmap.md`).
- Mark completed milestones as `[x]`.
- Add any newly uncovered sub-milestones if necessary.

### 4. Check for Empirical Scar Tissue
Ask the user / verify:
> *"Were any non-obvious tool quirks (Pharokka/Phold/Phynteny/RSQLite/GenBank) or architectural decisions resolved this session that should be logged to `.synapse/memory/project-quirks.md` (or `.agents/memory/project-quirks.md`)?"*

If yes, append the formatted entry directly.

### 5. Report Completion
Print a concise summary confirming local state was overwritten and the next session is primed.
