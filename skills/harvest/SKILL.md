---
name: harvest
description: >
  Command entrypoint to harvest session lessons. Catches /harvest and delegates execution to the synthesist subagent.
---

# /harvest

User-facing command interface for extracting runtime lessons, bug workarounds, and architecture decisions from session logs into persistent memory.

> [!NOTE]
> **Dispatch Flow:** `/harvest` (Skill Entrypoint) $\longrightarrow$ [`agents/synthesist.md`](../../agents/synthesist.md) (Execution Worker).
> Skills trigger subagents; subagents never trigger skills.

## Execution Steps

### 1. Gather Session Context
Collect current workspace diff and handoff notes:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"
git status -sb
git diff --stat
```
Read `.synapse/handoff.md` (or `.agents/state/handoff.md` / `state/handoff.md`).

### 2. Delegate to Synthesist Subagent
Invoke the specialized **`synthesist`** subagent (`agents/synthesist.md`) with the gathered session context:
```text
Task: Audit session diffs and handoff notes to extract empirical tool quirks and ADRs.
Target Ledgers: memory/tool-quirks.md and memory/architecture-decisions.md.
Rules: Enforce append-only discipline and duplicate prevention (instructions/memory-discipline.instructions.md).
```

### 3. Subagent Execution Specifications
The `synthesist` executes the memory extraction:
- **Check for Existing Records:** Grep memory ledgers to prevent duplicate entries.
- **Append Tool Quirk:** Format with Quirk, Failure Mode, and Workaround into `memory/tool-quirks.md` (or `.synapse/memory/project-quirks.md`).
- **Append ADR:** Format with Status, Context, Decision, and Consequences into `memory/architecture-decisions.md` (or `.synapse/memory/project-decisions.md`).

### 4. Confirm Memory Synchronization
Report the harvested entries back to the user and confirm memory files are committed or staged.
