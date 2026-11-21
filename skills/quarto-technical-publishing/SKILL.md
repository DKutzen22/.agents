---
name: quarto-technical-publishing
description: >
  Conventions for Quarto document authoring, reproducible chunk caching,
  relative asset paths, link validation, and publishing workflows.
---

# Quarto Technical Publishing

## When to Use

Activate this skill when:
- Authoring or editing Quarto `.qmd` documents
- Configuring `_quarto.yml` project files
- Setting up reproducible report rendering
- Validating links and assets before publishing
- Troubleshooting Quarto render failures

## YAML Frontmatter Conventions

### Single Document

```yaml
---
title: "Phage Genome Annotation Report"
author:
  - name: "Author Name"
    orcid: "0000-0000-0000-0000"
date: last-modified
format:
  html:
    toc: true
    toc-depth: 3
    code-fold: true
    code-tools: true
    self-contained: true
    anchor-sections: true
execute:
  echo: true
  warning: false
  message: false
  freeze: auto
bibliography: references.bib
csl: apa.csl
---
```

### Project `_quarto.yml`

```yaml
project:
  type: website  # or book
  output-dir: _site
  render:
    - "*.qmd"
    - "!_drafts/"

website:
  title: "Project Title"
  navbar:
    left:
      - text: Home
        href: index.qmd
      - text: Methods
        href: methods.qmd

format:
  html:
    theme: cosmo
    css: styles.css
    toc: true

execute:
  freeze: auto
```

## Reproducible Chunk Caching

### `freeze: auto` (Recommended)

```yaml
execute:
  freeze: auto  # Only re-execute when source changes
```

This stores computed results in `_freeze/` and re-renders only when the
`.qmd` source file changes. Commit `_freeze/` to version control for
reproducible builds in CI.

### Explicit Cache Control

For R chunks:
```
#| cache: true
#| cache-vars: [genome_data, annotation_summary]
#| dependson: load-data
```

- Use `cache: true` for chunks taking > 10 seconds.
- Always set `cache-vars` to declare which objects are cached.
- Use `dependson` to chain cache invalidation across chunks.

### Cache Busting

```bash
# Clear all caches and re-render from scratch:
rm -rf _freeze/ *_cache/ *_files/
quarto render
```

## Asset Path Conventions

- **Images**: Use relative paths from the `.qmd` file location:
  ```markdown
  ![DAG](figures/rulegraph.svg)
  ```
- **Data files**: Reference from project root with project-relative paths:
  ```r
  read.csv("data/annotations.csv")
  ```
- **Never use absolute paths** — they break portability across machines.
- **Static assets** (CSS, images, logos) go in a top-level `assets/` or
  `images/` directory.

## Link Validation

### Pre-Publish Checklist

```bash
# 1. Render the full project:
quarto render

# 2. Check local links and assets using the bundled zero-dependency script:
python3 ../../scripts/check-links.py --root _site
# Or from workspace root: python3 scripts/check-links.py --root _site
```

### External Link Checking

```bash
# Using lychee (Rust-based link checker):
lychee --no-progress _site/

# Or with htmlproofer (Ruby):
htmlproofer _site/ --disable-external --check-html
```

## Rendering Commands

```bash
# Render entire project:
quarto render

# Render single document:
quarto render report.qmd

# Render to specific format:
quarto render report.qmd --to pdf

# Preview with live reload:
quarto preview

# Preview specific port:
quarto preview --port 4200
```

## Common Render Errors

| Error | Cause | Fix |
|---|---|---|
| `Error in loadNamespace(x)` | Missing R package | Install in the render environment |
| `Notebook render failed: ...knitr...` | knitr chunk error | Check `execute:` YAML and chunk options |
| `Path '...' not found` | Broken relative path | Verify path relative to `.qmd` location |
| `YAML parse error` | Frontmatter indentation | Use 2-space indentation, check for tabs |
| `bibliography not found` | Missing `.bib` file | Verify path in frontmatter `bibliography:` |
| `! LaTeX Error: File 'X.sty' not found` | Missing LaTeX package (PDF output) | `tlmgr install X` or use `tinytex::tlmgr_install("X")` |

## Publishing Workflow

1. `quarto render` — full build
2. Validate links and assets (see above)
3. Review `_site/` output locally: `quarto preview`
4. Commit `_freeze/` if using `freeze: auto`
5. Push to trigger CI/CD (GitHub Pages, Netlify, etc.)
