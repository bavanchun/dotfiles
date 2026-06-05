---
phase: 5
title: Verify
status: completed
priority: P2
effort: 10m
dependencies:
  - 4
---

# Phase 5: Verify

## Overview
Confirm the trail renders like kitty, tune params if needed, and record the rebuild/rollback procedure.

## Requirements
- Functional: moving cursor (fast jump >5 cells) draws a visible smear/trail; no config errors on startup.
- Non-functional: documented rebuild-after-brew-upgrade + rollback steps.

## Implementation Steps
1. Launch custom `WezTerm.app`. Check `wezterm` logs for config parse errors: `wezterm --config-file ~/.config/wezterm/wezterm.lua start -- true` or read `~/.local/share/wezterm/` logs.
2. Visual check: move cursor across lines / `vim` navigation / `clear` + prompt jump — observe trail. Compare side-by-side with kitty.
3. Tune if off: adjust `duration` (slower=longer smear), `spread`, `opacity`, `distance_threshold` in chezmoi source → `chezmoi apply` → WezTerm hot-reloads.
4. Document in plan: rebuild = re-run phase 2 step 5 + phase 3 steps 3-4; rollback = `brew reinstall wezterm && rm /opt/homebrew/bin/wezterm` symlink.

## Success Criteria
- [ ] Visible cursor trail on fast cursor movement
- [ ] No config errors in WezTerm logs at startup
- [ ] Params tuned to taste (or defaults accepted)
- [ ] Rebuild + rollback steps recorded

## Rebuild & Rollback (exact)

Source tree: `~/src/wezterm-cursor-trail`. Build version: `20251208-125701-fe53678a`.

**Rebuild after a future brew/cask reinstall clobbers /Applications, or to pull fork updates:**
```bash
cd ~/src/wezterm-cursor-trail
git fetch origin cursor_trail && git reset --hard origin/cursor_trail
git submodule update --init --recursive --depth 1
source "$HOME/.cargo/env" && cargo build --release
# reassemble bundle (replicates ci/deploy.sh): see one-liner in phase-02 / cook transcript
rm -rf /Applications/WezTerm.app && cp -R pkgbuild/WezTerm.app /Applications/WezTerm.app
xattr -dr com.apple.quarantine /Applications/WezTerm.app
for b in wezterm wezterm-gui wezterm-mux-server; do ln -sf "/Applications/WezTerm.app/Contents/MacOS/$b" "/opt/homebrew/bin/$b"; done
```
Bump the `wezterm.lua` guard threshold only if a newer build's datestamp drops below it (unlikely — dates increase).

**Rollback to stock brew cask:**
```bash
rm -rf /Applications/WezTerm.app
brew install --cask wezterm            # restores 20240203 + symlinks
# config guard auto-disables cursor_trail on the stock build (ver < 20250101) — no config edit needed
```

## Risk Assessment
- Effect may differ from kitty's feel — fork is an early impl. Mitigation: live-tune; if unsatisfactory, decision point = accept / keep tuning / revert to brew + kitty.
- No automated regression — manual visual check only (acceptable for cosmetic dotfile change).
