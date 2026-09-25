#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " Git Configuration"
echo "========================================"

git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.editor "code --wait"
git config --global fetch.prune true
git config --global rerere.enabled true

echo
echo "[Git] Current configuration:"
git config --global --list

echo
echo "[Git] Configuration complete."
