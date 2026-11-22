---
description: "Session closure workflow: summarize progress, update state.json/handoff.md, and record lessons"
---
Execute the Synapse session handoff protocol:

1. Locate workspace root (`git rev-parse --show-toplevel`).
2. Inspect session diff: `git status -sb` and `git diff --stat`.
3. Overwrite local `.synapse/state.json` and `.synapse/handoff.md` (or `.agents/state/handoff.md`) with the 6 canonical sections (under 50 lines):
   - Active Repo & Branch
   - Current Objective
   - Completed This Session
   - Blockers / Failing Checks
   - Next Concrete Action
   - Modified Files
4. Update `.synapse/active-roadmap.md` marking completed milestones.
5. Prompt if any non-obvious tool quirks or architectural decisions need logging in `.synapse/memory/`.
