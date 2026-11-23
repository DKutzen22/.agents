---
description: >
  Enforces skill-to-subagent dispatch flow: skills trigger subagents; subagents never trigger skills.
applyTo: "agents/**, skills/**, instructions/**"
globs: "agents/**, skills/**, instructions/**"
---

# Subagent Autonomy & Skill Dispatch Flow

## Architectural Principle: Command vs. Execution
In the Synapse framework, components are strictly separated by responsibility:
1. **Skills (`skills/*/SKILL.md`):** Command Interface (Verbs & Entrypoints). Catch user intents or commands (e.g., `/scaffold`, `/harvest`), parse arguments, validate initial state, and act as the user-facing API.
2. **Subagents (`agents/*.md`):** Execution Specialists (Workers). Provide isolated context windows, specialized personas, and focused tool permissions. They never listen for direct user commands.

## Canonical Dispatch Flow
$$\text{User Command} \longrightarrow \text{Skill (Entrypoint)} \longrightarrow \text{Subagent (Isolated Worker)}$$

- **Skills trigger subagents; subagents never trigger skills.**

## Canonical Skill-to-Subagent Pairings
- `/scaffold` $\rightarrow$ Delegates structural code and manifest generation to `agents/architect.md`.
- `/harvest` $\rightarrow$ Delegates session analysis and memory appending to `agents/synthesist.md`.
- `/janitor` $\rightarrow$ Delegates static hygiene and frontmatter checks to `agents/janitor.md`.
- `/doctor` $\rightarrow$ Delegates consumer symlink and mount audits to `agents/scout.md`.

## Enforcement Rules
1. **No User-Facing Subagents:** Never author a subagent that attempts to parse user-facing command flags or act as a primary chat entrypoint.
2. **Programmatic Delegation:** Always implement user-facing commands as a Skill, and have that skill programmatically invoke the corresponding Subagent for isolated execution.
3. **Spec Alignment:** All generated primitives must conform to `context/repo-governance-spec.md` line caps and frontmatter schemas.
