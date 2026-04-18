local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Fix GPU rendering on Intel UHD (Wayland/Hyprland)
config.front_end = "OpenGL"

-- ── Font ──────────────────────────────────────────────────────
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0

-- ── Colors (Catppuccin Mocha, matched to kitty) ───────────────
config.colors = {
    foreground    = "#cdd6f4",
    background    = "#0f0f0f",   -- kitty custom (darker than mocha default)
    cursor_bg     = "#f5e0dc",
    cursor_fg     = "#1e1e2e",
    cursor_border = "#f5e0dc",
    selection_fg  = "#1e1e2e",
    selection_bg  = "#89b4fa",

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

    -- Extended 256-color overrides: fix starship prompt colors in kitty
    indexed = {
        [232] = "#080808", [233] = "#121212", [234] = "#1c1c1c",
        [235] = "#262626", [236] = "#303030", [237] = "#3a3a3a",
        [238] = "#444444", [239] = "#4e4e4e", [244] = "#808080",
        [245] = "#8a8a8a", [248] = "#a8a8a8", [249] = "#b2b2b2",
        [250] = "#bcbcbc", [251] = "#c6c6c6", [252] = "#d0d0d0",
        [253] = "#dadada", [254] = "#e4e4e4", [255] = "#eeeeee",
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
config.window_padding = { left = 22, right = 22, top = 22, bottom = 22 }
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

-- ── Shell ─────────────────────────────────────────────────────
config.default_prog = { "zsh" }

-- ── Scrollback ────────────────────────────────────────────────
config.scrollback_lines = 10000

-- ── Copy on select (matches kitty copy_on_select yes) ─────────
config.mouse_bindings = {
    {
        event  = { Up = { streak = 1, button = "Left" } },
        mods   = "NONE",
        action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
    },
}

-- ── Keybindings ───────────────────────────────────────────────
config.keys = {
    -- Ctrl+C: copy if selection exists, otherwise send interrupt (kitty copy_or_interrupt)
    { key = "c", mods = "CTRL", action = wezterm.action_callback(function(window, pane)
        if window:get_selection_text_for_pane(pane) ~= "" then
            window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
        else
            window:perform_action(wezterm.action.SendKey { key = "c", mods = "CTRL" }, pane)
        end
    end) },

    -- Paste
    { key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },

    -- Search (Ctrl+F)
    { key = "f", mods = "CTRL", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },

    -- Font size
    { key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },

    -- Scroll
    { key = "PageUp",   mods = "NONE", action = wezterm.action.ScrollByPage(-1) },
    { key = "PageDown", mods = "NONE", action = wezterm.action.ScrollByPage(1) },

    -- Tab mới / đóng tab
    { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },

    -- Chuyển tab
    { key = "Tab", mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

    -- Split pane
    { key = "\\", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-",  mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Di chuyển giữa panes
    { key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
}

return config
