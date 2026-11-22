---
name: janitor
description: >
  Audits and cleans repository governance: verifies frontmatter, line limits,
  skills structure, broken cross-references, and state/memory hygiene.
  Trigger with /janitor or ask to run repository cleanup / janitor audit.
---

# /janitor

Audit and maintain repository governance across Synapse against the formal specification in [`context/repo-governance-spec.md`](../../context/repo-governance-spec.md).

> [!NOTE]
> **Trigger:** Invoke directly via `/janitor` or request a repository governance audit.

## Execution Steps

### 1. Detect Mode & Target Scope
Determine whether running in **Central Hub Mode** or **Target Repo Mode**:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
if [ -f "context/repo-governance-spec.md" ] && [ ! -L "context" ]; then
    AUDIT_MODE="central"
else
    AUDIT_MODE="target"
fi
echo "==> Running Janitor in $AUDIT_MODE mode at $REPO_ROOT"
```

### 2. Audit by Mode

#### A. Central Hub Mode Checks:
* **`rules/`:** Check that every `.md` file (except `README.md`) has `globs:` string in YAML frontmatter and does not exceed line limits (≤45 target, 60 hard cap).
* **`skills/`:** Verify no loose `.md` files in `skills/` root (except `README.md`). Verify every subdirectory contains a valid `SKILL.md` with `name` and `description` in YAML frontmatter.
* **`agents/`:** Verify YAML frontmatter declaring `subagent: true`, `mainAgent: false`, model tier (`pro`/`flash`/`flash_lite`), and `tools:` list.
* **`context/`:** Check that Markdown files in `context/` (excluding `README.md` and `repo-governance-spec.md`) contain declarative reference data and zero imperative agent directives (`You must`, `Always run`, `Step 1:`).
* **`scripts/`:** Verify all files in `scripts/` have executable permissions (`chmod +x`), pass syntax checks (`sh -n` or `python3 -m py_compile`), and support `--help`.
* **No `commands/` Drift:** Ensure no stray `commands/` directory exists in the central repo.
* **Manifests & Hooks:** Verify `hooks.json`, `rules.json`, `skills.json`, `agents.json` exist and contain valid JSON.

#### B. Target Repo Mode Checks:
* **Symlink Resolution:** Check that all relative symlinks in `.agents/` (`rules`, `skills`, `agents`, `context`, `scripts`, `hooks.json`, `rules.json`, `skills.json`, `agents.json`, `commands`) resolve to existing directories/files on disk (`test -e .agents/<item>`).
* **Git Exclude Contract:** Verify `.git/info/exclude` contains the `# --- .agents global symlinks ---` block so mounts are never committed to target git history.
* **Local Rules:** If `.agents/local-rules/` contains `.md` files, verify each has valid `globs:` frontmatter.
* **Local State Hygiene:** Check `.agents/state/handoff.md` line count (≤50 lines, 6 mandatory headers) and prune completed milestones in `.agents/state/active-roadmap.md`.

### 3. Absolute Path Audit (Both Modes)
Scan tracked repository files for hardcoded machine-specific absolute paths:
```bash
git grep -n -E '(/Users/[a-zA-Z0-9_.-]+|/home/[a-zA-Z0-9_.-]+|[A-Za-z]:\\[a-zA-Z0-9_.-]+)' | grep -v '# allow-path' || true
```
Every detected path must be replaced with repo-relative paths (e.g., `.agents/state/handoff.md`) or explicitly marked with `# allow-path`.

### 4. Broken Cross-Reference Check
Extract and validate all local path cross-references:
```bash
python3 scripts/check-links.py --root .
```
Flag any dangling pointers or broken links.

### 5. State & Memory Hygiene
* **`state/handoff.md`:** Count lines. If >50 lines, condense the content while preserving the 6 canonical section headers.
* **`state/active-roadmap.md`:** Scan for completed items (`- [x]`). Recommend archiving or pruning completed milestones.
* **`memory/*.md`:** Check for duplicate ADR numbers or duplicate tool quirk headings.
* **Rule-to-Memory Promotion:** Check `rules/` for any newly introduced tool quirks that should be extracted into `memory/bioinfo-tool-quirks.md`.

### 4. Audit Reporting & Safe Remediation
Output a consolidated health report in Markdown:

| Status | Path | Check Category | Issue Detected | Action Taken / Proposed Fix |
|---|---|---|---|---|
| 🟢 OK | `rules/r-package-standards.md` | Frontmatter | Valid YAML with globs (54 lines) | None needed |
| ⚠️ WARN | `state/handoff.md` | Line Cap | Approaching 45 lines | Condense completed items |
| 🔴 FAIL | `skills/old-tool.md` | Structure | Loose file in skills root | Move to `skills/old-tool/SKILL.md` |

Remediation rules:
- **Auto-Fix (Safe):** Reformatting frontmatter, removing whitespace, moving loose skill files into standard layout, pruning confirmed completed roadmap items.
- **Requires Confirmation (Unsafe):** Modifying any file in `context/` or deleting any entry from `memory/`.

## Success Criteria
- Zero missing frontmatter blocks across `rules/`, `skills/`, and `agents/`.
- All `scripts/` files are executable and pass syntax checks.
- Zero broken internal cross-references across documentation.
- `state/handoff.md` strictly within the 50-line cap.
- Pre-commit hook `.githooks/pre-commit` passes with exit code 0.
