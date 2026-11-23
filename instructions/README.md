# Instructions Directory Guide (for Maintainers)

This directory contains always-on guardrails and standards that govern agent
behavior when modifying specific files across the repository.

## Active Instruction Rules
* [`memory-protocol.instructions.md`](./memory-protocol.instructions.md): Gate requiring consultation of specs and quirks before altering data contracts or schemas.
* [`memory-discipline.instructions.md`](./memory-discipline.instructions.md): Enforces append-only discipline and duplicate prevention across all memory files.
* [`state-continuity.instructions.md`](./state-continuity.instructions.md): Gate requiring checking `handoff.md` before multi-file edits.
* [`synapse-governance.instructions.md`](./synapse-governance.instructions.md): Token discipline, line caps, and lifecycle contracts across repo components.
* [`subagent-autonomy.instructions.md`](./subagent-autonomy.instructions.md): Advisory constraints and governance bounds for generative subagents.
* [`portable-path.instructions.md`](./portable-path.instructions.md): Enforces relative-path portability across mounted repositories.

## File Naming & Starter Template
Rules follow the APM instruction standard and are named `kebab-case.instructions.md`. They target ≤45 lines (hard cap 60 lines).

```yaml
---
description: Concise purpose statement
applyTo: "src/**, lib/**, pkg/**"
globs: "src/**, lib/**, pkg/**"
scope: core  # or "personal"
---

# Rule Title

- Explicit constraints in declarative bullet points.
```

## How & When Agents Touch These Files
* Agents do **not** read this entire directory on every prompt.
* Rules are auto-evaluated when an agent edits a file matching the declared `applyTo` / `globs`.
* Humans or the `architect` subagent edit these files when establishing a new cross-cutting policy.
