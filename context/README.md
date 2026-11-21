# Context Directory Guide (for Maintainers)

This directory contains passive reference specifications, canonical data schemas,
hardware resource profiles, and repository governance definitions.

## What Belongs Here vs. What Doesn't
* **Belongs:** Single sources of truth (e.g. `sqlite-phage-schema.sql`, `genbank-and-phrog-specs.md`, `hpc-and-env-profiles.md`, `repo-governance-spec.md`).
* **Doesn't Belong:** Imperative agent instructions ("You must", "Always run", "Step 1:"), procedural checklists (move to `skills/`), or transient state (move to `state/`).

## File Formats & Conventions
Files may be `.sql`, `.md`, `.yaml`, or `.json`. All Markdown files in this directory
must be written in purely declarative reference style.

```sql
-- DDL Schemas: Full PRAGMA foreign_keys = ON, typed columns, constraints
CREATE TABLE IF NOT EXISTS example (
    id TEXT PRIMARY KEY,
    val REAL NOT NULL
);
```

## How & When Agents Touch These Files
* Read-only for agents during standard tasks.
* Agents access these files when gated by specific rules (`rules/context-and-memory-gates.md`) prior to touching schemas, parsers, or SQL queries.
* Modifications require explicit human requests for schema migrations or specification updates.
