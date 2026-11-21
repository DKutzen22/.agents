# Rules Directory Guide (for Maintainers)

This directory contains always-on guardrails and coding standards that govern agent
behavior when modifying specific files across the repository.

## What Belongs Here vs. What Doesn't
* **Belongs:** Hard architectural constraints (e.g., zero `library()` calls in `R/`, mandatory `NS(id)` in Shiny modules, parameterized `DBI` queries, pinned major.minor packages in Conda YAMLs).
* **Doesn't Belong:** Empirical third-party bug workarounds (move to `memory/bioinfo-tool-quirks.md`), step-by-step procedural playbooks (move to `skills/`), or passive DDL schemas (move to `context/`).

## File Naming & Starter Template
Rules are named in `kebab-case.md` and should target ≤45 lines (hard cap 60 lines).

```yaml
---
trigger: glob
globs:
  - "**/*.R"
  - "**/DESCRIPTION"
description: Enforces explicit namespacing and roxygen2 documentation standards
---

# Rule Title

- Explicit constraints in declarative bullet points.
```

## How & When Agents Touch These Files
* Agents do **not** read this entire directory on every prompt.
* Rules are auto-evaluated when an agent edits a file matching the declared `globs`.
* Humans edit these files when establishing a new cross-cutting coding policy.
