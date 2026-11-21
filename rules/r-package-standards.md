---
trigger: glob
globs: "**/*.R, **/DESCRIPTION, **/NAMESPACE"
description: >
  Enforces R package development standards: roxygen2 documentation,
  explicit namespacing, testthat 3e, and styler/lintr compliance.
---

# R Package Standards

## roxygen2 Documentation

- Every exported function MUST have a `@description`, `@param` for each
  argument, and `@return` block.
- Use `@examples` with `\dontrun{}` for functions requiring database
  connections or file I/O.
- Internal helper functions use `@noRd` to suppress manual pages.
- Run `devtools::document()` after any roxygen change; never hand-edit
  `NAMESPACE` or `man/*.Rd`.

## Explicit Namespacing

- **Zero `library()` or `require()` calls inside `R/`.**
- Reference external functions as `pkg::fun()` everywhere in `R/`.
- Declare dependencies in `DESCRIPTION` under `Imports:` (runtime) or
  `Suggests:` (test/dev).
- Use `@importFrom pkg fun` only when operator overloading or
  performance-critical hot loops demand it; document the reason in a comment.

## testthat 3rd Edition

- Set `Config/testthat/edition: 3` in `DESCRIPTION`.
- Name test files `test-<module>.R` matching the source file `R/<module>.R`.
- Use `expect_snapshot()` for complex output comparisons; commit
  `tests/testthat/_snaps/` to version control.
- Tag slow or integration tests with `testthat::skip_on_cran()` and
  `testthat::skip_if_not_installed()`.

## styler and lintr

- Format code with `styler::style_pkg()` using the default tidyverse style.
- Lint with `lintr::lint_package()` before committing.
- Address all `lintr` findings; suppress only with an inline
  `# nolint: <linter_name>. reason: <justification>` comment.

## DESCRIPTION Hygiene

- `Version:` follows semantic versioning: `MAJOR.MINOR.PATCH.dev`.
- `Roxygen: list(markdown = TRUE)` is set to enable Markdown in roxygen.
- `Authors@R:` uses `person()` with ORCID where available.
- `License:` matches the `LICENSE` file exactly.
