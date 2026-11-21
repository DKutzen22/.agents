---
name: verify-site-links
description: >
  Renders a Quarto project and validates internal/external links and
  asset references for pre-publish integrity.
  Trigger with /verify-site-links or ask to verify links / check site assets.
---

# /verify-site-links

Render a Quarto site or document set and validate all links and assets.

> [!NOTE]
> **Trigger:** Invoke directly via `/verify-site-links` or ask to validate links and rendered assets.  
> **Script utility:** [`../../scripts/check-links.py`](../../scripts/check-links.py) can be run standalone to scan for broken local paths.

## Steps

### 1. Locate Quarto Project

Check for `_quarto.yml` in the working directory. If absent, look for
individual `.qmd` files and treat each as a standalone document.

### 2. Render

```bash
quarto render
```

- Capture stdout and stderr.
- If render fails, report the error with file and line number.
- Note any warnings about missing references, bibliography entries, or cross-references.

### 3. Validate Internal Links

Scan all rendered HTML files in `_site/` (or the configured `output-dir`):

```bash
# Using the bundled zero-dependency Python link validator:
python3 ../../scripts/check-links.py --root _site
# Or from workspace root: python3 scripts/check-links.py --root _site
```

Or manually:
```bash
# Find all internal href and src attributes:
grep -rohP '(?:href|src)="([^"]*)"' _site/ | grep -v '^http' | sort -u
```

For each internal reference:
- Verify the target file exists in the output directory.
- Check anchor links (`#section-id`) resolve to actual `id=` attributes.
- Flag any relative path that escapes the output directory (`../`).

### 4. Validate Asset References

Check all image, CSS, JS, and data file references:

```bash
grep -rn '!\[.*\](.*)' *.qmd | while IFS= read -r line; do
  asset=$(echo "$line" | grep -oP '!\[.*?\]\(\K[^)]+')
  if [ ! -f "$asset" ]; then
    echo "MISSING: $asset (referenced in $line)"
  fi
done
```

### 5. Validate External Links (Optional)

If `lychee` is available:
```bash
lychee --no-progress --format markdown _site/
```

### 6. Report

| Check | Result |
|---|---|
| Quarto render | ✅ PASS / ❌ FAIL (with error) |
| Internal links | N checked, M broken (list them) |
| Asset references | N checked, M missing (list them) |
| External links | N checked, M broken / SKIPPED |
| Cross-references | N checked, M unresolved |

## Success Criteria

- Quarto renders without errors.
- Zero broken internal links.
- Zero missing asset references.
- External link failures are reported but non-blocking.

## Example Invocation

```
/verify-site-links
```
