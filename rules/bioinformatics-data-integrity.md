---
trigger: glob
globs: "**/*.py, **/*.R, **/*.smk, **/*.qmd"
description: >
  Guards against hardcoded paths, non-reproducible randomness, fragile parsing
  of bioinformatics formats (GenBank, GFF3, FASTA), and unverified scientific transformations.
---

# Bioinformatics Data & Scientific Integrity

## Scientific Rigor & Provenance
- **Preserve raw inputs:** Record transformations separately; raw data is immutable.
- **Provenance tracking:** Always record software, reference database, and environment versions.
- **Distinguish missing vs. negative:** Missing annotations/homology != verified negative finding.
- **Software tests != biological validation:** Passing unit/pipeline tests verifies code mechanics, not biological truth.
- **Explicit assumptions:** State assumptions that could alter biological interpretation (e.g., genetic code 11, linear vs. circular topology).

## No Hardcoded Paths or Accessions
- **Ban all absolute paths** (`/home/`, `/data/`, `/scratch/`) in source code.
  Paths MUST come from `config.yaml`, `snakemake.input`, CLI `argparse` arguments, or R parameters.
- **Ban hardcoded accession IDs** (e.g., `NC_001416`, `MN908947`). Accessions must be read from sample sheets, config files, or function arguments.
- Exception: test fixture files in `tests/fixtures/` or `.test/data/` may use static accessions if documented in the test docstring.

## Secrets, HPC Paths & Private Data Security
- **Ban hardcoded API credentials:** Never commit `NCBI_API_KEY` or web service tokens; access only via `os.environ.get("NCBI_API_KEY")` or `Sys.getenv("NCBI_API_KEY")`.
- **Ban internal HPC hostnames & user scratch paths:** Absolute paths to user scratch (`/scratch/<user>`, `/lustre/...`) or cluster SSH host strings are forbidden in tracked code and rule templates.
- **Ban unreleased/private genome data:** Never commit unreleased FASTA or GenBank sequence payloads to source trees or tests. Test fixtures must use synthetic minimal sequences (e.g., in `.test/data/`).

## Deterministic Random Seeds
- Any function using random sampling, bootstrapping, or stochastic algorithms MUST accept a `seed` or `random_state` parameter with a documented default.
- In Python: `random.seed(seed)` and `numpy.random.default_rng(seed)`.
- In R: `set.seed(seed)` at the start of the function body.
- Snakemake rules calling stochastic tools must pass seeds from config: `params: seed=config.get("seed", 42)`.

## Defensive Format Parsing
### GenBank (`.gbk`, `.gb`, `.gbff`)
- Use `Bio.SeqIO.parse(handle, "genbank")` (Python) or a validated parser; never regex raw GenBank flat files.
- Handle records where `seq_record.seq` is `UnknownSeq` — check `len(seq_record.seq)` and test for `"N" * len(seq)`.
- Tolerate missing qualifiers: access via `feature.qualifiers.get("product", ["hypothetical protein"])[0]`.
- Handle multi-record GenBank files (concatenated genomes) — always iterate, never assume single-record.

### GFF3 (`.gff`, `.gff3`)
- Validate the `##gff-version 3` header line is present.
- Handle URL-encoded characters in column 9 attributes (`%3B`, `%3D`, `%2C`).
- Skip comment lines (`#`) and `##FASTA` section correctly.
- Tolerate missing `ID=` attributes on non-gene features.

### FASTA (`.fasta`, `.fa`, `.fna`, `.faa`)
- Strip trailing `*` from protein sequences (translation stop codons).
- Normalize line wrapping — never assume 80-character lines.
- Validate sequence alphabet: nucleotide (`ACGTNRYSWKMBDHV.-`) or amino acid (`ACDEFGHIKLMNPQRSTVWY*X.-`).
- Handle multi-line headers: truncate at first whitespace for the sequence ID.

## Identifier Preservation
- When transforming annotations across formats (GBK → GFF → SQLite), preserve `locus_tag`, `protein_id`, and `gene` qualifiers as immutable keys.
- Log any identifiers that fail to map between formats.
- Never silently drop records — raise errors or warnings with the record identifier.
