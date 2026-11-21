---
trigger: glob
globs: "**/R/**, **/workflow/**, **/src/**"
description: >
  Enforces session continuity: requires checking state/handoff.md before
  initiating multi-file changes or architecture modifications.
---

# State Continuity & Handoff Awareness

## Session Alignment Gate

Before executing multi-file edits, refactoring, or planning complex tasks:
1. **Check for Handoff State:** Consult @../state/handoff.md in the active workspace.
2. **Review Current Status:**
   - Inspect `## Active Repo & Branch` to confirm target workspace alignment.
   - Read `## Blockers / Failing Checks` to avoid re-triggering known broken states.
   - Verify `## Next Concrete Action` to ensure the current prompt is aligned with recent progress.
3. **Check Active Milestones:** Check @../state/active-roadmap.md if planning tasks spanning multiple components.
4. **Prevent Context Drift:** If the user request contradicts the queued `## Next Concrete Action` in `state/handoff.md`, explicitly ask for clarification before modifying uncommitted files.
