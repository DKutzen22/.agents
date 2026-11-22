#!/bin/sh
# scripts/package-synapse.sh — Cleans caches, validates manifest, and packs Synapse for APM release
set -eu

SCRIPT_NAME="package-synapse.sh"
OUTPUT_DIR="dist"
CLEAN_ONLY=0

show_help() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Cleans local build caches, validates apm.yml, and archives the Synapse
multi-agent repository into a standard .zip distribution conforming to the APM layout.

Options:
  -o, --output-dir DIR   Output directory for built archives (default: dist)
  -c, --clean-only       Clean caches and exit without building archive
  -h, --help             Show this help message and exit

Generated Artifacts:
  <output-dir>/<name>-v<version>.zip
  <output-dir>/<name>-v<version>.zip.sha256
EOF
}

# Parse CLI options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output-dir)
            if [ -z "${2:-}" ]; then
                echo "Error: --output-dir requires a directory path argument." >&2
                exit 1
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -c|--clean-only)
            CLEAN_ONLY=1
            shift
            ;;
        *)
            echo "Error: Unknown argument: $1" >&2
            echo "Run '$SCRIPT_NAME --help' for usage." >&2
            exit 1
            ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Cleaning local caches and temporary build files..."
rm -rf "$OUTPUT_DIR" build/ .pytest_cache/
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.py[cod]" -delete 2>/dev/null || true
find state/ -maxdepth 1 -name "*.tmp.md" -delete 2>/dev/null || true
echo "✓ Local caches cleared."

if [ "$CLEAN_ONLY" -eq 1 ]; then
    exit 0
fi

# Validate presence of apm.yml
if [ ! -f "apm.yml" ]; then
    echo "Error: apm.yml manifest not found in $REPO_ROOT" >&2
    exit 1
fi

echo "==> Validating apm.yml manifest..."
VALIDATION_RESULT=$(python3 - << 'EOF'
import sys, re

manifest = {}
try:
    import yaml
    with open('apm.yml', 'r', encoding='utf-8') as f:
        manifest = yaml.safe_load(f) or {}
except ImportError:
    with open('apm.yml', 'r', encoding='utf-8') as f:
        content = f.read()
    for key in ['name', 'namespace', 'version', 'description']:
        m = re.search(f"^{key}" + r":\s*[\"']?([^\"'\n\r]+)[\"']?", content, re.M) # allow-path
        if m:
            manifest[key] = m.group(1).strip()
    targets_block = re.search(r"^targets" + r":\s*\n((?:\s*-\s*[^\n\r]+\n?)+)", content, re.M) # allow-path
    if targets_block:
        manifest['targets'] = [line.strip().lstrip('-').strip() for line in targets_block.group(1).strip().split('\n') if line.strip().startswith('-')]
except Exception as e:
    sys.stderr.write(f'Error reading apm.yml: {e}\n')
    sys.exit(1)

required = ['name', 'namespace', 'version', 'description', 'targets']
missing = [k for k in required if k not in manifest]
if missing:
    sys.stderr.write(f'Error: apm.yml missing required keys: {missing}\n')
    sys.exit(1)

if not isinstance(manifest['targets'], list) or len(manifest['targets']) == 0:
    sys.stderr.write('Error: apm.yml targets must be a non-empty list\n')
    sys.exit(1)

name = str(manifest['name']).strip()
version = str(manifest['version']).strip().lstrip('v')
namespace = str(manifest['namespace']).strip()

print(f'{namespace}|{name}|{version}')
EOF
)

NAMESPACE=$(echo "$VALIDATION_RESULT" | cut -d'|' -f1)
PKG_NAME=$(echo "$VALIDATION_RESULT" | cut -d'|' -f2)
PKG_VERSION=$(echo "$VALIDATION_RESULT" | cut -d'|' -f3)

echo "✓ Manifest valid: $NAMESPACE/$PKG_NAME v$PKG_VERSION"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

ARCHIVE_BASENAME="${PKG_NAME}-v${PKG_VERSION}.zip"
ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_BASENAME"
SHA256_PATH="$OUTPUT_DIR/${ARCHIVE_BASENAME}.sha256"

echo "==> Assembling Synapse APM package archive: $ARCHIVE_PATH..."

# Create zip archive excluding git internal metadata, .github release CI, and environment artifacts
zip -r -q "$ARCHIVE_PATH" \
    apm.yml \
    .gitattributes \
    AGENTS.md \
    README.md \
    LICENSE \
    agents.json \
    rules.json \
    skills.json \
    hooks.json \
    mcp.json.template \
    rules/ \
    prompts/ \
    skills/ \
    agents/ \
    context/ \
    memory/ \
    state/ \
    scripts/ \
    -x "*/__pycache__/*" \
    -x "*.py[cod]" \
    -x "*/.DS_Store" \
    -x "state/*.tmp.md" \
    -x "dist/*" \
    -x "build/*"

# Compute SHA-256 checksum
if command -v sha256sum >/dev/null 2>&1; then
    (cd "$OUTPUT_DIR" && sha256sum "$ARCHIVE_BASENAME" > "${ARCHIVE_BASENAME}.sha256")
elif command -v shasum >/dev/null 2>&1; then
    (cd "$OUTPUT_DIR" && shasum -a 256 "$ARCHIVE_BASENAME" > "${ARCHIVE_BASENAME}.sha256")
else
    echo "Warning: Neither sha256sum nor shasum available; skipping checksum." >&2
fi

echo "✓ Successfully built APM distribution archive:"
echo "   Package:  $ARCHIVE_PATH"
if [ -f "$SHA256_PATH" ]; then
    echo "   Checksum: $SHA256_PATH ($(cat "$SHA256_PATH" | awk '{print $1}'))"
fi
