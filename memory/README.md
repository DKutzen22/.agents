# Memory Directory Guide (for Maintainers)

This directory serves as the repository's long-term empirical memory and architectural
decision ledger. It keeps global rules lean by recording edge cases out-of-band.

## What Belongs Here vs. What Doesn't
* **Belongs:** Categorized empirical tool quirks (`memory/bioinfo-tool-quirks.md`: GenBank wrapping, Pharokka `"No_PHROG"`, RSQLite 0/1 boolean coercion) and formal Architectural Decision Records (`memory/architecture-decisions.md`: `ADR-001` through `ADR-NNN`).
* **Doesn't Belong:** Ephemeral session handoffs (move to `state/`), general programming tutorials, or duplicate unverified notes.

## Entry Formats & Conventions
Files in this directory are strictly **append-only**. Never overwrite prior entries.

```markdown
### ADR-XXX: Title
* **Date:** YYYY-MM-DD
* **Status:** Accepted
* **Context:** Problem description and trade-offs.
* **Decision:** Architectural choice made.
* **Consequences:** Implications and maintenance commitments.
```

## How & When Agents Touch These Files
* Agents read entries when gated by `instructions/memory-protocol.instructions.md`.
* Agents append new entries only when resolving a verified, non-obvious bug or when documenting an agreed-upon architecture shift via `/handoff`.
* Agents verify that an equivalent quirk or ADR does not already exist before appending.
