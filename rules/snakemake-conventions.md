---
trigger: glob
globs: "**/Snakefile, **/*.smk, **/config/*.yaml, **/config/*.yml"
description: >
  Enforces Snakemake workflow conventions: environment isolation, logging,
  benchmarking, temp file management, and HPC-ready resource declarations.
---

# Snakemake Conventions

## Environment Isolation

- Every rule MUST specify exactly one of:
  - `conda: "envs/<tool>.yaml"` (preferred for local/CI runs), or
  - `container: "docker://<image>:<tag>"` (for full reproducibility).
- Conda environment YAML files pin major+minor versions:
  `pharokka=1.7`, not `pharokka>=1.0`.
- Never use `shell:` commands that assume globally installed tools.

## Logging and Benchmarking

- Every rule MUST include:
  ```python
  log: "logs/{rule}/{wildcards}.log"
  benchmark: "benchmarks/{rule}/{wildcards}.tsv"
  ```
- Redirect stderr in `shell:` blocks: `command ... 2> {log}` or
  `command ... &> {log}`.
- Log files are committed to `.gitignore` but their path patterns are not.

## Temporary and Protected Outputs

- Wrap large intermediates with `temp()`:
  ```python
  output: temp("results/intermediate/{sample}.bam")
  ```
- Wrap critical final outputs with `protected()`:
  ```python
  output: protected("results/final/{sample}.gbk")
  ```
- Never use `temp()` on files consumed by more than 2 downstream rules
  without `--notemp` testing first.

## Resource Declarations

- Standard resource tier definitions: see @../context/hpc-and-env-profiles.md.
- Every computationally non-trivial rule MUST declare:
  ```python
  threads: config.get("threads", 4)
  resources:
      mem_mb=config.get("mem_mb", 8000),
      runtime=config.get("runtime", 60),  # minutes
  ```
- Thread counts come from `config.yaml`, never hardcoded.
- For SLURM submission, the `--profile` directory must contain a matching
  `config.yaml` with `default-resources` and `set-threads`.

## Wildcard Discipline

- Define `wildcard_constraints:` at the top of each `.smk` module:
  ```python
  wildcard_constraints:
      sample="[A-Za-z0-9_-]+",
      phage_id="[A-Za-z0-9_.]+",
  ```
- Never allow wildcards to match `/` or whitespace.
- Use `expand()` with explicit `zip` or `product` to prevent combinatorial
  explosion.

## Config and Validation

- All file paths, sample sheets, and tool parameters come from
  `config/config.yaml`, never hardcoded in rules.
- Validate config at workflow entry with `validate(config, "schemas/config.schema.yaml")`.
- Validate sample sheets with `validate(samples, "schemas/samples.schema.yaml")`.

## Dry-Run Discipline

- Before any execution, run: `snakemake -n -p --configfile config/config.yaml`.
- Before committing workflow changes, run: `snakemake --lint`.
