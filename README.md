# Synapse — Centralized Memory & State Continuity Framework

A standardized, multi-agent memory framework providing persistent context, session continuity, empirical knowledge tracking, and execution guardrails for AI coding assistants (Google Antigravity, Claude Code, Cursor, Codex, Gemini CLI).

---

## What is Synapse?

Synapse acts as a **centralized brain and memory architecture** for agentic AI coding assistants. Instead of repeatedly writing AI rules, state templates, and prompt instructions inside every separate project, you mount Synapse into your active repositories (via APM or local symlinks).

Any AI agent working in a mounted repository automatically adopts:
- **Session Continuity:** Standardized state restoration (`/resume`) and closure (`/handoff`) preventing context loss between sessions.
- **Empirical Memory:** Append-only recording of tool quirks and architectural decisions via starter templates and automated hydration.
- **Context Governance:** Declarative specification management and token discipline (≤50 line handoff caps, ≤60 line rules).
- **Workspace State Isolation:** Distinct separation between immutable package rules and mutable project memory (`.synapse/`).

---

## Fork & Install Architecture

Synapse is designed for a **fork-ready core vs. personal overlay** distribution model. Users fork `main`, install their own fork via APM or local symlinks, and seamlessly pull upstream framework updates without inheriting personal memories or suffering merge conflicts.

### The Two-Branch Maintainer Workflow

```text
upstream/main (Public Framework Core)
     │
     ▼ (git pull upstream main)
  main (Your Fork's Framework Core) ───► Clean templates (*.template.md), no personal memory
     │
     ▼ (git merge main)
personal (Your Personal Overlay Branch) ──► Tracks private user-profile.md, anti-patterns.md, & custom skills
```

1. **`main` Branch (Public Framework Core):**
   - Keeps clean starter templates (`memory/*.template.md`), core skills, rules, and governance scripts.
   - Hydrated memory files (`memory/*.md`) are untracked so upstream pulls remain 100% clean and conflict-free.
   - Any generic improvements can be contributed back upstream via pull request.

2. **`personal` Branch (Private Daily-Driver Overlay):**
   - Created off `main` to store your personal cross-project developer habits (`memory/user-profile.md`), negative constraints (`memory/anti-patterns.md`), and custom skills tagged with `scope: personal`.
   - Merging framework updates from `main` into `personal` never produces merge conflicts on memory or personal preferences.

---

### 4-Step Fork & Install Quickstart

#### Step 1: Fork the Upstream Repository (GitHub Web or CLI)
* **[Terminal / Web]**: Fork `https://github.com/dkutzen22/synapse` to your GitHub account (e.g. `https://github.com/<your-username>/synapse`) via the GitHub UI or CLI:
  ```bash
  gh repo fork dkutzen22/synapse --clone=false
  ```

#### Step 2: Clone & Initialize Your Central Fork
1. **[Terminal Shell]** Clone your fork locally and configure Git hooks:
   ```bash
   git clone https://github.com/<your-username>/synapse.git ~/.synapse-central
   cd ~/.synapse-central
   git config core.hooksPath .githooks
   ```
2. **[Agent Chat Command]** Open `~/.synapse-central` in your AI coding assistant (Google Antigravity, Claude Code, Cursor) and trigger the initialization slash command in the chat input:
   ```text
   /synapse-init
   ```
   *What this does:* The agent auto-detects your fork's GitHub origin URL, configures `apm.yml` (`namespace: <your-username>`), and hydrates starter templates (`*.template.md` $\rightarrow$ `*.md`).

#### Step 3: Create Your Personal Overlay Branch
1. **[Terminal Shell]** Create and switch to your private overlay branch:
   ```bash
   cd ~/.synapse-central
   git checkout -b personal
   ```
2. **[Editor / Agent]** Customize your durable developer habits in [`memory/user-profile.md`](memory/user-profile.template.md) and rejected behaviors in [`memory/anti-patterns.md`](memory/anti-patterns.template.md).
3. **[Terminal Shell]** Commit your personal memory overlay:
   ```bash
   git add memory/
   git commit -m "feat: initialize personal memory overlay"
   ```

#### Step 4: Install into Consumer Projects
Choose either APM installation or local symlink mounting:

* **Option A: Install via APM [Terminal Shell]**
  In any consumer project repository where you want to use Synapse:
  ```bash
  apm install github:<your-username>/synapse
  ```
  Then in your agent chat inside that consumer project, run **[Agent Chat Command]**:
  ```text
  /synapse-init
  ```
  *(Scaffolds local `.synapse/state.json`, `.synapse/context.md`, and local `.synapse/memory/`).*

