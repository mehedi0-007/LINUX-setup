#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================"
echo " Shell Environment Setup"
echo "========================================"

echo
echo "[1/2] Configuring Bash..."

BASHRC="$HOME/.bashrc"

# Add our machine-config block only once.
if ! grep -q "# linux-machine-config" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# linux-machine-config
export EDITOR="code --wait"
export VISUAL="code --wait"

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
EOF
fi

echo
echo "[2/2] Verifying shell..."

echo "  Bash: $(bash --version | head -n1)"
echo "  Shell: $SHELL"

echo
echo "[Shell] Setup complete."
echo "Restart your terminal or run: source ~/.bashrc"
