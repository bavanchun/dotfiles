#!/usr/bin/env bash
# chsh version: 1
set -euo pipefail

ZSH_PATH=$(command -v zsh 2>/dev/null || true)
if [[ -z "$ZSH_PATH" ]]; then
  echo "Warning: zsh not found, skipping chsh"
  exit 0
fi

CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  echo "Switching default shell to zsh ($ZSH_PATH)..."
  chsh -s "$ZSH_PATH" "$USER" || echo "Warning: chsh failed (may need sudo or PAM config)"
fi
