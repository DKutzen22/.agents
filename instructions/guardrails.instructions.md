---
description: >
  Guards against hardcoded paths, non-reproducible randomness, fragile parsing
  of bioinformatics formats (GenBank, GFF3, FASTA), and unverified scientific transformations.
applyTo: "**/*.py, **/*.R, **/*.smk, **/*.qmd"
globs: "**/*.py, **/*.R, **/*.smk, **/*.qmd"
---

# Bioinformatics & Execution Guardrails

## Scientific Rigor & Provenance
- **Preserve raw inputs:** Record transformations separately; raw data is immutable.
- **Record software parameters:** Capture tool versions, database builds, and invocation flags.
- **Defensive parsing:** Expect missing qualifiers, non-standard feature keys, and circular coordinates.

## Security & Path Integrity
- **Ban hardcoded absolute paths:** Never hardcode `/Users/`, `/home/`, or machine-specific directories.
- **Ban hardcoded credentials:** Never commit API tokens, `NCBI_API_KEY`, or private SSH keys.
- **Ban cluster scratch paths:** Disallow hardcoded `/scratch/<user>` or `/lustre/...` paths.
- **Enforce deterministic seeds:** Always set explicit random seeds in Python (`random.seed()`, `np.random.seed()`) and R (`set.seed()`).

## Output Sanity Checks
- Verify coordinate bounds (1-based closed intervals, strand correctness).
- Assert non-empty parser yields and report unmapped attributes.
- Guard against silent truncation during sequence or table exports.
