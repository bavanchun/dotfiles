#!/bin/bash
MODE=$(cat "$HOME/.config/theme-mode" 2>/dev/null || echo "dark")
ln -sf "$HOME/.config/alacritty/theme-${MODE}.toml" "$HOME/.config/alacritty/theme.toml"
