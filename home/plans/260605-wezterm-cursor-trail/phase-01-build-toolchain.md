---
phase: 1
title: Build Toolchain
status: completed
priority: P2
effort: 20m
dependencies: []
---

# Phase 1: Build Toolchain

## Overview
Install prerequisites to compile WezTerm from source on macOS Apple Silicon: Xcode CLT + Rust toolchain. Idempotent — skip what's present.

## Requirements
- Functional: `cargo`, `rustc`, `cc` (clang) available on PATH.
- Non-functional: don't disturb existing brew packages.

## Implementation Steps
1. Xcode CLT: `xcode-select -p` — if error, run `xcode-select --install` and wait for GUI install.
2. Rust: `rustc --version` — confirmed absent. Install via `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y`.
3. Load env: `source "$HOME/.cargo/env"`.
4. Verify: `rustc --version && cargo --version`.

## Success Criteria
- [ ] `xcode-select -p` returns a path
- [ ] `cargo --version` prints a version
- [ ] `~/.cargo/env` sourced (note for phase 2 shell)

## Risk Assessment
- Xcode CLT install is GUI/interactive + slow (~GBs) — user may need to confirm dialog. Mitigation: surface clearly, wait.
- rustup adds cargo to `~/.zshrc`? It edits a profile; confirm no clobber of chezmoi-managed `dot_zshrc`. If rustup tries to edit, prefer `-y` (uses `~/.cargo/env` sourcing) and verify `dot_zshrc` unchanged.
