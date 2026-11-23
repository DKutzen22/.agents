---
name: janitor
description: >
  Command entrypoint to audit repository governance. Catches /janitor and delegates execution to the janitor subagent.
---

# /janitor

User-facing command interface for auditing and cleaning repository governance across Synapse against the formal specification in [`context/repo-governance-spec.md`](../../context/repo-governance-spec.md).

> [!NOTE]
> **Dispatch Flow:** `/janitor` (Skill Entrypoint) $\longrightarrow$ [`agents/janitor.md`](../../agents/janitor.md) (Execution Worker).
> Skills trigger subagents; subagents never trigger skills.

## Execution Steps

### 1. Detect Mode & Target Scope
Determine whether running in **Central Hub Mode** or **Target Repo Mode**:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"
if [ -f "context/repo-governance-spec.md" ] && [ ! -L "context" ]; then
    AUDIT_MODE="central"
else
    AUDIT_MODE="target"
fi
echo "==> Preparing Janitor audit in $AUDIT_MODE mode at $REPO_ROOT"
```

### 2. Delegate to Janitor Subagent
Invoke the specialized **`janitor`** subagent (`agents/janitor.md`) with the target audit mode:
```text
Task: Perform governance, line cap, frontmatter, and link integrity audit in mode: <AUDIT_MODE>.
Governance Spec: context/repo-governance-spec.md.
Tools: scripts/check-links.py, .githooks/pre-commit.
```

### 3. Subagent Audit Scope
The `janitor` subagent verifies:
- **Central Mode:** Validates YAML frontmatter across `skills/`, `instructions/`, and `agents/`. Checks line caps (rules ≤45 lines, handoff ≤50 lines, agents ≤80 lines). Audits executable scripts (`scripts/*.sh`, `scripts/*.py`) and runs `python3 scripts/check-links.py --root .`.
- **Target Mode:** Validates `.synapse/state.json`, `.synapse/handoff.md` line count (≤50 lines), relative mount symlinks, and `.git/info/exclude` blocks.
- **Path Scanner:** Scans tracked files for hardcoded machine-specific absolute paths (`/Users/`, `/home/`, `C:\`).
- **Memory Compaction Pass:** Flags duplicate or superseded entries in `memory/tool-quirks.md` and relocates them to `memory/archive/YYYY-MM.md`, keeping active files within line limits while honoring append-only governance.

### 4. Output Audit Summary
The `janitor` subagent emits a structured audit report highlighting passed checks and required remediation steps.
