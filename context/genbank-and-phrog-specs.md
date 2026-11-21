# GenBank Qualifiers and PHROG / Phage Tool Specifications

This document defines passive reference mappings across INSDC/GenBank specifications,
upstream phage annotation tools (**Pharokka**, **Phold**, **Phynteny**), and the canonical
SQLite database tables defined in `context/sqlite-phage-schema.sql`.

---

## 1. INSDC / GenBank Feature Qualifier Mappings

| GenBank Feature / Qualifier | Target SQLite Table | Target Column | Type / Constraint | Parser Conversion Notes |
|---|---|---|---|---|
| Record Header / `LOCUS` | `genomes` | `genome_id` | `TEXT PRIMARY KEY` | Use first whitespace-delimited token; strip `.` version if storing unversioned id |
| Record Header / `ACCESSION` | `genomes` | `accession` | `TEXT` | `NULL` if unsubmitted or raw assembly contig |
| Record Header / `ORGANISM` | `genomes` | `organism` | `TEXT` | Raw organism string from `SOURCE` / `ORGANISM` lines |
| Record Sequence length | `genomes` | `length_bp` | `INTEGER NOT NULL` | Exact nucleotide length of `seq_record.seq` |
| Record GC calculation | `genomes` | `gc_content` | `REAL NOT NULL` | Float fraction `(G + C) / (A + C + G + T)`, rounded to 4 decimals |
| Feature Type (`CDS`, `tRNA`, etc.) | `features` | `feature_type` | `TEXT` | Constrained to `('CDS','tRNA','tmRNA','CRISPR','repeat_region')` |
| `/locus_tag` | `features` | `locus_tag` | `TEXT NOT NULL` | Mandatory unique key per genome; fallback to `ID` or synthesise `<genome>_feat_<N>` if absent |
| Feature Location `start` | `features` | `start_pos` | `INTEGER NOT NULL` | Convert 1-based GenBank coordinate to 0-based closed-open start (`start = location.start`) |
| Feature Location `end` | `features` | `end_pos` | `INTEGER NOT NULL` | End position (`end = location.end`, 0-based exclusive) |
| Feature Location `strand` | `features` | `strand` | `INTEGER NOT NULL` | `1` for forward, `-1` for reverse/complement |
| `/product` | `annotations` | `product` | `TEXT NOT NULL` | Default to `'hypothetical protein'`. Strip wrapping whitespace/newlines |
| `/translation` | `features` | `aa_seq` | `TEXT` | Amino acid sequence. Strip trailing terminal `*` stop codon |
| `/transl_table` | `features` | `note` / metadata | - | Must default to bacterial code `11` for phages; log warning if table `4` or others |
| `/phrog` | `annotations` | `phrog_id` | `TEXT` | Standardise as `phrog_<N>` integer format |
| `/function` | `annotations` | `phrog_category` | `TEXT` | Foreign key to `phrog_categories.category_name` |

---

## 2. Upstream Tool Output Column Mappings

### A. Pharokka (`pharokka_cds_final_merged_output.tsv`)

| Pharokka Column | Target Table | Target Column | Translation / Cleaning Rules |
|---|---|---|---|
| `locus_tag` | `features` / `annotations` | `locus_tag` | Join key to `features` table |
| `start` | `features` | `start_pos` | `start - 1` (convert 1-based closed to 0-based) |
| `stop` | `features` | `end_pos` | `stop` (remains exact 0-based exclusive boundary) |
| `frame` / `strand` | `features` | `strand` | `+` -> `1`, `-` -> `-1` |
| `phrog` | `annotations` | `phrog_id` | If string is `'No_PHROG'`, `'None'`, or empty -> set to `NULL` |
| `category` | `annotations` | `phrog_category` | Match against `phrog_categories.category_name`; if `'unknown function'` or unassigned -> set to `'unknown function'` |
| `product` | `annotations` | `product` | If `'unknown function'` or `'hypothetical protein'` -> store `'hypothetical protein'` |
| (tool identity) | `annotations` | `tool_source` | Literal `'pharokka'` |

### B. Phold (`phold_per_cds_predictions.tsv`)

| Phold Column | Target Table | Target Column | Translation / Cleaning Rules |
|---|---|---|---|
| `cds_id` / `locus_tag` | `annotations` | `feature_id` (via join) | Join via `features.locus_tag` |
| `phold_product` | `annotations` | `product` | Curated structural homology product call |
| `phold_phrog` | `annotations` | `phrog_id` | If `'No_PHROG'`, `'-'`, or `'None'` -> set to `NULL` |
| `phold_category` | `annotations` | `phrog_category` | Validated PHROG category |
| `evalue` / `foldseek_evalue` | `annotations` | `evalue` | Parse as float; exponent notation (e.g., `1e-12`) |
| `bitscore` | `annotations` | `bitscore` | Parse as float |
| (tool identity) | `annotations` | `tool_source` | Literal `'phold'` |

### C. Phynteny (`phynteny_per_cds_functions.tsv`)

| Phynteny Column | Target Table | Target Column | Translation / Cleaning Rules |
|---|---|---|---|
| `locus_tag` | `annotations` | `feature_id` (via join) | Join via `features.locus_tag` |
| `phynteny_category` | `annotations` | `phrog_category` | Predicted syntactic category |
| `phynteny_score` / `confidence` | `annotations` | `confidence_score` | Float range `[0.0, 1.0]`. If `< 0.5`, discard or flag |
| `phynteny_product` | `annotations` | `product` | If absent, preserve prior tool product |
| (tool identity) | `annotations` | `tool_source` | Literal `'phynteny'` |

---

## 3. Phage-Specific Genomic Edge Cases

### A. Circular Wrap-Around Coordinates (`join(start..end, 1..overlap)`)
* Phage genomes assembled as circular contigs frequently have CDS features overlapping the arbitrary in silico sequence origin `0` (e.g., origin placed mid-terminase).
* **GenBank Representation:** `join(48500..49000, 1..350)`.
* **Database Model:**
  - `start_pos`: Coordinate on 5' segment (`48499` in 0-based).
  - `end_pos`: Wrap coordinate (`350` in 0-based) OR normalized virtual length (`48499 + 501 + 350`).
  - Flag `is_partial = 1` or handle split features through two linked `features` rows if strict linear interval arithmetic is required by consumers.
* **Parser Requirement:** Detect `CompoundLocation` in Biopython or multi-part intervals in R; never truncate feature end to chromosome boundary.

### B. Genetic Code Table 11
* Most double-stranded DNA bacteriophages use **Bacterial, Archaeal and Plant Plastid Code (Table 11)**.
* **Start Codons:** `ATG`, `GTG`, `TTG` (all translate to `M` / Methionine at start position).
* **Stop Codons:** `TAA`, `TAG`, `TGA`.
* Always enforce translation using table 11 (`Bio.Seq.translate(table=11, cds=True)`) unless explicitly annotated otherwise.
