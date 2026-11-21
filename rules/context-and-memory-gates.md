---
trigger: glob
globs: "**/*.sql, **/db_*.R, **/parse*, **/ingest*, **/Snakefile, **/*.smk"
description: >
  Gates access to technical specs and empirical memory: requires reading
  context/ and memory/ before modifying schemas, parsers, or pipeline rules.
---

# Context and Memory Gates

## Read Requirements Before Modification

When tasked with modifying database schemas, GenBank/TSV parsers, database access queries,
or pipeline ingestion rules, you MUST consult the following canonical references first:

1. **Database Schema Changes (`*.sql`, `db_*.R`, `ingest*`):**
   - Read @../context/sqlite-phage-schema.sql to verify table definitions, primary/foreign keys, and data types.
   - Do NOT invent ad-hoc column names or change schema types without checking alignment across both Python and R.

2. **Parser and Feature Mapping Changes (`parse*`, `ingest*`, `*.smk`):**
   - Read @../context/genbank-and-phrog-specs.md for exact qualifier-to-column mappings across Pharokka, Phold, and Phynteny.
   - Read @../memory/bioinfo-tool-quirks.md to prevent known regressions (e.g., multiline qualifier wrapping, `No_PHROG` sentinels, circular `join(...)` coordinates).

## Append-Only Memory Updates

- **Empirical Quirks:** When you diagnose and resolve a novel bioinformatics tool quirk, parser failure, or RSQLite driver bug, append a concrete entry to @../memory/bioinfo-tool-quirks.md.
- **Architectural Shifts:** When an architectural choice alters the relationship between pipeline outputs, databases, or UI modules, record an ADR entry in @../memory/architecture-decisions.md.
- **Constraint:** Never update `memory/` speculatively. Only document verified failure modes or agreed design decisions.
