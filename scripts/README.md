# Scripts Directory Guide (for Maintainers)

This directory houses zero-dependency repository management, verification, and setup
utilities invoked by skills, automated workflows, and Git hooks.

## What Belongs Here vs. What Doesn't
* **Belongs:** Deterministic repository tooling and cross-stack verification utilities:
  - Repository linking & mounting (`scripts/link-repo.sh`)
  - Repository unlinking & mount teardown (`scripts/unlink-repo.sh`)
  - Multi-repo fleet synchronization & audit (`scripts/sync-all-repos.sh`)
  - Antigravity lifecycle hook runner (`scripts/hook-handler.py`)
  - Database schema & sentinel verification (`scripts/validate-gbk-sqlite.py`)
  - Documentation & asset relative link auditing (`scripts/check-links.py`)
  - APM distribution packaging & archive generation (`scripts/package-agent.sh`)
* **Doesn't Belong:** Project-specific bioinformatics analysis pipelines, Snakemake execution logic, or Shiny server code (those belong in their respective consumer repositories).

## Zero-Dependency Contract
Every script in this directory must run without requiring virtual environments or package installations:
1. **Shell Scripts:** Strictly POSIX `sh` (`#!/bin/sh` with `set -eu`).
2. **Python Scripts:** Python 3 standard library only (`sqlite3`, `pathlib`, `re`, `argparse`, `sys`).
3. **CLI Interface Contract:**
   - Every script must implement a `--help` / `-h` flag describing usage and arguments.
   - Standard UNIX exit codes: `0` for success, `1` (or non-zero) on failure with diagnostic messages printed to stderr.
   - Scripts must have executable permissions (`chmod +x`).

## How & When Agents Touch These Files
* Agents invoke these scripts during workflow execution (`/janitor`, `/verify-site-links`, schema audits).
* `scripts/link-repo.sh` is executed when initializing or refreshing `.agents` in target projects.
