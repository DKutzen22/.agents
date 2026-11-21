#!/usr/bin/env python3
"""scripts/hook-handler.py — Antigravity lifecycle hook runner.

Enforces repo governance during tool calls:
- PreToolUse: Blocks writes to context/* (except context/README.md) unless ALLOW_SPEC_UPDATE=1.
- PostToolUse: Warns if state/handoff.md > 50 lines, enforces chmod +x and syntax-checks scripts/*,
               and checks .R syntax if Rscript is available.

Zero external dependencies: Python 3 standard library only.
"""

import argparse
import json
import os
import pathlib
import shutil
import subprocess
import sys


def parse_args():
    parser = argparse.ArgumentParser(
        description="Antigravity lifecycle hook runner for repo governance and linting."
    )
    parser.add_argument(
        "event",
        nargs="?",
        choices=["pre", "post", "auto"],
        default="auto",
        help="Hook event to run: 'pre' (PreToolUse), 'post' (PostToolUse), or 'auto' (detect from payload).",
    )
    return parser.parse_args()


def load_payload():
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return {}
        return json.loads(raw)
    except Exception:
        return {}


def resolve_target_path(path_str, cwd):
    if not path_str:
        return None
    p = pathlib.Path(path_str)
    if p.is_absolute():
        return p
    if cwd:
        return pathlib.Path(cwd) / p
    return pathlib.Path.cwd() / p


def handle_pre_tool_use(payload):
    tool_call = payload.get("toolCall", {})
    args = tool_call.get("args", {})
    raw_path = args.get("Path") or args.get("path") or ""

    if not raw_path:
        return {"decision": "allow"}

    norm_path = str(raw_path).replace("\\", "/")

    # Check for context/ gate
    is_context = "/context/" in norm_path or norm_path.startswith("context/") or norm_path == "context"
    is_readme = norm_path.endswith("context/README.md") or norm_path.endswith("context/README")

    if is_context and not is_readme:
        if os.environ.get("ALLOW_SPEC_UPDATE") == "1":
            return {"decision": "allow"}
        return {
            "decision": "deny",
            "reason": (
                "Writing to context/* (except context/README.md) is blocked by repo governance "
                "to prevent accidental schema drift. Set ALLOW_SPEC_UPDATE=1 to authorize spec modifications."
            ),
        }

    return {"decision": "allow"}


def handle_post_tool_use(payload):
    tool_call = payload.get("toolCall", {})
    args = tool_call.get("args", {})
    cwd = payload.get("cwd") or str(pathlib.Path.cwd())
    raw_path = args.get("Path") or args.get("path") or ""

    if not raw_path:
        return {}

    target = resolve_target_path(raw_path, cwd)
    norm_path = str(raw_path).replace("\\", "/")

    # 1. Check handoff.md line cap (max 50 lines)
    if norm_path.endswith("state/handoff.md"):
        if target and target.is_file():
            try:
                with open(target, "r", encoding="utf-8", errors="ignore") as f:
                    lines = len(f.readlines())
                if lines > 50:
                    sys.stderr.write(
                        f"[HOOK WARNING] state/handoff.md has {lines} lines (maximum allowed is 50). "
                        "Please condense handoff notes before session completion.\n"
                    )
            except Exception as e:
                sys.stderr.write(f"[HOOK WARNING] Could not read handoff.md: {e}\n")

    # 2. Check scripts/ permissions and syntax
    if "/scripts/" in norm_path or norm_path.startswith("scripts/"):
        if target and target.is_file():
            try:
                current_mode = target.stat().st_mode
                target.chmod(current_mode | 0o111)
            except Exception as e:
                sys.stderr.write(f"[HOOK WARNING] Failed to set executable permission on {target}: {e}\n")

            if target.suffix == ".sh":
                res = subprocess.run(["sh", "-n", str(target)], capture_output=True, text=True)
                if res.returncode != 0:
                    sys.stderr.write(
                        f"[HOOK ERROR] Shell syntax error in {target}:\n{res.stderr.strip()}\n"
                    )
            elif target.suffix == ".py":
                res = subprocess.run(
                    [sys.executable, "-m", "py_compile", str(target)],
                    capture_output=True,
                    text=True,
                )
                if res.returncode != 0:
                    sys.stderr.write(
                        f"[HOOK ERROR] Python syntax error in {target}:\n{res.stderr.strip()}\n"
                    )

    # 3. Check .R syntax if Rscript is available
    if target and target.is_file() and target.suffix in (".R", ".r"):
        rscript = shutil.which("Rscript")
        if rscript:
            escaped_path = str(target).replace("'", "\\'")
            res = subprocess.run(
                [rscript, "-e", f"parse(file='{escaped_path}')"],
                capture_output=True,
                text=True,
            )
            if res.returncode != 0:
                sys.stderr.write(
                    f"[HOOK WARNING] R parse check reported errors in {target}:\n{res.stderr.strip()}\n"
                )

    return {}


def main():
    args = parse_args()
    payload = load_payload()

    event = args.event
    if event == "auto":
        hook_name = payload.get("hookEventName", "")
        if hook_name == "PreToolUse":
            event = "pre"
        elif hook_name == "PostToolUse":
            event = "post"
        else:
            # Fallback based on payload structure
            if "toolCall" in payload:
                event = "pre"
            else:
                event = "post"

    if event == "pre":
        out = handle_pre_tool_use(payload)
    else:
        out = handle_post_tool_use(payload)

    json.dump(out, sys.stdout)
    sys.stdout.write("\n")
    sys.stdout.flush()
    return 0


if __name__ == "__main__":
    sys.exit(main())
