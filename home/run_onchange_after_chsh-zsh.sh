#!/usr/bin/env bash
# chsh version: 1
set -euo pipefail

ZSH_PATH=$(command -v zsh 2>/dev/null || true)
if [[ -z "$ZSH_PATH" ]]; then
  echo "Warning: zsh not found, skipping chsh"
  exit 0
fi

CURRENT_SHELL="${SHELL:-}"
if [[ -z "$CURRENT_SHELL" ]] && command -v getent >/dev/null 2>&1; then
  CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
fi

if [[ "$(basename "$CURRENT_SHELL")" == "zsh" ]]; then
  exit 0
fi

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  echo "Switching default shell to zsh ($ZSH_PATH)..."
  chsh -s "$ZSH_PATH" "$USER" || echo "Warning: chsh failed (may need sudo or PAM config)"
fi
