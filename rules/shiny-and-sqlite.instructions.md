---
description: >
  Enforces Shiny module patterns, parameterized SQLite queries, and
  strict separation between database logic and reactive UI code.
applyTo: "**/inst/shiny/**, **/R/mod_*.R, **/*.sql, **/R/*_db.R, **/R/fct_database*.R"
globs: "**/inst/shiny/**, **/R/mod_*.R, **/*.sql, **/R/*_db.R, **/R/fct_database*.R"
---

# Shiny and SQLite Standards

## Shiny Module Architecture
- Enforce `NS(id)` namespace isolation for all input and output IDs.
- Keep module server logic decoupled from database queries via pure helper functions.

## Database Access & Queries
- Never construct raw SQL strings using string concatenation or `paste()`.
- Use parameterized queries via `DBI::dbBind()` or `glue::glue_sql()`.
- Always open database connections defensively and close them in on.exit handlers.
- Enforce `PRAGMA foreign_keys = ON;` on all SQLite connections.

## UI & State Management
- Handle empty datasets and missing table records gracefully.
- Validate inputs using `shiny::req()` and informative feedback messages.
