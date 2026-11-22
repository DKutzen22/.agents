---
name: scaffold-domain
description: >
  Guided workflow for expanding Synapse safely: checks for overlap, scaffolds
  glob-scoped rules, skills, and context specs, and runs verification checks.
  Trigger with /scaffold-domain or ask to add a new domain, language, or tool.
---

# /scaffold-domain

Standardized playbook for expanding Synapse with a new language, tool, or engineering domain while maintaining strict governance compliance.

## Execution Steps

### 1. Check for Overlap
Before authoring new files, audit existing rules, skills, and context:
```bash
grep -rn -i "<domain_keyword>" rules/ skills/ context/
```
Ensure the capability does not duplicate existing domain standards (e.g., Python packaging, R standards, Snakemake conventions).

### 2. Scaffold Glob-Scoped Rule (`rules/<domain>.md`)
If the domain requires enforceable, always-on invariants:
- Create `rules/<domain>.md` with strictly ≤45 lines.
- Frontmatter must declare `trigger: glob` with comma-separated string patterns:
  ```yaml
  ---
  trigger: glob
  globs: "*.ext, config.toml"
  description: Concise purpose statement
  ---
  ```
- Use Antigravity `@../context/<spec>` imports (up to 24 KB) for technical reference rather than bloating rule text.

### 3. Scaffold Domain Playbook (`skills/<domain>/SKILL.md`)
- Create dedicated directory `skills/<domain>/` with `skills/<domain>/SKILL.md`.
- Frontmatter must declare:
  ```yaml
  ---
  name: <domain>
  description: >
    Actionable summary of playbook capabilities and explicit triggers.
  ---
  ```
- Structure: Prerequisites, Step-by-Step Runbook, CLI Flags, Troubleshooting Matrix.

### 4. Add Static Context Specs (if needed)
- Place passive reference schemas (DDL, column mappings, hardware profiles) in `context/<spec>.<ext>`.
- Keep tone declarative and passive; ban second-person imperatives (`You must`, `Always run`).

### 5. Validate Governance
Run the full verification suite before committing:
```bash
sh .githooks/pre-commit --all
python3 scripts/check-links.py --root .
```
Ensure zero line-cap violations, frontmatter errors, or broken local links.
