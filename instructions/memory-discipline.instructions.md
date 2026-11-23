---
description: >
  Enforces append-only discipline and duplicate prevention across all memory ledgers.
applyTo: "memory/**, .synapse/memory/**, .agents/memory/**"
globs: "memory/**, .synapse/memory/**, .agents/memory/**"
---

# Memory Discipline & Append-Only Contract

## Append-Only Invariant
All memory files (`architecture-decisions.md`, `tool-quirks.md`, `project-decisions.md`, `project-quirks.md`) are strictly append-only:
1. **Never Overwrite Historical Entries:** Existing ADRs or quirks represent accepted decisions and historical diagnosis. Do not edit, truncate, or rewrite existing entries.
2. **Duplicate Prevention:** Before appending an entry, search the file to confirm the quirk or decision has not already been documented.
3. **Structured Formats:**
   - Architectural decisions must follow the 5-point ADR schema: `Date`, `Status`, `Context`, `Decision`, and `Consequences`.
   - Tool quirks must follow the 3-point schema: `Quirk`, `Failure Mode`, and `Workaround`.
4. **Verified Evidence Only:** Never append speculative or unverified failure modes. Only log verified behaviors observed during active runs.
