---
description: "Initialize Synapse local workspace state, context, and memory in the current project"
---
Initialize the Synapse multi-agent workspace in this repository:

1. **Locate Workspace Root:** Determine repository root using `git rev-parse --show-toplevel` or current working directory.
2. **Scaffold Local State & Memory:**
   - Create `.synapse/` directory in the repository root.
   - Scaffold `.synapse/state.json` containing current timestamp, active objective, blockers, next action, and active agent.
   - Scaffold `.synapse/context.md` with project architecture, active database schemas, and stack profile.
   - Scaffold `.synapse/handoff.md` with standard 6-section session tracking template.
   - Scaffold `.synapse/active-roadmap.md` with milestone checklist.
   - Scaffold `.synapse/memory/project-decisions.md` and `.synapse/memory/project-quirks.md`.
   - Scaffold `.synapse/local-rules/` for project-specific rules.
3. **Configure Git Hygiene:**
   - Verify `.gitignore` ignores ephemeral scratch files (`.synapse/state/*.tmp.md`, `.synapse/scratch-*`).
   - Ensure `.synapse/state.json`, `.synapse/context.md`, `.synapse/handoff.md`, and `.synapse/memory/` remain tracked in Git.
4. **Confirm Initialization:** Print a summary of created files and instruct the user to run `/resume` to begin active development.
