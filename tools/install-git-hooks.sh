#!/usr/bin/env bash
# Install the repo's git hooks (currently: pre-commit → codebase index refresh).
# Run from anywhere; idempotent.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
mkdir -p "$root/.git/hooks"
cp "$root/tools/git-hooks/pre-commit" "$root/.git/hooks/pre-commit"
chmod +x "$root/.git/hooks/pre-commit"
echo "Installed pre-commit hook: regenerates docs/codebase_index.* on lib/ changes."
