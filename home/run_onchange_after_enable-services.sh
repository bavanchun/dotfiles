#!/usr/bin/env bash
# services version: 2
set -euo pipefail

# ── System services ───────────────────────────────────────────────────────────
system_services=(
  NetworkManager.service
  bluetooth.service
  power-profiles-daemon.service
  sddm.service
)

for svc in "${system_services[@]}"; do
  if systemctl list-unit-files "$svc" &>/dev/null; then
    sudo systemctl enable --now "$svc" || echo "Warning: failed to enable $svc"
  fi
done

# ── Snapshot / rollback (snapper + grub-btrfs) ────────────────────────────────
# Việc dựng subvolume @snapshots và tạo config snapper nằm ở README (mục Rollback)
# vì nó đụng tới fstab; ở đây chỉ bật timer khi config đã tồn tại.
if [ -d /etc/snapper/configs ] && [ -e /etc/snapper/configs/root ]; then
  for svc in snapper-timeline.timer snapper-cleanup.timer grub-btrfsd.service; do
    if systemctl list-unit-files "$svc" &>/dev/null; then
      sudo systemctl enable --now "$svc" || echo "Warning: failed to enable $svc"
    fi
  done
fi

# ── User services ─────────────────────────────────────────────────────────────
# DMS chạy bằng systemd chứ không phải exec-once trong hyprland.conf: unit có
# Restart=on-failure nên bar tự dựng lại khi quickshell crash.
if systemctl --user list-unit-files dms.service &>/dev/null; then
  systemctl --user enable dms.service || echo "Warning: failed to enable dms.service"
fi

# dunst cũng giữ bus org.freedesktop.Notifications và làm systemd từ chối
# dms.service ("Two services allocated for the same bus name"). DMS đã lo
# notification nên mask hẳn dunst.
if systemctl --user list-unit-files dunst.service &>/dev/null; then
  systemctl --user mask dunst.service || echo "Warning: failed to mask dunst.service"
fi

echo "Services enabled. (zsh default shell is handled by dotconfig-term repo)"
