---
description: "R package quality gate: run devtools::document(), devtools::test(), and rcmdcheck"
---
Execute the Synapse R package quality verification workflow:

1. Validate package root (`DESCRIPTION` and `NAMESPACE` presence).
2. Generate documentation via `devtools::document()`.
3. Execute unit test suite with `devtools::test()`.
4. Run full CRAN/Bioconductor compliance check via `rcmdcheck::rcmdcheck(args = c('--no-manual', '--as-cran'))`.
5. Triage any `ERROR` or `WARNING` diagnostics and propose minimal diffs.
