---
description: >
  Enforces Snakemake workflow conventions: environment isolation, logging,
  benchmarking, temp file management, and HPC-ready resource declarations.
applyTo: "**/Snakefile, **/*.smk, **/config/*.yaml, **/config/*.yml"
globs: "**/Snakefile, **/*.smk, **/config/*.yaml, **/config/*.yml"
---

# Snakemake Conventions

## Environment Isolation
- Define per-rule `conda:` or `container:` directives with pinned versions.
- Never rely on ambient host packages or unpinned global environments.

## Logging & Benchmarks
- Every rule must specify `log:` and `benchmark:` directives.
- Redirect standard output and error to designated log files.

## Resources & Intermediate Files
- Declare standard `resources:` tiers (`light_io`, `cpu_annotation`, `gpu_structure_fold`).
- Mark transient intermediate files with `temp()` to preserve storage.
- Validate workflow execution using `snakemake -n -p` dry-runs before cluster submission.
