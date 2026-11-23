---
name: scaffold
description: >
  Command entrypoint to scaffold new Synapse primitives. Catches /scaffold and delegates execution to the architect subagent.
---

# /scaffold

User-facing command interface for scaffolding new Synapse primitives (`skills/`, `instructions/`, `agents/`).

> [!NOTE]
> **Dispatch Flow:** `/scaffold` (Skill Entrypoint) $\longrightarrow$ [`agents/architect.md`](../../agents/architect.md) (Execution Worker).
> Skills trigger subagents; subagents never trigger skills.

## Routing & Triage Rubric
Before scaffolding, route the requirement strictly:
- **Rule (`instructions/`):** Hard invariants, style guardrails, and safety constraints. MUST declare explicit `applyTo` / `globs` file patterns; catch-all `**/*` is prohibited.
- **Skill (`skills/`):** Repeatable, multi-step user-triggered workflows and commands (`skills/<name>/SKILL.md`).
- **Subagent (`agents/`):** Isolated context execution with focused tool grants or adversarial verification roles (`agents/<name>.md`).
- **Anti-Pattern (`memory/anti-patterns.md`):** Explicitly rejected behaviors, negative examples, and "never do X" corrections.

## Execution Steps

### 1. Parse Command Arguments & Target Scope
Capture user intent, target primitive name, type, and distribution scope:
- **Primitive Type:**
  - **Skill:** `skills/<name>/SKILL.md`
  - **Instruction Rule:** `instructions/<name>.instructions.md`
  - **Subagent:** `agents/<name>.md`
- **Scope Classification (Prompt User if Unspecified):**
  - **Framework Core (`scope: core`):** Generic, domain-agnostic primitive intended for public upstream `main`.
  - **Personal Overlay (`scope: personal`):** User-specific workflow, machine habits, or private commands kept on your `personal` overlay branch to avoid upstream merge conflicts.

### 2. Delegate to Architect Subagent
Invoke the specialized **`architect`** subagent (`agents/architect.md`) with the task specifications:
```text
Task: Scaffold primitive '<name>' of type '<type>' with scope '<scope>'.
Target File: <path>
Governance: Conform to context/repo-governance-spec.md line limits and frontmatter schemas.
```

### 3. Subagent Execution Specifications

#### A. Scaffolding a Skill (`skills/<name>/SKILL.md`):
```yaml
---
name: <kebab-name>
description: >
  Concise purpose statement. Trigger with /<kebab-name> or request <task>.
scope: core  # or "personal"
---

# /<kebab-name>

## Execution Steps
1. Step details...
```

#### B. Scaffolding an Instruction (`instructions/<name>.instructions.md`):
Ensure length is ≤45 lines (hard cap 60 lines):
```yaml
---
description: Concise behavioral constraint
applyTo: "path/pattern/**, other/*.ext"
globs: "path/pattern/**, other/*.ext"
scope: core  # or "personal"
---

# Rule Title

## Constraints
- Explicit rules in declarative bullet points.
```

#### C. Scaffolding a Subagent (`agents/<name>.md`):
Ensure length is ≤80 lines:
```yaml
---
name: <kebab-name>
description: Focused agent persona and responsibilities
subagent: true
mainAgent: false
model: "flash"  # or "pro"
scope: core  # or "personal"
tools:
  - read_file
  - run_command
---

# Persona Title
```

### 4. Manifest Registration & Validation
Upon completion by `architect`:
- Register new primitives in `apm.yml`, `skills.json`, or `agents.json`.
- Run `make validate` to assert schema compliance, YAML validity, and link resolution.
