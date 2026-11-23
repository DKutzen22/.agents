# Memory Directory Guide (for Maintainers)

This directory serves as the repository's long-term empirical memory, architectural
decision ledger, and cross-project user preferences.

## 3-Tier Memory Architecture
* **Tier 1 (Framework & Governance):** Standard rules in `instructions/` and canonical specs in `context/`.
* **Tier 2 (User Preferences & Anti-Patterns):** Central cross-project starter templates in [`user-profile.template.md`](./user-profile.template.md), [`anti-patterns.template.md`](./anti-patterns.template.md), [`tool-quirks.template.md`](./tool-quirks.template.md), and [`architecture-decisions.template.md`](./architecture-decisions.template.md). Active instances (`*.md`) are hydrated automatically upon `/synapse-init` or `link-repo.sh` execution.
* **Tier 3 (Project-Local Memory):** Repository-specific quirks and decisions stored in consumer `.synapse/memory/` (or `.agents/memory/`).

## Archiving & Compaction
Historical or superseded quirks are compacted non-destructively into [`archive/`](./archive/README.md) to keep active memory files under token caps while maintaining an append-only audit trail.

## Entry Formats & Conventions
Files in this directory are strictly **append-only**. Never overwrite or delete prior entries.

## How & When Agents Touch These Files
* Agents read entries when gated by `instructions/memory-protocol.instructions.md`.
* Agents append new entries only when resolving a verified, non-obvious bug, capturing an anti-pattern, or documenting an agreed architecture decision via `/handoff` or `/harvest`.
