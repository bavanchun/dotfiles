# dotconfig-arch

> Arch Linux desktop dotfiles (Hyprland + DankMaterialShell) — managed by [chezmoi](https://www.chezmoi.io/), zero-touch bootstrap.
>
> **Terminal/CLI configs** live in a separate repo: [bavanchun/dotconfig-term](https://github.com/bavanchun/dotconfig-term)

```
┌─────────────────────────────────────────────────────┐
│  Compositor  : Hyprland                             │
│  Shell       : DankMaterialShell (Quickshell + Go)  │
│    ├ bar, launcher, notifications, control center   │
│    ├ lock screen, idle/sleep, polkit agent          │
│    ├ clipboard, screenshot, wallpaper, theming      │
│    └ điều khiển qua `dms ipc call ...`              │
│  Terminal    : WezTerm · Kitty · Alacritty          │
│  Input       : fcitx5 + Bamboo (Alt+Space)          │
│  Theming     : Material You từ wallpaper (matugen)  │
└─────────────────────────────────────────────────────┘
```

DMS thay cho toàn bộ stack cũ: **waybar, rofi, fuzzel, swaync, wlogout, hyprlock,
hypridle, hyprpolkitagent, nm-applet, awww, cliphist, flameshot, hyprshot**.

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Key Bindings](#key-bindings)
- [Theming](#theming)
- [Per-machine Configuration](#per-machine-configuration)
- [Repository Structure](#repository-structure)
- [Daily Workflow](#daily-workflow)
- [Troubleshooting](#troubleshooting)

---

## Features

- **Zero-touch bootstrap** — chạy 1 lệnh trên máy Arch mới là setup xong toàn bộ
- **Ít mảnh ghép** — một shell lo bar + launcher + notification + lock + clipboard,
  thay vì 10 daemon rời rạc phải tự nối với nhau
- **Cài từ repo chính thức** — `dms-shell-hyprland` nằm trong `extra`, không phải
  build quickshell fork như caelestia hay end-4
- **Config tách khỏi code shell** — tuỳ chỉnh nằm ở `~/.config/DankMaterialShell/settings.json`
  (chỉnh bằng GUI), `pacman -Syu` nâng shell mà không đụng vào
- **Per-machine configs** — biến `machine` auto-detect từ hostname, monitor config riêng từng máy
- **Material You theming** — matugen sinh màu từ wallpaper cho GTK, Qt, kitty,
  alacritty, wezterm, nvim, KDE
- **Bộ gõ tiếng Việt** — fcitx5 + Bamboo, `Alt+Space` chuyển Việt/Anh

---

## Quick Start

### Setup trên máy Arch mới

Yêu cầu: Arch Linux đã cài, user đã tạo, sudo đã setup, mạng đã thông.

```bash
# 1. Đặt hostname có nghĩa (quan trọng — machine config dựa vào hostname)
hostnamectl set-hostname <tên-máy>

# 2. Cài chezmoi + git (chỉ 2 packages này cần cài thủ công)
sudo pacman -S --needed chezmoi git

# 3. Init terminal repo trước (shell, nvim, tmux, alacritty, kitty, wezterm)
chezmoi init --apply git@github.com:bavanchun/dotconfig-term.git

# 4. Init arch repo vào source directory riêng
chezmoi init --source ~/.local/share/chezmoi-arch --apply git@github.com:bavanchun/dotconfig-arch.git
```

Bước 4 sẽ tự động:

| Bước | Thực hiện |
|------|-----------|
| 1 | Render `~/.config/chezmoi/chezmoi.toml` với `machine = hostname` |
| 2 | Cài `yay` (AUR helper) từ source nếu chưa có |
| 3 | Cài **48 pacman + 2 AUR packages** từ `.chezmoidata/packages.yaml` |
| 4 | Apply configs vào `~/.config/` |
| 5 | Enable systemd: `NetworkManager`, `bluetooth`, `power-profiles-daemon` |
| 6 | Tạo fallback monitor config nếu chưa có `monitors-<hostname>.conf` |

> `zsh` default shell được xử lý bởi `dotconfig-term` repo (bước 3).

### Hậu install

```bash
mkdir -p ~/Pictures/Wallpapers
cp /path/to/wallpapers/*.jpg ~/Pictures/Wallpapers/

# Logout và chọn Hyprland trong display manager
```

Lần đầu chạy, DMS hiện **greeter first-launch** để chọn theme và wallpaper.

Kiểm tra tình trạng cài đặt bất cứ lúc nào:

```bash
dms doctor
```

---

## Architecture

### Bootstrap flow

```
chezmoi init --apply
        │
        ├─► [.chezmoi.toml.tmpl] → render → ~/.config/chezmoi/chezmoi.toml
        │                                    (machine = hostname)
        │
        ├─► run_onchange_before_01-install-yay.sh
        │       └─► clone yay-bin → makepkg -si
        │
        ├─► run_onchange_before_02-install-packages.sh.tmpl
        │       └─► pacman -S + yay -S từ .chezmoidata/packages.yaml
        │
        ├─► Apply dotfiles (dot_config/** → ~/.config/**)
        │       └─► Render hyprland.conf.tmpl với machine = hostname
        │
        ├─► run_onchange_after_enable-services.sh
        │       └─► systemctl enable NetworkManager bluetooth power-profiles-daemon
        │
        └─► run_onchange_after_ensure-monitor-fallback.sh.tmpl
                └─► tạo monitors-<hostname>.conf nếu chưa có
```

### Repo này quản lý gì, DMS quản lý gì

| Thuộc repo (chezmoi) | Thuộc DMS (GUI / `dms ipc`) |
|---|---|
| `hyprland.conf` — keybind, window rule, layout | Bar, launcher, notification, control center |
| `monitors-<host>.conf` | Wallpaper, theme, màu Material You |
| Danh sách package | Lock screen, idle/sleep timeout |
| Autostart (`exec-once`) | Dock, widget, plugin |
| Script `bluetooth-audio.sh` | Clipboard history, screenshot |

Ranh giới này là lý do chính chọn DMS: nâng cấp shell không ghi đè tuỳ chỉnh của bạn.

---

## Key Bindings

`SUPER` là phím chính. Xem cheatsheet đầy đủ ngay trong shell bằng `SUPER+F1`.

### Shell (DMS)

| Phím | Hành động |
|------|-----------|
| `SUPER+SPACE` | Launcher (spotlight) |
| `SUPER+N` | Trung tâm thông báo |
| `SUPER+C` | Control center |
| `SUPER+I` | Cài đặt DMS |
| `SUPER+SHIFT+Q` | Power menu |
| `SUPER+SHIFT+V` | Lịch sử clipboard |
| `SUPER+W` | Chọn wallpaper |
| `SUPER+F1` | Cheatsheet phím tắt |
| `SUPER+F9` | Bật/tắt lọc ánh sáng xanh |
| `SUPER+F10` | Đổi sáng / tối |
| `SUPER+\`` | Xem tất cả workspace (overview) |
| `SUPER+Delete` | Khoá màn hình |

### Window management

| Phím | Hành động |
|------|-----------|
| `SUPER+T` | Terminal |
| `SUPER+Q` | Đóng cửa sổ |
| `SUPER+E` | File manager |
| `SUPER+V` | Toggle floating |
| `SUPER+F` | Fullscreen |
| `SUPER+h/j/k/l` | Chuyển focus |
| `SUPER+SHIFT+h/j/k/l` | Đổi chỗ cửa sổ |
| `SUPER+CTRL+h/j/k/l` | Resize |
| `SUPER+1..0` | Chuyển workspace |
| `SUPER+SHIFT+1..0` | Đẩy cửa sổ sang workspace |
| `SUPER+S` | Special workspace |
| `ALT+TAB` | hyprswitch |

### Screenshot

| Phím | Hành động |
|------|-----------|
| `Print` / `CTRL+SHIFT+4` / `CTRL+SHIFT+3` | Chụp vùng → file + clipboard |
| `CTRL+SHIFT+2` | Chụp cửa sổ → chỉ clipboard |
| `SUPER+Print` | Chụp toàn màn hình |
| `CTRL+SHIFT+S` | Chụp vùng → annotate bằng swappy |
| `CTRL+SHIFT+5` | Chụp cuộn (ảnh dài) |

### Khác

| Phím | Hành động |
|------|-----------|
| `ALT+SPACE` | Chuyển tiếng Việt / tiếng Anh (fcitx5) |
| Phím âm lượng / độ sáng | wpctl / brightnessctl |

---

## Theming

DMS sinh màu Material You từ wallpaper qua matugen, áp cho:

```
GTK3 · GTK4 · Qt (qt6ct) · kitty · alacritty · wezterm · nvim · KDE (kcolorscheme) · dgop
```

Kiểm tra app nào đang được theme:

```bash
dms matugen check
```

Đổi wallpaper / theme:

```bash
dms ipc call dash toggle wallpaper   # UI chọn wallpaper (SUPER+W)
dms ipc call wallpaper next          # wallpaper kế tiếp
dms ipc call theme toggle            # sáng / tối (SUPER+F10)
```

### Màu viền cửa sổ Hyprland

DMS chỉ sinh màu Hyprland dạng **Lua** (`~/.config/hypr/dms/colors.lua`) theo
Hyprland 0.55+, không còn ghi file `.conf`. Repo này vẫn dùng config hyprlang
(`hyprland.conf`) nên **màu viền là tĩnh**, đặt trong khối `general {}`.

Muốn viền đổi màu theo wallpaper thì phải migrate config Hyprland sang Lua
(`dms setup` sẽ sinh `hyprland.lua` + `dms/*.lua`, keybind riêng để ở
`dms/binds-user.lua`). Đó là thay đổi lớn, chưa làm trong repo này.

---

## Per-machine Configuration

### Machine detection

`.chezmoi.toml.tmpl` set `machine = {{ .chezmoi.hostname }}`. Biến này được dùng để
source đúng file monitor:

```
source = ~/.config/hypr/monitors-{{ .machine }}.conf
```

### Monitor config

Mỗi máy có một file riêng, commit vào repo:

```
dot_config/hypr/monitors-vchun.conf
dot_config/hypr/monitors-<hostname>.conf
```

Nếu file chưa tồn tại, `run_onchange_after_ensure-monitor-fallback.sh.tmpl` tạo
fallback `monitor=,preferred,auto,1`. Sửa lại theo hardware rồi commit.

---

## Repository Structure

```
.chezmoi.toml.tmpl                      # machine = hostname
.chezmoidata/packages.yaml              # danh sách package (pacman + aur)
.chezmoiignore

dot_config/hypr/
  hyprland.conf.tmpl                    # config chính (template)
  monitors-vchun.conf                   # monitor theo máy
  empty_workspaces.conf
  scripts/executable_bluetooth-audio.sh # auto switch sink sang bluetooth

run_onchange_before_01-install-yay.sh
run_onchange_before_02-install-packages.sh.tmpl
run_onchange_after_enable-services.sh
run_onchange_after_ensure-monitor-fallback.sh.tmpl
```

### File prefix convention (chezmoi)

| Prefix | Ý nghĩa |
|---|---|
| `dot_` | `.` ở đầu tên file đích |
| `executable_` | chmod +x sau khi apply |
| `.tmpl` | render bằng Go template |
| `run_once_` | chạy đúng một lần |
| `run_onchange_` | chạy lại khi nội dung script đổi |
| `before_` / `after_` | chạy trước / sau khi apply dotfiles |

---

## Daily Workflow

### Sửa một config

```bash
# 1. Edit trong source
chezmoi edit --source ~/.local/share/chezmoi-arch ~/.config/hypr/hyprland.conf

# 2. Apply
chezmoi apply --source ~/.local/share/chezmoi-arch

# 3. Reload
hyprctl reload          # Hyprland
dms restart             # DMS

# 4. Commit + push
chezmoi cd --source ~/.local/share/chezmoi-arch && git add -A && git commit && git push
```

### Sửa cài đặt shell

Cài đặt DMS **không** nằm trong repo — chỉnh bằng GUI (`SUPER+I`) hoặc:

```bash
dms ipc call settings set <key> <value>
```

### Thêm/bỏ package

Sửa `.chezmoidata/packages.yaml` rồi `chezmoi apply` — script install chạy lại
vì hash nội dung đổi.

---

## Troubleshooting

### DMS không lên sau khi login

```bash
dms doctor              # kiểm tra cài đặt + dependency
pgrep -af 'dms|qs -p'   # kiểm tra tiến trình
dms run                 # chạy tay để xem log
```

### Bar hiện nhưng thiếu tính năng

`dms doctor` liệt kê optional dependency còn thiếu (matugen, cava, wtype,
power-profiles-daemon, cups-pk-helper, ...).

### Background blur báo Unsupported

Cần Hyprland ≥ 0.55 **đang chạy**. Nếu vừa `pacman -Syu` nâng Hyprland thì phải
logout/reboot, vì session cũ vẫn chạy binary cũ.

### `chezmoi apply` fail vì sudo cần TTY

Chạy `sudo -v` trước, hoặc chạy `chezmoi apply` trong terminal có TTY.

### Hyprland config reload failed

```bash
hyprctl configerrors
```

---

## Credits

- [Hyprland](https://hypr.land)
- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
- [Quickshell](https://quickshell.org)
- [chezmoi](https://www.chezmoi.io)
- [matugen](https://github.com/InioX/matugen)
