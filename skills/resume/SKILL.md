---
name: resume
description: >
  Resumes work session: inspects state/handoff.md, state/active-roadmap.md,
  and git status to summarize context and confirm the next action.
  Trigger with /resume or ask to resume session / pick up where left off.
---

# /resume

Resume an ongoing session with complete context continuity and zero guesswork.

> [!NOTE]
> **Trigger:** Invoke directly via `/resume` or ask to resume work / pick up current state.

## Execution Steps

### 1. Resolve Target Repo Root & Read Working State
Always determine the target repository root first using git to ensure state isolation:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"
```
Read the project-local state files directly from `$REPO_ROOT`:
- **Primary (APM):** `$REPO_ROOT/.synapse/state.json` and `$REPO_ROOT/.synapse/handoff.md`
- **Fallback (Legacy Mount):** `$REPO_ROOT/.agents/state/handoff.md` and `$REPO_ROOT/.agents/state/active-roadmap.md`

*If neither `.synapse/` nor `.agents/` state files exist, inform the user and suggest running `/synapse-init` to initialize project state.*

**Never follow symlinks back to the central template files or write into `apm_modules/`.**

### 2. Inspect Workspace Git Status
Run a concise git status check:
```bash
git status -sb
```
Identify any uncommitted changes, staged files, or untracked test artifacts.

### 3. Output Briefing (Maximum 5 Bullets)
Summarize current status concisely for the user:
* **Current Objective:** What the project is actively working toward.
* **Last Completed Work:** Most recent changes landed or verified.
* **Active Blockers / Issues:** Any failing checks or open problems (from `handoff.md`).
* **Uncommitted Changes:** Summary of files currently modified according to `git status`.
* **Immediate Next Action:** The exact queued task from `## Next Concrete Action`.

### 4. Await Confirmation
Ask the user:
> *"Ready to proceed with [Immediate Next Action], or would you like to pivot?"*

Do NOT edit any source code files until the user confirms or provides an updated directive.
