---
description: >
  Gates access to technical specs and empirical memory: requires consulting
  context/ and memory/ before modifying architecture, data contracts, or core interfaces.
applyTo: "src/**, lib/**, pkg/**, app/**, config/**, db/**, schema/**, scripts/**"
globs: "src/**, lib/**, pkg/**, app/**, config/**, db/**, schema/**, scripts/**"
---

# Memory Protocol & Context Gates

## Consult Specifications & Memory Before Modification

Before modifying database schemas, API contracts, parsers, or core interfaces:
1. **Consult Canonical Specifications:**
   - Review project schemas and specs in `context/` (or `.synapse/context.md`).
   - Obey repository governance in `context/repo-governance-spec.md`.
   - Never introduce ad-hoc column names, schema migrations, or interface breaks without checking canonical specs.

2. **Check Empirical Memory & Quirks:**
   - Read `memory/tool-quirks.md` and local `.synapse/memory/project-quirks.md` to prevent known regressions or tool idiosyncrasies.
   - Review accepted decisions in `memory/architecture-decisions.md` and local `.synapse/memory/project-decisions.md`.

## Append-Only Memory Updates

- **Empirical Quirks:** When diagnosing and resolving a verified, non-obvious failure mode or tool quirk, append a structured entry to `.synapse/memory/project-quirks.md` (or central `memory/tool-quirks.md`).
- **Architectural Decisions:** When agreeing on an architectural choice, contract change, or technology adoption, record an ADR entry in `.synapse/memory/project-decisions.md` (or central `memory/architecture-decisions.md`).
- **Discipline:** Never record unverified bug notes or speculative changes. Only document verified failure modes and approved design decisions.
