---
description: "Database & parser audit: cross-check SQLite DDL against R/Python parser schemas"
---
Execute the Synapse SQLite schema synchronization audit:

1. Locate canonical SQLite DDL (`context/sqlite-phage-schema.sql` or `.synapse/context.md`).
2. Scan R query helpers (`db_*.R`) and Python parsers (`parse_*.py`) for table and column references.
3. Compare column names and types against the canonical schema definitions.
4. Check for unindexed foreign keys or type coercion mismatches.
5. Report schema drift or missing columns before migrations land.
