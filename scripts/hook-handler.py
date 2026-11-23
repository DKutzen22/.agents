#!/usr/bin/env python3
"""scripts/hook-handler.py — Antigravity lifecycle hook runner.

Enforces repo governance during tool calls:
- PreToolUse: Blocks writes to context/* (except context/README.md) unless ALLOW_SPEC_UPDATE=1.
- PostToolUse: Warns if state/handoff.md > 50 lines, enforces chmod +x and syntax-checks scripts/*,
               and checks .R syntax if Rscript is available.

Zero external dependencies: Python 3 standard library only.
"""

import argparse
import datetime
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


def resolve_state_dir(cwd):
    base = pathlib.Path(cwd) if cwd else pathlib.Path.cwd()
    candidates = [
        base / ".synapse" / "state",
        base / ".agents" / "state",
        base / "state",
    ]
    for c in candidates:
        if c.is_dir():
            return c
    if (base / ".synapse").is_dir():
        d = base / ".synapse" / "state"
        d.mkdir(parents=True, exist_ok=True)
        return d
    d = base / "state"
    d.mkdir(parents=True, exist_ok=True)
    return d


def record_passive_telemetry(payload, cwd):
    """Passively detects recovery after failure and repeated action patterns."""
    tool_call = payload.get("toolCall", {})
    tool_name = tool_call.get("name") or payload.get("tool") or ""
    args = tool_call.get("args", {})
    tool_result = payload.get("toolResult") or payload.get("result") or {}

    target_key = (
        args.get("Path")
        or args.get("path")
        or args.get("CommandLine")
        or args.get("command")
        or args.get("script")
        or ""
    )
    if not target_key:
        return

    is_failure = False
    if isinstance(tool_result, dict):
        if tool_result.get("isError") is True or bool(tool_result.get("error")):
            is_failure = True
        elif tool_result.get("exitCode", 0) not in (0, None):
            is_failure = True
    elif isinstance(tool_result, str):
        if "error" in tool_result.lower() and "traceback" in tool_result.lower():
            is_failure = True

    state_dir = resolve_state_dir(cwd)
    session_file = state_dir / ".hook-session-state.json"
    buffer_file = state_dir / "pattern-buffer.jsonl"

    session_data = {"recent_failures": {}, "action_counts": {}}
    if session_file.is_file():
        try:
            with open(session_file, "r", encoding="utf-8") as f:
                session_data = json.load(f)
        except Exception:
            session_data = {"recent_failures": {}, "action_counts": {}}

    recent_failures = session_data.get("recent_failures", {})
    action_counts = session_data.get("action_counts", {})
    now_iso = datetime.datetime.now(datetime.timezone.utc).isoformat()
    events_to_log = []

    action_id = f"{tool_name}:{target_key}"
    if not is_failure and recent_failures.get(action_id):
        events_to_log.append(
            {
                "timestamp": now_iso,
                "type": "recovery",
                "category": tool_name,
                "detail": f"Recovered from failure on {target_key}",
            }
        )
        recent_failures.pop(action_id, None)
    elif is_failure:
        recent_failures[action_id] = True

    count_key = target_key.strip()
    if tool_name == "run_command" and len(count_key) > 80:
        count_key = count_key[:80] + "..."

    current_count = action_counts.get(count_key, 0) + 1
    action_counts[count_key] = current_count

    if current_count == 2 or (current_count > 2 and current_count % 3 == 0):
        events_to_log.append(
            {
                "timestamp": now_iso,
                "type": "repetition",
                "category": tool_name,
                "detail": f"Repeated action: {count_key} ({current_count}x in session)",
            }
        )

    if events_to_log:
        try:
            with open(buffer_file, "a", encoding="utf-8") as f:
                for ev in events_to_log:
                    f.write(json.dumps(ev) + "\n")
        except Exception as e:
            sys.stderr.write(f"[HOOK WARNING] Could not append to pattern-buffer.jsonl: {e}\n")

    session_data["recent_failures"] = recent_failures
    session_data["action_counts"] = action_counts
    try:
        with open(session_file, "w", encoding="utf-8") as f:
            json.dump(session_data, f)
    except Exception:
        pass


def handle_post_tool_use(payload):
    cwd = payload.get("cwd") or str(pathlib.Path.cwd())

    # Passively record telemetry events
    try:
        record_passive_telemetry(payload, cwd)
    except Exception as e:
        sys.stderr.write(f"[HOOK WARNING] Telemetry error: {e}\n")

    tool_call = payload.get("toolCall", {})
    args = tool_call.get("args", {})
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
