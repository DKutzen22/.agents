# Synapse — Centralized Multi-Agent Engineering Framework

Standardized rules, skills, subagents, technical specifications, and zero-dependency scripts for AI-assisted development across three specialized bioinformatics stacks:

| Track | Core Technologies | Primary Use Cases |
|---|---|---|
| **Phage Bioinformatics Pipelines** | Python, Snakemake, Conda, SLURM | Automated phage genome annotation (**Pharokka**, **Phold**, **Phynteny**) & comparative genomics |
| **Annotation Database Apps** | R packages, Shiny modules, SQLite, DBI | Parsing, storing, filtering, and exporting GenBank (`.gbk`) and PHROG annotations |
| **Technical Publishing & Sites** | Quarto, Markdown, knitr | Reproducible research reports, documentation sites, and automated link/asset validation |

---

## What is Synapse?

Synapse acts as a **centralized brain** for agentic AI coding assistants (Google Antigravity, Claude Code, Cursor, Codex). Instead of repeatedly writing AI rules, database schemas, and prompt instructions inside every separate phage pipeline, R package, or Quarto project, you mount Synapse into your active projects. 

Any AI agent working in a mounted repository automatically adopts your coding standards, obeys database schemas, avoids known bioinformatics edge cases, and provides standardized slash workflows (`/resume`, `/handoff`, `/janitor`).

---

## Installation & Distribution

This repository is distributed for public, team, and multi-agent usage via APM (Agent Package Manager), GitHub Releases, and direct repository linking:

### Option 1: Install via APM (Recommended for Teams & Multi-Tool Environments)

Using Microsoft's **APM (Agent Package Manager)**, you can install Synapse into any repository and compile configurations directly to your target harnesses (Claude Code, Cursor, GitHub Copilot):

```bash
# Install directly from GitHub into your active project:
apm install github:dkutzen22/.agents

# Or install from the APM registry / namespace shorthand:
apm install dkutzen22/synapse
```

To declare Synapse as a versioned dependency in your consumer project's `apm.yml`:

```yaml
# In your target project's apm.yml
name: my-phage-project
version: 0.1.0

targets:
  - antigravity
  - agent-skills
  - claude
  - cursor
  - copilot
  - gemini

dependencies:
  apm:
    - git: https://github.com/dkutzen22/.agents
      ref: v1.0.0
```

Run `apm install` to fetch, verify with `apm.lock.yaml`, and compile the skills, rules, and configurations into the appropriate native paths (`.claude/`, `.cursor/`, `.github/`, `.gemini/`).

### Post-Install Workspace Architecture & State Isolation

When installing Synapse via APM:
1. **Immutable Source Cache (`apm_modules/dkutzen22/synapse/`):**
   APM places the raw, versioned Synapse package inside `apm_modules/dkutzen22/synapse/`. This directory is content-addressed, strictly read-only, and should never be modified.
2. **Native Harness Compilation:**
   APM compiles and projects Synapse's primitives directly into your configured target harness directories:
   * **Antigravity / Agent Skills:** Projected into `rules/` and `skills/` with native manifest discovery.
   * **GitHub Copilot:** Deploys instructions to `.github/copilot-instructions.md` and prompts to `.github/prompts/*.prompt.md`.
   * **Claude Code:** Deploys slash commands into `.claude/commands/` and memory guidelines.
   * **Cursor:** Compiles scoped instruction rules into `.cursor/rules/*.mdc`.
   * **Gemini CLI:** Generates TOML prompt manifests under `.gemini/commands/`.
3. **Initialize Mutable Project State (`/synapse-init`):**
   To keep your project's working memory separate from the immutable package cache, initialize local project state on first run:
   ```bash
   # Run the initialization command in your agent chat:
   /synapse-init
   ```
   This scaffolds the `.synapse/` workspace directory:
   * `.synapse/state.json`: Machine-readable session ledger tracking active objectives, blockers, and next actions.
   * `.synapse/context.md`: Project-specific technical context and active schemas.
   * `.synapse/handoff.md`: Inter-session handoff summary.
   * `.synapse/memory/`: Local append-only architectural decisions (`project-decisions.md`) and tool quirks (`project-quirks.md`).
   * `.synapse/local-rules/`: Project-specific instruction overrides.

