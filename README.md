# .agents — Centralized AI Coding Configurations

Standardized rules, skills, subagents, technical specifications, and zero-dependency scripts for AI-assisted development across three specialized bioinformatics stacks:

| Track | Core Technologies | Primary Use Cases |
|---|---|---|
| **Phage Bioinformatics Pipelines** | Python, Snakemake, Conda, SLURM | Automated phage genome annotation (**Pharokka**, **Phold**, **Phynteny**) & comparative genomics |
| **Annotation Database Apps** | R packages, Shiny modules, SQLite, DBI | Parsing, storing, filtering, and exporting GenBank (`.gbk`) and PHROG annotations |
| **Technical Publishing & Sites** | Quarto, Markdown, knitr | Reproducible research reports, documentation sites, and automated link/asset validation |

---

## What is This Repository?

This repository acts as a **centralized brain** for agentic AI coding assistants (Google Antigravity, Claude Code, Cursor, Codex). Instead of repeatedly writing AI rules, database schemas, and prompt instructions inside every separate phage pipeline, R package, or Quarto project, you mount this single repository into your active projects. 

Any AI agent working in a mounted repository automatically adopts your coding standards, obeys database schemas, avoids known bioinformatics edge cases, and provides standardized slash workflows (`/resume`, `/handoff`, `/janitor`).

---

## 30-Second Quick Start

```bash
# 1. Clone this repository (if not already local)
git clone https:github.com/DKutzen22/.agents.git ~/.agents-central

# 2. Activate the pre-commit governance & security hook in this repository
cd ~/.agents-central
git config core.hooksPath .githooks

# 3. Mount into your target bioinformatics or R project repository
./scripts/link-repo.sh ~/projects/<my-project>

# 4. Open your project in your IDE or CLI and type:
# /resume
```

---

## Slash Command & Workflow Cheat Sheet

These commands live as unified skills in `skills/<name>/SKILL.md` and autocomplete natively in the Antigravity chat input (`/`):

| Command | Purpose | When to Use |
|---|---|---|
| **`/resume`** | Session Continuity | Run at the start of every session to review current blockers, modified files, and queued next actions. |
| **`/handoff`** | Session Closure | Run before ending a work session to cleanly package progress into `state/handoff.md` and update milestones. |
| **`/janitor`** | Repo Governance Audit | Audits frontmatter, checks line limits, validates internal links, and verifies repo health. |
| **`/check-r-pkg`** | R Package Quality Gate | Runs `devtools::document()`, `devtools::test()`, and `rcmdcheck::rcmdcheck()` with error triaging. |
| **`/smoke-test-pipeline`** | Snakemake Validation | Performs dry-runs (`snakemake -n -p`), lints rules, and executes minimal phage test fixtures. |
| **`/audit-schema-sync`** | Schema Drift Audit | Cross-checks SQLite DDL against R/Python parser outputs and Shiny queries to catch column drift. |
| **`/verify-site-links`** | Link & Asset Audit | Renders Quarto sites and verifies that all relative Markdown/HTML links and image assets resolve on disk. |

---

## Directory Architecture & Core Capabilities

The repository is organized into 7 canonical directories. Formal lifecycle specifications are codified in [`context/repo-governance-spec.md`](context/repo-governance-spec.md).

```text
.agents/
├── rules/        # Always-on guardrails auto-triggered by file globs
├── skills/       # Unified home for domain playbooks and callable /workflows
├── agents/       # Isolated subagent definitions with restricted tool grants
├── context/      # Passive reference data (DDL schemas, format lookups, HPC tiers)
├── memory/       # Append-only empirical scar tissue, tool quirks, and ADRs
├── state/        # Ephemeral working memory (handoff state & roadmap checklist)
├── scripts/      # Zero-dependency utilities (POSIX sh, Python 3 stdlib)
├── hooks.json    # Native lifecycle hooks (PreToolUse/PostToolUse governance)
├── rules.json    # Antigravity rule discovery manifest
├── skills.json   # Antigravity skill discovery manifest
└── agents.json   # Antigravity subagent discovery manifest
```

