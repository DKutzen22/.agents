# Architectural Decision Records (ADRs)

This file tracks durable architectural choices across repositories and agent workflows. It is append-only for new decisions.

---

## ADR Template

```markdown
### ADR-XXX: [Short Decision Title]
* **Date:** YYYY-MM-DD
* **Status:** [Proposed | Accepted | Superseded | Deprecated]
* **Context:** [Problem statement, technical constraints, alternative approaches considered]
* **Decision:** [The architectural choice made and why]
* **Consequences:** [Positive trade-offs, negative implications, maintenance burdens, invariants]
```

---

### ADR-001: Consolidation of Workflow Commands into Skills with Portability Symlinks
* **Date:** 2026-11-21
* **Status:** Accepted
* **Context:**
  Antigravity native slash-command discovery indexes `skills/<name>/SKILL.md` rather than a
  standalone `commands/` directory. Maintaining separate `commands/*.md` workflows led to
  dual-maintenance drift and prevented custom commands from appearing in the IDE slash menu.
  However, other tools (e.g., Claude Code CLI) expect `.agents/commands/`.
* **Decision:**
  Consolidate all callable workflow specifications into standard skills (`skills/<name>/SKILL.md`)
  as the single source of truth, removing the top-level `commands/` folder from the central repo.
  Provide cross-agent compatibility by having `scripts/link-repo.sh` create a relative symlink
  `.agents/commands -> skills` when mounting into consumer project repositories.
* **Consequences:**
  - Zero duplicate workflow maintenance.
  - Native slash-command autocomplete in Antigravity chat UI (`/janitor`, `/resume`, `/handoff`, etc.).
  - Preserves full out-of-the-box compatibility with Claude Code and other CLI agents.
