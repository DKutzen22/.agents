---
description: >
  Enforces session continuity: requires checking state.json/handoff.md before
  initiating multi-file changes or architecture modifications.
applyTo: "src/**, lib/**, pkg/**, app/**, cmd/**, scripts/**, test/**, tests/**"
globs: "src/**, lib/**, pkg/**, app/**, cmd/**, scripts/**, test/**, tests/**"
---

# State Continuity & Handoff Awareness

## Session Alignment Gate

Before executing multi-file edits, refactoring, or planning complex tasks:
1. **Check for Handoff State:** Consult `.synapse/state.json` or `.synapse/handoff.md` (or `.agents/state/handoff.md` if present) in the active workspace root. If neither exists, prompt the user to run `/synapse-init`.
2. **Review Current Status:**
   - Confirm active objective and branch alignment.
   - Read blockers to avoid re-triggering known broken states.
   - Verify next concrete action to ensure the current prompt is aligned with recent progress.
3. **Check Active Milestones:** Check `.synapse/active-roadmap.md` (or `.agents/state/active-roadmap.md`) if planning tasks spanning multiple components.
4. **Prevent Context Drift:** If the user request contradicts the queued action in `state.json`/`handoff.md`, explicitly ask for clarification before modifying uncommitted files.
