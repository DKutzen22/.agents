---
trigger: glob
globs: "**/inst/shiny/**, **/R/mod_*.R, **/*.sql, **/R/*_db.R, **/R/fct_database*.R"
description: >
  Enforces Shiny module patterns, parameterized SQLite queries, and
  strict separation between database logic and reactive UI code.
---

# Shiny and SQLite Standards

## Shiny Module Architecture

- Every UI/server pair MUST use `NS(id)` namespacing:
  ```r
  mod_upload_ui <- function(id) {
    ns <- NS(id)
    tagList(
      fileInput(ns("gbk_file"), "Upload .gbk", accept = ".gbk")
    )
  }

  mod_upload_server <- function(id, db_pool) {
    moduleServer(id, function(input, output, session) {
      # ...
    })
  }
  ```
- Module server functions receive database connections as parameters
  (dependency injection); never create connections inside `moduleServer()`.
- Each module lives in its own file: `R/mod_<name>.R`.

## SQLite Query Safety

- **All queries MUST use parameterized bindings.** Zero string interpolation
  of user inputs into SQL:
  ```r
  # CORRECT — parameterized
  DBI::dbGetQuery(con,
    "SELECT * FROM annotations WHERE locus_tag = ?",
    params = list(input$locus_tag)
  )

  # CORRECT — glue_sql with .con for auto-quoting
  query <- glue::glue_sql(
    "SELECT * FROM annotations WHERE phrog = {phrog_id}",
    phrog_id = input$phrog_id,
    .con = con
  )
  DBI::dbGetQuery(con, query)

  # FORBIDDEN — raw paste/sprintf
  DBI::dbGetQuery(con, paste0("SELECT * FROM annotations WHERE product = '",
    input$product, "'"))
  ```
- Use `DBI::dbWriteTable()` with `overwrite = FALSE, append = TRUE` for
  inserts; never construct multi-row `INSERT` strings manually.

## Database Connection Management

- Use `pool::dbPool(RSQLite::SQLite(), dbname = db_path)` for Shiny apps;
  close with `onStop(function() pool::poolClose(pool))`.
- For non-Shiny R package functions, use `DBI::dbConnect()` /
  `DBI::dbDisconnect()` with `withr::defer()` or `on.exit()` cleanup.
- Database path comes from a config parameter or
  `system.file("db", package = "pkgname")`, never hardcoded.

## Separation of Concerns

- **Database query functions** live in `R/fct_database*.R` or `R/*_db.R`.
  They accept a connection and return data frames. They contain zero
  Shiny-specific code (`reactive()`, `observe()`, `input$`, `output$`).
- **Reactive logic** lives only in `R/mod_*.R` server functions.
  It calls database functions and feeds results to `render*()`.
- **UI definitions** contain zero business logic — only layout and
  input/output widget declarations.

## GenBank Metadata in SQLite

- Canonical DDL schema: @../context/sqlite-phage-schema.sql
- Text fields storing GenBank qualifiers (`product`, `note`, `function`)
  MUST use `TEXT` affinity, never `VARCHAR(n)` — GenBank product strings
  have no reliable length cap.
- Store `translation` sequences as `TEXT`; store sequence `length` as
  `INTEGER` for query filtering.
- Index on `locus_tag` (unique), `phrog` (non-unique), and
  `contig_id` (non-unique) at minimum.
