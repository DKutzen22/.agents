# Agents Directory Guide (for Maintainers)

This directory defines isolated subagent configurations with domain-scoped personas
and explicit tool permission allocations.

## What Belongs Here vs. What Doesn't
* **Belongs:** Specialized subagent roles (e.g. `bioinfo-pipeline-reviewer`, `shiny-ui-tester`, `docs-and-vigilance-agent`, `ci-failure-triager`) with targeted review checklists and strict tool constraints.
* **Doesn't Belong:** Generic developer personas, unbounded script runners, or broad instructions without tool restrictions.

## File Naming & Starter Template
Agent files are named in `kebab-case.md` and define the subagent role.

```yaml
---
name: my-specialist-reviewer
description: Evaluates code changes for domain safety and edge cases
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
