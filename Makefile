.PHONY: all package validate clean help test

all: help

help:
	@echo "Available make targets for Synapse:"
	@echo "  make package   - Clean caches, validate apm.yml, and pack zip archive for Synapse release"
	@echo "  make validate  - Run full repository governance, manifests, and link validation"
	@echo "  make clean     - Clean local build caches, pycache, and dist/ directory"
	@echo "  make test      - Run governance checks and end-to-end smoke tests"

package: clean
	@./scripts/package-synapse.sh

validate:
	@echo "==> Validating configuration manifests"
	@python3 -m json.tool hooks.json > /dev/null
	@python3 -m json.tool agents.json > /dev/null
	@python3 -m json.tool rules.json > /dev/null
	@python3 -m json.tool skills.json > /dev/null
	@python3 -m json.tool mcp.json.template > /dev/null
	@python3 -c '\
import sys, re; \
c = open("apm.yml").read(); \
assert all(re.search(rf"^{k}:", c, re.M) for k in ["name", "namespace", "version", "description", "targets"])'
	@echo "✓ All JSON and YAML manifests valid."
	@echo "==> Running full-repo pre-commit governance verification"
	@sh .githooks/pre-commit --all
	@echo "✓ Governance checks passed."
	@echo "==> Auditing relative links across documentation"
	@python3 scripts/check-links.py --root .
	@echo "✓ Cross-link audit passed."

clean:
	@rm -rf dist/ build/ .pytest_cache/
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.py[cod]" -delete 2>/dev/null || true
	@find state/ -maxdepth 1 -name "*.tmp.md" -delete 2>/dev/null || true
	@echo "✓ Cleaned build artifacts and caches."

test: validate
	@echo "==> Verifying shell and Python script syntax"
	@sh -n scripts/*.sh
	@python3 -m py_compile scripts/*.py
	@./scripts/package-agent.sh --help > /dev/null
	@./scripts/link-repo.sh --help > /dev/null
	@./scripts/unlink-repo.sh --help > /dev/null
	@./scripts/sync-all-repos.sh --help > /dev/null
	@python3 scripts/check-links.py --help > /dev/null
	@python3 scripts/hook-handler.py --help > /dev/null
	@echo "✓ All test suites and CLI interfaces verified."