### 1. `rules/` (Always-On Guardrails)
*Maintainer Guide: [`rules/README.md`](rules/README.md) | Trigger: Automatic via file globs*
* **[`bioinformatics-data-integrity.md`](rules/bioinformatics-data-integrity.md):** Bans hardcoded absolute paths and accession IDs; enforces random seeds; mandates defensive parsing for `.gbk`, `.gff3`, and `.fasta`; bans hardcoded `NCBI_API_KEY` tokens and HPC cluster user scratch paths (`/scratch/<user>`, `/lustre/...`).
* **[`r-package-standards.md`](rules/r-package-standards.md):** Enforces explicit `pkg::fun()` namespacing (zero `library()` calls in `R/`), `roxygen2` documentation on exported functions, `testthat` 3rd edition, and `styler`/`lintr` compliance.
* **[`shiny-and-sqlite.md`](rules/shiny-and-sqlite.md):** Enforces Shiny module `NS(id)` isolation, parameterized queries (`DBI::dbBind` / `glue::glue_sql`), and physical separation of pure database query functions from reactive observers.
* **[`snakemake-conventions.md`](rules/snakemake-conventions.md):** Enforces per-rule `conda:`/`container:` directives with pinned package versions, `log:` and `benchmark:` paths, `temp()` intermediate management, and SLURM-ready `resources:` tiers.
* **[`context-and-memory-gates.md`](rules/context-and-memory-gates.md):** Mandates consulting schemas in `context/` and quirks in `memory/` before modifying database access or parsers.
* **[`state-continuity.md`](rules/state-continuity.md):** Checks `state/handoff.md` before initiating multi-file edits or architecture plans.
* **[`agents-repo-governance.md`](rules/agents-repo-governance.md):** Enforces lifecycle contracts, line limits (≤60 lines), and token discipline.

### 2. `skills/` (Domain Playbooks & Workflows)
*Maintainer Guide: [`skills/README.md`](skills/README.md) | Trigger: Intent match or explicit `/<name>`*
* **Domain Playbooks:**
  - **[`phage-annotation-parsers`](skills/phage-annotation-parsers/SKILL.md):** Output structures and qualifier mapping for **Pharokka**, **Phold**, and **Phynteny**, handling circular genomes, overlapping ORFs, and PHROG categories.
  - **[`snakemake-dryrun-and-dag`](skills/snakemake-dryrun-and-dag/SKILL.md):** Validation checklist, DAG/rulegraph SVG generation, and minimal phage test fixture design (`.test/data/`).
  - **[`r-pkg-ci-and-release`](skills/r-pkg-ci-and-release/SKILL.md):** Local R package verification cycle, semantic version bump protocols, and GitHub Actions `R-CMD-check` diagnostics.
  - **[`quarto-technical-publishing`](skills/quarto-technical-publishing/SKILL.md):** YAML frontmatter conventions, reproducible chunk caching (`freeze: auto`), and relative asset link validation.
* **Callable Slash Workflows:** Houses the 7 executable workflows listed in the cheat sheet (`janitor`, `resume`, `handoff`, `check-r-pkg`, `smoke-test-pipeline`, `audit-schema-sync`, `verify-site-links`).

### 3. `agents/` (Isolated Subagents)
*Maintainer Guide: [`agents/README.md`](agents/README.md) | Trigger: Agent orchestration via `invoke_subagent`*
* **[`bioinfo-pipeline-reviewer`](agents/bioinfo-pipeline-reviewer.md):** Specialist code reviewer evaluating Snakemake rules, Python scripts, wildcard ambiguity, and phage-specific biological edge cases.
* **[`shiny-ui-tester`](agents/shiny-ui-tester.md):** Automated headless UI test runner via `shinytest2` / `chromote` testing `.gbk` uploads, table filtering, and CSV/TSV exports.
* **[`docs-and-vigilance-agent`](agents/docs-and-vigilance-agent.md):** Synchronizes `roxygen2` docs, `README.md`, `NEWS.md`, and Quarto vignettes after API or schema changes.
* **[`ci-failure-triager`](agents/ci-failure-triager.md):** Parses failing GitHub Actions logs (R, Snakemake, Conda, Quarto) to isolate root causes and propose minimal diffs.

