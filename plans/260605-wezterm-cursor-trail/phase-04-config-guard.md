---
phase: 4
title: Config Guard
status: completed
priority: P2
effort: 10m
dependencies:
  - 3
---

# Phase 4: Config Guard

## Overview
Add the version-guarded `cursor_trail` block to chezmoi-managed `wezterm.lua`, replacing the stale "not available in stable" comment. Guard prevents config errors on machines still running stock/brew WezTerm.

## Requirements
- Functional: custom build applies `cursor_trail`; stock build skips it (no unknown-key error).
- Non-functional: chezmoi source edited (not the applied `~/.config` copy), then `chezmoi apply`.

## Related Code Files
- Modify: `~/.local/share/chezmoi/dot_config/wezterm/wezterm.lua` (line ~195, the `cursor_trail requires custom WezTerm build` comment)

## Architecture
`wezterm.version` returns e.g. `"20240203-110809-..."` (stock) vs `"20260112-..."` (custom). Guard parses leading 8 digits; enable only if `>= 20260101`.

## Implementation Steps
1. Edit chezmoi source `dot_config/wezterm/wezterm.lua`. Replace the comment line with:
   ```lua
   -- cursor_trail: custom build from flowchartsman:cursor_trail (PR #7420)
   -- version-guarded so stock/brew builds don't error on the unknown key
   local ver = tonumber((wezterm.version or "0"):sub(1, 8)) or 0
   if ver >= 20260101 then
     config.cursor_trail = {
       enabled            = true,
       dwell_threshold    = 80,
       distance_threshold = 5,
       duration           = 300,
       spread             = 2,
       opacity            = 0.6,
     }
   end
   ```
2. Confirm `wezterm` is in scope at that point (top-level `local wezterm = require("wezterm")` exists — verify).
3. `chezmoi diff` then `chezmoi apply` to sync `~/.config/wezterm/wezterm.lua`.

## Success Criteria
- [ ] chezmoi source updated; stale comment removed
- [ ] `chezmoi diff` shows only the intended change
- [ ] `chezmoi apply` clean; `~/.config/wezterm/wezterm.lua` contains guarded block

## Risk Assessment
- Guard heuristic: a future unpatched brew *nightly* dated >=20260101 would falsely enable → config error. Acceptable edge case for single-user dotfiles (documented).
- `wezterm.version` format change could break parse. Mitigation: `tonumber(... ) or 0` fails safe to disabled.
