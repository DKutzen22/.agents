# Agents Directory Guide (for Maintainers)

This directory defines isolated subagent configurations with domain-scoped personas
and explicit tool permission allocations.

## Active Subagents
* [`architect.md`](./architect.md): Generates new skills, rules, and agents from runtime patterns.
* [`synthesist.md`](./synthesist.md): Harvests empirical debugging lessons and ADRs into `memory/`.
* [`janitor.md`](./janitor.md): Audits frontmatter, line caps, and repo hygiene.
* [`scout.md`](./scout.md): Manages consumer repository mount points and symlink sync.
* [`explorer.md`](./explorer.md): Read-only codebase reconnaissance and dependency mapping.
* [`verifier.md`](./verifier.md): Adversarial test runner and post-change diff auditor.

## File Naming & Starter Template
Agent files are named in `kebab-case.md` and define the subagent role (hard cap ≤80 lines).

```yaml
---
name: my-specialist-reviewer
description: Evaluates code changes for domain safety and edge cases
subagent: true
mainAgent: false
model: "flash"
tools:
  - read_file
  - run_command
---

# Specialist Reviewer Agent

## Scope
Defined file boundaries and review responsibilities.

## Verification Checklist
- [ ] Explicit criteria evaluated before approving changes.
```

## How & When Agents Touch These Files
* Agents read these files when delegating tasks to subagents via orchestration tools (`invoke_subagent`).
* Subagents execute in isolated context windows, limiting token consumption and context pollution.
