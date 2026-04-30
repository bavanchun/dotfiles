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

-- ── Colors (Catppuccin Mocha) ─────────────────────────────────
config.colors = {
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

    indexed = {
        [232] = "#080808", [233] = "#121212", [234] = "#1c1c1c",
        [235] = "#262626", [236] = "#303030", [237] = "#3a3a3a",
        [238] = "#444444", [239] = "#4e4e4e", [244] = "#808080",
        [245] = "#8a8a8a", [248] = "#a8a8a8", [249] = "#b2b2b2",
        [250] = "#bcbcbc", [251] = "#c6c6c6", [252] = "#d0d0d0",
        [253] = "#dadada", [254] = "#e4e4e4", [255] = "#eeeeee",
    },

    tab_bar = {
        background    = "#0f0f0f",
        new_tab       = { bg_color = "#0f0f0f", fg_color = "#3a3a3a" },
        new_tab_hover = { bg_color = "#222222", fg_color = "#808080" },
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
        source  = { Color = "#0f0f0f" },
        width   = "100%",
        height  = "100%",
        opacity = 0.92,
    },
    {
        source = {
            Gradient = {
                orientation   = { Linear = { angle = 90.0 } },
                colors        = { "#000000dd", "#00000000", "#000000dd" },
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
    active_titlebar_bg   = "#0f0f0f",
    inactive_titlebar_bg = "#0f0f0f",
}

local TAB_ACT  = { bg = "#242424", fg = "#d0d0d0" }
local TAB_NORM = { bg = "#141414", fg = "#484848" }
local HINT_FG  = "#333333"

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

-- cursor_trail requires custom WezTerm build (PR #7420), not available in stable

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