### Option 2: Pre-Packaged Release Archive (.zip)

Every release published via GitHub Actions attaches a standardized `.zip` distribution bundle and SHA-256 checksum:

```bash
# Download and install pre-built release package
apm install https://github.com/dkutzen22/.agents/releases/download/v1.0.0/synapse-v1.0.0.zip
```

### Option 3: Local Monorepo & HPC Symlink Mount

For local multi-repo development or offline HPC clusters without APM:

```bash
# 1. Clone this repository centrally (if not already local)
git clone https://github.com/DKutzen22/.agents.git ~/.synapse-central

# 2. Activate the pre-commit governance & security hook in this repository
cd ~/.synapse-central
git config core.hooksPath .githooks

# 3. Mount into your target bioinformatics or R project repository
./scripts/link-repo.sh ~/projects/<my-project>

# 4. Open your project in your IDE or CLI and invoke:
# /resume
```

---

## Slash Command & Workflow Cheat Sheet

These commands live as unified skills in `skills/<name>/SKILL.md` and autocomplete natively in the Antigravity chat input (`/`):

| Command | Purpose | When to Use |
|---|---|---|
| **`/synapse-init`** | Workspace State Init | Run once after `apm install` to scaffold local mutable `.synapse/` state, context, and memory. |
| **`/resume`** | Session Continuity | Run at the start of every session to review current blockers, modified files, and queued next actions. |
| **`/handoff`** | Session Closure | Run before ending a work session to cleanly package progress into `state/handoff.md` and update milestones. |
| **`/janitor`** | Repo Governance Audit | Audits frontmatter, checks line limits, validates internal links, and verifies repo health. |
| **`/check-r-pkg`** | R Package Quality Gate | Runs `devtools::document()`, `devtools::test()`, and `rcmdcheck::rcmdcheck()` with error triaging. |
| **`/smoke-test-pipeline`** | Snakemake Validation | Performs dry-runs (`snakemake -n -p`), lints rules, and executes minimal phage test fixtures. |
| **`/audit-schema-sync`** | Schema Drift Audit | Cross-checks SQLite DDL against R/Python parser outputs and Shiny queries to catch column drift. |
| **`/verify-site-links`** | Link & Asset Audit | Renders Quarto sites and verifies that all relative Markdown/HTML links and image assets resolve on disk. |

---

## Directory Architecture & Core Capabilities

The repository is organized into canonical primitives conforming to APM and Antigravity specifications. Formal lifecycle specifications are codified in [`context/repo-governance-spec.md`](context/repo-governance-spec.md).

```text
synapse/
├── rules/        # APM *.instructions.md guardrails auto-triggered by globs/applyTo
├── prompts/      # APM *.prompt.md parameter-driven workflows & slash commands
├── skills/       # Modular skills (<skill-name>/SKILL.md) for Antigravity & Agent Skills
├── agents/       # Isolated subagent definitions with restricted tool grants
├── context/      # Canonical reference specifications (DDL schemas, format lookups, HPC tiers)
├── memory/       # Central append-only scar tissue, tool quirks, and ADRs
├── state/        # Ephemeral working memory templates
├── scripts/      # Zero-dependency utilities (POSIX sh, Python 3 stdlib)
├── apm.yml       # APM package manifest declaring targets, primitives, and entrypoints
├── hooks.json    # Native lifecycle hooks (PreToolUse/PostToolUse governance)
├── rules.json    # Antigravity rule discovery manifest
├── skills.json   # Antigravity skill discovery manifest
└── agents.json   # Antigravity subagent discovery manifest
```