### 4. `context/` (Passive Reference Specifications)
*Maintainer Guide: [`context/README.md`](context/README.md) | Access Mode: Read-only reference data (Nouns)*
* **[`sqlite-phage-schema.sql`](context/sqlite-phage-schema.sql):** Canonical DDL schema (`PRAGMA foreign_keys = ON;`) defining `genomes`, `features`, `annotations`, and pre-seeded `phrog_categories` lookup table with hex colors.
* **[`genbank-and-phrog-specs.md`](context/genbank-and-phrog-specs.md):** Mappings between INSDC qualifiers, upstream tool TSV columns, circular `join(...)` wrap-around coordinates, and genetic code table 11.
* **[`hpc-and-env-profiles.md`](context/hpc-and-env-profiles.md):** Standard Snakemake `resources:` tiers (`light_io`, `cpu_annotation`, `gpu_structure_fold`, `comparative_genomics`) with concrete thread, memory, and runtime defaults.
* **[`repo-governance-spec.md`](context/repo-governance-spec.md):** Formal structural specifications, folder contracts, and symlink topology rules.

### 5. `memory/` (Empirical Scar Tissue & ADRs)
*Maintainer Guide: [`memory/README.md`](memory/README.md) | Access Mode: Append-only*
* **[`architecture-decisions.md`](memory/architecture-decisions.md):** Permanent ledger of Architectural Decision Records:
  - `ADR-001`: SQLite as canonical interchange format between pipelines and Shiny.
  - `ADR-002`: Strict physical separation of pure `DBI` query helpers from Shiny reactives.
  - `ADR-003`: Three-tier Snakemake validation via minimal phage fixtures before HPC runs.
  - `ADR-004`: Consolidation of workflow commands into `skills/` with portability symlinks.
* **[`bioinfo-tool-quirks.md`](memory/bioinfo-tool-quirks.md):** Real-world edge cases (GenBank multiline product wrapping, Pharokka `"No_PHROG"` sentinels, RSQLite integer `0`/`1` boolean coercion, database locks).

### 6. `state/` (Ephemeral Working Memory)
*Maintainer Guide: [`state/README.md`](state/README.md) | Access Mode: Overwrite-only / Repo-local*
* **[`handoff.md`](state/handoff.md):** Fixed 6-section template capturing current objective, blockers, next action, and modified files (hard cap of 50 lines).
* **[`active-roadmap.md`](state/active-roadmap.md):** Lightweight `[ ]` / `[x]` milestone tracker across bioinformatics pipelines, R/Shiny, and Quarto publishing.

### 7. `scripts/` (Zero-Dependency CLI Utilities)
*Maintainer Guide: [`scripts/README.md`](scripts/README.md) | Standard: POSIX `sh` or Python 3 stdlib only*
* **[`link-repo.sh`](scripts/link-repo.sh):** Executable shell script mounting `.agents` into consumer repositories, creating portability symlinks, and generating IDE pointer entrypoints.
* **[`hook-handler.py`](scripts/hook-handler.py):** Antigravity lifecycle hook runner enforcing real-time spec protection (`PreToolUse`), handoff line caps, and script syntax verification (`PostToolUse`).
* **[`validate-gbk-sqlite.py`](scripts/validate-gbk-sqlite.py):** Verifies SQLite databases against canonical DDL, checking foreign keys, column presence, and sentinels.
* **[`check-links.py`](scripts/check-links.py):** Scans Markdown and HTML files to verify that all relative local links and image assets exist on disk.

---

## Mounting into Target Repositories

