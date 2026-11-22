#!/bin/sh
# scripts/sync-all-repos.sh — Audits or refreshes .agents mounts across all registered repositories
set -eu

usage() {
    cat << 'EOF'
Usage: sync-all-repos.sh [OPTIONS]

Audits or refreshes the central .agents mount across all registered repositories.
Repositories are registered in a user-local registry file.

Options:
  --check             Audit mounts: verify relative symlinks, git exclusions, and state limits (default)
  --refresh           Re-run scripts/link-repo.sh on all registered repositories
  --registry <PATH>   Override default registry file path
  -h, --help          Show this help message and exit

Default Registry Path:
  ${XDG_CONFIG_HOME:-$HOME/.config}/agents/linked-repos.txt
EOF
}

MODE="check"
REGISTRY="${XDG_CONFIG_HOME:-$HOME/.config}/agents/linked-repos.txt"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --check)
            MODE="check"
            shift
            ;;
        --refresh)
            MODE="refresh"
            shift
            ;;
        --registry)
            if [ $# -lt 2 ]; then
                echo "Error: --registry requires a file path argument" >&2
                exit 1
            fi
            REGISTRY="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            echo "Error: Unexpected positional argument $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CENTRAL_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

if [ ! -f "$REGISTRY" ]; then
    echo "ℹ Registry file not found: $REGISTRY"
    echo "  No repositories currently registered. Use './scripts/link-repo.sh --register <TARGET>' to add repos."
    exit 0
fi

TOTAL=0
FAILED=0

echo "==> Syncing all registered repositories in mode: $MODE"
echo "    Registry: $REGISTRY"

while IFS= read -r repo_path || [ -n "$repo_path" ]; do
    # Trim whitespace and skip comments or empty lines
    repo_path=$(echo "$repo_path" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    case "$repo_path" in
        ""|\#*) continue ;;
    esac

    TOTAL=$((TOTAL + 1))
    echo "\n------------------------------------------------------------"
    echo "[$TOTAL] Target: $repo_path"

    if [ ! -d "$repo_path" ]; then
        echo "  ❌ Directory does not exist on disk: $repo_path"
        FAILED=$((FAILED + 1))
        continue
    fi

    if ! git -C "$repo_path" rev-parse --git-dir > /dev/null 2>&1; then
        echo "  ❌ Not a valid Git repository: $repo_path"
        FAILED=$((FAILED + 1))
        continue
    fi

    if [ "$MODE" = "refresh" ]; then
        if "$CENTRAL_DIR/scripts/link-repo.sh" --force "$repo_path"; then
            echo "  ✓ Refreshed mount successfully"
        else
            echo "  ❌ Failed to refresh mount"
            FAILED=$((FAILED + 1))
        fi
    else
        # --check mode
        TARGET_AGENTS="$repo_path/.agents"
        REPO_FAIL=0

        if [ ! -d "$TARGET_AGENTS" ]; then
            echo "  ❌ Missing .agents directory"
            FAILED=$((FAILED + 1))
            continue
        fi

        # 1. Verify relative symlinks resolve
        REQUIRED_LINKS="rules skills agents context scripts hooks.json commands"
        for link in $REQUIRED_LINKS; do
            lp="$TARGET_AGENTS/$link"
            if [ ! -L "$lp" ]; then
                echo "  ❌ .agents/$link is missing or not a symlink"
                REPO_FAIL=1
            elif [ ! -e "$lp" ]; then
                echo "  ❌ .agents/$link is a broken symlink (points to non-existent target)"
                REPO_FAIL=1
            else
                target_dest=$(readlink "$lp")
                case "$target_dest" in
                    /*)
                        echo "  ⚠️ .agents/$link is an absolute symlink ($target_dest); expected relative"
                        REPO_FAIL=1
                        ;;
                esac
            fi
        done

        # 2. Verify git exclusion
        GIT_DIR=$(git -C "$repo_path" rev-parse --git-dir 2>/dev/null || true)
        case "$GIT_DIR" in
            /*) ;;
            *) GIT_DIR="$repo_path/$GIT_DIR" ;;
        esac
        EXCLUDE="$GIT_DIR/info/exclude"
        if [ ! -f "$EXCLUDE" ] || ! grep -q '# --- \.agents global symlinks ---' "$EXCLUDE"; then
            echo "  ⚠️ Missing global symlink exclusion block in .git/info/exclude"
            REPO_FAIL=1
        fi

        # 3. Verify local handoff line limit
        HANDOFF="$TARGET_AGENTS/state/handoff.md"
        if [ -f "$HANDOFF" ]; then
            h_lines=$(wc -l < "$HANDOFF")
            if [ "$h_lines" -gt 50 ]; then
                echo "  ⚠️ state/handoff.md has $h_lines lines (exceeds 50-line limit)"
                REPO_FAIL=1
            fi
        fi

        if [ "$REPO_FAIL" -eq 0 ]; then
            echo "  ✓ Repository mount and state verified (all checks passed)"
        else
            FAILED=$((FAILED + 1))
        fi
    fi
done < "$REGISTRY"

echo "\n============================================================"
echo "Summary: $TOTAL registered repos checked, $FAILED failure(s)."

if [ "$FAILED" -ne 0 ]; then
    exit 1
fi
exit 0
