---
description: "Documentation & asset link audit: scan Markdown/HTML files for broken relative links"
---
Execute the Synapse documentation and relative link audit:

1. Run link verification via `python3 scripts/check-links.py --root .`.
2. Inspect Markdown and rendered HTML files for unresolved relative links or missing image assets.
3. Verify Quarto cross-references (`@fig-`, `@tbl-`) and frozen computational chunks (`freeze: auto`).
4. Output verified links count and report any missing local targets.
