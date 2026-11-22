---
description: >
  Gates access to technical specs and empirical memory: requires reading
  context/ and memory/ before modifying schemas, parsers, or pipeline rules.
applyTo: "**/*.sql, **/db_*.R, **/parse*, **/ingest*, **/Snakefile, **/*.smk"
globs: "**/*.sql, **/db_*.R, **/parse*, **/ingest*, **/Snakefile, **/*.smk"
---

# Memory Protocol & Context Gates

## Read Requirements Before Modification

When tasked with modifying database schemas, GenBank/TSV parsers, database access queries,
or pipeline ingestion rules, you MUST consult canonical package context and local memory first:

1. **Database Schema Changes (`*.sql`, `db_*.R`, `ingest*`):**
   - Read canonical SQLite DDL (`context/sqlite-phage-schema.sql` or `apm_modules/dkutzen22/synapse/context/sqlite-phage-schema.sql`).
   - Do NOT invent ad-hoc column names or change schema types without checking alignment across both Python and R.

2. **Parser and Feature Mapping Changes (`parse*`, `ingest*`, `*.smk`):**
   - Read `context/genbank-and-phrog-specs.md` for exact qualifier-to-column mappings across Pharokka, Phold, and Phynteny.
   - Read `memory/bioinfo-tool-quirks.md` and local `.synapse/memory/project-quirks.md` to prevent known regressions (e.g., multiline qualifier wrapping, `No_PHROG` sentinels, circular `join(...)` coordinates).

## Append-Only Memory Updates

- **Empirical Quirks:** When you diagnose and resolve a novel tool quirk or parser failure, append a concrete entry to `.synapse/memory/project-quirks.md` (or central `memory/bioinfo-tool-quirks.md`).
- **Architectural Shifts:** When an architectural choice alters the relationship between pipeline outputs, databases, or UI modules, record an ADR entry in `.synapse/memory/project-decisions.md` (or central `memory/architecture-decisions.md`).
- **Constraint:** Never update memory speculatively. Only document verified failure modes or agreed design decisions.