* **Option B: Mount Locally via Symlinks [Terminal Shell]**
  ```bash
  ~/.synapse-central/scripts/link-repo.sh ~/projects/my-project
  ```
  Then in your agent chat inside that consumer project, run **[Agent Chat Command]**:
  ```text
  /resume
  ```

---

## Installation & Distribution

This repository is distributed for public, team, and multi-agent usage via APM (Agent Package Manager), GitHub Releases, and direct repository linking:

### Option 1: Install via APM (Recommended)

Using **APM (Agent Package Manager)**, you can install Synapse into any repository and compile configurations directly to your target harnesses (Claude Code, Cursor, GitHub Copilot, Antigravity):

```bash
# Install directly from GitHub into your active project:
apm install github:dkutzen22/synapse

# Or install from the APM registry / namespace shorthand:
apm install dkutzen22/synapse
```

To declare Synapse as a versioned dependency in your consumer project's `apm.yml`:

```yaml
# In your target project's apm.yml
name: my-project
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
    - git: https://github.com/dkutzen22/synapse
      ref: v1.1.0
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
apm install https://github.com/dkutzen22/synapse/releases/download/v1.1.0/synapse-v1.1.0.zip
```

### Option 3: Local Monorepo & Symlink Mount

For local multi-repo development without APM:

