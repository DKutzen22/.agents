#!/bin/sh
# scripts/unlink-repo.sh — Safely tears down Synapse (.agents) symlinks in a target repository
set -eu

usage() {
    cat << 'EOF'
Usage: unlink-repo.sh [OPTIONS] <TARGET_REPO_DIR>

Tears down the central Synapse (.agents) symlink mount inside a target project repository,
removing shared symlinks and cleaning up .git/info/exclude while strictly
preserving all repo-local state/, memory/, and local-rules/ files.

Arguments:
  <TARGET_REPO_DIR>   Path to the consumer Git repository (absolute or relative)

Options:
  -h, --help          Show this help message and exit

Items Removed:
  - Symlinks: rules, skills, agents, context, scripts, commands,
              hooks.json, rules.json, skills.json, agents.json
  - Git exclude block in <target>/.git/info/exclude

Items Preserved (Untouched):
  - .agents/state/ (handoff.md, active-roadmap.md)
  - .agents/memory/ (project-decisions.md, project-quirks.md)
  - .agents/local-rules/
  - Root entrypoint files (GEMINI.md, CLAUDE.md)
EOF
}

TARGET=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [ -n "$TARGET" ]; then
                echo "Error: Multiple target directories specified" >&2
                usage >&2
                exit 1
            fi
            TARGET="$1"
            shift
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    echo "Error: Target repository directory required." >&2
    usage >&2
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Error: Target directory does not exist: $TARGET" >&2
    exit 1
fi

TARGET_DIR="$(cd "$TARGET" && pwd -P)"
TARGET_AGENTS="$TARGET_DIR/.agents"

if [ ! -d "$TARGET_AGENTS" ]; then
    echo "Error: No .agents directory found in target: $TARGET_DIR" >&2
    exit 1
fi

echo "==> Unlinking central .agents from: $TARGET_DIR"

# 1. Remove standard symlinks only (never touch real directories/files)
SYMLINKS_TO_REMOVE="rules prompts instructions skills agents context scripts commands hooks.json rules.json skills.json agents.json apm.yml"

for item in $SYMLINKS_TO_REMOVE; do
    link_path="$TARGET_AGENTS/$item"
    if [ -L "$link_path" ]; then
        rm -f "$link_path"
        echo "  ✓ Removed symlink .agents/$item"
    fi
done

# Check for any remaining dangling symlinks inside .agents
for item in "$TARGET_AGENTS"/*; do
    if [ -L "$item" ]; then
        rm -f "$item"
        echo "  ✓ Removed dangling symlink $(basename "$item")"
    fi
done

# 2. Clean up .git/info/exclude
GIT_DIR=$(git -C "$TARGET_DIR" rev-parse --git-dir 2>/dev/null || true)
if [ -n "$GIT_DIR" ]; then
    case "$GIT_DIR" in
        /*) ;;
        *) GIT_DIR="$TARGET_DIR/$GIT_DIR" ;;
    esac
    EXCLUDE_FILE="$GIT_DIR/info/exclude"

    if [ -f "$EXCLUDE_FILE" ] && grep -q '# --- \.agents global symlinks ---' "$EXCLUDE_FILE"; then
        # Remove block between marker and next empty line or EOF
        python3 -c '
import sys, pathlib
p = pathlib.Path(sys.argv[1])
lines = p.read_text(encoding="utf-8").splitlines()
out = []
skip = False
for line in lines:
    if line.strip() == "# --- .agents global symlinks ---":
        skip = True
        continue
    if skip and line.startswith(".agents/"):
        continue
    if skip and not line.strip():
        skip = False
        continue
    skip = False
    out.append(line)
p.write_text("\n".join(out) + ("\n" if out else ""), encoding="utf-8")
' "$EXCLUDE_FILE"
        echo "  ✓ Cleaned up .git/info/exclude"
    fi
fi

echo "==> Done. Unlinked .agents mount. Local state/, memory/, and local-rules/ were preserved."
exit 0
