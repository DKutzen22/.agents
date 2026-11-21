---
name: phage-annotation-parsers
description: >
  Reference schemas and edge-case rules for parsing Pharokka, Phold, and
  Phynteny outputs. Maps GenBank qualifiers into normalized SQLite tables.
---

# Phage Annotation Parsers

## When to Use

Activate this skill when:
- Parsing outputs from **Pharokka** (`.gbk`, `_final.tsv`, `_cds_functions.tsv`)
- Parsing outputs from **Phold** (`.gbk` with updated annotations, `phold_predictions.tsv`)
- Parsing outputs from **Phynteny** (`.gbk` with `/phynteny_score` qualifiers)
- Designing or modifying SQLite schemas for phage annotation storage
- Writing R or Python import functions for GenBank annotation data

> [!NOTE]
> Canonical DDL definitions: [`context/sqlite-phage-schema.sql`](../../context/sqlite-phage-schema.sql)  
> Exact qualifier-to-column mappings: [`context/genbank-and-phrog-specs.md`](../../context/genbank-and-phrog-specs.md)

## Pharokka Output Structure

Pharokka produces per-phage output directories containing:

```
pharokka_output/
├── <phage_id>.gbk              # Annotated GenBank flat file
├── <phage_id>_final.tsv        # CDS summary table
├── <phage_id>_cds_functions.tsv # PHROGs functional categories
├── <phage_id>.gff              # GFF3 annotations
├── <phage_id>.faa              # Translated CDS protein sequences
├── <phage_id>.ffn              # CDS nucleotide sequences
└── <phage_id>_length_gc.tsv    # Genome length and GC content
```

### Key GenBank Qualifiers from Pharokka

| Qualifier | Example | Notes |
|---|---|---|
| `/locus_tag` | `<phage_id>_CDS_0001` | Unique per CDS, 1-indexed |
| `/product` | `terminase large subunit` | From PHROGs DB; `hypothetical protein` if no hit |
| `/function` | `DNA packaging` | PHROGs functional category |
| `/phrog` | `phrog_1234` | PHROGs cluster ID |
| `/gene` | `terL` | Only present if PHROGs has a gene name |
| `/transl_table` | `11` | Standard bacterial translation table |
| `/translation` | `MVKRL...` | Full amino acid sequence |

### Pharokka Edge Cases

- **Circular genomes**: CDS features may wrap around the origin. Check for
  `CompoundLocation` with `join(start..end, 1..overlap)`.
- **Overlapping ORFs**: Multiple CDS on the same strand can share
  coordinates. Never deduplicate by position alone.
- **Missing PHROG hits**: `product` = `hypothetical protein`, `function` = empty,
  `phrog` qualifier absent (not `None`, literally missing from the feature).
- **tRNA/tmRNA features**: Pharokka annotates non-CDS features; filter by
  `feature.type == "CDS"` when building protein tables.

## Phold Output Structure

Phold re-annotates Pharokka outputs using structural homology:

```
phold_output/
├── <phage_id>.gbk              # Updated GenBank with Phold annotations
├── phold_predictions.tsv       # Per-CDS prediction table
└── foldseek/                   # Raw Foldseek alignment results
```

### Phold-Specific Qualifiers

| Qualifier | Source | Notes |
|---|---|---|
| `/product` | Updated by Phold | Overrides Pharokka `hypothetical protein` if Phold finds a hit |
| `/phold_hit` | Phold | Foldseek target ID |
| `/phold_evalue` | Phold | Foldseek E-value (parse as float) |
| `/phold_category` | Phold | Functional category from Phold DB |

### Phold Edge Cases

- **Annotation precedence**: When both Pharokka and Phold assign a non-hypothetical
  product, Phold's assignment takes precedence (it's the later pass).
- **Missing predictions**: CDSs with no structural hit retain Pharokka's original
  annotations unchanged.
- **Tab-separated output**: `phold_predictions.tsv` uses `\t` delimiter; some
  `product` fields contain commas — do NOT parse as CSV.

## Phynteny Output Structure

