---
description: >
  Enforces structural governance, lifecycle contracts, and token discipline
  defined in context/repo-governance-spec.md across all Synapse components.
applyTo: ".agents/**, rules/**, skills/**, agents/**, context/**, memory/**, state/**, scripts/**"
globs: ".agents/**, rules/**, skills/**, agents/**, context/**, memory/**, state/**, scripts/**"
---

# Synapse Repository Governance

## Spec Compliance & Lifecycle Contracts
Before creating or modifying any file in Synapse, consult `context/repo-governance-spec.md`.

1. **Context Protection (Read-Only):**
   - Files in `context/` are immutable technical reference specifications.
   - Do NOT edit or overwrite `context/` files unless explicitly executing a schema or spec migration.

2. **State Hygiene (Overwrite-Only):**
   - Active state files (`state.json`, `handoff.md`) are strictly overwrite-only.
   - Maintain the fixed 6 standard headers and keep handoffs under 50 lines.

3. **Memory Discipline (Append-Only):**
   - Do NOT bloat global instructions with single-project quirks or one-off workarounds.
   - Record tool findings in `memory/bioinfo-tool-quirks.md` and major architecture choices in `memory/architecture-decisions.md`.

4. **Skills & Prompts Structure:**
   - Slash workflows and prompts live in `prompts/*.prompt.md`.
   - Reusable domain playbooks reside in `skills/<kebab-name>/SKILL.md`.
   - Scripts in `scripts/` must be executable (`chmod +x`), implement `--help`, and require zero external dependencies.
