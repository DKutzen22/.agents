# Repository Governance Specification

This document provides the formal structural and operational specification for the `.agents`
repository. It serves as the single source of truth for repository layout, lifecycle contracts,
frontmatter schemas, and symlinking topology across all integrated tech stacks.

---

## 1. Folder Contract Table

| Folder | Purpose | Read Trigger | Write Trigger | Lifespan | Line Limit | Allowed Content | Banned Content |
|---|---|---|---|---|---|---|---|
| `rules/` | Always-on behavioral guardrails and coding standards | Auto-evaluated on file matching `globs` | New cross-cutting standard or project convention | Permanent | ≤45 lines (hard cap 60) | Scoped YAML frontmatter, deterministic constraints, lint/style rules | Catch-all `**/*` without justification, narrative tutorials, tool output quirks |
| `skills/` | Unified home for domain playbooks and callable `/workflow` skills | Intent match on description OR explicit `/<name>` invocation | New domain runbook or repeatable workflow | Permanent | None (modular sections) | Procedural checklists, CLI flags, troubleshooting tables in `<name>/SKILL.md` | Loose `.md` files at `skills/` root, non-standard directory layouts |
| `agents/` | Isolated subagent definitions with scoped tooling | Delegated execution via agent orchestration tool | New specialized subagent role or persona | Permanent | ≤80 lines | YAML frontmatter (`description`, `tools`), review checklists, scope definitions | Hardcoded credentials, unrestricted tool allocations |
| `context/` | Canonical passive reference data, schemas, and resource profiles | Triggered by gated rules (`rules/context-and-memory-gates.md`) | Formal specification change or schema migration | Permanent | None (normative) | DDL scripts, lookup tables, column mapping dictionaries, hardware tiers | Imperative agent instructions ("You must", "Always run", "Step 1:") |
| `memory/` | Empirical scar tissue, tool quirks, and architectural decisions | Scoped rule triggers (`rules/context-and-memory-gates.md`) | Discovery of new tool quirks, parser bugs, or accepted ADRs | Append-Only | None (itemized entries) | Structured ADRs (`ADR-NNN`), tool quirk entries, deduplicated failure patterns | Speculative advice, unverified bug notes, overwriting existing decisions |
| `state/` | Ephemeral working memory for inter-session continuity | Session start (`/resume`) or rule gate (`rules/state-continuity.md`) | Session conclusion (`/handoff`) or milestone transition | Overwrite-Only | Hard cap 50 lines (`handoff.md`) | Fixed 6-section handoff schema, checkbox roadmap tracking (`active-roadmap.md`) | Unbounded append logs, scratch files without `.tmp` suffix, commit logs |
| `scripts/` | Zero-dependency repository tooling, linking, and verification scripts | Automated workflows (`/janitor`, Git hooks, linking) | New repo management or verification utility | Permanent | None (modular) | POSIX `sh` (`set -eu`) and Python 3 stdlib CLI scripts supporting `--help` | External dependencies (pip/virtualenvs), non-executable scripts, analysis pipelines |

> [!NOTE]
> **Commands Deprecation:** Antigravity does not use a separate `commands/` directory; all slash workflows live in `skills/<name>/SKILL.md`. For compatibility with other CLI agents (such as Claude Code) expecting a `.agents/commands/` path, `scripts/link-repo.sh` generates a relative symlink `.agents/commands -> skills` inside consumer repositories.

---

## 2. Frontmatter & Naming Schemas

### A. Rules (`rules/<kebab-case-name>.md`)
* **Path Pattern:** `rules/[a-z0-9-]+.md`
* **Size Constraint:** Target ≤45 lines; absolute maximum 60 lines.
* **Frontmatter Schema:**
  ```yaml
  ---
  trigger: glob
  globs: "pattern/one/**, pattern/two/*.ext"
  description: Concise purpose statement
  ---
  ```
* **Constraints:** Must declare specific globs using comma-separated strings (YAML array syntax is ignored by Antigravity). Catch-all `**/*` is prohibited unless explicitly justified. Use `@../path` imports (up to 24 KB) to reference context specs and tool quirks.

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
* **Scope:** Encompasses both domain runbooks (e.g. `phage-annotation-parsers`) and callable workflows (`janitor`, `resume`, `handoff`).

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
* **Access Mode:** Append-only.
* **Structure:**
  - Architecture decisions: Strict ADR format (`Status`, `Context`, `Decision`, `Consequences`).
  - Empirical tool quirks: Categorized entries (`Quirk`, `Failure Mode`, `Workaround`).
* **Validation:** Prior check for duplicate entries required before appending.

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

To balance centralized standardization with repo-specific state isolation across projects (`PHANTOM`, `Pharos`, `kutzen.org`), `scripts/link-repo.sh` mounts the central repository using strict relative paths and two-tier Git tracking separation:

```text
[ Target Repository Root: <target>/ ]
  ├── .git/info/exclude ─────────────► Ignores all .agents global symlinks (keeps .gitignore clean)
  ├── .gitignore        ─────────────► Ignores transient scratch state (.agents/state/*.tmp.md)
  ├── GEMINI.md / CLAUDE.md ─────────► Committed repo-relative entrypoints pointing to .agents/
  └── .agents/
      ├── rules/        ─────────────► Relative symlink -> <rel-path-to-central>/rules
      ├── skills/       ─────────────► Relative symlink -> <rel-path-to-central>/skills
      ├── agents/       ─────────────► Relative symlink -> <rel-path-to-central>/agents
      ├── context/      ─────────────► Relative symlink -> <rel-path-to-central>/context
      ├── scripts/      ─────────────► Relative symlink -> <rel-path-to-central>/scripts
      ├── hooks.json    ─────────────► Relative symlink -> <rel-path-to-central>/hooks.json
      ├── rules.json    ─────────────► Relative symlink -> <rel-path-to-central>/rules.json
      ├── skills.json   ─────────────► Relative symlink -> <rel-path-to-central>/skills.json
      ├── agents.json   ─────────────► Relative symlink -> <rel-path-to-central>/agents.json
      ├── commands      ─────────────► Relative sibling symlink -> skills (IDE compatibility)
      ├── local-rules/  ─────────────► COMMITTED: Repo-specific rule overrides (survives --force)
      ├── state/        ─────────────► COMMITTED: Local session handoff & roadmap state
      └── memory/       ─────────────► COMMITTED: Local project-decisions.md & project-quirks.md
```

### Mount Distribution Guidelines
1. **Tier 1 — Global Symlinks (Excluded from Target Git):** `rules/`, `skills/`, `agents/`, `context/`, `scripts/`, `hooks.json`, and discovery manifests are relative symlinks (`$REL_CENTRAL/...`) excluded via `<target>/.git/info/exclude`. They propagate central updates instantly without polluting the target repository's git status or commit history.
2. **Tier 2 — Repo-Local Files (Committed to Target Git):** `state/`, `memory/`, `local-rules/`, `GEMINI.md`, and `CLAUDE.md` are genuine files initialized from templates and version-controlled inside the consumer repository.
3. **Local Rules Directory (`.agents/local-rules/`):** Project-specific rules live here, allowing repositories to add domain rules that complement central guardrails. `link-repo.sh --force` will never overwrite or purge `local-rules/`, `state/`, or `memory/`.
4. **CI Script Decoupling (`--ci-copy`):** When `--ci-copy` is passed, `validate-gbk-sqlite.py` and `check-links.py` are copied into `<target>/.github/scripts/` as tracked files so GitHub Actions workflows run independently of local symlinks.