### 1. `rules/` (Always-On Guardrails & Instructions)
*Maintainer Guide: [`rules/README.md`](rules/README.md) | Trigger: Automatic via `applyTo` / `globs`*
* **[`guardrails.instructions.md`](rules/guardrails.instructions.md):** Bans hardcoded absolute paths and accession IDs; enforces random seeds; mandates defensive parsing for `.gbk`, `.gff3`, and `.fasta`; bans hardcoded `NCBI_API_KEY` tokens and HPC cluster user scratch paths (`/scratch/<user>`, `/lustre/...`).
* **[`r-package-standards.instructions.md`](rules/r-package-standards.instructions.md):** Enforces explicit `pkg::fun()` namespacing (zero `library()` calls in `R/`), `roxygen2` documentation on exported functions, `testthat` 3rd edition, and `styler`/`lintr` compliance.
* **[`shiny-and-sqlite.instructions.md`](rules/shiny-and-sqlite.instructions.md):** Enforces Shiny module `NS(id)` isolation, parameterized queries (`DBI::dbBind` / `glue::glue_sql`), and physical separation of pure database query functions from reactive observers.
* **[`snakemake-conventions.instructions.md`](rules/snakemake-conventions.instructions.md):** Enforces per-rule `conda:`/`container:` directives with pinned package versions, `log:` and `benchmark:` paths, `temp()` intermediate management, and SLURM-ready `resources:` tiers.
* **[`memory-protocol.instructions.md`](rules/memory-protocol.instructions.md):** Mandates consulting schemas in `context/` and quirks in `memory/` before modifying database access or parsers.
* **[`state-continuity.instructions.md`](rules/state-continuity.instructions.md):** Checks `.synapse/state.json` / `.synapse/handoff.md` before initiating multi-file edits or architecture plans.
* **[`synapse-governance.instructions.md`](rules/synapse-governance.instructions.md):** Enforces lifecycle contracts, line limits (≤60 lines), and token discipline across all Synapse components.
* **[`git-conventions.instructions.md`](rules/git-conventions.instructions.md):** Enforces Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), atomic changesets, descriptive PR summaries, and bans raw data files (>10MB).
* **[`python-standards.instructions.md`](rules/python-standards.instructions.md):** Enforces modern Python packaging (`src/` layout, `pyproject.toml`), explicit type annotations, `pytest` unit suites, `ruff` linting, `pathlib.Path`, and deterministic seeds.

### 2. `skills/` (Domain Playbooks & Workflows)
*Maintainer Guide: [`skills/README.md`](skills/README.md) | Trigger: Intent match or explicit `/<name>`*
* **Domain Playbooks:**
  - **[`scaffold-domain`](skills/scaffold-domain/SKILL.md):** Guided workflow for expanding Synapse safely with new languages, tools, rules, and context specifications.
  - **[`promote-memory`](skills/promote-memory/SKILL.md):** Periodic harvesting protocol for promoting empirical project quirks and decisions into central memory or rules.
  - **[`python-packaging-and-cli`](skills/python-packaging-and-cli/SKILL.md):** Modern `src/` layout packaging, `pyproject.toml` metadata, `argparse`/`typer` CLI entrypoints, and `pytest` suites.
  - **[`docker-and-reproducibility`](skills/docker-and-reproducibility/SKILL.md):** Multi-stage Dockerfiles, Apptainer/Singularity `.def` recipes for SLURM/HPC, and pinned lockfile environments.
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
* **[`manuscript-reviewer`](agents/manuscript-reviewer.md):** Specialized scientific editorial reviewer auditing computational reproducibility claims, figure captions, statistical precision, and terminology without altering code logic.

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
* **[`link-repo.sh`](scripts/link-repo.sh):** Executable shell script mounting Synapse into consumer repositories, creating portability symlinks, and generating IDE pointer entrypoints.
* **[`unlink-repo.sh`](scripts/unlink-repo.sh):** Clean teardown utility removing shared symlinks and `.git/info/exclude` blocks while preserving repo-local state, memory, and local-rules.
* **[`sync-all-repos.sh`](scripts/sync-all-repos.sh):** Fleet management script auditing (`--check`) or updating (`--refresh`) all registered consumer repositories listed in `${XDG_CONFIG_HOME:-$HOME/.config}/agents/linked-repos.txt`.
* **[`hook-handler.py`](scripts/hook-handler.py):** Antigravity lifecycle hook runner enforcing real-time spec protection (`PreToolUse`), handoff line caps, and script syntax verification (`PostToolUse`).
* **[`validate-gbk-sqlite.py`](scripts/validate-gbk-sqlite.py):** Verifies SQLite databases against canonical DDL, checking foreign keys, column presence, and sentinels.
* **[`check-links.py`](scripts/check-links.py):** Scans Markdown and HTML files to verify that all relative local links and image assets exist on disk.
* **[`package-synapse.sh`](scripts/package-synapse.sh):** Cleans caches, asserts `apm.yml` schema, and builds `.zip` release distribution.

