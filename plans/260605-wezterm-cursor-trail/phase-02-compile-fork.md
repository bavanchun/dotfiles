---
phase: 2
title: Compile Fork
status: completed
priority: P2
effort: 30m
dependencies:
  - 1
---

# Phase 2: Compile Fork

## Overview
Clone the `cursor_trail` fork branch and build a release `WezTerm.app` bundle.

## Requirements
- Functional: produce `target/release/WezTerm.app` (+ `wezterm`, `wezterm-gui`, `wezterm-mux-server` binaries).
- Non-functional: build in a scratch dir outside chezmoi source (not dotfile-managed).

## Architecture
Build dir: `~/src/wezterm-cursor-trail` (scratch, gitignored from chezmoi). PR base is `main`, MERGEABLE CLEAN → builds against current upstream.

## Related Code Files
- Create: `~/src/wezterm-cursor-trail/` (cloned repo, NOT in chezmoi)

## Implementation Steps
1. `mkdir -p ~/src && cd ~/src`
2. `git clone --branch cursor_trail --single-branch https://github.com/flowchartsman/wezterm.git wezterm-cursor-trail`
3. `cd wezterm-cursor-trail && git submodule update --init --recursive`
4. `./get-deps` — installs system deps via brew (harfbuzz, etc.).
5. `source "$HOME/.cargo/env" && cargo build --release` (15-30min first build).
6. macOS app bundle: `cd ci && ./build-docs.sh` not needed; the `.app` is assembled by `cargo build`. Confirm bundle at `target/release/WezTerm.app` — if absent, run `make build` or check `ci/macos-bundle.sh` per repo. Locate actual bundle path before phase 3.

## Success Criteria
- [ ] `cargo build --release` exits 0
- [ ] `WezTerm.app` bundle located (record absolute path)
- [ ] `target/release/wezterm --version` prints a 2026-dated build string (for the phase-4 version guard)

## Risk Assessment
- Long compile + multi-GB deps. Mitigation: run foreground, report progress.
- Unmerged fork may fail to build despite "MERGEABLE" (merge-clean != compiles). Mitigation: if build breaks, capture error; fallback options = rebase onto older main commit, or report blocker to user.
- `get-deps` may install brew formulae that conflict. Mitigation: review its output; it's the repo's official dep script.
