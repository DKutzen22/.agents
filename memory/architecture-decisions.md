# Architectural Decision Records (ADRs)

This file tracks durable architectural choices across our phage bioinformatics pipelines,
R packages, SQLite databases, and Shiny dashboards. It is append-only for new decisions.

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

### ADR-001: SQLite as Canonical Interchange Format Across Pipelines and Shiny Frontend
* **Date:** 2026-11-21
* **Status:** Accepted
* **Context:**
  Bioinformatics pipelines (Snakemake + Python) produce heterogeneous files (GenBank `.gbk`,
  TSVs, FASTA), while the R Shiny frontend requires responsive sub-second querying, complex
  filtering across hundreds of phage genomes, and selective data export. Flat CSV/TSV files
  lead to high memory consumption, slow search times, and disparate column schema parsing in R.
* **Decision:**
  Standardize on SQLite (`context/sqlite-phage-schema.sql`) as the single source of truth and
  canonical data interchange format. The Snakemake pipeline finishes with a dedicated ingestion
  step that populates an SQLite database. The R package and Shiny frontend connect to this
  SQLite database directly via `DBI` and `RSQLite`.
* **Consequences:**
  - Standardized schema across both Python and R codebases.
  - Sub-millisecond indexed queries on `locus_tag`, `genome_id`, `phrog_id`, and `product`.
  - Zero requirement for dedicated database servers (e.g., PostgreSQL/MySQL) in HPC or local laptop environments.
  - Requires database write locking discipline in parallel jobs (writes are localized to a single final pipeline rule).

---

### ADR-002: Strict Separation of Pure DBI Query Helpers from Shiny Reactive Modules
* **Date:** 2026-11-21
* **Status:** Accepted
* **Context:**
  Embedding SQL queries and database connections directly inside Shiny reactive observers
  (`observeEvent`, `renderTable`, `reactive`) tightly couples presentation with storage. This
  makes automated unit testing (`testthat`) nearly impossible without running headless browser
  sessions, introduces SQL injection vulnerabilities, and leaks database connection handles.
* **Decision:**
  Enforce strict physical and architectural decoupling:
  1. All database access logic must reside in standalone functions in `R/db_*.R` (or `R/fct_database*.R`).
  2. Database helper functions accept a `con` or `pool` handle and return standard R `data.frame` / `tibble` objects.
  3. No database helper function may import or call Shiny reactivity (`shiny::reactive`, `shiny::isolate`, `input$`).
  4. Shiny modules (`R/mod_*.R`) only receive data from database helpers and handle UI reactivity.
* **Consequences:**
  - Database queries can be 100% unit-tested via `testthat` using in-memory SQLite fixtures (`:memory:`).
  - Parameterized queries (`DBI::dbBind` / `glue::glue_sql`) are audited in isolation.
  - Shiny modules remain modular, lightweight, and focused purely on user experience.

---

### ADR-003: Snakemake Workflow Validation via Minimal Phage Genome Fixtures and Dry-Runs
* **Date:** 2026-11-21
* **Status:** Accepted
* **Context:**
  Phage annotation pipelines integrate heavy tools (**Pharokka**, **Phold**, **Phynteny**) requiring
  large reference databases (PHROGs, Foldseek) and SLURM HPC resources. Syntax mistakes,
  wildcard ambiguities, or missing intermediate directories discovered mid-run waste compute
  allocations and generate messy half-written states.
* **Decision:**
  Mandate a three-phase validation gate before submitting production jobs:
  1. Static dry-run and command linting: `snakemake -n -p` and `snakemake --lint`.
  2. Local integration test on a committed micro-fixture (a synthetic ~5 kb phage genome with 5-10 CDS) located in `.test/data/`.
  3. Golden-file diffing against expected `.gbk` and SQLite tables in `.test/expected/`.
* **Consequences:**
  - Catches 95% of rule DAG, wildcard, and environment errors locally in seconds.
  - Ensures continuous integration (CI) tests can run on GitHub Actions without downloading 40 GB database bundles.
  - Requires maintaining a valid minimal phage fixture genome whenever new rules or qualifiers are added.

---

### ADR-004: Unification of Workflow Commands into Skills with Portability Symlinks
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
