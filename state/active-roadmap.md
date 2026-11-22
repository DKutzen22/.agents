# Active Roadmap & Milestone Tracker

---

### Track 1: Snakemake & Bioinformatics Pipelines
- [x] Standardize Snakemake conventions rule with HPC resource directives (`instructions/snakemake-conventions.instructions.md`)
- [x] Create reference resource tiers and SLURM profiles (`context/hpc-and-env-profiles.md`)
- [x] Document Pharokka, Phold, and Phynteny output specs (`context/genbank-and-phrog-specs.md`)
- [x] Author automated workflow smoke-testing skill (`skills/smoke-test-pipeline/SKILL.md`)
- [ ] Implement Snakemake workflow module integrating Pharokka, Phold, and Phynteny rules
- [ ] Build minimal test fixture dataset (`.test/data/test_phage_1.fasta`) for CI dry-runs

---

### Track 2: R Package, SQLite & Shiny Frontend
- [x] Establish R package style and testthat 3e standards (`rules/r-package-standards.md`)
- [x] Define canonical SQLite phage annotation schema (`context/sqlite-phage-schema.sql`)
- [x] Document SQLite query patterns and Shiny module isolation (`instructions/shiny-and-sqlite.instructions.md`)
- [x] Author schema drift audit skill (`skills/audit-schema-sync/SKILL.md`)
- [ ] Implement `R/db_*.R` database access functions with parameterized queries
- [ ] Build Shiny module `R/mod_browse.R` for annotation table filtering with PHROG category colors
- [ ] Implement `tests/testthat/` suite for GenBank ingestion and SQLite query helpers

---

### Track 3: Quarto Reports & Web Publishing
- [x] Define Quarto technical publishing standards and caching conventions (`skills/quarto-technical-publishing/SKILL.md`)
- [x] Create link validation skill (`skills/verify-site-links/SKILL.md`)
- [ ] Build template Quarto report (`vignettes/phage-annotation-report.qmd`) for automated pipeline summaries
- [ ] Configure CI action for automated Quarto rendering and static site link checking
