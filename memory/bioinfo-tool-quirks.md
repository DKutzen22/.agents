# Bioinformatics Tool Quirks & Empirical Scar Tissue

This document records non-obvious failure modes, version discrepancies, and format edge cases
encountered across bioinformatics toolchains, parsers, and database drivers.
Append newly diagnosed empirical quirks directly to this file.

---

## 1. GenBank & INSDC Flat File Quirks

### Multi-Line Qualifier Wrapping
* **Quirk:** The standard GenBank format wraps long qualifier strings across multiple lines indented with 21 spaces:
  ```text
  /product="terminase large subunit involved in viral packaging
                       and capsid maturation"
  ```
* **Failure Mode:** Naive regex or line-by-line parsers capture only the first line or retain literal `\n` and spaces in the middle of strings, causing broken exact-match searches in SQLite/Shiny (e.g., `'terminase large subunit involved...'` != `'terminase large subunit'`).
* **Workaround:** Always parse via `Bio.SeqIO` or an established parser that normalizes multiline qualifiers into a single whitespace-collapsed string: `re.sub(r'\s+', ' ', val.strip())`.

### Circular Origin Wrap-Around Coordinates (`join(...)`)
* **Quirk:** Circular bacteriophage contigs have genes spanning the origin:
  ```text
  CDS             join(48200..48500,1..250)
  ```
* **Failure Mode:** `feature.location.start` and `feature.location.end` in some parsers throw exceptions or report `start=0` and `end=48500` spanning the entire genome length.
* **Workaround:** Check `isinstance(feature.location, CompoundLocation)`. Explicitly flag `is_partial = 1` or track compound sub-locations to avoid calculating negative or full-genome lengths.

### Missing Qualifiers on Non-CDS Features
* **Quirk:** `tRNA`, `tmRNA`, and `repeat_region` features in GenBank files frequently lack `/locus_tag`, `/product`, or `/translation` qualifiers.
* **Failure Mode:** Direct dictionary indexing `feat.qualifiers['locus_tag'][0]` raises unhandled `KeyError`, crashing the ingestion pipeline.
* **Workaround:** Use `.get()` with deterministic fallbacks:
  ```python
  locus_tag = feat.qualifiers.get("locus_tag", [f"{genome_id}_{feat.type}_{idx}"])[0]
  product = feat.qualifiers.get("product", [feat.type])[0]
  ```

---

## 2. Pharokka, Phold, and Phynteny Edge Cases

### Pharokka `No_PHROG` Sentinel Values
* **Quirk:** When a CDS has no significant homology in the PHROGs database, Pharokka outputs the string literal `"No_PHROG"` in TSVs and qualifiers, rather than leaving the field empty.
* **Failure Mode:** Ingesting `"No_PHROG"` into SQLite creates invalid foreign keys or creates a phantom functional category named `"No_PHROG"` with millions of entries.
* **Workaround:** Sanitize all incoming PHROG fields at parser boundary:
  ```python
  phrog_id = None if raw_phrog in ("No_PHROG", "None", "", "-") else raw_phrog
  ```

### Reconciling Product Labels (`hypothetical protein` vs `unknown function`)
* **Quirk:** Pharokka defaults unannotated genes to `"hypothetical protein"`, whereas Phold/PHROGs categories often categorize them as `"unknown function"`.
* **Failure Mode:** Discrepancy causes split grouping in Shiny aggregation queries (some count as 'hypothetical', others as 'unknown function').
* **Workaround:** Standardize product calls on `'hypothetical protein'` in the database whenever category is `'unknown function'` or confidence is below threshold.

### Phold Tabular Delimiter Quoting
* **Quirk:** Certain phage protein descriptions produced by structural matches contain commas (e.g., `"tail fiber, C-terminal domain"`).
* **Failure Mode:** Parsing `phold_per_cds_predictions.tsv` using comma-delimited or poorly configured CSV readers splits fields across columns.
* **Workaround:** Strictly enforce tab separation (`\t`) with `quotechar='"'` and `quoting=csv.QUOTE_MINIMAL`.

---

## 3. R & RSQLite Gotchas

### Logical Booleans Stored as 0 / 1 Integers
* **Quirk:** SQLite does not have a native `BOOLEAN` data type; it uses `INTEGER` (`0` or `1`).
* **Failure Mode:** When `DBI::dbGetQuery()` returns integer columns (e.g., `is_partial`, `is_primary`), R treats them as integers `0L`/`1L`. Conditional checks like `if (res$is_primary)` fail in strict contexts, and Shiny checkbox inputs (`input$checkbox`) expecting logical `TRUE`/`FALSE` misbehave.
* **Workaround:** Explicitly cast boolean columns in R query helpers:
  ```r
  res$is_primary <- as.logical(res$is_primary)
  ```

### R `NA` vs SQL `NULL` in Parameterized Queries
* **Quirk:** Passing an R `NA` directly into `DBI::dbBind()` or `glue_sql()` can translate to string `"NA"` instead of SQL `NULL` if not properly typed.
* **Failure Mode:** SQLite queries search for literal text `'NA'` instead of evaluating `IS NULL`.
* **Workaround:** Use typed NAs (`NA_character_`, `NA_real_`, `NA_integer_`) or `DBI::SQL("NULL")` when binding parameters.

### Connection Leaks & File Locks in Shiny Apps
* **Quirk:** Opening SQLite connections in reactive blocks without explicit cleanup locks the `.sqlite` file on disk (WAL mode `-wal` and `-shm` files remain active). On Windows or networked NFS filesystems, this prevents downstream pipeline steps or other users from writing to the database.
* **Failure Mode:** `database is locked` error (`sqlite3.OperationalError`).
* **Workaround:** Use `pool::dbPool()` for long-lived app sessions and ensure cleanup is registered in `onStop()`:
  ```r
  pool <- pool::dbPool(RSQLite::SQLite(), dbname = db_path)
  shiny::onStop(function() {
    pool::poolClose(pool)
  })
  ```
