# Brainstorm — WezTerm cursor trail (kitty parity)

**Date:** 2026-06-05
**Status:** Agreed, ready for /ck:plan

## Problem

Want kitty's `cursor_trail` smear/comet effect in WezTerm. kitty.conf:59 has `cursor_trail 1` (kitty 0.47.1). WezTerm has no equivalent.

## Scout findings

- `dot_config/kitty/kitty.conf:59` — `cursor_trail 1` (the target effect).
- `dot_config/wezterm/wezterm.lua:188-195` — stable `20240203`, only `BlinkingBar` + blink ease. Existing comment correctly notes trail unavailable.
- WezTerm installed via Homebrew (`/opt/homebrew/bin/wezterm`). No Rust toolchain present.
- Feature exists ONLY in PR #7420 (`flowchartsman/wezterm:cursor_trail`), base `main`, **OPEN/not merged**, **MERGEABLE CLEAN**, updated 2026-01-12, 10 commits.

## Decision

Build WezTerm from the unmerged fork branch (no config-only path exists). Rejected: stock approximation (placebo — only blink ease, no trail); keep-kitty (declined by user).

User decisions:
- **Install:** replace brew build (copy `WezTerm.app` → `/Applications`, overwrite).
- **Config:** version-guard `cursor_trail` in Lua so chezmoi-synced stock-brew machines don't error.

## Requirements (locked)

1. **Output:** custom `WezTerm.app` w/ cursor_trail in `/Applications` replacing brew; `wezterm.lua` updated w/ guarded `cursor_trail` block.
2. **Acceptance:** cursor jump → visible smear/trail like kitty; stock-brew machines parse config w/o error (guard active).
3. **Scope OUT:** other wezterm features; auto-rebuild CI; chezmoi-managed binary distribution.
4. **Constraints:** macOS Apple Silicon; chezmoi-managed config; replace brew; version-guard.
5. **Touchpoints:** `dot_config/wezterm/wezterm.lua`. Build done in external cloned repo.

## Build (macOS Apple Silicon)

```bash
xcode-select --install                      # if missing
git clone --branch cursor_trail --single-branch \
  https://github.com/flowchartsman/wezterm.git
cd wezterm && git submodule update --init --recursive
./get-deps
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo build --release                       # 15-30min first build
# → target/release/WezTerm.app
```

## Config block (replace wezterm.lua:195 comment)

```lua
-- cursor_trail: requires custom build from flowchartsman:cursor_trail (PR #7420)
-- version-guarded so stock/brew builds don't error on the unknown key
local ver = tonumber((wezterm.version or "0"):sub(1, 8)) or 0
if ver >= 20260101 then
  config.cursor_trail = {
    enabled            = true,
    dwell_threshold    = 80,   -- ms still before trail draws
    distance_threshold = 5,    -- cells jumped before trail
    duration           = 300,  -- ms leading edge -> cursor
    spread             = 2,    -- trailing-edge smear multiplier
    opacity            = 0.6,
  }
end
-- animation_fps = 60 already set above
```

## Risks

- Unmerged fork code — possible bugs/instability; no upstream support.
- Maintenance: every brew upgrade may overwrite custom `.app` → must rebuild/recopy. Mitigate: pin/skip brew wezterm, or document rebuild step.
- Version guard heuristic: assumes any build dated >= 20260101 has the patch. Brew nightly (unpatched, future-dated) would falsely trip it. Acceptable edge case for single-user dotfiles.
- First build needs Rust toolchain + Xcode CLT (~several GB, 15-30min).

## Open questions

- Tune trail params (duration/spread/opacity) after first run? Defaults are kitty-ish; iterate live.
- Want a `run_onchange` chezmoi script to detect & rebuild after brew clobbers it, or manual rebuild acceptable? (Leaning manual — YAGNI.)
