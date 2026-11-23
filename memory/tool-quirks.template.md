# Tool Quirks & Empirical Scar Tissue (Template)

This document records non-obvious failure modes, version discrepancies, and format edge cases
encountered across toolchains, parsers, and libraries.
Append newly diagnosed empirical quirks directly to `tool-quirks.md`.

---

## Quirk Schema

```markdown
### [Tool / Component Name]: [Brief Description of Quirk]
* **Quirk:** [Detailed description of the unexpected behavior or edge case]
* **Failure Mode:** [How it manifests, errors thrown, or data corruption caused]
* **Workaround:** [Deterministic workaround or defensive parsing approach]
```

---

### Example Starter Quirk: SQLite Concurrent Write Locks
* **Quirk:** SQLite databases throw `database is locked` under concurrent agent processes without WAL mode.
* **Failure Mode:** Parallel worker tasks fail with unhandled SQLite lock exceptions.
* **Workaround:** Execute `PRAGMA journal_mode=WAL;` and `PRAGMA busy_timeout=5000;` on connection initialization.
