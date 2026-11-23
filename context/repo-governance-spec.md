# Synapse Repository Governance Specification

This document provides the formal structural and operational specification for the Synapse (`.agents`)
repository. It serves as the single source of truth for repository layout, lifecycle contracts,
frontmatter schemas, and symlinking topology across all integrated tech stacks.

---

## 1. Folder Contract Table

| Folder | Purpose | Read Trigger | Write Trigger | Lifespan | Line Limit | Allowed Content | Banned Content |
|---|---|---|---|---|---|---|---|
| `instructions/` | Always-on behavioral guardrails and APM instructions | Auto-evaluated on file matching `applyTo` / `globs` | New cross-cutting standard or project convention | Permanent | ≤45 lines (hard cap 60) | Scoped YAML frontmatter (`applyTo`, `globs`), deterministic constraints | Catch-all `**/*` without justification, narrative tutorials, tool output quirks |
| `skills/` | Modular session workflows and AgentSkills capabilities | Intent match on description OR explicit `/<name>` invocation | New domain runbook or repeatable workflow | Permanent | None (modular sections) | Procedural checklists, CLI flags, troubleshooting tables in `<name>/SKILL.md` | Loose `.md` files at `skills/` root, non-standard directory layouts |
| `agents/` | Isolated subagent definitions with scoped tooling | Delegated execution via agent orchestration tool | New specialized subagent role or persona | Permanent | ≤80 lines | YAML frontmatter (`description`, `tools`), review checklists, scope definitions | Hardcoded credentials, unrestricted tool allocations |
| `context/` | Canonical passive reference data, schemas, and resource profiles | Triggered by gated rules (`instructions/memory-protocol.instructions.md`) | Formal specification change or schema migration | Permanent | None (normative) | DDL scripts, lookup tables, column mapping dictionaries, hardware tiers | Imperative agent instructions ("You must", "Always run", "Step 1:") |
| `memory/` | 3-Tier memory: Tier 2 starter templates/hydrated files & Tier 3 local ADRs/quirks | Scoped rule triggers (`instructions/memory-protocol.instructions.md`) | Discovery of new tool quirks, parser bugs, or accepted ADRs | Append-Only & Archive | None (itemized entries) | Structured ADRs (`ADR-NNN`), tool quirks, `*.template.md`, `archive/` | Speculative advice, unverified bug notes, overwriting existing decisions |
| `state/` | Ephemeral working memory for inter-session continuity | Session start (`/resume`) or rule gate (`instructions/state-continuity.instructions.md`) | Session conclusion (`/handoff`) or milestone transition | Overwrite-Only | Hard cap 50 lines (`handoff.md`) | Fixed 6-section handoff schema, checkbox roadmap tracking (`active-roadmap.md`) | Unbounded append logs, scratch files without `.tmp` suffix, commit logs |
| `scripts/` | Zero-dependency repository tooling, linking, and verification scripts | Automated workflows (`/janitor`, Git hooks, linking) | New repo management or verification utility | Permanent | None (modular) | POSIX `sh` (`set -eu`) and Python 3 stdlib CLI scripts supporting `--help` | External dependencies (pip/virtualenvs), non-executable scripts, analysis pipelines |

> [!NOTE]
> **Instructions & Primitives:** APM natively deploys from `instructions/`. For Antigravity compatibility, `rules.json` points directly to `instructions`.

---

## 2. Frontmatter & Naming Schemas

### A. Instructions (`instructions/<kebab-case-name>.instructions.md`)
* **Path Pattern:** `instructions/[a-z0-9-]+.instructions.md`
* **Size Constraint:** Target ≤45 lines; absolute maximum 60 lines.
* **Frontmatter Schema:**
  ```yaml
  ---
  description: Concise purpose statement
  applyTo: "pattern/one/**, pattern/two/*.ext"
  globs: "pattern/one/**, pattern/two/*.ext"
  ---
  ```
* **Constraints:** Must declare specific globs using comma-separated strings. Catch-all `**/*` is prohibited unless explicitly justified. Use relative file references to consult context specs and tool quirks.

