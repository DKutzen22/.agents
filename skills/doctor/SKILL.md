---
name: doctor
description: >
  Command entrypoint to diagnose repository health. Catches /doctor and delegates mount audits to the scout subagent.
---

# /doctor

User-facing command interface for auditing the physical integrity, environment dependencies, and mounting contracts of the Synapse repository.

> [!NOTE]
> **Dispatch Flow:** `/doctor` (Skill Entrypoint) $\longrightarrow$ [`agents/scout.md`](../../agents/scout.md) (Execution Worker).
> Skills trigger subagents; subagents never trigger skills.

## Execution Steps

### 1. Locate Repository Root
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"
echo "==> Running Synapse Doctor at $REPO_ROOT"
```

### 2. Verify Manifests & Configurations
Validate JSON manifests and `apm.yml`:
```bash
python3 -m json.tool hooks.json > /dev/null
python3 -m json.tool rules.json > /dev/null
python3 -m json.tool skills.json > /dev/null
python3 -m json.tool agents.json > /dev/null
python3 -m json.tool mcp.json.template > /dev/null
python3 -c "import yaml; d = yaml.safe_load(open('apm.yml')); assert all(k in d for k in ['name', 'namespace', 'version', 'targets'])"
echo "✓ Manifests are valid."
```

### 3. Delegate Symlink & Mount Audit to Scout Subagent
Invoke the specialized **`scout`** subagent (`agents/scout.md`) to verify mount topology and consumer configurations:
```text
Task: Audit relative symlink integrity, .git/info/exclude entries, and fleet mount registrations.
Target Script: scripts/sync-all-repos.sh --check.
Registry: ${XDG_CONFIG_HOME:-$HOME/.config}/agents/linked-repos.txt.
```

### 4. Verify Git Hooks & Helper Scripts
Confirm Git hooks and helper scripts are executable and syntactically valid:
```bash
test -x .githooks/pre-commit || chmod +x .githooks/pre-commit
for s in scripts/*.sh scripts/*.py; do
    test -x "$s" || chmod +x "$s"
done
sh -n scripts/*.sh
python3 -m py_compile scripts/*.py
echo "✓ Scripts and hooks verified."
```

### 5. Verify Cross-Links & Distribution Checksums
- Audit documentation links: `python3 scripts/check-links.py --root .`
- Verify distribution archives:
  ```bash
  if [ -d "dist" ] && [ -f dist/*.zip ]; then
      (cd dist && sha256sum -c *.sha256 2>/dev/null || true)
  fi
  ```
