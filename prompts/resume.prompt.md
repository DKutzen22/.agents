---
description: "Session continuity workflow: inspect blockers, state.json/handoff.md, and confirm immediate next actions"
---
Execute the Synapse session resume protocol:

1. Locate workspace root (`git rev-parse --show-toplevel`).
2. Read project state from `.synapse/state.json` or `.synapse/handoff.md` (fallback to `.agents/state/handoff.md` if present).
   - If no state directory exists, prompt to run `/synapse-init`.
3. Inspect `git status -sb` for uncommitted or untracked changes.
4. Output a maximum 5-bullet executive briefing:
   - Current Objective
   - Last Completed Work
   - Active Blockers / Issues
   - Uncommitted Changes
   - Immediate Next Action
5. Await user confirmation before altering any code or documents.
