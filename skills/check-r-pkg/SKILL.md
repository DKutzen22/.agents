---
name: check-r-pkg
description: >
  Runs the full R package check cycle: document, test, and rcmdcheck.
  Triages ERRORs, WARNINGs, and NOTEs with actionable fixes.
  Trigger with /check-r-pkg or ask to check/test R package.
---

# /check-r-pkg

Run the complete R package quality gate and triage results.

> [!NOTE]
> **Trigger:** Invoke directly via `/check-r-pkg` or ask to run R package checks/tests.  
> **Standards:** [`instructions/r-package-standards.instructions.md`](../../instructions/r-package-standards.instructions.md)

## Steps

### 1. Generate Documentation

```r
devtools::document()
```

- Verify zero roxygen warnings.
- If `NAMESPACE` changed, confirm the diff is intentional.

### 2. Run Tests

```r
devtools::test()
```

- If any test fails, report the test file, test name, and failure message.
- For snapshot failures, show the diff and ask whether to accept or reject.

### 3. R CMD Check

```r
rcmdcheck::rcmdcheck(
  args = c("--no-manual", "--as-cran"),
  error_on = "warning"
)
```

### 4. Triage Results

Classify each finding:

| Severity | Action |
|---|---|
| `ERROR` | **Must fix.** Report the exact error, the check phase, and a proposed fix. |
| `WARNING` | **Should fix.** Most warnings are CRAN-blocking. Propose a fix. |
| `NOTE` | **Evaluate.** Some NOTEs are acceptable (e.g., "New submission"). Flag non-trivial NOTEs. |

### 5. Lint (Optional Follow-Up)

```r
lintr::lint_package()
```

Report any new lint findings introduced by recent changes.

## Success Criteria

- Zero `ERROR` and zero `WARNING` from `rcmdcheck`.
- All `testthat` tests pass.
- `NAMESPACE` and `man/` are up-to-date with roxygen.

## Example Invocation

```
/check-r-pkg
```
