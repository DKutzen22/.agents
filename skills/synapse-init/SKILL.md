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

### 2. Scaffold `.synapse/` Directory Structure
Create the dedicated project-local state and memory directory:
```bash
mkdir -p "$REPO_ROOT/.synapse/memory"
mkdir -p "$REPO_ROOT/.synapse/local-rules"
mkdir -p "$REPO_ROOT/.synapse/state"
```

### 3. Initialize `.synapse/state.json`
Write the canonical JSON state ledger:
```json
{
  "framework": "synapse",
  "version": "1.0.0",
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
- **Core Languages & Tools:** Python / Snakemake / R / Quarto / SQLite
- **Package Manager:** APM (Agent Package Manager) / Conda

## Active Schemas & Hardware Profiles
- Consult canonical DDL in package `context/sqlite-phage-schema.sql`
- Standard HPC resource tiers: `light_io`, `cpu_annotation`, `gpu_structure_fold`
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