### B. Skills (`skills/<kebab-case-name>/SKILL.md`)
* **Path Pattern:** `skills/[a-z0-9-]+/SKILL.md`
* **Hierarchy:** Every skill must reside in a dedicated subdirectory. Loose `.md` files in `skills/` root are invalid (except `skills/README.md`).
* **Frontmatter Schema:**
  ```yaml
  ---
  name: kebab-case-name
  description: >
    Concise explanation of purpose and triggers.
    Trigger with /<kebab-case-name> or ask to run <task>.
  ---
  ```
* **Scope:** Encompasses both memory playbooks (e.g. `promote-memory`) and callable workflows (`janitor`, `resume`, `handoff`, `synapse-init`).

### C. Scripts (`scripts/<name>.<ext>`)
* **Path Pattern:** `scripts/[a-z0-9_-]+\.(sh|py)`
* **Zero Dependencies:** Strictly POSIX `sh` (`set -eu`) or Python 3 standard library (`sqlite3`, `pathlib`, `re`, `argparse`, `sys`).
* **CLI Contract:** Executable (`chmod +x`), implements `--help` / `-h`, exits `0` on success and `1` on failure.

### D. Agents (`agents/<kebab-case-name>.md`)
* **Path Pattern:** `agents/[a-z0-9-]+.md`
* **Frontmatter Schema:**
  ```yaml
  ---
  name: kebab-case-name
  description: Specialized subagent role and domain focus
  subagent: true
  mainAgent: false
  model: "pro"  # "pro", "flash", or "flash_lite"
  tools:
    - tool_name_1
    - tool_name_2
  ---
  ```
* **Constraints:** Declare explicit tools, `subagent: true`, and model routing tier. Scoped role only.

### E. Context (`context/<kebab-case-name>.<ext>`)
* **Allowed Extensions:** `.sql`, `.md`, `.json`, `.yaml`
* **Style:** Declarative, passive reference specifications and lookups.
* **Forbidden Elements:** Direct second-person imperatives (`"You must"`, `"Always run"`, `"Step 1:"`).

### F. Memory (`memory/<kebab-case-name>.md`)
* **Access Mode:** Append-only (active ledgers) and non-destructive archival (`memory/archive/`).
* **3-Tier Hierarchy:**
  - **Tier 1:** Scoped instruction rules (`instructions/`).
  - **Tier 2:** Git-backed cross-project user profile (`memory/user-profile.md`) and negative guardrails (`memory/anti-patterns.md`).
  - **Tier 3:** Repo-local architecture decisions (`project-decisions.md`) and quirks (`project-quirks.md`).
* **Structure:**
  - Architecture decisions: Strict ADR format (`Status`, `Context`, `Decision`, `Consequences`).
  - Empirical tool quirks: Categorized entries (`Quirk`, `Failure Mode`, `Workaround`).
* **Validation & Compaction:** Prior check for duplicate entries required before appending. Non-destructive compaction moves superseded entries into `memory/archive/YYYY-MM.md`.

### G. State Files
* **`state/handoff.md`:** Overwrite-only, hard cap of 50 lines, 6 mandatory headers.
* **`state/active-roadmap.md`:** Markdown task items (`- [ ]` / `- [x]`) pruned periodically.

---

## 3. Relative-Path Portability Rule

To guarantee multi-repo interoperability across diverse user environments and continuous integration runners, all repository components must strictly adhere to the **Relative-Path Rule**:

1. **Zero Machine-Specific Absolute Paths:**
   - Never write `/Users/...`, `/home/...`, or `C:\...` paths into any generated symlink, JSON manifest, rule, skill, root pointer (`GEMINI.md`/`CLAUDE.md`), or documentation file.
   - Hardcoded paths are blocked by `.githooks/pre-commit` and flagged by `/janitor` (unless explicitly annotated with `# allow-path`).

