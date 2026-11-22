---
name: python-packaging-and-cli
description: >
  Playbook for structuring reproducible Python packages and CLI tools:
  pyproject.toml build configuration, src/ layout, argparse/typer entrypoints,
  pytest suites, ruff verification, and editable installs.
  Trigger with /python-packaging-and-cli or ask to build a Python package or CLI.
---

# Python Packaging and CLI Playbook

Standardized protocol for creating and maintaining production-grade, reproducible Python packages and CLI applications.

## Standard Layout (`src/` Architecture)

```text
my-tool/
├── pyproject.toml              # Build & dependency metadata (PEP 517/621)
├── README.md                   # Installation and usage instructions
├── LICENSE                     # Standard open-source license
├── src/
│   └── my_tool/                # Canonical source package
│       ├── __init__.py         # Package exports and __version__
│       ├── cli.py              # CLI entrypoint parsing (argparse or typer)
│       ├── core.py             # Pure domain logic functions
│       └── py.typed            # PEP 561 typing marker
└── tests/
    ├── conftest.py             # Shared pytest fixtures & test data paths
    ├── test_cli.py             # Command-line interface tests
    └── test_core.py            # Unit tests for domain functions
```

## Step-by-Step Package Creation

### 1. Configure `pyproject.toml`
Use `hatchling` as the lightweight, modern build backend:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-tool"
version = "0.1.0"
description = "Deterministic bioinformatics CLI tool"
readme = "README.md"
requires-python = ">=3.10"
license = { text = "MIT" }
authors = [{ name = "Maintainer", email = "author@example.com" }]
dependencies = []

[project.scripts]
my-tool = "my_tool.cli:main"

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.4.0",
]

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]
```

### 2. Implement Zero-Dependency CLI (`src/my_tool/cli.py`)
For standalone or core repository tools, prefer standard library `argparse`:

```python
import argparse
import sys
from pathlib import Path


def parse_args(args=None):
    parser = argparse.ArgumentParser(
        prog="my-tool",
        description="Deterministic data processing tool.",
    )
    parser.add_argument(
        "--input",
        "-i",
        type=Path,
        required=True,
        help="Path to input data file",
    )
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        default=Path("output.tsv"),
        help="Path to output destination",
    )
    return parser.parse_args(args)


def main():
    args = parse_args()
    if not args.input.is_file():
        sys.stderr.write(f"Error: Input file not found: {args.input}\n")
        sys.exit(1)
    print(f"Processing {args.input} -> {args.output}")
    sys.exit(0)


if __name__ == "__main__":
    main()
```

### 3. Unit Testing with `pytest`
Structure tests in `tests/` and test both API and CLI:

```python
# tests/test_cli.py
from my_tool.cli import parse_args


def test_cli_parsing(tmp_path):
    fake_in = tmp_path / "in.txt"
    fake_in.write_text("sample")
    args = parse_args(["--input", str(fake_in)])
    assert args.input == fake_in
```

### 4. Code Quality & Local Installation
Run linters and install in editable mode:
```bash
# Verify code quality
ruff check .
ruff format --check .
pytest -v

# Editable installation
pip install -e ".[dev]"
# Or with uv:
uv pip install -e ".[dev]"
```
