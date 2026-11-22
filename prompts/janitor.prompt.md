---
description: "Governance & health audit: verify frontmatter, line limits, relative links, and state hygiene"
---
Execute the Synapse repository governance and hygiene audit:

1. Verify YAML frontmatter across `rules/*.instructions.md` and `skills/*/SKILL.md`.
2. Check rule line lengths against standard limits (≤45 target, 60 hard cap).
3. Validate all internal markdown cross-references and relative asset paths.
4. Verify workspace state and memory hygiene in `.synapse/` or `.agents/`.
5. Audit scripts for zero-dependency compliance and `--help` flags.
6. Output a structured Markdown health matrix with findings and required remediation.
