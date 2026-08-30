# dotfiles

> Dotfiles hợp nhất, quản lý bằng [chezmoi](https://www.chezmoi.io/), **chia theo tầng
> chứ không theo distro**. Một repo, một lệnh, dựng lại được cả máy Arch desktop lẫn
> server headless lẫn macOS.

Repo này thay cho `dotconfig-term` + `dotconfig-arch` (đã archive).

## Phân tầng

Trục biến thiên của một người hay đổi máy/đổi distro không phải là *distro*, mà là
*tầng*. Chia theo distro thì mỗi lần nhảy phải nhân bản lại tầng dưới; chia theo tầng
thì không.

| Tầng | Nội dung | Áp dụng ở đâu |
|---|---|---|
| **cli** | zsh + p10k, nvim, tmux, yazi, git, wezterm/kitty/alacritty/ghostty | mọi máy, mọi OS |
| **system** | boot, kernel, mạng, snapshot/rollback | mọi máy Arch |
| **desktop** | Hyprland, DankMaterialShell, xkb remap, fcitx5, font, GPU | chỉ `role=desktop` |

Tầng được chọn bằng **một biến duy nhất** là `role`, hỏi một lần lúc `chezmoi init`
(mặc định tự đoán: có Hyprland/Wayland thì `desktop`, không thì `cli`).

- `home/.chezmoiignore` là **template** — máy `role=cli` bị ignore hẳn `.config/hypr`,
  `.config/xkb`, `.config/fcitx5`, `.config/DankMaterialShell`.
- `home/.chezmoidata/packages.yaml` chia package theo đúng 3 tầng đó.
- Mọi `run_onchange_` script đều có guard distro + role, nên chạy trên Ubuntu hay
  macOS không còn làm hỏng lượt apply.

```
┌─────────────────────────────────────────────────────┐
│  Compositor  : Hyprland                             │
│  Shell       : DankMaterialShell (Quickshell + Go)  │
│    ├ bar, launcher, notifications, control center   │
│    ├ lock screen, idle/sleep, polkit agent          │
│    ├ clipboard, screenshot, wallpaper, theming      │
│    └ điều khiển qua `dms ipc call ...`              │
│  Terminal    : WezTerm · Kitty · Alacritty · Ghostty│
│  Input       : fcitx5 + Bamboo (Alt+Space)          │
│  Theming     : Material You từ wallpaper (matugen)  │
│  Rollback    : snapper + snap-pac + grub-btrfs      │
└─────────────────────────────────────────────────────┘
```

---

## Table of Contents

- [Phân tầng](#phân-tầng)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Key Bindings](#key-bindings)
- [Theming](#theming)
- [Per-machine Configuration](#per-machine-configuration)
- [Repository Structure](#repository-structure)
- [Snapshot & Rollback](#snapshot--rollback)
- [Daily Workflow](#daily-workflow)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

Chỉ cần cài tay đúng 2 thứ: `chezmoi` và `git`.

```bash
# 1. Hostname có nghĩa (per-machine config bám vào hostname)
sudo hostnamectl set-hostname vchun

# 2. Cài chezmoi + git
sudo pacman -S --needed chezmoi git        # Arch
# sudo apt install -y git && sh -c "$(curl -fsLS get.chezmoi.io)"   # Ubuntu
# brew install chezmoi git                                          # macOS

# 3. Một lệnh duy nhất cho MỌI máy — chezmoi sẽ hỏi role + terminal
chezmoi init --apply bavanchun/dotfiles
```

`role` chỉ hỏi lần đầu (`promptChoiceOnce`); các lần `chezmoi init` sau dùng lại
giá trị đã lưu trong `~/.config/chezmoi/chezmoi.toml`.

### Hậu install (chỉ máy desktop)

```bash
# Snapshot/rollback — xem mục "Snapshot & Rollback" bên dưới, có sửa /etc/fstab
# nên cố ý KHÔNG tự động hoá trong run_onchange_.

# Logout và chọn Hyprland trong display manager
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

`.chezmoiroot` trỏ vào `home/`, nên **chỉ những gì trong `home/` mới là source của
chezmoi**. README và `plans/` nằm ngoài, chezmoi không nhìn thấy — không cần ignore.

```
.chezmoiroot                            # = "home"
README.md                               # ngoài source
plans/                                  # ngoài source

home/
  .chezmoi.toml.tmpl                    # MỘT file config duy nhất cho mọi máy
  .chezmoidata/packages.yaml            # package chia theo tầng cli/system/desktop
  .chezmoiignore                        # TEMPLATE — gate tầng desktop theo .role

  dot_zshrc  dot_p10k.zsh  dot_gitconfig.tmpl  dot_markdownlint-cli2.yaml
  yazi/                                 # nguồn cho symlink ~/.config/yazi

  dot_config/                           # ── tầng cli ──
    nvim/ tmux/ wezterm/ kitty/ alacritty/ ghostty/ symlink_yazi.tmpl
                                        # ── tầng desktop ──
    hypr/       hyprland.conf.tmpl, monitors-<machine>.conf, scripts/
    xkb/        remap phím cấp user (Caps->Ctrl, Alt phải->Esc)
    fcitx5/     gõ tiếng Việt (config + profile)
    DankMaterialShell/settings.json

  run_onchange_before_01-install-yay.sh.tmpl      # guard: Arch + desktop
  run_onchange_before_02-install-packages.sh.tmpl # cli/system/desktop theo role+OS
  run_onchange_after_chsh-zsh.sh
  run_onchange_after_enable-services.sh.tmpl      # guard: Arch + desktop
  run_onchange_after_ensure-monitor-fallback.sh.tmpl  # guard: desktop
  run_after_apply-theme.sh
```

### File prefix convention (chezmoi)

| Prefix | Ý nghĩa |
|---|---|
| `dot_` | `.` ở đầu tên file đích |
| `executable_` | chmod +x sau khi apply |
| `symlink_` | tạo symlink, nội dung file là đích |
| `.tmpl` | render bằng Go template |
| `run_once_` | chạy đúng một lần |
| `run_onchange_` | chạy lại khi nội dung script đổi |
| `before_` / `after_` | chạy trước / sau khi apply dotfiles |

### Một cái bẫy đã dính

`.chezmoiignore` khớp theo đường dẫn **đích** (`.config/...`), **không** phải đường
dẫn nguồn (`dot_config/...`). Repo `dotconfig-arch` cũ ghi kiểu nguồn nên toàn bộ
dòng ignore ở đó vô tác dụng suốt thời gian dài. Kiểm chứng bằng:

```bash
chezmoi managed --source <src> --destination <dest>
```

---

## Snapshot & Rollback

Repo này là **công thức dựng lại**, không phải rollback. Cài lại máy thì
`chezmoi apply` ra một máy giống — nhưng nếu một bản update làm hỏng hệ thống
thì repo vô dụng, vì file config có sai đâu, cái sai là phiên bản package.

Phần rollback thật do **snapper + snap-pac + grub-btrfs** lo, chạy trên btrfs.

### Điều kiện

Root phải là btrfs theo layout subvolume `@` (layout mặc định của archinstall):

```bash
findmnt -no FSTYPE,SOURCE /     # mong đợi: btrfs /dev/sdX2[/@]
```

### Dựng lần đầu (một lần cho mỗi máy)

Đụng tới `/etc/fstab` nên không tự động hoá trong `run_onchange_`; làm tay:

```bash
sudo pacman -S --needed snapper snap-pac grub-btrfs inotify-tools

# snapper create-config tạo /.snapshots dạng subvolume lồng trong @.
# Ta thay bằng subvolume @snapshots riêng ở top-level cho khớp layout @/@home/@log/@pkg,
# để sau này thay nguyên @ mà không kéo theo đống snapshot.
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir -p /.snapshots

DEV=$(findmnt -no SOURCE / | sed 's/\[.*//')
UUID=$(blkid -s UUID -o value "$DEV")
sudo mount -o subvolid=5 "$DEV" /mnt
sudo btrfs subvolume create /mnt/@snapshots
sudo umount /mnt
echo "UUID=$UUID /.snapshots btrfs rw,relatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=/@snapshots 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo chmod 750 /.snapshots

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer grub-btrfsd.service
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Sau bước này `run_onchange_after_enable-services.sh` sẽ tự giữ các timer bật ở
những lần apply sau (nó kiểm tra `/etc/snapper/configs/root` có tồn tại không).

### Dùng hàng ngày

| Việc | Lệnh |
|---|---|
| Xem snapshot | `sudo snapper -c root list` |
| Snapshot thủ công trước khi vọc | `sudo snapper -c root create -d "truoc khi doi X"` |
| Xem một file đổi gì giữa 2 snapshot | `sudo snapper -c root diff 42..0 /etc/foo.conf` |
| Khôi phục vài file (không rollback cả máy) | `sudo snapper -c root undochange 42..0 /etc/foo.conf` |
| Rollback cả hệ thống | Reboot → menu GRUB → *Arch Linux snapshots* → chọn snapshot |

`snap-pac` tự tạo cặp snapshot pre/post quanh **mỗi** transaction pacman, nên
"update xong hỏng" luôn có điểm quay về ngay trước transaction đó.

### Giới hạn cần biết

- **`/boot` là ESP (vfat), nằm ngoài btrfs** → kernel và initramfs KHÔNG nằm
  trong snapshot. Boot vào snapshot cũ vẫn dùng kernel hiện tại, nên nếu
  snapshot cũ hơn một lần nâng kernel thì `/usr/lib/modules/<kernel hiện tại>`
  không tồn tại trong đó → thiếu module. Rollback ăn chắc nhất là snapshot
  `pre` của chính transaction vừa làm hỏng máy (cùng đời kernel).
- **Snapshot không phải backup.** Nó nằm cùng ổ `/dev/sda2`. Ổ chết là mất sạch.
  Muốn an toàn thật thì cần backup ra ngoài (`btrfs send/receive`, restic...).
- Chỉ subvolume `@` (root) được snapshot. `@home` chưa có config snapper —
  thêm bằng `sudo snapper -c home create-config /home` nếu cần.

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