```bash
# 1. Clone this repository centrally (if not already local)
git clone https://github.com/DKutzen22/synapse.git ~/.synapse-central

# 2. Activate the pre-commit governance & security hook in this repository
cd ~/.synapse-central
git config core.hooksPath .githooks

# 3. Mount into your target project repository
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
| **`/doctor`** | Repo Health & Symlink Audit | Audits relative symlinks, Git hooks, distribution checksums, and manifest schemas. |
| **`/harvest`** | Runtime Knowledge Extraction | Extracts runtime debugging lessons, tool quirks, and ADRs for the `synthesist` subagent. |
| **`/scaffold`** | Primitive Generation | Materializes new skills, rules, or subagents conforming to governance specs for the `architect`. |
| **`/promote-memory`** | Empirical Memory Harvesting | Run periodically to harvest project quirks and decisions into central memory. |
| **`/janitor`** | Repo Governance Audit | Audits frontmatter, checks line limits, validates internal links, and verifies repo health. |

---

## Directory Architecture & Core Capabilities

The repository is organized into canonical primitives conforming to APM and Antigravity specifications. Formal lifecycle specifications are codified in [`context/repo-governance-spec.md`](context/repo-governance-spec.md).

```text
synapse/
├── instructions/ # APM *.instructions.md guardrails auto-triggered by applyTo / globs
├── skills/       # Modular skills (<skill-name>/SKILL.md) for Antigravity & Agent Skills
├── agents/       # Isolated subagent definitions with restricted tool grants
├── context/      # Canonical reference specifications & governance contracts
├── memory/       # Central append-only scar tissue, tool quirks, and ADRs
├── state/        # Ephemeral working memory templates (handoff, active-roadmap)
├── scripts/      # Zero-dependency utilities (POSIX sh, Python 3 stdlib)
├── apm.yml       # APM package manifest declaring targets, primitives, and entrypoints
├── hooks.json    # Native lifecycle hooks (PreToolUse/PostToolUse governance)
├── rules.json    # Antigravity rule discovery manifest (points to instructions)
├── skills.json   # Antigravity skill discovery manifest
└── agents.json   # Antigravity subagent discovery manifest
```

### 1. `instructions/` (Always-On Memory & Governance Guardrails)
*Maintainer Guide: [`instructions/README.md`](instructions/README.md) | Trigger: Automatic via `applyTo` / `globs`*
* **[`memory-protocol.instructions.md`](instructions/memory-protocol.instructions.md):** Mandates consulting schemas in `context/` and quirks in `memory/` before modifying database access, contracts, or core interfaces.
* **[`memory-discipline.instructions.md`](instructions/memory-discipline.instructions.md):** Enforces append-only writes, duplicate prevention, and structured schemas across all memory files.
* **[`state-continuity.instructions.md`](instructions/state-continuity.instructions.md):** Checks `.synapse/state.json` / `.synapse/handoff.md` before initiating multi-file edits or architecture plans to prevent context loss.
* **[`synapse-governance.instructions.md`](instructions/synapse-governance.instructions.md):** Enforces lifecycle contracts, line limits (≤60 lines for rules, ≤50 lines for handoffs), and token discipline across all Synapse components.
* **[`subagent-autonomy.instructions.md`](instructions/subagent-autonomy.instructions.md):** Advisory constraints and governance bounds for generative subagents materializing primitives.
* **[`portable-path.instructions.md`](instructions/portable-path.instructions.md):** Enforces relative-path portability and bans machine-specific absolute paths.

### 2. `skills/` (Session Workflows & Runbooks)
*Maintainer Guide: [`skills/README.md`](skills/README.md) | Trigger: Intent match or explicit `/<name>`*
* **[`doctor`](skills/doctor/SKILL.md):** Audits repository health, relative mount symlinks, Git hooks, distribution checksums, and manifest schemas.
* **[`handoff`](skills/handoff/SKILL.md):** Concludes work sessions by overwriting `handoff.md` (under 50 lines), updating roadmaps, and prompting to record empirical quirks.
* **[`harvest`](skills/harvest/SKILL.md):** Extracts runtime debugging lessons, tool quirks, and architectural decisions from session logs for the synthesist.
* **[`janitor`](skills/janitor/SKILL.md):** Audits frontmatter, checks line limits, validates internal links, and verifies state/memory hygiene.
* **[`promote-memory`](skills/promote-memory/SKILL.md):** Periodic harvesting protocol for promoting empirical project quirks and decisions into central memory or rules.
* **[`resume`](skills/resume/SKILL.md):** Restores session briefing from `handoff.md` and `git status -sb`, outputting a 5-bullet summary and awaiting confirmation before changes.
* **[`scaffold`](skills/scaffold/SKILL.md):** Materializes new skills, instructions, or subagents based on observed workflow patterns for the architect.
* **[`synapse-init`](skills/synapse-init/SKILL.md):** Scaffolds local mutable project memory (`.synapse/state.json`, `handoff.md`, `context.md`, `memory/`).

### 3. `agents/` (Isolated Subagents)
*Maintainer Guide: [`agents/README.md`](agents/README.md) | Trigger: Agent orchestration via `invoke_subagent`*
* **[`architect.md`](agents/architect.md):** Generates new skills, rules, and agents from recurring runtime patterns and bottlenecks.
* **[`synthesist.md`](agents/synthesist.md):** Harvests empirical debugging lessons, tool quirks, and architectural decisions into `memory/`.
* **[`janitor.md`](agents/janitor.md):** Audits repository governance, frontmatter validity, line limits, and file hygiene.
* **[`scout.md`](agents/scout.md):** Manages consumer repository mount points, relative symlink integrity, and fleet synchronization.
* **[`explorer.md`](agents/explorer.md):** Read-only codebase reconnaissance, architecture mapping, and dependency exploration.
* **[`verifier.md`](agents/verifier.md):** Adversarial test runner, post-change diff auditor, and quality gate verifier.

### 4. `context/` (Passive Reference Specifications)
*Maintainer Guide: [`context/README.md`](context/README.md) | Access Mode: Read-only reference data (Nouns)*
* **[`repo-governance-spec.md`](context/repo-governance-spec.md):** Formal structural specifications, folder contracts, lifecycle rules, and symlink topology.
* **[`index.md`](context/index.md):** Master index of reference specifications.

### 5. `memory/` (Empirical Scar Tissue & ADRs)
*Maintainer Guide: [`memory/README.md`](memory/README.md) | Access Mode: Append-only*
* **[`architecture-decisions.template.md`](memory/architecture-decisions.template.md):** Clean starter template for Architectural Decision Records (`ADR-001` through `ADR-NNN`).
* **[`tool-quirks.template.md`](memory/tool-quirks.template.md):** Clean starter template for categorized empirical failure modes, version discrepancies, and defensive workarounds.
* **[`user-profile.template.md`](memory/user-profile.template.md):** Clean starter template for durable cross-project developer preferences.
* **[`anti-patterns.template.md`](memory/anti-patterns.template.md):** Clean starter template for rejected agent habits and negative examples.

### 6. `state/` (Ephemeral Working Memory)
*Maintainer Guide: [`state/README.md`](state/README.md) | Access Mode: Overwrite-only / Repo-local*
* **[`handoff.md`](state/handoff.md):** Fixed 6-section template capturing current objective, blockers, next action, and modified files (hard cap of 50 lines).
* **[`active-roadmap.md`](state/active-roadmap.md):** Lightweight milestone checklist tracker.

### 7. `scripts/` (Zero-Dependency CLI Utilities)
*Maintainer Guide: [`scripts/README.md`](scripts/README.md) | Standard: POSIX `sh` or Python 3 stdlib only*
* **[`link-repo.sh`](scripts/link-repo.sh):** Executable shell script mounting Synapse into consumer repositories, creating portability symlinks, and generating IDE pointer entrypoints.
* **[`unlink-repo.sh`](scripts/unlink-repo.sh):** Clean teardown utility removing shared symlinks and `.git/info/exclude` blocks while preserving repo-local state, memory, and local-rules.
* **[`sync-all-repos.sh`](scripts/sync-all-repos.sh):** Fleet management script auditing (`--check`) or updating (`--refresh`) all registered consumer repositories listed in `${XDG_CONFIG_HOME:-$HOME/.config}/agents/linked-repos.txt`.
* **[`hook-handler.py`](scripts/hook-handler.py):** Antigravity lifecycle hook runner enforcing real-time spec protection (`PreToolUse`), handoff line caps, and script syntax verification (`PostToolUse`).
* **[`check-links.py`](scripts/check-links.py):** Scans Markdown and HTML files to verify that all relative local links and image assets exist on disk.
* **[`package-synapse.sh`](scripts/package-synapse.sh):** Cleans caches, asserts `apm.yml` schema, and builds `.zip` release distribution.

---

## Mounting Synapse into Target Repositories

To standardize AI memory and state tracking across your repositories, run [`scripts/link-repo.sh`](scripts/link-repo.sh) to mount Synapse:

```bash
./scripts/link-repo.sh /path/to/target-repo
```

### What `link-repo.sh` Does:
1. **Dynamic Relative Symlinks:** Computes the relative offset from `<target>/.agents` back to the central repository and creates strictly relative symlinks for `instructions`, `skills`, `agents`, `context`, `scripts`, `hooks.json`, and discovery manifests (`rules.json`, `skills.json`, `agents.json`, `apm.yml`). Zero hardcoded absolute paths.
2. **Clean Git Exclusion (`.git/info/exclude`):** Idempotently appends all global symlinks to the target's `.git/info/exclude`, ensuring mount artifacts never pollute `<target>`'s git status or commit history.
3. **Local Rules Directory (`local-rules/`):** Initializes `.agents/local-rules/` for project-specific rules, which are tracked in target git and guaranteed to survive `link-repo.sh --force`.
5. **Initializes Local State & Memory:** Copies clean starter templates for `state/handoff.md`, `state/active-roadmap.md`, `memory/project-decisions.md`, and `memory/project-quirks.md`.
6. **Generates Root IDE Entrypoints:** Creates lightweight pointer files (`GEMINI.md` and `CLAUDE.md`) in `<target>/` instructing any agent to follow `.agents` rules and local rules.
7. **Optional Standalone CI Scripts (`--ci-copy`):** Copies `check-links.py` into `<target>/.github/scripts/` so GitHub Actions workflows run independently of local symlinks.
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
3. **Rules Frontmatter & Size:** Enforces `globs:` in frontmatter and a ≤60 line limit on rules.
4. **Context Declarative Tone:** Scans `context/*.md` to ban imperative agent instructions (`You must`, `Always run`, `Step 1:`).
5. **Context Protection:** Guards against accidental specification changes unless tagged with `[spec-update]` or bypassed via `--no-verify`.
6. **Secret & Scratch Path Scan:** Blocks commits containing hardcoded private keys or cluster scratch paths.
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

* **APM Manifest (`apm.yml`):** Specifies package metadata (`dkutzen22/synapse`), version (`1.1.0`), primitive directories, and target harnesses.
* **Line Ending Governance (`.gitattributes`):** Normalizes all text files to LF line endings (`eol=lf`) and marks binary/archive formats explicitly.
* **Build Command (`make package`):** Cleans transient caches and calls [`scripts/package-synapse.sh`](scripts/package-synapse.sh) to assemble `dist/synapse-v<version>.zip` and calculate its SHA-256 checksum.
* **Tag-Triggered CI/CD ([`.github/workflows/release.yml`](.github/workflows/release.yml)):** Automatically runs on semantic git tags (`v*.*.*`), validates `apm.yml`, executes pre-commit governance, compiles the distribution zip, and publishes a GitHub Release.
