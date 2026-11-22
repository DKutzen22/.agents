---
trigger: glob
globs: "*.py, pyproject.toml"
description: >
  Enforces modern Python packaging (src/ layout, pyproject.toml), type hints,
  pytest test suites, ruff linting, pathlib.Path, and deterministic seeds.
---

# Python Engineering Standards

All Python code must follow modern standard library and packaging conventions:

1. **Packaging & Layout:**
   - Use `pyproject.toml` (PEP 517/621) with `hatchling` or `flit-core` for build configuration.
   - Structure installable libraries under `src/<package_name>/` to prevent accidental in-tree imports.
2. **Type Annotations & Modern Syntax:**
   - Annotate arguments and return values on all public functions and classes using standard `typing` / Python 3.10+ syntax (`list[str]`, `str | None`).
3. **Filesystem Operations:**
   - Always use `pathlib.Path` for filesystem operations. Ban string concatenation and manual `/` joins for paths.
4. **Determinism:**
   - Explicitly seed stochastic routines (`random.seed(42)`, `numpy.random.default_rng(42)`) and expose seeds via CLI arguments or configs.
5. **Linting & Formatting:**
   - Adhere to `ruff check` and `ruff format` standards (PEP 8, line length ≤100 chars, sorted imports via isort rules).
6. **Testing:**
   - Structure unit tests under `tests/` using `pytest`. Use `tmp_path` fixtures for temporary disk writes; never pollute the workspace.