2. **Dynamic Root Resolution Contracts:**
   - **Static Context & Schemas (`context/*`):** Helper scripts must resolve canonical DDL and formats relative to `Path(__file__).resolve().parent.parent / "context"` (falling back to `.agents/context/` if copied into CI directories).
   - **Ephemeral State & Working Memory (`state/*`, `memory/*`):** Agents must always determine the project root via `git rev-parse --show-toplevel` and read/write `.agents/state/handoff.md`, `.agents/state/active-roadmap.md`, and `.agents/memory/project-decisions.md` directly. Never follow symlinks back into the central `.agents` repository templates.

---

## 4. Target Repository Mount & Git Tracking Contract

To balance centralized standardization with repo-specific state isolation across projects, `scripts/link-repo.sh` mounts the central repository using strict relative paths and 3-tier Git tracking separation:

```text
[ Target Repository Root: <target>/ ]
  ├── .git/info/exclude ─────────────► Ignores global symlinks & Tier 2 memory (keeps .gitignore clean)
  ├── .gitignore        ─────────────► Ignores transient scratch state (.agents/state/*.tmp.md)
  ├── GEMINI.md / CLAUDE.md ─────────► Committed repo-relative entrypoints pointing to .agents/
  └── .agents/
      ├── instructions/ ─────────────► Relative symlink -> <rel-path-to-central>/instructions
      ├── skills/       ─────────────► Relative symlink -> <rel-path-to-central>/skills
      ├── agents/       ─────────────► Relative symlink -> <rel-path-to-central>/agents
      ├── context/      ─────────────► Relative symlink -> <rel-path-to-central>/context
      ├── scripts/      ─────────────► Relative symlink -> <rel-path-to-central>/scripts
      ├── hooks.json    ─────────────► Relative symlink -> <rel-path-to-central>/hooks.json
      ├── rules.json    ─────────────► Relative symlink -> <rel-path-to-central>/rules.json
      ├── skills.json   ─────────────► Relative symlink -> <rel-path-to-central>/skills.json
      ├── agents.json   ─────────────► Relative symlink -> <rel-path-to-central>/agents.json
      ├── apm.yml       ─────────────► Relative symlink -> <rel-path-to-central>/apm.yml
      ├── local-rules/  ─────────────► COMMITTED: Repo-specific rule overrides (survives --force)
      ├── state/        ─────────────► COMMITTED: Local session handoff & roadmap state
      └── memory/       ─────────────► LOCAL & TIER 2:
          ├── user-profile.md  ──────► Relative symlink (Tier 2 cross-project profile, excluded)
          ├── anti-patterns.md ──────► Relative symlink (Tier 2 negative guardrails, excluded)
          ├── project-decisions.md ──► COMMITTED (Tier 3: local ADRs)
          └── project-quirks.md    ──► COMMITTED (Tier 3: local quirks)
```

### Mount Distribution Guidelines
1. **Tier 1 — Global Symlinks (Excluded from Target Git):** `instructions/`, `skills/`, `agents/`, `context/`, `scripts/`, `hooks.json`, and discovery manifests are relative symlinks (`$REL_CENTRAL/...`) excluded via `<target>/.git/info/exclude`. They propagate central updates instantly without polluting the target repository's git status or commit history.
2. **Tier 2 — Cross-Project User Memory (Excluded from Target Git):** `memory/user-profile.md` and `memory/anti-patterns.md` are relative symlinks into the central repository, excluded via `.git/info/exclude`, providing portable developer preferences and negative guardrails across all linked repositories.
3. **Tier 3 — Repo-Local Files (Committed to Target Git):** `state/`, local `memory/` (`project-decisions.md`, `project-quirks.md`), `local-rules/`, `GEMINI.md`, and `CLAUDE.md` are genuine files version-controlled inside the consumer repository.
4. **Local Rules Directory (`.agents/local-rules/`):** Project-specific rules live here, allowing repositories to add domain rules that complement central guardrails. `link-repo.sh --force` will never overwrite or purge `local-rules/`, `state/`, or local `memory/`.
5. **CI Script Decoupling (`--ci-copy`):** When `--ci-copy` is passed, `check-links.py` is copied into `<target>/.github/scripts/` as a tracked file so GitHub Actions workflows run independently of local symlinks.
