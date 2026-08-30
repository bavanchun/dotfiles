---
phase: 3
title: Install Replace Brew
status: completed
priority: P2
effort: 10m
dependencies:
  - 2
---

# Phase 3: Install Replace Brew

## Overview
Replace the Homebrew WezTerm with the custom build: put `WezTerm.app` in `/Applications`, point the CLI at the custom binary, prevent brew from clobbering it.

## Requirements
- Functional: `wezterm --version` (PATH) resolves to the custom 2026 build; GUI launches the custom `.app`.
- Non-functional: reversible — keep a note to restore brew (`brew reinstall wezterm`).

## Architecture
Current install: `brew` formula at `/opt/homebrew/bin/wezterm`. Strategy: copy `.app` to `/Applications`, symlink CLI from the app bundle's `MacOS/` dir into `/opt/homebrew/bin` (or `~/.local/bin`), and `brew pin`/unlink to stop upgrades overwriting it.

## Implementation Steps
1. Quit running WezTerm.
2. Remove brew version cleanly: `brew uninstall wezterm` (formula) — OR keep installed but `brew pin wezterm` if side-effects. Decision: uninstall to avoid PATH ambiguity (user chose "replace brew").
3. `cp -R ~/src/wezterm-cursor-trail/target/release/WezTerm.app /Applications/`
4. CLI symlink: `ln -sf /Applications/WezTerm.app/Contents/MacOS/wezterm /opt/homebrew/bin/wezterm` (and `wezterm-gui`, `wezterm-mux-server` if used).
5. macOS Gatekeeper: unsigned local build → `xattr -dr com.apple.quarantine /Applications/WezTerm.app` (only needed if launch blocked).
6. Verify: `hash -r; which wezterm; wezterm --version` → 2026 build string.

## Success Criteria
- [ ] `which wezterm` → `/opt/homebrew/bin/wezterm` symlink → custom app
- [ ] `wezterm --version` shows 2026 date (guard threshold)
- [ ] GUI `WezTerm.app` opens from /Applications without Gatekeeper block

## Risk Assessment
- Future `brew install`/`upgrade` could recreate `/opt/homebrew/bin/wezterm`. Mitigation: documented in plan; manual rebuild on update (YAGNI on automation per brainstorm).
- Unsigned build → Gatekeeper warning. Mitigation: quarantine xattr strip (step 5).
- Reversibility: `brew reinstall wezterm` restores stock. Record in verify phase.
