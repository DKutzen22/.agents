---
description: >
  Enforces Conventional Commits, atomic changesets, descriptive PR summaries,
  and bans committing raw data files or unverified AI-generated boilerplate.
applyTo: "*"
globs: "*"
---

# Git & PR Conventions

All version control operations must maintain clean, bisectable history:

## Commit Structure
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Scope commits atomically: avoid mixing linting or refactoring with feature logic.
- Include ticket/issue identifiers where applicable.

## Repository Hygiene
- Never commit binary data files (>10MB), credentials, or scratch output.
- Keep commit messages concise, descriptive, and imperative.
- Ensure all CI gates and pre-commit checks pass before pushing.
