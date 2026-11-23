# Skills Directory Guide (for Maintainers)

This directory serves as the unified home for modular skills and user-facing
slash workflows (`/workflow-name`) conforming to the AgentSkills specification.

## Active Skills
* [`doctor`](./doctor/SKILL.md) (`/doctor`): Audits repository health, mount symlinks, Git hooks, and checksums (delegates to `scout`).
* [`handoff`](./handoff/SKILL.md) (`/handoff`): Concludes work session, processes passive telemetry buffer, and writes ephemeral handoff state.
* [`harvest`](./harvest/SKILL.md) (`/harvest`): Extracts session quirks and decisions for the synthesist (delegates to `synthesist`).
* [`janitor`](./janitor/SKILL.md) (`/janitor`): Audits frontmatter schemas, line caps, and repository hygiene (delegates to `janitor`).
* [`promote-memory`](./promote-memory/SKILL.md) (`/promote-memory`): Harvests project quirks into central memory and pushes to user fork remote.
* [`resume`](./resume/SKILL.md) (`/resume`): Resumes session, reads handoff, and confirms next action.
* [`scaffold`](./scaffold/SKILL.md) (`/scaffold`): Materializes new skills, rules, and subagents for the architect (delegates to `architect`).
* [`synapse-init`](./synapse-init/SKILL.md) (`/synapse-init`): Scaffolds local `.synapse/` mutable memory and context, hydratable from starter templates.

## Architecture & Dispatch Principle
Skills are the **Command Interface (Verbs & Entrypoints)**. They parse user arguments, check initial state, and programmatically invoke dedicated **Subagents (Workers)** in `agents/` for isolated execution.

## Directory Structure & Frontmatter Schema
Every skill **must** live in its own named subdirectory: `skills/<name>/SKILL.md`. Loose `.md` files at `skills/` root are strictly prohibited.

```yaml
---
name: my-workflow
description: >
  Performs automated verification. Trigger with /my-workflow or ask to run check.
scope: core  # or "personal"
---

# /my-workflow

## Steps
1. Execute command: `tool --flag`
```

## IDE & Cross-Agent Portability
* **Antigravity Native:** Antigravity registers skills directly in the chat `/` autocomplete menu.
* **APM Standard:** APM compiles `skills/` to target harnesses (`.github/skills/`, `.claude/skills/`).
