# Synapse Repository

This repository provides centralized AI coding configurations and multi-agent
orchestration for phage bioinformatics (Snakemake + Python), R package / Shiny / SQLite
development, and Quarto technical publishing.

## Conventions

- Rules in `rules/` are always-on and scoped by file globs.
- Skills in `skills/` house domain playbooks and callable slash workflows (`/<name>`).
- Agents in `agents/` define isolated subagent contexts with specific tooling.
- Specs in `context/` ([`context/index.md`](context/index.md)) provide canonical schemas and format lookups.
- Memory in `memory/` tracks append-only ADRs and empirical tool quirks.
- The [`bioinformatics-data-integrity.md`](rules/bioinformatics-data-integrity.md) rule applies to all scientific data operations.
