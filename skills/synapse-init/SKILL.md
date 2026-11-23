---
name: synapse-init
description: >
  Initializes local workspace state, context, and memory in a consumer project.
  Scaffolds .synapse/state.json, .synapse/context.md, and local memory directories.
  Trigger with /synapse-init or ask to initialize Synapse workspace state.
---

# /synapse-init

Scaffolds mutable, project-local state, context, and memory in the workspace root, keeping project memory completely isolated from immutable package files in `apm_modules/` or central symlinks.

> [!NOTE]
> **Trigger:** Invoke directly via `/synapse-init` or request workspace state initialization.

## Execution Steps

### 1. Resolve Workspace Root
Determine the active repository root using Git:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"
```

### 2. Scaffold `.synapse/` Directory Structure & Hydrate Memory
Create the dedicated project-local state and memory directory:
```bash
mkdir -p "$REPO_ROOT/.synapse/memory"
mkdir -p "$REPO_ROOT/.synapse/local-rules"
mkdir -p "$REPO_ROOT/.synapse/state"

# Hydrate central memory files from starter templates if missing
if [ -d "$REPO_ROOT/memory" ]; then
    for tpl in "$REPO_ROOT/memory"/*.template.md; do
        if [ -f "$tpl" ]; then
            target_mf="$REPO_ROOT/memory/$(basename "$tpl" .template.md).md"
            if [ ! -f "$target_mf" ]; then
                cp "$tpl" "$target_mf"
                echo "✓ Hydrated $target_mf from template"
            fi
        fi
    done
fi

# Hydrate consumer workspace memory from starter templates if missing
if [ ! -f "$REPO_ROOT/.synapse/memory/project-decisions.md" ]; then
    if [ -f "$REPO_ROOT/memory/architecture-decisions.template.md" ]; then
        cp "$REPO_ROOT/memory/architecture-decisions.template.md" "$REPO_ROOT/.synapse/memory/project-decisions.md"
    else
        echo "# Project Architecture Decisions" > "$REPO_ROOT/.synapse/memory/project-decisions.md"
    fi
fi
if [ ! -f "$REPO_ROOT/.synapse/memory/project-quirks.md" ]; then
    if [ -f "$REPO_ROOT/memory/tool-quirks.template.md" ]; then
        cp "$REPO_ROOT/memory/tool-quirks.template.md" "$REPO_ROOT/.synapse/memory/project-quirks.md"
    else
        echo "# Project Tool Quirks" > "$REPO_ROOT/.synapse/memory/project-quirks.md"
    fi
fi
```

### 3. Synchronize Fork Owner in `apm.yml`
When running in a fork of the framework repository, auto-detect the origin remote and update `apm.yml`:
```bash
ORIGIN_URL=$(git remote get-url origin 2>/dev/null || true)
if [ -n "$ORIGIN_URL" ] && [ -f "$REPO_ROOT/apm.yml" ]; then
    python3 -c '
import re, sys, pathlib
origin = sys.argv[1].strip()
m = re.search(r"[:/](?P<owner>[^/]+)/(?P<repo>[^/]+?)(?:\.git)?$", origin)
if m:
    owner, repo = m.group("owner"), m.group("repo")
    p = pathlib.Path("apm.yml")
    c = p.read_text(encoding="utf-8")
    c = re.sub(r"^namespace:.*$", f"namespace: {owner}", c, flags=re.M)
    c = re.sub(r"^author:.*$", f"author: {owner}", c, flags=re.M)
    c = re.sub(r"^repository:.*$", f"repository: https://github.com/{owner}/{repo}", c, flags=re.M)
    p.write_text(c, encoding="utf-8")
    print(f"✓ Configured apm.yml with fork owner: {owner}/{repo}")
' "$ORIGIN_URL"
fi
```

### 4. Initialize `.synapse/state.json`
Write the canonical JSON state ledger:
```json
{
  "framework": "synapse",
  "version": "2.0.0",
  "initialized_at": "2026-11-21T21:30:00Z",
  "last_session": "2026-11-21T21:30:00Z",
  "objective": "Project initialization and environment setup",
  "current_blockers": "None",
  "next_action": "Run /resume to begin first active development session",
  "modified_files": [],
  "active_agent": "coordinator"
}
```

### 4. Initialize `.synapse/context.md`
Scaffold project architecture and technical stack specifications:
```markdown
# Project Context & Architecture

## Stack Overview
- **Core Languages & Tools:** [Add project languages, frameworks, and databases]
- **Package Manager:** [APM / npm / pip / cargo / etc.]

## Architecture & Data Contracts
- Consult canonical specifications in `context/` or local specs
- Record durable architecture choices in `.synapse/memory/project-decisions.md`
```

### 5. Initialize `.synapse/handoff.md` and `.synapse/active-roadmap.md`
Write the starting session handoff document (under 50 lines) and milestone checklist.

### 6. Update `.gitignore`
Append ephemeral scratch patterns while preserving state:
```gitignore
# Synapse Ephemeral State
.synapse/state/*.tmp.md
.synapse/scratch-*
.synapse/state/tmp/

# Keep Persistent State Tracked
!.synapse/state.json
!.synapse/context.md
!.synapse/handoff.md
!.synapse/active-roadmap.md
!.synapse/memory/
```

### 7. Confirm Setup
Print confirmation to the user and suggest running `/resume`.
