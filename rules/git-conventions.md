---
trigger: always_on
globs: "*"
description: >
  Enforces Conventional Commits, atomic changesets, descriptive PR summaries,
  and bans committing raw data files or unverified AI-generated boilerplate.
---

# Git & PR Conventions

All version control operations must maintain clean, bisectable history:

1. **Conventional Commits:** Prefix all commit messages with standard tags:
   - `feat:` (new capability or user-facing feature)
   - `fix:` (bug fix or error resolution)
   - `docs:` (documentation, vignettes, or markdown changes)
   - `refactor:` (code restructuring with unchanged behavior)
   - `test:` (adding or updating test suites)
   - `chore:` (dependency updates, build configurations, linting)
2. **Atomic Commits:** Each commit must address a single logical change. Do not mix refactoring with behavioral modifications.
3. **Imperative Subject Lines:** Write concise, imperative subjects (≤72 chars): e.g., `feat: add relative path calculation in link-repo.sh`.
4. **Banned Artifacts:** Never commit:
   - Large raw datasets (>10 MB), binary blobs, or intermediate analysis caches.
   - Credentials, private keys, or API tokens.
   - Unverified AI-generated boilerplate or commented-out legacy code.
5. **PR Descriptions:** Include context, summary of changes, and exact commands used to verify correctness.
