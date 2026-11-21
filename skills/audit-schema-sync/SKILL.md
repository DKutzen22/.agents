---
name: audit-schema-sync
description: >
  Cross-checks SQLite CREATE TABLE schemas against R/Python GenBank parser
  outputs and Shiny query functions to detect column name or type drift.
  Trigger with /audit-schema-sync or ask to audit/verify schema synchronization.
---

# /audit-schema-sync

Detect schema drift between SQLite table definitions, parser code, and
Shiny query functions.

> [!NOTE]
> **Trigger:** Invoke directly via `/audit-schema-sync` or request an audit of schema-to-code alignment.  
> **Canonical DDL definitions:** [`context/sqlite-phage-schema.sql`](../../context/sqlite-phage-schema.sql)  
> **Exact qualifier-to-column mappings:** [`context/genbank-and-phrog-specs.md`](../../context/genbank-and-phrog-specs.md)

## Steps

### 1. Extract SQLite Schema

Find all `.sql` files and R/Python files containing `CREATE TABLE` statements.
Parse table names and column definitions.

```bash
# Find schema definitions:
grep -rn "CREATE TABLE" --include="*.sql" --include="*.R" --include="*.py" .
```

Extract for each table:
- Table name
- Column names and types
- Constraints (PRIMARY KEY, NOT NULL, UNIQUE, REFERENCES)

### 2. Extract Parser Output Columns

Scan R and Python parser functions that write to SQLite:

**Python** — look for:
```python
# DBI patterns:
cursor.execute("INSERT INTO annotations ...")
pd.DataFrame.to_sql("annotations", ...)
```

**R** — look for:
```r
# DBI patterns:
DBI::dbWriteTable(con, "annotations", df)
DBI::dbAppendTable(con, "annotations", df)
```

Extract the data frame column names being written.

### 3. Extract Shiny Query Columns

Scan `R/mod_*.R` and `R/fct_database*.R` for `SELECT` queries:

```r
DBI::dbGetQuery(con, "SELECT locus_tag, product, phrog_id FROM annotations WHERE ...")
```

Extract the column names being read.

### 4. Cross-Reference

Build a comparison matrix:

| Column | Schema | Parser writes | Shiny reads | Status |
|---|---|---|---|---|
| `locus_tag` | ✓ TEXT NOT NULL | ✓ | ✓ | OK |
| `phrog_id` | ✓ TEXT | ✓ | ✗ | ⚠ Read gap |
| `phold_evalue` | ✓ REAL | ✗ | ✓ | 🔴 Write gap |
| `old_column` | ✗ | ✗ | ✓ | 🔴 Missing column |

### 5. Report Findings

Classify each mismatch:

| Issue | Severity | Action |
|---|---|---|
| Column in schema but not written by parser | ⚠ Warning | Column will be NULL — verify this is intentional |
| Column read by Shiny but not in schema | 🔴 Error | Query will fail at runtime |
| Column written by parser but not in schema | 🔴 Error | Write will fail or silently drop data |
| Type mismatch (e.g., schema says INTEGER, parser writes TEXT) | ⚠ Warning | SQLite is flexible but downstream code may break |

## Success Criteria

- Zero 🔴 Error findings.
- All ⚠ Warnings are acknowledged with rationale.
- Schema, parsers, and queries reference an identical column set for each table.

## Example Invocation

```
/audit-schema-sync
```
