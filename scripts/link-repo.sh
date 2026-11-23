#!/bin/sh
# scripts/link-repo.sh — Mounts centralized Synapse (.agents) into a target repository using relative symlinks
set -eu

usage() {
    cat << 'EOF'
Usage: link-repo.sh [OPTIONS] <TARGET_REPO_DIR>

Mounts this central Synapse (.agents) repository into a target project repository by creating
strict relative symlinks, configuring Git exclusions in .git/info/exclude, initializing
repo-local state/memory/local-rules, and generating root entrypoint pointers.

Arguments:
  <TARGET_REPO_DIR>   Path to consumer Git repository (absolute or relative)

Options:
  --force             Replace conflicting symlinks or non-protected directories
  --no-entrypoints    Skip generating root GEMINI.md and CLAUDE.md pointer files
  --ci-copy           Copy standalone CI scripts into <target>/.github/scripts/
  --register          Register target path in ${XDG_CONFIG_HOME:-$HOME/.config}/agents/linked-repos.txt
  -h, --help          Show this help message and exit

Symlink Topology Created:
  <target>/.agents/instructions -> <rel-path-to-central>/instructions
  <target>/.agents/skills       -> <rel-path-to-central>/skills
  <target>/.agents/agents       -> <rel-path-to-central>/agents
  <target>/.agents/context      -> <rel-path-to-central>/context
  <target>/.agents/scripts      -> <rel-path-to-central>/scripts
  <target>/.agents/hooks.json   -> <rel-path-to-central>/hooks.json
  <target>/.agents/rules.json   -> <rel-path-to-central>/rules.json
  <target>/.agents/skills.json  -> <rel-path-to-central>/skills.json
  <target>/.agents/agents.json  -> <rel-path-to-central>/agents.json
  <target>/.agents/apm.yml      -> <rel-path-to-central>/apm.yml
  <target>/.agents/memory/user-profile.md  -> <rel-path-to-central>/memory/user-profile.md
  <target>/.agents/memory/anti-patterns.md -> <rel-path-to-central>/memory/anti-patterns.md

Git Tracking Separation:
  - Global symlinks excluded via <target>/.git/info/exclude (never committed)
  - Repo-local state/, memory/, and local-rules/ tracked in <target> Git history
EOF
}

FORCE=0
GEN_ENTRYPOINTS=1
CI_COPY=0
REGISTER=0
TARGET=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --no-entrypoints)
            GEN_ENTRYPOINTS=0
            shift
            ;;
        --ci-copy)
            CI_COPY=1
            shift
            ;;
        --register)
            REGISTER=1
            shift
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

# 1. Validate target directory exists and is a Git repository
if [ ! -d "$TARGET" ]; then
    mkdir -p "$TARGET"
fi

if ! git -C "$TARGET" rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Target directory '$TARGET' is not a valid Git repository." >&2
    echo "       Please run 'git init' in the target directory first." >&2
    exit 1
fi

TARGET_DIR="$(cd "$TARGET" && pwd -P)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CENTRAL_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"

# Verify central directory has expected governance marker
if [ ! -f "$CENTRAL_DIR/context/repo-governance-spec.md" ]; then
    echo "Error: Unable to locate central repository governance spec at $CENTRAL_DIR" >&2
    exit 1
fi

# Prevent mounting into central repo itself
if [ "$TARGET_DIR" = "$CENTRAL_DIR" ]; then
    echo "Error: Target directory cannot be the central .agents repository itself." >&2
    exit 1
fi

TARGET_AGENTS="$TARGET_DIR/.agents"
mkdir -p "$TARGET_AGENTS"