Phynteny adds synteny-based confidence scores to existing annotations:

### Phynteny-Specific Qualifiers

| Qualifier | Type | Notes |
|---|---|---|
| `/phynteny_score` | float (0.0–1.0) | Synteny-based confidence score |
| `/phynteny_prediction` | string | Predicted function from synteny context |

### Phynteny Edge Cases

- **Score threshold**: Only trust `phynteny_score >= 0.9` for automatic
  functional assignment; flag 0.5–0.9 for manual review.
- **Qualifier format**: The score is stored as a string in the GenBank
  qualifier — cast to `float` explicitly.
- **Missing scores**: Not every CDS gets a Phynteny score; absence means
  the synteny context was insufficient for prediction.

## Reference SQLite Schema

Use this as the canonical schema for storing parsed annotations. All parsers
(R and Python) must produce data conforming to these tables:

```sql
CREATE TABLE IF NOT EXISTS genomes (
    genome_id     TEXT PRIMARY KEY,          -- e.g., phage isolate name
    accession     TEXT,                       -- GenBank accession if submitted
    length_bp     INTEGER NOT NULL,
    gc_content    REAL NOT NULL,              -- fraction, e.g., 0.394
    topology      TEXT DEFAULT 'linear',     -- 'linear' or 'circular'
    molecule_type TEXT DEFAULT 'DNA',
    definition    TEXT,                       -- GenBank DEFINITION line
    organism      TEXT,
    taxonomy      TEXT,                       -- semicolon-delimited lineage
    date_added    TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS annotations (
    annotation_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    genome_id          TEXT NOT NULL REFERENCES genomes(genome_id),
    locus_tag          TEXT NOT NULL,
    feature_type       TEXT NOT NULL DEFAULT 'CDS',  -- CDS, tRNA, tmRNA, etc.
    start_pos          INTEGER NOT NULL,              -- 0-based, inclusive
    end_pos            INTEGER NOT NULL,              -- 0-based, exclusive
    strand             INTEGER NOT NULL,              -- 1 or -1
    is_complement      INTEGER NOT NULL DEFAULT 0,    -- boolean
    wraps_origin       INTEGER NOT NULL DEFAULT 0,    -- boolean, circular genomes
    gene               TEXT,
    product            TEXT DEFAULT 'hypothetical protein',
    function_category  TEXT,                           -- PHROGs functional category
    phrog_id           TEXT,                           -- e.g., 'phrog_1234'
    phold_hit          TEXT,
    phold_evalue       REAL,
    phold_category     TEXT,
    phynteny_score     REAL,
    phynteny_prediction TEXT,
    translation        TEXT,                           -- amino acid sequence
    nucleotide_seq     TEXT,
    UNIQUE(genome_id, locus_tag)
);

CREATE INDEX idx_annotations_genome ON annotations(genome_id);
CREATE INDEX idx_annotations_phrog ON annotations(phrog_id);
CREATE INDEX idx_annotations_product ON annotations(product);
CREATE INDEX idx_annotations_locus ON annotations(locus_tag);
```

## Parsing Checklist

1. **Read GenBank** with `Bio.SeqIO.parse()` (Python) or a validated R parser.
2. **Extract genome metadata** → insert into `genomes` table.
3. **Iterate CDS features** → extract qualifiers using `.get()` with defaults.
4. **Handle compound locations** → set `wraps_origin = 1` for `join()` locations.
5. **Merge Phold predictions** → update `product`, `phold_*` columns where Phold has a hit.
6. **Merge Phynteny scores** → update `phynteny_*` columns by `locus_tag` join.
7. **Validate** → assert all `locus_tag` values are unique per genome; log duplicates.
8. **Write to SQLite** → use parameterized inserts, never string interpolation.
9. **Validate Database Integrity** → verify foreign keys and sentinels:
   ```bash
   python3 ../../scripts/validate-gbk-sqlite.py --db results/phage_annotations.sqlite
   # Or from workspace root: python3 scripts/validate-gbk-sqlite.py --db results/phage_annotations.sqlite
   ```
