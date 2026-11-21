---
name: smoke-test-pipeline
description: >
  Runs a Snakemake dry-run and optional micro-fixture execution
  to validate pipeline integrity before full runs.
  Trigger with /smoke-test-pipeline or ask to smoke test / validate pipeline.
---

# /smoke-test-pipeline

Validate a Snakemake phage annotation pipeline without full execution.

> [!NOTE]
> **Trigger:** Invoke directly via `/smoke-test-pipeline` or request a pipeline dry-run / smoke test.  
> **Resource profiles:** [`context/hpc-and-env-profiles.md`](../../context/hpc-and-env-profiles.md)

## Steps

### 1. Locate Config

Identify the config file. Check in order:
1. `config/config.yaml`
2. `.test/config/config.yaml` (test override)
3. Ask the user if neither exists.

### 2. Dry-Run

```bash
snakemake -n -p --configfile <config_path>
```

- Verify exit code is 0.
- Confirm all expected target rules appear.
- Flag any `MissingInputException`, `AmbiguousRuleException`, or `WorkflowError`.

### 3. Lint

```bash
snakemake --lint --configfile <config_path>
```

- Report all lint warnings grouped by severity.
- Propose fixes for missing `log:` or `resources:` directives.

### 4. Micro-Fixture Run (if `.test/` exists)

```bash
snakemake --cores 1 \
  --configfile .test/config/config.yaml \
  --use-conda \
  --conda-frontend mamba
```

- Run only on the minimal test fixture phage genome.
- Verify expected output files are created:
  - `.test/results/<phage_id>.gbk`
  - `.test/results/<phage_id>_final.tsv`
- Compare against golden files in `.test/expected/` if they exist.

### 5. Report

Summarize:
- Dry-run: PASS / FAIL (with error details)
- Lint: N warnings (list them)
- Fixture run: PASS / FAIL / SKIPPED (no `.test/` directory)
- Expected outputs: MATCH / DIFF / MISSING

## Success Criteria

- Dry-run exits 0 with no exceptions.
- Lint produces zero critical warnings.
- If fixture data exists, the micro-run completes and outputs match expectations.

## Example Invocation

```
/smoke-test-pipeline
```

```
/smoke-test-pipeline --config .test/config/config.yaml
```
