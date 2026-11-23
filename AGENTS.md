# Synapse Repository

This repository provides a self-filling, adaptive multi-agent memory and state continuity framework for agentic coding assistants.

## Architecture & Dispatch Principle

Synapse strictly separates Command Interface from Execution Specialists:
- **Skills (`skills/*/SKILL.md`) are the Command Interface (Verbs & Entrypoints):** They handle user intents and slash commands (`/scaffold`, `/harvest`, `/doctor`, etc.), parse arguments, and validate initial state.
- **Subagents (`agents/*.md`) are the Execution Specialists (Workers):** They run in isolated context windows with focused tool permissions. They do not act as direct chat entrypoints.
- **Canonical Flow:** **Skills trigger subagents; subagents never trigger skills.**
  $$\text{User Command} \longrightarrow \text{Skill (Entrypoint)} \longrightarrow \text{Subagent (Worker)}$$

### Canonical Skill-to-Subagent Pairings
- **`/scaffold`** $\rightarrow$ Delegates structural code and manifest generation to `agents/architect.md`.
- **`/harvest`** $\rightarrow$ Delegates session analysis and memory appending to `agents/synthesist.md`.
- **`/janitor`** $\rightarrow$ Delegates static hygiene and frontmatter checks to `agents/janitor.md`.
- **`/doctor`** $\rightarrow$ Delegates consumer symlink and mount audits to `agents/scout.md`.

## Conventions

- Rules in `instructions/` are always-on and scoped by file globs (`memory-protocol`, `memory-discipline`, `state-continuity`, `synapse-governance`, `subagent-autonomy`, `portable-path`).
- Skills in `skills/` house modular workflows (`/doctor`, `/handoff`, `/harvest`, `/janitor`, `/promote-memory`, `/resume`, `/scaffold`, `/synapse-init`).
- Subagents in `agents/` define specialized personas (`architect`, `synthesist`, `janitor`, `scout`, `explorer`, `verifier`).
- Specs in `context/` ([`context/index.md`](context/index.md)) provide canonical governance specifications.
- Memory in `memory/` tracks append-only ADRs and empirical tool quirks.
- State in `state/` tracks ephemeral session handoffs and milestone roadmaps.