---

## Mounting Synapse into Target Repositories

To standardize AI workflows across your phage bioinformatics pipelines, R packages, or Quarto publishing sites, run [`scripts/link-repo.sh`](scripts/link-repo.sh) to mount Synapse:

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

## Machine Configuration & MCP Template

A sanitized template for Model Context Protocol (MCP) server definitions is provided in [`mcp.json.template`](mcp.json.template):
* **Filesystem MCP:** Configured with `${WORKSPACE_DIR}`.
* **SQLite MCP:** Configured with `${DB_PATH}`.
* **GitHub MCP:** Configured with `${GITHUB_TOKEN}`.
* **Browser DevTools MCP:** Configured for local UI testing.

To configure MCP servers on a new development workstation:
```bash
cp mcp.json.template ~/.gemini/antigravity/mcp.json
# Or for project-local IDE usage (gitignored):
cp mcp.json.template mcp.json
```

---

## Continuous Integration Self-Testing

The central Synapse architecture is automatically validated via GitHub Actions in [`.github/workflows/validate-synapse.yml`](.github/workflows/validate-synapse.yml) on every push and pull request to `main`:
1. **JSON & Manifest Parsing:** Validates `hooks.json`, `agents.json`, `rules.json`, `skills.json`, and `mcp.json.template` with `python3 -m json.tool`.
2. **Full Repository Governance:** Executes `.githooks/pre-commit --all` to audit frontmatter, line limits, and verify zero machine-specific absolute paths.
3. **Cross-Link Integrity:** Runs `scripts/check-links.py` to assert zero broken internal file references.
4. **CLI Contract Verification:** Syntax-checks all shell and Python scripts and verifies `--help` execution.
5. **End-to-End Mount & Teardown:** Executes `scripts/link-repo.sh` and `scripts/unlink-repo.sh` against an isolated Git fixture repository.

---

## Packaging & Release Automation

This repository provides reproducible build scripts and continuous integration for packaging and releasing agent configurations:

* **APM Manifest (`apm.yml`):** Specifies package metadata (`dkutzen22/synapse`), version (`1.0.0`), primitive directories, and target harnesses.
* **Line Ending Governance (`.gitattributes`):** Normalizes all text files to LF line endings (`eol=lf`) and marks binary/archive formats explicitly.
* **Build Command (`make package`):** Cleans transient caches and calls [`scripts/package-synapse.sh`](scripts/package-synapse.sh) to assemble `dist/synapse-v<version>.zip` and calculate its SHA-256 checksum.
* **Tag-Triggered CI/CD ([`.github/workflows/release.yml`](.github/workflows/release.yml)):** Automatically runs on semantic git tags (`v*.*.*`), validates `apm.yml`, executes pre-commit governance, compiles the distribution zip, and publishes a GitHub Release.

---

## Frontmatter Quick Reference

Every `rules/*.md` file uses:
```yaml
---
trigger: glob
globs: "workflow/**/*.smk, config/*.yaml"
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
subagent: true
mainAgent: false
model: "pro"  # "pro", "flash", or "flash_lite"
tools:
  - read_file
  - run_command
---
```
