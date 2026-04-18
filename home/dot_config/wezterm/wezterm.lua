local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Fix GPU rendering on Intel UHD (Wayland/Hyprland)
config.front_end = "OpenGL"

-- ── Font ──────────────────────────────────────────────────────
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13.0

-- ── Catppuccin Mocha theme ────────────────────────────────────
config.colors = {
    foreground = "#cdd6f4",
    background = "#1e1e2e",
    cursor_bg  = "#f5e0dc",
    cursor_fg  = "#1e1e2e",
    cursor_border = "#f5e0dc",
    selection_fg = "#1e1e2e",
    selection_bg = "#89b4fa",

    ansi = {
        "#45475a", -- black
        "#f38ba8", -- red
        "#a6e3a1", -- green
        "#f9e2af", -- yellow
        "#89b4fa", -- blue
        "#cba6f7", -- magenta
        "#94e2d5", -- cyan
        "#bac2de", -- white
    },
    brights = {
        "#585b70", -- bright black
        "#f38ba8", -- bright red
        "#a6e3a1", -- bright green
        "#f9e2af", -- bright yellow
        "#89b4fa", -- bright blue
        "#cba6f7", -- bright magenta
        "#94e2d5", -- bright cyan
        "#a6adc8", -- bright white
    },

    tab_bar = {
        background = "#181825",
        active_tab = {
            bg_color  = "#89b4fa",
            fg_color  = "#1e1e2e",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#313244",
            fg_color = "#a6adc8",
        },
        inactive_tab_hover = {
            bg_color = "#45475a",
            fg_color = "#cdd6f4",
        },
        new_tab = {
            bg_color = "#181825",
            fg_color = "#a6adc8",
        },
        new_tab_hover = {
            bg_color = "#313244",
            fg_color = "#cdd6f4",
        },
    },
}

-- ── Window ────────────────────────────────────────────────────
config.window_background_opacity = 0.92
config.window_padding = { left = 10, right = 10, top = 8, bottom = 8 }
config.window_decorations = "RESIZE"
config.initial_cols = 120
config.initial_rows = 36

-- ── Tab bar ───────────────────────────────────────────────────
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 30

-- ── Cursor ────────────────────────────────────────────────────
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- ── Scrollback ────────────────────────────────────────────────
config.scrollback_lines = 10000

-- ── Keybindings ───────────────────────────────────────────────
config.keys = {
    -- Paste bằng Ctrl+V
    { key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },

    -- Tab mới
    { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

    -- Đóng tab
    { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },

    -- Chuyển tab
    { key = "Tab",       mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },
    { key = "Tab",       mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

    -- Split pane ngang / dọc
    { key = "\\", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-",  mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Di chuyển giữa panes
    { key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
}

return config
