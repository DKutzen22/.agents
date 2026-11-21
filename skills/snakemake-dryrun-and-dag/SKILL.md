---
name: snakemake-dryrun-and-dag
description: >
  Exact commands and checklist for validating Snakemake phage annotation
  workflows via dry-runs, linting, DAG visualization, and minimal test fixtures.
---

# Snakemake Dry-Run and DAG Validation

## When to Use

Activate this skill when:
- Validating a new or modified Snakemake workflow before execution
- Setting up test fixtures for CI pipeline testing
- Debugging rule dependency or wildcard resolution issues
- Generating workflow DAGs for documentation

## Pre-Execution Validation Checklist

### Step 1: Lint the Workflow

```bash
snakemake --lint --configfile config/config.yaml
```

This checks for:
- Rules without `log:` directives (warning)
- Rules without `resources:` (warning for HPC workflows)
- Ambiguous wildcard patterns
- Unused rules
- Style issues

Fix all warnings before proceeding.

### Step 2: Dry-Run with Full Output

```bash
snakemake -n -p --configfile config/config.yaml
```

Flags:
- `-n` / `--dry-run`: Do not execute, only show what would run
- `-p` / `--printshellcmds`: Print the actual shell commands

Verify:
- [ ] All expected rules appear in the execution plan
- [ ] No `AmbiguousRuleException` or `MissingInputException`
- [ ] Wildcard values resolve to expected sample names
- [ ] File paths match the expected output directory structure
- [ ] The rule execution order is logically correct

### Step 3: Quiet Summary

```bash
snakemake -n --quiet --configfile config/config.yaml
```

This prints only the rule counts. Use for quick validation when the full
output is too verbose.

### Step 4: Reason Tracing

```bash
snakemake -n -r --configfile config/config.yaml
```

The `-r` / `--reason` flag explains why each rule is scheduled (missing
output, updated input, forced, etc.). Essential for debugging unexpected
re-runs.

## DAG and Rulegraph Visualization

### Generate DAG (all jobs, all samples)

```bash
snakemake --dag --configfile config/config.yaml | dot -Tsvg > dag.svg
```

Warning: for large sample sets, the DAG becomes unreadable. Use `--rulegraph`
instead.

### Generate Rulegraph (rule-level dependencies only)

```bash
snakemake --rulegraph --configfile config/config.yaml | dot -Tsvg > rulegraph.svg
```

This is the preferred visualization for documentation — it shows the workflow
structure without per-sample fan-out.

### Generate Filegraph

```bash
snakemake --filegraph --configfile config/config.yaml | dot -Tsvg > filegraph.svg
```

Shows file-level dependencies, useful for debugging intermediate file issues.

## Minimal Test Fixtures

### Fixture Design for Phage Genomes

Create a minimal test dataset in `.test/data/`:

```
.test/
├── config/
│   └── config.yaml         # Test-specific config overriding paths
├── data/
│   ├── test_phage_1.fasta   # Short phage genome (~5 kb, 5-10 CDS)
│   └── samples.tsv          # Sample sheet with test_phage_1 only
└── expected/
    ├── test_phage_1.gbk     # Expected Pharokka output (golden file)
    └── test_phage_1.tsv     # Expected summary table
```

### Test Config Override

```yaml
# .test/config/config.yaml
samples: .test/data/samples.tsv
input_dir: .test/data
output_dir: .test/results
threads: 1
mem_mb: 2000
```

### Running the Test Fixture

```bash
# Dry-run with test config:
snakemake -n -p --configfile .test/config/config.yaml

# Actual micro-run (if tools are installed):
snakemake --cores 1 --configfile .test/config/config.yaml --use-conda

# Verify expected outputs exist:
diff .test/results/test_phage_1.gbk .test/expected/test_phage_1.gbk
```

### CI Integration

```yaml
# In .github/workflows/test-pipeline.yaml:
- name: Dry-run Snakemake
  run: |
    snakemake -n -p --configfile .test/config/config.yaml
    echo "Dry-run passed"

- name: Lint Snakemake
  run: |
    snakemake --lint --configfile .test/config/config.yaml
```

## Common Errors and Fixes

| Error | Cause | Fix |
|---|---|---|
| `MissingInputException` | Upstream rule not producing expected file | Check `output:` path matches downstream `input:` |
| `AmbiguousRuleException` | Two rules can produce the same output | Add `ruleorder:` directive or tighten `wildcard_constraints:` |
| `WorkflowError: Target rules may not contain wildcards` | `rule all:` input uses unresolved wildcards | Use `expand()` with explicit sample list |
| `IncompleteFilesException` | Previous run was interrupted | Run `snakemake --cleanup-metadata` then re-run |
| `CreateRuleException: ... defines ... output but ... already defined` | Duplicate output paths | Ensure unique output paths per rule |
