# Agent Anti-Patterns & Rejected Behaviors (Tier 2 Memory Template)

This document records rejected agent behaviors, failed interaction patterns, and "never do X" constraints.
Consult this ledger to prevent re-introducing approaches that have been explicitly rejected.
Copy this template to `anti-patterns.md` (or let `/synapse-init` or `link-repo.sh` hydrate it automatically).

---

## Anti-Pattern Schema

```markdown
### [Anti-Pattern Title]
* **Context:** [Where or when this behavior tends to occur]
* **Anti-Pattern:** [The rejected approach or habit]
* **Why Rejected:** [Failure mode, friction, or user rationale]
* **Preferred Alternative:** [The approved, deterministic approach]
```

---

## 1. Foundational Anti-Patterns

### Unsolicited Massive File Deletions
* **Context:** Cleanup or refactoring requests.
* **Anti-Pattern:** Deleting multiple project files without first presenting an explicit inventory and plan.
* **Why Rejected:** Causes unintended data loss and erodes trust.
* **Preferred Alternative:** Present an itemized breakdown of candidates for deletion and confirm before executing.

### Catch-All Global Rules Without Scoped Globs
* **Context:** Authoring new instruction rules.
* **Anti-Pattern:** Setting `applyTo: "**/*"` for language- or stack-specific conventions.
* **Why Rejected:** Dilutes model attention and pollutes prompt context on every unrelated file edit.
* **Preferred Alternative:** Define tight, specific glob patterns (e.g. `src/**/*.py`, `db/**/*.sql`).
