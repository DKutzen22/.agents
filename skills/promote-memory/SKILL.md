---
name: promote-memory
description: >
  Periodic hygiene workflow for reviewing repo-local memory across active projects
  and promoting generalizable empirical lessons into central memory or rules.
  Trigger with /promote-memory or ask to harvest/promote project memory.
---

# /promote-memory

Hygiene workflow for harvesting empirical tool quirks and architectural patterns from linked repositories (`PHANTOM`, `Pharos`, `kutzen.org`) into the central Synapse knowledge base.

## Execution Steps

### 1. Harvest Local Project Memory
Scan registered project repositories for local decision and quirk files:
```bash
# Using sync-all-repos registry or active target:
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
# Check APM native .synapse/memory or legacy .agents/memory:
cat "$REPO_ROOT/.synapse/memory/project-quirks.md" 2>/dev/null || cat "$REPO_ROOT/.agents/memory/project-quirks.md" 2>/dev/null || true
cat "$REPO_ROOT/.synapse/memory/project-decisions.md" 2>/dev/null || cat "$REPO_ROOT/.agents/memory/project-decisions.md" 2>/dev/null || true
```

### 2. Evaluate Promotion Criteria (The 2-Project Rule)
Evaluate candidate entries against generalizability criteria:
- **Project-Specific (Leave in Target):** Local dataset quirks, single-use server URLs, or repository-specific workarounds stay in `<target>/.synapse/memory/` (or `<target>/.agents/memory/`).
- **Generalizable (Promote to Central Memory):** Tool bugs (e.g., Foldseek memory spikes, RSQLite locking, Biopython parser edge cases) appearing across ≥2 repositories or representing universal failure modes.
- **Rule Candidates (Promote to Rules):** Invariants that are deterministically enforceable via linters or AST checks (must keep target rule ≤45 lines).

### 3. Integrate into Central Memory
- Append tool bugs to `memory/bioinfo-tool-quirks.md` under the appropriate category (`Quirk`, `Failure Mode`, `Workaround`).
- Record cross-cutting architectural choices in `memory/architecture-decisions.md` using the canonical ADR format (`ADR-NNN`, `Status`, `Context`, `Decision`, `Consequences`).
- Deduplicate existing entries before writing.

### 4. Prune Local Project Memory
Once promoted centrally, condense or archive the entry in the target project's `.agents/memory/` file with a reference to the central memory document.

### 5. Verify Repository Health
```bash
python3 scripts/check-links.py --root .
sh .githooks/pre-commit --all
```
