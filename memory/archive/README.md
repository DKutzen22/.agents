# Memory Archive Directory

This directory preserves retired, consolidated, or superseded empirical quirks and ADRs.

## Archival Contract
- **Non-Destructive Compaction:** When entries in `memory/tool-quirks.md` or `memory/architecture-decisions.md` become obsolete (e.g. upstream library fixed the bug, or ADR superseded), move them to `memory/archive/YYYY-MM.md`.
- **Append-Only Invariant:** Active memory files remain lean and under token caps, while historical empirical records are permanently preserved.
