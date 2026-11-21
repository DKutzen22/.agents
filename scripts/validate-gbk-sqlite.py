#!/usr/bin/env python3
"""
scripts/validate-gbk-sqlite.py — Verifies SQLite phage annotation databases against canonical DDL.
Zero external dependencies (Python 3 standard library only).
"""

import argparse
import os
import re
import sqlite3
import subprocess
import sys
from pathlib import Path


def extract_expected_schema(schema_path: Path):
    """Parses CREATE TABLE statements from the canonical DDL file."""
    if not schema_path.is_file():
        raise FileNotFoundError(f"Schema file not found: {schema_path}")

    sql_text = schema_path.read_text(encoding="utf-8")
    table_pattern = re.compile(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_]+)\s*\((.*?)\);",
        re.DOTALL | re.IGNORECASE,
    )

    tables = {}
    for match in table_pattern.finditer(sql_text):
        tbl_name = match.group(1).strip()
        body = match.group(2).strip()

        columns = set()
        for line in body.splitlines():
            clean_line = line.strip().rstrip(",")
            if not clean_line or clean_line.startswith("--"):
                continue
            first_token = clean_line.split()[0].upper()
            if first_token in (
                "PRIMARY",
                "FOREIGN",
                "UNIQUE",
                "CHECK",
                "CONSTRAINT",
            ):
                continue
            col_name = clean_line.split()[0]
            columns.add(col_name.strip("`\"[]"))

        tables[tbl_name] = columns

    return tables


def validate_database(db_path: Path, schema_path: Path) -> bool:
    """Performs deep integrity and sentinel checks on the SQLite database."""
    if not db_path.is_file():
        sys.stderr.write(f"❌ Error: Database file does not exist: {db_path}\n")
        return False

    try:
        expected_tables = extract_expected_schema(schema_path)
    except Exception as exc:
        sys.stderr.write(f"❌ Error parsing schema DDL: {exc}\n")
        return False

    success = True
    con = sqlite3.connect(f"file:{db_path.resolve()}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    cur = con.cursor()

    try:
        # Check 1: Foreign key check
        cur.execute("PRAGMA foreign_key_check;")
        fk_violations = cur.fetchall()
        if fk_violations:
            success = False
            sys.stderr.write(
                f"❌ Foreign Key Violations detected ({len(fk_violations)} violations):\n"
            )
            for row in fk_violations[:10]:
                sys.stderr.write(f"   Table: {row[0]}, RowID: {row[1]}, Parent: {row[2]}, FK index: {row[3]}\n")
            if len(fk_violations) > 10:
                sys.stderr.write(f"   ... and {len(fk_violations) - 10} more.\n")
        else:
            print("  ✓ Foreign key integrity verified (0 violations)")

        # Check 2: Verify all expected tables and columns exist
        cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
        existing_tables = {row[0] for row in cur.fetchall()}

        for tbl, expected_cols in expected_tables.items():
            if tbl not in existing_tables:
                sys.stderr.write(f"❌ Missing expected table in database: '{tbl}'\n")
                success = False
                continue

            cur.execute(f"PRAGMA table_info({tbl});")
            actual_cols = {row["name"] for row in cur.fetchall()}
            missing_cols = expected_cols - actual_cols
            if missing_cols:
                sys.stderr.write(
                    f"❌ Table '{tbl}' is missing expected columns: {sorted(missing_cols)}\n"
                )
                success = False
            else:
                print(f"  ✓ Table '{tbl}' columns verified ({len(actual_cols)} columns)")

        # Check 3: Check for unnormalized sentinel strings
        if "annotations" in existing_tables:
            sentinels = ("No_PHROG", "None", "-")
            placeholders = ",".join(["?"] * len(sentinels))
            cur.execute(
                f"SELECT COUNT(*) FROM annotations WHERE phrog_id IN ({placeholders});",
                sentinels,
            )
            count = cur.fetchone()[0]
            if count > 0:
                sys.stderr.write(
                    f"❌ Unnormalized sentinels found in annotations.phrog_id: {count} rows contain 'No_PHROG'/'None'/'-'.\n"
                    f"   Expected: NULL for unassigned PHROGs (see memory/bioinfo-tool-quirks.md).\n"
                )
                success = False
            else:
                print("  ✓ PHROG sentinels normalized (0 raw 'No_PHROG' strings)")

        # Check 4: Quick genome record summary
        if "genomes" in existing_tables:
            cur.execute("SELECT COUNT(*) FROM genomes;")
            genome_count = cur.fetchone()[0]
            print(f"  ℹ Database holds {genome_count} genome record(s)")

    finally:
        con.close()

    return success


def get_default_schema_path() -> Path:
    """Dynamically resolves canonical DDL schema across central, symlinked, and CI contexts."""
    # 1. Resolve relative to script location (handles central repo & symlinked .agents/scripts/)
    resolved_parent = Path(__file__).resolve().parent.parent / "context" / "sqlite-phage-schema.sql"
    if resolved_parent.is_file():
        return resolved_parent

    # 2. Check repo root .agents/context (handles scripts copied to .github/scripts/ via --ci-copy)
    cwd_context = Path.cwd() / ".agents" / "context" / "sqlite-phage-schema.sql"
    if cwd_context.is_file():
        return cwd_context

    # 3. Check git toplevel if available
    try:
        res = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True)
        if res.returncode == 0:
            git_context = Path(res.stdout.strip()) / ".agents" / "context" / "sqlite-phage-schema.sql"
            if git_context.is_file():
                return git_context
    except Exception:
        pass

    return resolved_parent


def main():
    parser = argparse.ArgumentParser(
        description="Verify SQLite phage annotation databases against canonical DDL and data integrity rules.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--db",
        required=True,
        type=Path,
        help="Path to the SQLite database file to validate",
    )
    parser.add_argument(
        "--schema",
        type=Path,
        default=None,
        help="Path to canonical DDL schema file (defaults to context/sqlite-phage-schema.sql)",
    )

    args = parser.parse_args()

    # Resolve schema path (default or user-specified)
    schema_path = args.schema.resolve() if args.schema else get_default_schema_path()

    # Resolve db path relative to cwd if relative
    db_path = args.db.resolve() if args.db.is_absolute() else (Path.cwd() / args.db).resolve()

    print(f"==> Validating SQLite database: {db_path}")
    print(f"    Against schema:            {schema_path}")

    if validate_database(db_path, schema_path):
        print("✅ Validation PASSED: Database adheres to canonical schema and integrity rules.")
        sys.exit(0)
    else:
        sys.stderr.write("🚨 Validation FAILED: Address the schema/integrity errors reported above.\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