To standardize AI workflows across your phage bioinformatics pipelines, R packages, or Quarto publishing sites, run [`scripts/link-repo.sh`](scripts/link-repo.sh):

```bash
./scripts/link-repo.sh /path/to/target-repo
```

### What `link-repo.sh` Does:
1. **Dynamic Relative Symlinks:** Computes the relative offset from `<target>/.agents` back to the central repository and creates strictly relative symlinks for `rules`, `skills`, `agents`, `context`, `scripts`, `hooks.json`, and discovery manifests (`rules.json`, `skills.json`, `agents.json`). Zero hardcoded absolute paths.
2. **Clean Git Exclusion (`.git/info/exclude`):** Idempotently appends all global symlinks to the target's `.git/info/exclude`, ensuring mount artifacts never pollute `<target>`'s git status or commit history.
3. **Commands Portability Symlink:** Generates `<target>/.agents/commands -> skills` so CLI tools expecting a `commands/` directory resolve all workflow skills.
4. **Local Rules Directory (`local-rules/`):** Initializes `.agents/local-rules/` for project-specific rules, which are tracked in target git and guaranteed to survive `link-repo.sh --force`.
5. **Initializes Local State & Memory:** Copies clean starter templates for `state/handoff.md`, `state/active-roadmap.md`, `memory/project-decisions.md`, and `memory/project-quirks.md`.
6. **Generates Root IDE Entrypoints:** Creates lightweight pointer files (`GEMINI.md` and `CLAUDE.md`) in `<target>/` instructing any agent to follow `.agents` rules and local rules.
7. **Optional Standalone CI Scripts (`--ci-copy`):** Copies `validate-gbk-sqlite.py` and `check-links.py` into `<target>/.github/scripts/` so GitHub Actions workflows run independently of local symlinks.
8. **Updates Gitignore:** Appends `.agents/state/*.tmp.md` and scratch patterns to the target repo's `.gitignore`.

---

## Pre-Commit Governance & Security Hook

A mechanical git hook is provided in `.githooks/pre-commit` to prevent governance drift, secret leakage, or broken links before any commit lands.

Activate the hook locally with:
```bash
git config core.hooksPath .githooks
```

### Automated Pre-Commit Checks:
1. **Handoff Line Cap:** Fails if `state/handoff.md` exceeds 50 lines.
2. **Skills Hierarchy:** Blocks loose `.md` files in `skills/` root; verifies YAML frontmatter on all `SKILL.md` files.
3. **Rules Frontmatter & Size:** Enforces `globs:` in frontmatter and a ≤60 line limit on new rules.
4. **Context Declarative Tone:** Scans `context/*.md` to ban imperative agent instructions (`You must`, `Always run`, `Step 1:`).
5. **Context Protection:** Guards against accidental specification changes unless tagged with `[spec-update]` or bypassed via `--no-verify`.
6. **Secret & HPC Path Scan:** Blocks commits containing hardcoded `NCBI_API_KEY` assignments, private SSH keys, or cluster scratch paths (`/scratch/<user>`, `/lustre/...`).
7. **Scripts Contract:** Verifies files in `scripts/` are executable and pass `sh -n` or `python3 -m py_compile`.
8. **Commands Drift:** Blocks stray files from being added to a top-level `commands/` directory in the central repo.
9. **Absolute Path Scanner:** Flags machine-specific absolute paths (`/Users/`, `/home/`, `C:\`) across staged changes to ensure multi-repo portability.

---

## Frontmatter Quick Reference

Every `rules/*.md` file uses:
```yaml
---
trigger: glob
globs:
  - "workflow/**/*.smk"
  - "config/*.yaml"
description: "Concise purpose statement"
---
```

Every `skills/<name>/SKILL.md` uses:
```yaml
---
name: workflow-name
description: >
  Concise purpose. Trigger with /workflow-name or ask to run check.
---
```

Every `agents/*.md` uses:
```yaml
---
name: agent-name
description: "Specialized review persona"
tools:
  - read_file
  - run_command
---
```
