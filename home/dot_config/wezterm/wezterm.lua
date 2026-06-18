local wezterm = require("wezterm")
local config  = wezterm.config_builder()
local is_linux  = wezterm.target_triple:find("linux") ~= nil
local is_macos  = wezterm.target_triple:find("darwin") ~= nil
local copy_destination = is_linux and "ClipboardAndPrimarySelection" or "Clipboard"

if is_linux then
    -- Fix GPU rendering on Intel UHD (Wayland/Hyprland)
    config.front_end = "OpenGL"
end

-- ── Font ──────────────────────────────────────────────────────
config.font      = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0

-- ── Theme palettes (Catppuccin Mocha / Latte) ─────────────────
local themes = {
    dark = { -- Catppuccin Mocha
        bg            = "#0f0f0f",
        foreground    = "#cdd6f4",
        cursor_bg     = "#f5e0dc",
        cursor_fg     = "#1e1e2e",
        cursor_border = "#f5e0dc",
        selection_fg  = "#1e1e2e",
        selection_bg  = "#89b4fa",
        ansi = {
            "#45475a", "#f38ba8", "#a6e3a1", "#f9e2af",
            "#89b4fa", "#cba6f7", "#94e2d5", "#bac2de",
        },
        brights = {
            "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af",
            "#89b4fa", "#cba6f7", "#94e2d5", "#a6adc8",
        },
        bg_opacity    = 0.92,
        gradient      = { "#000000dd", "#00000000", "#000000dd" },
        tab_bar_bg    = "#0f0f0f",
        new_tab_fg    = "#3a3a3a",
        new_tab_hover = { bg = "#222222", fg = "#808080" },
        tab_act       = { bg = "#242424", fg = "#d0d0d0" },
        tab_norm      = { bg = "#141414", fg = "#484848" },
        hint_fg       = "#333333",
        -- 256-color grayscale ramp: dark->light (for dark backgrounds)
        indexed = {
            [232] = "#080808", [233] = "#121212", [234] = "#1c1c1c",
            [235] = "#262626", [236] = "#303030", [237] = "#3a3a3a",
            [238] = "#444444", [239] = "#4e4e4e", [244] = "#808080",
            [245] = "#8a8a8a", [248] = "#a8a8a8", [249] = "#b2b2b2",
            [250] = "#bcbcbc", [251] = "#c6c6c6", [252] = "#d0d0d0",
            [253] = "#dadada", [254] = "#e4e4e4", [255] = "#eeeeee",
        },
    },
    light = { -- Catppuccin Latte (crisp, high-contrast light)
        bg            = "#dfe2e8",
        foreground    = "#1c1e2a",
        cursor_bg     = "#dc8a78",
        cursor_fg     = "#eff1f5",
        cursor_border = "#dc8a78",
        selection_fg  = "#4c4f69",
        selection_bg  = "#bcc0cc",
        ansi = {
            "#5c5f77", "#d20f39", "#40a02b", "#df8e1d",
            "#1e66f5", "#8839ef", "#179299", "#acb0be",
        },
        brights = {
            "#6c6f85", "#d20f39", "#40a02b", "#df8e1d",
            "#1e66f5", "#8839ef", "#179299", "#bcc0cc",
        },
        bg_opacity    = 1.0,
        gradient      = { "#00000010", "#00000000", "#00000010" },
        tab_bar_bg    = "#e6e9ef",
        new_tab_fg    = "#8c8fa1",
        new_tab_hover = { bg = "#ccd0da", fg = "#4c4f69" },
        tab_act       = { bg = "#ccd0da", fg = "#4c4f69" },
        tab_norm      = { bg = "#e6e9ef", fg = "#8c8fa1" },
        hint_fg       = "#9ca0b0",
        -- 256-color grayscale ramp inverted: light->dark so dim text stays
        -- visible on the white background (apps emit high indices for "dim").
        indexed = {
            [232] = "#eeeeee", [233] = "#e4e4e4", [234] = "#dadada",
            [235] = "#d0d0d0", [236] = "#c6c6c6", [237] = "#bcbcbc",
            [238] = "#b2b2b2", [239] = "#a8a8a8", [244] = "#8a8a8a",
            [245] = "#808080", [248] = "#4e4e4e", [249] = "#444444",
            [250] = "#3a3a3a", [251] = "#303030", [252] = "#262626",
            [253] = "#1c1c1c", [254] = "#121212", [255] = "#080808",
        },
    },
}

-- Theme mode: "auto" follows macOS appearance; "light" / "dark" force one.
local THEME_MODE = "auto"

-- macOS appearance -> theme (WezTerm reloads config when it changes)
local function current_appearance()
    if THEME_MODE == "light" or THEME_MODE == "dark" then
        return THEME_MODE
    end
    if wezterm.gui then
        return wezterm.gui.get_appearance():find("Dark") and "dark" or "light"
    end
    return "dark"
end

local theme = themes[current_appearance()]

-- ── Colors ────────────────────────────────────────────────────
config.colors = {
    foreground    = theme.foreground,
    cursor_bg     = theme.cursor_bg,
    cursor_fg     = theme.cursor_fg,
    cursor_border = theme.cursor_border,
    selection_fg  = theme.selection_fg,
    selection_bg  = theme.selection_bg,
    ansi          = theme.ansi,
    brights       = theme.brights,

    indexed = theme.indexed,

    tab_bar = {
        background    = theme.tab_bar_bg,
        new_tab       = { bg_color = theme.tab_bar_bg, fg_color = theme.new_tab_fg },
        new_tab_hover = { bg_color = theme.new_tab_hover.bg, fg_color = theme.new_tab_hover.fg },
    },
}

