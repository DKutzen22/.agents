---
name: promote-memory
description: >
  Periodic hygiene workflow for reviewing repo-local memory across active projects
  and promoting generalizable empirical lessons into central memory or rules.
  Trigger with /promote-memory or ask to harvest/promote project memory.
---

# /promote-memory

Hygiene workflow for harvesting empirical tool quirks and architectural patterns from linked repositories into the user's central Synapse knowledge base and fork origin.

## Execution Steps

### 1. Harvest Local Project Memory
Scan registered project repositories for local decision and quirk files:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cat "$REPO_ROOT/.synapse/memory/project-quirks.md" 2>/dev/null || cat "$REPO_ROOT/.agents/memory/project-quirks.md" 2>/dev/null || true
cat "$REPO_ROOT/.synapse/memory/project-decisions.md" 2>/dev/null || cat "$REPO_ROOT/.agents/memory/project-decisions.md" 2>/dev/null || true
```

### 2. Evaluate Promotion Criteria (The 2-Project Rule)
Evaluate candidate entries against generalizability criteria:
- **Project-Specific (Leave in Target):** Local dataset quirks, single-use server URLs, or repository-specific workarounds stay in `<target>/.synapse/memory/` (or `<target>/.agents/memory/`).
- **Generalizable (Promote to Central Memory):** Tool bugs appearing across ≥2 repositories or representing universal failure modes.
- **Rule Candidates (Promote to Rules):** Invariants that are deterministically enforceable via linters or AST checks (must keep target rule ≤45 lines).

### 3. Integrate into Central Memory
- Append tool bugs to `memory/tool-quirks.md` under the appropriate category (`Quirk`, `Failure Mode`, `Workaround`).
- Record cross-cutting architectural choices in `memory/architecture-decisions.md` using the canonical ADR format (`ADR-NNN`, `Status`, `Context`, `Decision`, `Consequences`).
- Deduplicate existing entries before writing.

### 4. Target Fork Origin Remote
When committing and pushing promoted memory entries, target the user's own fork origin rather than upstream `dkutzen22/synapse`:
```bash
CENTRAL_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [ -L ".agents/skills" ]; then
    CENTRAL_DIR=$(cd "$(readlink .agents/skills)/.." && pwd -P)
fi
FORK_ORIGIN=$(git -C "$CENTRAL_DIR" remote get-url origin 2>/dev/null || echo "origin")
echo "==> Promoting memory to user fork remote: $FORK_ORIGIN"
git -C "$CENTRAL_DIR" add memory/
git -C "$CENTRAL_DIR" commit -m "chore(memory): promote empirical quirks and ADRs from active projects"
git -C "$CENTRAL_DIR" push origin HEAD
```

### 5. Prune Local Project Memory
Once promoted centrally, condense or archive the entry in the target project's `.agents/memory/` file with a reference to the central memory document.

### 6. Verify Repository Health
```bash
python3 scripts/check-links.py --root .
sh .githooks/pre-commit --all
```
