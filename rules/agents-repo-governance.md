---
trigger: glob
globs: ".agents/**, rules/**, skills/**, agents/**, context/**, memory/**, state/**, scripts/**"
description: >
  Enforces structural governance, lifecycle contracts, and token discipline
  defined in context/repo-governance-spec.md across all Synapse components.
---

# Synapse Repository Governance

## Spec Compliance & Lifecycle Contracts
Before creating or modifying any file in Synapse, consult @../context/repo-governance-spec.md.

1. **Context Protection (Read-Only):**
   - Files in `context/` are immutable technical reference specifications.
   - Do NOT edit or overwrite `context/` files unless the user explicitly requests a spec or schema migration.

2. **State Hygiene (Overwrite-Only):**
   - `state/handoff.md` is strictly overwrite-only (never append). Keep under 50 lines using the 6 standard headers.
   - Keep `state/active-roadmap.md` lean by pruning completed milestones.

3. **Memory Discipline (Append-Only):**
   - Do NOT bloat global `rules/` with tool quirks, version discrepancies, or one-off workarounds.
   - Push empirical findings to @../memory/bioinfo-tool-quirks.md and major design shifts to @../memory/architecture-decisions.md.
   - Check for existing entries before appending to prevent duplication.

4. **Skills & Scripts Structure:**
   - All workflows and playbooks live in `skills/<kebab-name>/SKILL.md`. No top-level `commands/` directory.
   - Scripts in `scripts/` must be executable (`chmod +x`), implement `--help`, and require zero external dependencies (POSIX `sh` or Python 3 stdlib only).

5. **Lifecycle Hooks & Manifests:**
   - Antigravity lifecycle hooks in `hooks.json` enforce context protection (`PreToolUse`) and script/handoff validation (`PostToolUse`).
   - Discovery manifests (`rules.json`, `skills.json`, `agents.json`) enable seamless configuration inheritance across target repositories.
