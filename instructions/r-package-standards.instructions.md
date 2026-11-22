---
description: >
  Enforces R package development standards: roxygen2 documentation,
  explicit namespacing, testthat 3e, and styler/lintr compliance.
applyTo: "**/*.R, **/DESCRIPTION, **/NAMESPACE"
globs: "**/*.R, **/DESCRIPTION, **/NAMESPACE"
---

# R Package Standards

## roxygen2 Documentation
- Document all exported functions with `@param`, `@return`, and `@export`.
- Maintain package metadata in `DESCRIPTION` and `NAMESPACE`.

## Namespacing & Dependencies
- Use explicit `pkg::fun()` namespacing everywhere in `R/`.
- Never call `library()` inside package functions.
- Import external dependencies explicitly via `DESCRIPTION` (`Imports:` or `Suggests:`).

## Testing & Quality
- Write comprehensive unit tests in `tests/testthat/` using testthat 3rd edition.
- Enforce clean `rcmdcheck` runs with zero errors and zero warnings.
- Maintain consistent formatting using `styler` and `lintr`.
