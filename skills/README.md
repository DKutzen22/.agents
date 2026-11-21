# Skills Directory Guide (for Maintainers)

This directory serves as the unified home for both deep domain runbooks and user-facing
slash workflows (`/workflow-name`) across the repository.

## What Belongs Here vs. What Doesn't
* **Domain Playbooks:** Deep multi-step reference guides (e.g. `phage-annotation-parsers`, `snakemake-dryrun-and-dag`, `quarto-technical-publishing`, `r-pkg-ci-and-release`).
* **Workflow Skills:** Repeatable slash-commands (`janitor`, `resume`, `handoff`, `check-r-pkg`, `smoke-test-pipeline`, `audit-schema-sync`, `verify-site-links`).
* **Doesn't Belong:** Always-on linters (move to `rules/`), passive schemas (move to `context/`), or transient state (move to `state/`).

## Directory Structure & Frontmatter Schema
Every skill **must** live in its own named subdirectory: `skills/<name>/SKILL.md`. Loose `.md` files at `skills/` root are strictly prohibited.

```yaml
---
name: my-workflow
description: >
  Performs automated verification. Trigger with /my-workflow or ask to run check.
---

# /my-workflow

## Steps
1. Execute command: `tool --flag`
```

## IDE & Cross-Agent Portability
* **Antigravity Native:** Antigravity registers skills directly in the chat `/` autocomplete menu.
* **Other CLI Agents (Claude Code, etc.):** When mounting into consumer repositories via `scripts/link-repo.sh`, a relative symlink `.agents/commands -> skills` is created automatically so tools expecting a `commands/` directory resolve all workflow skills seamlessly.
