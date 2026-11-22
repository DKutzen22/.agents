---
description: >
  Enforces modern Python packaging (src/ layout, pyproject.toml), type hints,
  pytest test suites, ruff linting, pathlib.Path, and deterministic seeds.
applyTo: "*.py, pyproject.toml"
globs: "*.py, pyproject.toml"
---

# Python Engineering Standards

All Python code must follow modern standard library and packaging conventions:

## Package Structure
- Enforce standard `src/` layout with `pyproject.toml` (hatchling or flit-core).
- Define CLI entrypoints explicitly via `[project.scripts]`.

## Code Quality & Typing
- Use type hints (`typing` / built-in generics) across all public interfaces.
- Lint and format via `ruff` (`ruff check`, `ruff format`).
- Use `pathlib.Path` exclusively instead of `os.path`.
- Enforce deterministic execution: set random seeds on all pseudo-random processes.

## Testing
- Unit tests live under `tests/` and execute via `pytest`.
- Keep fixtures minimal, deterministic, and self-contained.