-- ── Window ────────────────────────────────────────────────────
config.window_padding    = { left = 22, right = 22, top = 22, bottom = 22 }
config.window_decorations = is_macos and "RESIZE|TITLE" or "NONE"
config.initial_cols      = 120
config.initial_rows      = 36

-- ── Background + vignette effect ──────────────────────────────
-- Two-layer: base dark bg (semi-transparent) + top/bottom darkness
config.background = {
    {
        source  = { Color = theme.bg },
        width   = "100%",
        height  = "100%",
        opacity = theme.bg_opacity,
    },
    {
        source = {
            Gradient = {
                orientation   = { Linear = { angle = 90.0 } },
                colors        = theme.gradient,
                interpolation = "Linear",
                blend         = "Rgb",
            },
        },
        width   = "100%",
        height  = "100%",
        opacity = 0.30,
    },
}

-- ── Tab bar ───────────────────────────────────────────────────
config.enable_tab_bar               = true
config.use_fancy_tab_bar            = false
config.tab_bar_at_bottom            = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width                = 60

-- title bar bg matches terminal background
config.window_frame = {
    font                 = wezterm.font("JetBrainsMono Nerd Font"),
    font_size            = 10.0,
    active_titlebar_bg   = theme.tab_bar_bg,
    inactive_titlebar_bg = theme.tab_bar_bg,
}

local TAB_ACT  = theme.tab_act
local TAB_NORM = theme.tab_norm
local HINT_FG  = theme.hint_fg

local function tab_title(tab)
    if tab.tab_title and #tab.tab_title > 0 then return tab.tab_title end
    if tab.active_pane.title and #tab.active_pane.title > 0 then return tab.active_pane.title end
    return "~"
end

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
    local title = tab_title(tab)
    local hint  = "⌘" .. (tab.tab_index + 1)
    local t     = tab.is_active and TAB_ACT or TAB_NORM

    local gap = max_width - 2 - #title - #hint
    if gap < 1 then
        gap   = 1
        title = wezterm.truncate_right(title, max_width - 2 - #hint - 1)
    end

    return {
        { Background = { Color = t.bg } },
        { Foreground = { Color = t.fg } },
        { Text = " " .. title .. string.rep(" ", gap) },
        { Foreground = { Color = HINT_FG } },
        { Text = hint .. " " },
    }
end)

-- ── Cursor ────────────────────────────────────────────────────
config.default_cursor_style    = "BlinkingBar"
config.cursor_blink_rate       = 500
config.animation_fps           = 60
config.cursor_blink_ease_in    = "EaseIn"
config.cursor_blink_ease_out   = "EaseOut"

-- cursor_trail: custom build from flowchartsman:cursor_trail (PR #7420), kitty-style smear.
-- version-guarded so stock/brew builds (e.g. 20240203) don't error on the unknown key.
-- threshold sits above stock and below the custom build's datestamp (20251208).
local ver = tonumber((wezterm.version or "0"):sub(1, 8)) or 0
if ver >= 20250101 then
  config.cursor_trail = {
    enabled            = true,
    dwell_threshold    = 80,   -- ms cursor still before trail draws
    distance_threshold = 5,    -- cells jumped before trail
    duration           = 300,  -- ms leading edge -> cursor
    spread             = 2,    -- trailing-edge smear multiplier
    opacity            = 0.6,
  }
end

-- ── Shell ─────────────────────────────────────────────────────
config.default_prog = { "zsh" }

-- ── Scrollback ────────────────────────────────────────────────
config.scrollback_lines = 10000

-- ── Copy on select ────────────────────────────────────────────
config.mouse_bindings = {
    {
        event  = { Up = { streak = 1, button = "Left" } },
        mods   = "NONE",
        action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor(copy_destination),
    },
}

-- ── Smart pane navigation (Neovim-aware) ─────────────────────
-- Ctrl+H/J/K/L: pass to Neovim when nvim is foreground, else move WezTerm pane
local nav_dirs = { h = "Left", j = "Down", k = "Up", l = "Right" }

local function is_nvim(pane)
    local proc = string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
    return proc == "nvim" or proc == "vim"
end

local function pane_nav(key)
    return {
        key = key, mods = "CTRL",
        action = wezterm.action_callback(function(win, pane)
            if is_nvim(pane) then
                win:perform_action(wezterm.action.SendKey { key = key, mods = "CTRL" }, pane)
            else
                win:perform_action(wezterm.action.ActivatePaneDirection(nav_dirs[key]), pane)
            end
        end),
    }
end

-- ── Keybindings ───────────────────────────────────────────────
config.keys = {
    { key = "c", mods = "CTRL", action = wezterm.action_callback(function(window, pane)
        if window:get_selection_text_for_pane(pane) ~= "" then
            window:perform_action(wezterm.action.CopyTo(copy_destination), pane)
        else
            window:perform_action(wezterm.action.SendKey { key = "c", mods = "CTRL" }, pane)
        end
    end) },
    { key = "v", mods = "CTRL",       action = wezterm.action.PasteFrom("Clipboard") },
    { key = "f", mods = "CTRL",       action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
    { key = "+", mods = "CTRL",       action = wezterm.action.IncreaseFontSize },
    { key = "=", mods = "CTRL",       action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL",       action = wezterm.action.DecreaseFontSize },
    { key = "0", mods = "CTRL",       action = wezterm.action.ResetFontSize },
    { key = "PageUp",   mods = "NONE", action = wezterm.action.ScrollByPage(-1) },
    { key = "PageDown", mods = "NONE", action = wezterm.action.ScrollByPage(1) },
    { key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
    { key = "Tab", mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "|", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    pane_nav("h"), pane_nav("j"), pane_nav("k"), pane_nav("l"),
}

return config