# 2. Compute dynamic relative path from <target>/.agents to central repo
REL_CENTRAL=$(python3 -c 'import os.path, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$CENTRAL_DIR" "$TARGET_AGENTS")
case "$REL_CENTRAL" in
    /*)
        echo "Error: Failed to compute relative path from $TARGET_AGENTS to $CENTRAL_DIR (got absolute: $REL_CENTRAL)" >&2
        exit 1
        ;;
    "")
        echo "Error: Computed relative path is empty" >&2
        exit 1
        ;;
esac

echo "==> Mounting central .agents into target repository"
echo "    Target Repository: $TARGET_DIR"
echo "    Relative Offset:   $REL_CENTRAL"

# 3. Create relative symlinks for shared static directories
SHARED_DIRS="instructions skills agents context scripts"
for dir in $SHARED_DIRS; do
    dest="$TARGET_AGENTS/$dir"
    rel_src="$REL_CENTRAL/$dir"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            rm -f "$dest"
        elif [ "$FORCE" -eq 1 ]; then
            echo "    [WARN] Replacing existing directory $dest with symlink (--force)"
            rm -rf "$dest"
        else
            echo "Error: $dest already exists and is not a symlink. Re-run with --force to replace." >&2
            exit 1
        fi
    fi
    (cd "$TARGET_AGENTS" && ln -s "$rel_src" "$dir")
    echo "  ✓ Linked $dir -> $rel_src"
done

# 4. Create relative symlinks for configuration manifests & hooks
SHARED_CONFIGS="hooks.json rules.json skills.json agents.json apm.yml"
for cfg in $SHARED_CONFIGS; do
    dest="$TARGET_AGENTS/$cfg"
    rel_src="$REL_CENTRAL/$cfg"
    if [ -f "$CENTRAL_DIR/$cfg" ]; then
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            rm -f "$dest"
        fi
        (cd "$TARGET_AGENTS" && ln -s "$rel_src" "$cfg")
        echo "  ✓ Linked $cfg -> $rel_src"
    fi
done

# 6. Initialize repo-local local-rules/ directory
LOCAL_RULES="$TARGET_AGENTS/local-rules"
mkdir -p "$LOCAL_RULES"
if [ ! -f "$LOCAL_RULES/README.md" ]; then
    cat << 'EOF' > "$LOCAL_RULES/README.md"
# Local Repository Rules

Rules placed in this directory apply specifically to this repository.
They complement the global rules symlinked under `.agents/rules/` and
are preserved across `link-repo.sh` updates.

Format: Standard Antigravity rule (`rules/[name].md`) with `globs:` frontmatter.
EOF
    echo "  ✓ Initialized repo-local local-rules/README.md"
fi

# 7. Initialize repo-local state/ (protected against --force)
LOCAL_STATE="$TARGET_AGENTS/state"
mkdir -p "$LOCAL_STATE"
if [ ! -f "$LOCAL_STATE/handoff.md" ] && [ -f "$CENTRAL_DIR/state/handoff.md" ]; then
    cp "$CENTRAL_DIR/state/handoff.md" "$LOCAL_STATE/handoff.md"
    echo "  ✓ Initialized repo-local state/handoff.md"
fi
if [ ! -f "$LOCAL_STATE/active-roadmap.md" ] && [ -f "$CENTRAL_DIR/state/active-roadmap.md" ]; then
    cp "$CENTRAL_DIR/state/active-roadmap.md" "$LOCAL_STATE/active-roadmap.md"
    echo "  ✓ Initialized repo-local state/active-roadmap.md"
fi

# 8. Initialize repo-local memory/ (protected against --force)
LOCAL_MEMORY="$TARGET_AGENTS/memory"
mkdir -p "$LOCAL_MEMORY"

# 8a. Hydrate central memory files from starter templates if missing
for tpl in "$CENTRAL_DIR/memory"/*.template.md; do
    if [ -f "$tpl" ]; then
        target_mf="$CENTRAL_DIR/memory/$(basename "$tpl" .template.md).md"
        if [ ! -f "$target_mf" ]; then
            cp "$tpl" "$target_mf"
            echo "  ✓ Hydrated central memory/$(basename "$target_mf") from template"
        fi
    fi
done

if [ ! -f "$LOCAL_MEMORY/project-decisions.md" ]; then
    if [ -f "$CENTRAL_DIR/memory/architecture-decisions.template.md" ]; then
        cp "$CENTRAL_DIR/memory/architecture-decisions.template.md" "$LOCAL_MEMORY/project-decisions.md"
    else
        cat << 'EOF' > "$LOCAL_MEMORY/project-decisions.md"
# Project Architecture Decisions (Local ADRs)

This ledger records architectural decisions specific to this repository.
Format: ADR-001 (Status, Context, Decision, Consequences).
EOF
    fi
    echo "  ✓ Initialized repo-local memory/project-decisions.md"
fi
if [ ! -f "$LOCAL_MEMORY/project-quirks.md" ]; then
    if [ -f "$CENTRAL_DIR/memory/tool-quirks.template.md" ]; then
        cp "$CENTRAL_DIR/memory/tool-quirks.template.md" "$LOCAL_MEMORY/project-quirks.md"
    else
        cat << 'EOF' > "$LOCAL_MEMORY/project-quirks.md"
# Project Tool Quirks & Empirical Notes

Log local dataset anomalies, non-standard tool versions, and repository-specific workarounds here.
EOF
    fi
    echo "  ✓ Initialized repo-local memory/project-quirks.md"
fi

# 8b. Link Tier 2 cross-project memory files (user-profile.md, anti-patterns.md)
TIER2_MEMORY_FILES="user-profile.md anti-patterns.md"
for mf in $TIER2_MEMORY_FILES; do
    if [ -f "$CENTRAL_DIR/memory/$mf" ]; then
        dest="$LOCAL_MEMORY/$mf"
        rel_src=$(python3 -c 'import os.path, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$CENTRAL_DIR/memory/$mf" "$LOCAL_MEMORY")
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            rm -f "$dest"
        fi
        (cd "$LOCAL_MEMORY" && ln -s "$rel_src" "$mf")
        echo "  ✓ Linked Tier 2 memory/$mf -> $rel_src"
    fi
done

# 9. Clean Git Exclusion via .git/info/exclude (never commits global symlinks)
GIT_DIR=$(git -C "$TARGET_DIR" rev-parse --git-dir)
case "$GIT_DIR" in
    /*) ;;
    *) GIT_DIR="$TARGET_DIR/$GIT_DIR" ;;
esac

EXCLUDE_FILE="$GIT_DIR/info/exclude"
mkdir -p "$(dirname "$EXCLUDE_FILE")"
touch "$EXCLUDE_FILE"

if ! grep -q '# --- \.agents global symlinks ---' "$EXCLUDE_FILE"; then
    cat << 'EOF' >> "$EXCLUDE_FILE"

# --- .agents global symlinks ---
.agents/instructions
.agents/skills
.agents/agents
.agents/context
.agents/scripts
.agents/hooks.json
.agents/rules.json
.agents/skills.json
.agents/agents.json
.agents/apm.yml
.agents/memory/user-profile.md
.agents/memory/anti-patterns.md
EOF
    echo "  ✓ Configured mount exclusions in .git/info/exclude"
fi

# 10. Optional CI script copying (--ci-copy)
if [ "$CI_COPY" -eq 1 ]; then
    CI_SCRIPTS_DIR="$TARGET_DIR/.github/scripts"
    mkdir -p "$CI_SCRIPTS_DIR"
    cp "$CENTRAL_DIR/scripts/check-links.py" "$CI_SCRIPTS_DIR/"
    chmod +x "$CI_SCRIPTS_DIR/check-links.py"
    echo "  ✓ Copied standalone CI scripts to .github/scripts/"
fi

# 11. Generate relative-only root IDE pointer files (GEMINI.md and CLAUDE.md) if absent
if [ "$GEN_ENTRYPOINTS" -eq 1 ]; then
    if [ ! -f "$TARGET_DIR/GEMINI.md" ]; then
        cat << 'EOF' > "$TARGET_DIR/GEMINI.md"
# AI Agent Instructions

- Standards: Read and obey all rules in `.agents/instructions/` and project-specific rules in `.agents/local-rules/`.
- Continuity: Check `@.agents/state/handoff.md` before making multi-file changes or architecture plans.
- Schemas & Specs: Reference `@.agents/context/repo-governance-spec.md` and `.agents/context/` for canonical specifications.
- Edge Cases: Check `.agents/memory/` and `.agents/state/` before modifying parsers or data contracts.
- Lifecycle Hooks: Native hooks in `.agents/hooks.json` enforce spec protection and script hygiene.
EOF
        echo "  ✓ Created root GEMINI.md pointer"
    fi

    if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
        cat << 'EOF' > "$TARGET_DIR/CLAUDE.md"
# AI Agent Instructions

- Standards: Read and obey all rules in `.agents/instructions/` and project-specific rules in `.agents/local-rules/`.
- Continuity: Check `@.agents/state/handoff.md` before making multi-file changes or architecture plans.
- Schemas & Specs: Reference `@.agents/context/repo-governance-spec.md` and `.agents/context/` for canonical specifications.
- Edge Cases: Check `.agents/memory/` and `.agents/state/` before modifying parsers or data contracts.
- Lifecycle Hooks: Native hooks in `.agents/hooks.json` enforce spec protection and script hygiene.
EOF
        echo "  ✓ Created root CLAUDE.md pointer"
    fi
fi

# 12. Idempotently update target .gitignore for transient state
TARGET_GITIGNORE="$TARGET_DIR/.gitignore"
touch "$TARGET_GITIGNORE"
if ! grep -q '\.agents/state/\*\.tmp\.md' "$TARGET_GITIGNORE"; then
    cat << 'EOF' >> "$TARGET_GITIGNORE"

# Local .agents ephemeral state
.agents/state/*.tmp.md
.agents/state/scratch-*
EOF
    echo "  ✓ Added .agents/state scratch patterns to target .gitignore"
fi

# 13. Optional repository registration in linked-repos.txt
if [ "$REGISTER" -eq 1 ]; then
    REG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/agents"
    REG_FILE="$REG_DIR/linked-repos.txt"
    mkdir -p "$REG_DIR"
    touch "$REG_FILE"
    if ! grep -q "^$TARGET_DIR\$" "$REG_FILE"; then
        echo "$TARGET_DIR" >> "$REG_FILE"
        echo "  ✓ Registered target in $REG_FILE"
    fi
fi

echo "==> Done. Repository successfully mounted with clean relative symlinks."
exit 0
