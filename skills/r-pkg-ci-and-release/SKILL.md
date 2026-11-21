---
name: r-pkg-ci-and-release
description: >
  Step-by-step workflow for R package CI: documentation generation,
  testing, R CMD check, version bumps, and GitHub Actions diagnostics.
---

# R Package CI and Release

## When to Use

Activate this skill when:
- Running the full R package check cycle locally
- Diagnosing `R-CMD-check` GitHub Actions failures
- Preparing a new release version
- Updating CI configuration for R packages

## Local Development Cycle

### 1. Generate Documentation

```r
devtools::document()
```

Verify: no warnings about missing `@param`, `@return`, or undocumented exports.
Check that `NAMESPACE` was regenerated — `git diff NAMESPACE` should show
only intentional changes.

### 2. Run Tests

```r
devtools::test()
# Or for a specific file:
devtools::test(filter = "database")
```

Expected: all tests pass. For snapshot tests, review changes with:

```r
testthat::snapshot_review()
```

Accept legitimate changes, reject regressions.

### 3. R CMD check

```r
rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning")
```

This runs the full check without building PDF manual pages (which require
LaTeX). The `error_on = "warning"` flag ensures warnings are treated as
failures — matching the strictness of CRAN and GitHub Actions.

### 4. Lint Check

```r
lintr::lint_package()
```

Address all findings before committing.

## Version Bump Protocol

### Development Versions

```r
# In DESCRIPTION, increment the dev component:
# 0.1.0.9000 → 0.1.0.9001 → ... → 0.2.0 (release)
usethis::use_version("dev")
```

### Release Versions

```r
# Bump to next minor/major:
usethis::use_version("minor")  # 0.1.0 → 0.2.0
usethis::use_version("major")  # 0.2.0 → 1.0.0
```

After bumping:
1. Update `NEWS.md` with user-facing changes.
2. Run the full check cycle (steps 1–4 above).
3. Commit with message: `chore: bump version to X.Y.Z`.
4. Tag: `git tag -a vX.Y.Z -m "Release X.Y.Z"`.

## GitHub Actions `R-CMD-check` Diagnostics

### Common Failure Patterns

| Error Pattern | Root Cause | Fix |
|---|---|---|
| `there is no package called 'X'` | Missing from `DESCRIPTION` Imports/Suggests | Add with `usethis::use_package("X")` |
| `no visible binding for global variable` | NSE column references in dplyr/data.table | Add `utils::globalVariables()` or use `.data$col` |
| `cannot open file 'inst/...'` | File path case sensitivity (macOS vs Linux) | Match exact case in code and filesystem |
| `checking tests ... ERROR` | Test uses local resource not available in CI | Add `skip_on_ci()` or use test fixtures |
| `checking compiled code ... WARNING` | C/C++ compiler flags | Check `src/Makevars` and `SystemRequirements:` |
| `Status: 1 NOTE` for "New submission" | First CRAN submission | Acceptable; not a real problem |

### Reading CI Logs

1. Find the failing job in GitHub Actions → click the red ✗.
2. Expand the `Run rcmdcheck` step.
3. Search for `ERROR`, `WARNING`, or `NOTE` (in that priority order).
4. Cross-reference the check name (e.g., `checking Rd cross-references`)
   with the [R CMD check documentation](https://r-pkgs.org/R-CMD-check.html).

### CI Configuration Template

The standard workflow file should be at `.github/workflows/R-CMD-check.yaml`
using `r-lib/actions/check-r-package@v2` with matrix testing across
`{os: [ubuntu-latest, macos-latest, windows-latest]}` and
`{r-version: ['release', 'devel']}`.

## DESCRIPTION Field Checklist

- [ ] `Package:` matches directory name
- [ ] `Title:` is title case, no period
- [ ] `Description:` is at least one full sentence with a period
- [ ] `Version:` follows semantic versioning
- [ ] `Authors@R:` uses `person()` with valid roles (`aut`, `cre`)
- [ ] `License:` matches LICENSE/LICENSE.md
- [ ] `Roxygen: list(markdown = TRUE)`
- [ ] `Config/testthat/edition: 3`
- [ ] `Encoding: UTF-8`
- [ ] All `Imports:` and `Suggests:` have minimum versions if API-sensitive
