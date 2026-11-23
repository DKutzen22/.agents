---
description: >
  Enforces relative-path portability and bans machine-specific absolute paths across repository files.
applyTo: "**/*"
globs: "**/*"
---

# Portable Path & Multi-Repo Contract

## Strict Relative-Path Requirement
To guarantee multi-repo interoperability across diverse workstations, CI runners, and mounted workspaces:
1. **No Machine-Specific Absolute Paths:** Never commit or write `/Users/...`, `/home/...`, or `C:\...` paths into rules, skills, configs, manifests, or docs. # allow-path
2. **Dynamic Root Resolution:**
   - Resolve workspace roots dynamically via `git rev-parse --show-toplevel 2>/dev/null || pwd`.
   - Helper scripts must resolve internal paths relative to their own file location via `pathlib.Path(__file__).resolve().parent`.
3. **Relative Mount Symlinks:** All symlinks created by `scripts/link-repo.sh` must be strictly relative offsets (e.g., `../../../path/to/central`).
4. **Override Annotation:** In documentation or test fixtures requiring path demonstrations, append `# allow-path` to bypass automated pre-commit scanners.
