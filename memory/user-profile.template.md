# User Profile & Cross-Project Preferences (Tier 2 Memory Template)

This document records durable, cross-project user preferences, CLI flag defaults, and workflow habits.
These preferences apply across all repositories linked to Synapse.
Copy this template to `user-profile.md` (or let `/synapse-init` or `link-repo.sh` hydrate it automatically).

---

## 1. Tooling & CLI Flag Defaults

### Test Execution Preferences
* **Context:** Running test suites (`pytest`, `npm test`, `cargo test`, etc.).
* **Preference:** Prefer verbose, targeted test execution for active changes (e.g., `pytest -vv`).
* **Rationale:** Reduces debugging roundtrips by surfacing failure details immediately.

### Linter & Formatter Discipline
* **Context:** Running linters and formatting commands.
* **Preference:** Prefer native auto-fixing CLI tools over manual whitespace formatting edits.
* **Rationale:** Eliminates formatting churn across commits.

---

## 2. Communication & Interaction Style

### Confirmation & Decision Gates
* **Context:** Architectural refactoring, destructive operations, or deleting existing files.
* **Preference:** Always present a clear rationale and await explicit confirmation before deleting files or restructuring modules.
* **Rationale:** Prevents unintended data loss and maintains alignment.
