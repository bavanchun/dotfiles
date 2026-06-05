---
title: WezTerm cursor_trail (kitty parity)
description: ''
status: completed
priority: P2
branch: main
tags: []
blockedBy: []
blocks: []
created: '2026-06-05T10:55:21.912Z'
createdBy: 'ck:plan'
source: skill
---

# WezTerm cursor_trail (kitty parity)

## Overview

Get kitty's `cursor_trail` smear effect in WezTerm by building from unmerged fork `flowchartsman/wezterm:cursor_trail` (PR #7420, MERGEABLE CLEAN vs main), replacing the brew build, and adding a version-guarded `cursor_trail` block to chezmoi-managed `wezterm.lua`.

Brainstorm: [brainstorm-summary.md](./brainstorm-summary.md). macOS Apple Silicon. No Rust toolchain present.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Build Toolchain](./phase-01-build-toolchain.md) | Completed |
| 2 | [Compile Fork](./phase-02-compile-fork.md) | Completed |
| 3 | [Install Replace Brew](./phase-03-install-replace-brew.md) | Completed |
| 4 | [Config Guard](./phase-04-config-guard.md) | Completed |
| 5 | [Verify](./phase-05-verify.md) | Completed |

## Dependencies

<!-- Cross-plan dependencies -->
