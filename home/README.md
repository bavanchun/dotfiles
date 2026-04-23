# dotconfig-term

Cross-platform terminal/CLI dotfiles managed with [chezmoi](https://chezmoi.io).
Works on both **Ubuntu** and **Arch Linux**.

## What's included

| Config | App |
|--------|-----|
| `dot_config/nvim/` | Neovim (LazyVim) |
| `dot_config/tmux/` | tmux |
| `dot_config/alacritty/` | Alacritty terminal |
| `dot_config/kitty/` | Kitty terminal |
| `dot_config/wezterm/` | WezTerm terminal |
| `dot_config/starship.toml` | Starship prompt |
| `dot_zshrc` | Zsh config |

## Install

```bash
# Install chezmoi if not present
sh -c "$(curl -fsLS get.chezmoi.io)"

# Init and apply
chezmoi init --apply bavanchun/dotconfig-term
```

Packages are installed automatically via `run_onchange_before_install-packages.sh.tmpl` using `apt` (Ubuntu) or `pacman` (Arch).

## Arch Linux users

Also apply the desktop stack after this:

```bash
chezmoi init --source ~/.local/share/chezmoi-arch --apply bavanchun/dotconfig-arch
```

## Theme

Light/dark toggle state is stored at `~/.config/theme-mode` (`dark` | `light`).

- Alacritty: `theme.toml` is a symlink to `theme-dark.toml` or `theme-light.toml` (static Catppuccin themes, no matugen dependency).
- On Arch: `dotconfig-arch` handles waybar/swaync/GTK theme switching via matugen.

See also: [bavanchun/dotconfig-arch](https://github.com/bavanchun/dotconfig-arch)
