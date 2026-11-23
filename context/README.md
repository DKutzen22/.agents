# Context Directory Guide (for Maintainers)

This directory contains passive reference specifications, canonical schemas,
and repository governance definitions.

## Active Specifications
* [`repo-governance-spec.md`](./repo-governance-spec.md): Formal structural specifications, folder contracts, lifecycle rules, and symlink topology.
* [`index.md`](./index.md): Master index of canonical reference specifications.

## What Belongs Here vs. What Doesn't
* **Belongs:** Single sources of truth and technical reference data (e.g. `repo-governance-spec.md`, project schemas).
* **Doesn't Belong:** Imperative agent instructions ("You must", "Always run", "Step 1:"), procedural checklists (move to `skills/`), or transient state (move to `state/`).

## File Formats & Conventions
Files may be `.sql`, `.md`, `.yaml`, or `.json`. All Markdown files in this directory
must be written in purely declarative reference style.

## How & When Agents Touch These Files
* Read-only for agents during standard tasks.
* Agents access these files when gated by specific rules (`instructions/memory-protocol.instructions.md`) prior to modifying schemas or contracts.
* Modifications require explicit human requests for specification updates.
