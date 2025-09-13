SHELL := /bin/bash
.SHELLFLAGS := -ec

# Project Configuration
PROJECT := mcp-redmine-enhanced
PACKAGE := mcp_redmine
VERSION := $(shell date +%Y.%m.%d.%H%M%S).post0

# Common Variables
TEST_VENV := /tmp/test-mcp-redmine-enhanced
PYTHON_VERSION := 3.12
PACKAGE_NAME := mcp-redmine-enhanced

# Version Management
version-bump:
	sed -i.bak "s/$(PACKAGE_NAME)==[0-9.]*\.post[0-9]*\"/$(PACKAGE_NAME)==$(VERSION)\"/g" README.md && rm README.md.bak
	awk -v ver="$(VERSION)" '\
	  BEGIN{in_proj=0}\
	  /^\[project\]$$/ {in_proj=1; print; next}\
	  /^\[/ && $$0!="[project]" {in_proj=0}\
	  in_proj && /^version = "/ { sub(/version = "[^"]*"/, "version = \"" ver "\""); print; next }\
	  {print}\
	' pyproject.toml > pyproject.toml.tmp && mv pyproject.toml.tmp pyproject.toml
	sed -i.bak "s/VERSION = \"[^\"]*\"/VERSION = \"$(VERSION)\"/" $(PACKAGE)/server.py && rm $(PACKAGE)/server.py.bak

version-bump-claude-desktop:
	@if [ -f ~/.config/Claude/claude_desktop_config.json ]; then \
		sed -i.bak "s/$(PACKAGE_NAME)==[0-9.]*\.post[0-9]*\"/$(PACKAGE_NAME)==$(VERSION)\"/g" ~/.config/Claude/claude_desktop_config.json && rm ~/.config/Claude/claude_desktop_config.json.bak; \
	else \
		echo "Skipping Claude config bump (file not found)"; \
	fi

# Build Helpers
clean-dist:
	rm -rf dist/

build-package: clean-dist
	uv build

# Development & Testing
test:
	uv run --group dev pytest tests/ -v

test-coverage:
	uv run --group dev pytest tests/ --cov=mcp_redmine --cov-report=html --cov-report=term

test-install:
	uv sync --group dev
	$(MAKE) test

# Pre-publication Checks
pre-publish-check:
	@echo "🔍 Running pre-publication checks..."
	$(MAKE) test
	@echo "✅ All tests passed"
	@echo "🔧 Testing package build..."
	$(MAKE) build-package
	@echo "✅ Package built successfully"
	@echo "📦 Ready for publication!"

# Publication Targets
publish-test: pre-publish-check
	@echo "🚀 Publishing $(PACKAGE_NAME) to Test PyPI..."
	@test -n "$$PYPI_TOKEN_TEST" || { echo "PYPI_TOKEN_TEST is not set (try: source .env)"; exit 1; }
	$(MAKE) version-bump
	$(MAKE) build-package
	uv publish --publish-url https://test.pypi.org/legacy/ --token "$$PYPI_TOKEN_TEST"
	@echo "✅ Published to Test PyPI: https://test.pypi.org/project/$(PACKAGE_NAME)/"
	git checkout -- README.md pyproject.toml || true; \
	[ -f "$(PACKAGE)/server.py" ] && git checkout -- $(PACKAGE)/server.py || true

publish-prod: pre-publish-check
	@echo "🚀 Publishing $(PACKAGE_NAME) to Production PyPI..."
	@test -n "$$PYPI_TOKEN_PROD" || { echo "PYPI_TOKEN_PROD is not set (try: source .env)"; exit 1; }
	$(MAKE) version-bump
	$(MAKE) version-bump-claude-desktop
	$(MAKE) build-package
	uv lock
	uv publish --token "$$PYPI_TOKEN_PROD"
	git add uv.lock README.md pyproject.toml
	[ -f "$(PACKAGE)/server.py" ] && git add "$(PACKAGE)/server.py" || true
	git commit -m "Published version $(VERSION) to PyPI"
	git push
	@echo "🎉 Published to PyPI: https://pypi.org/project/$(PACKAGE_NAME)/"

# Package Testing Helpers
setup-test-env:
	rm -rf $(TEST_VENV)
	uv venv $(TEST_VENV) --python $(PYTHON_VERSION)

package-inspect-test: setup-test-env
	source $(TEST_VENV)/bin/activate && uv pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ $(PACKAGE_NAME)
	(command -v tree > /dev/null && tree $(TEST_VENV)/lib/python$(PYTHON_VERSION)/site-packages/$(PACKAGE)) || \
	find $(TEST_VENV)/lib/python$(PYTHON_VERSION)/site-packages/$(PACKAGE) -maxdepth 2 -print
	source $(TEST_VENV)/bin/activate && which mcp-redmine

package-inspect-prod: setup-test-env
	source $(TEST_VENV)/bin/activate && uv pip install $(PACKAGE_NAME)
	(command -v tree > /dev/null && tree $(TEST_VENV)/lib/python$(PYTHON_VERSION)/site-packages/$(PACKAGE)) || \
	find $(TEST_VENV)/lib/python$(PYTHON_VERSION)/site-packages/$(PACKAGE) -maxdepth 2 -print
	source $(TEST_VENV)/bin/activate && which mcp-redmine

package-run-test:
	uvx --default-index https://test.pypi.org/simple/ --index https://pypi.org/simple/ --from $(PACKAGE_NAME) mcp-redmine

package-run-prod:
	uvx --from $(PACKAGE_NAME) mcp-redmine

# Utility Targets
clean: clean-dist
	rm -rf .pytest_cache htmlcov .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Help Documentation
help:
	@echo "🛠️  MCP Redmine Enhanced - Available Commands"
	@echo "=============================================="
	@echo ""
	@echo "📋 Development:"
	@echo "  test                   - Run all tests"
	@echo "  test-coverage         - Run tests with coverage report"
	@echo "  test-install          - Install dev dependencies and run tests"
	@echo "  clean                 - Clean build artifacts and cache files"
	@echo ""
	@echo "📦 Publication:"
	@echo "  pre-publish-check     - Run all pre-publication checks"
	@echo "  publish-test          - Publish to Test PyPI"
	@echo "  publish-prod          - Publish to Production PyPI"
	@echo ""
	@echo "🔍 Package Testing:"
	@echo "  package-inspect-test  - Test installation from Test PyPI"
	@echo "  package-inspect-prod  - Test installation from Production PyPI"
	@echo "  package-run-test      - Run package from Test PyPI"
	@echo "  package-run-prod      - Run package from Production PyPI"
	@echo ""
	@echo "⚙️  Version Management:"
	@echo "  version-bump          - Update version in all files"
	@echo "  version-bump-claude-desktop - Update Claude Desktop config"
	@echo ""
	@echo "🔧 Build Helpers:"
	@echo "  build-package         - Build source and wheel distributions"
	@echo "  clean-dist            - Clean distribution directory"
	@echo ""
	@echo "📚 Documentation:"
	@echo "  help                  - Show this help message"

# Default target
.DEFAULT_GOAL := help
