local wezterm = require("wezterm")
local config  = wezterm.config_builder()

-- Fix GPU rendering on Intel UHD (Wayland/Hyprland)
config.front_end = "OpenGL"

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
        background = "#181825",  -- tab bar bg; tab rendering handled by format-tab-title
    },
}

-- ── Window ────────────────────────────────────────────────────
config.window_padding    = { left = 22, right = 22, top = 22, bottom = 22 }
config.window_decorations = "NONE"
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
config.use_fancy_tab_bar            = false  -- retro mode for custom title colors
config.tab_max_width                = 36
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom            = true

-- ── Tab / status palette ──────────────────────────────────────
local TB = "#181825"  -- tab bar bg (mantle)

local TAB = {
    active = { bg = "#89b4fa", fg = "#1e1e2e" },
    hover  = { bg = "#45475a", fg = "#cdd6f4" },
    normal = { bg = "#313244", fg = "#a6adc8" },
}

local SEG = {
    { bg = "#313244", fg = "#a6adc8" },  -- workspace
    { bg = "#45475a", fg = "#bac2de" },  -- date
    { bg = "#89b4fa", fg = "#1e1e2e" },  -- time (blue accent)
}

local SEP_R = wezterm.nerdfonts.pl_right_hard_divider  -- ▶
local SEP_L = wezterm.nerdfonts.pl_left_hard_divider   -- ◀

local ICONS = {
    zsh = " ", bash = " ", fish = " ",
    nvim = " ", vim = " ",
    git = " ", lazygit = " ",
    python3 = " ", python = " ",
    node = " ", lua = " ",
    btop = " ", htop = " ",
    yazi = " ", ssh = " ",
    cargo = " ", rustc = " ",
}

local function basename(s)
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

-- ── Custom tab title ──────────────────────────────────────────
wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
    local proc       = basename(tab.active_pane.foreground_process_name)
    local icon       = ICONS[proc] or " "
    local pane_title = tab.active_pane.title
    -- priority: manually set title > pane title (set by app, e.g. "claude") > process name
    local title = (tab.tab_title ~= "" and tab.tab_title)
                  or (pane_title ~= "" and pane_title)
                  or (proc ~= "" and proc)
                  or "shell"
    title = wezterm.truncate_right(icon .. " " .. title, max_width - 4)

    local t = tab.is_active and TAB.active or (hover and TAB.hover or TAB.normal)

    return {
        { Background = { Color = TB } },
        { Foreground = { Color = t.bg } },
        { Text = SEP_R },
        { Background = { Color = t.bg } },
        { Foreground = { Color = t.fg } },
        { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
        { Text = " " .. title .. " " },
        { Background = { Color = TB } },
        { Foreground = { Color = t.bg } },
        { Text = SEP_L },
    }
end)

-- ── Right status bar ──────────────────────────────────────────
-- Layout (left → right): [workspace] [date] [time ▶]
wezterm.on("update-right-status", function(window, pane)
    local segments = {
        "  " .. window:active_workspace(),
        wezterm.strftime("  %a %d/%m"),
        wezterm.strftime("  %H:%M"),
    }

    local items = {}
    local prev_bg = TB

    for i, text in ipairs(segments) do
        local s = SEG[i]
        -- leading powerline arrow: transition prev_bg → s.bg
        table.insert(items, { Background = { Color = prev_bg } })
        table.insert(items, { Foreground = { Color = s.bg } })
        table.insert(items, { Text = SEP_R })
        -- segment content
        table.insert(items, { Background = { Color = s.bg } })
        table.insert(items, { Foreground = { Color = s.fg } })
        if i == #segments then
            table.insert(items, { Attribute = { Intensity = "Bold" } })
        end
        table.insert(items, { Text = text .. " " })
        prev_bg = s.bg
    end

    window:set_right_status(wezterm.format(items))
end)

-- ── Cursor ────────────────────────────────────────────────────
config.default_cursor_style    = "BlinkingBar"
config.cursor_blink_rate       = 500
config.animation_fps           = 60
config.cursor_blink_ease_in    = "EaseIn"
config.cursor_blink_ease_out   = "EaseOut"

-- NOTE: cursor_trail requires a custom WezTerm build (PR #7420); silently ignored on stable
config.cursor_trail = {
    enabled            = true,
    duration           = 100,
    spread             = 4.0,
    opacity            = 0.8,
    dwell_threshold    = 50,
    distance_threshold = 2,
}

-- ── Shell ─────────────────────────────────────────────────────
config.default_prog = { "zsh" }

-- ── Scrollback ────────────────────────────────────────────────
config.scrollback_lines = 10000

-- ── Copy on select ────────────────────────────────────────────
config.mouse_bindings = {
    {
        event  = { Up = { streak = 1, button = "Left" } },
        mods   = "NONE",
        action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
    },
}

-- ── Keybindings ───────────────────────────────────────────────
config.keys = {
    { key = "c", mods = "CTRL", action = wezterm.action_callback(function(window, pane)
        if window:get_selection_text_for_pane(pane) ~= "" then
            window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
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
    -- key = "|" (Shift+\) and key = "_" (Shift+-) use the resulting char directly
    -- to avoid Wayland stripping SHIFT on special keys causing wrong match
    { key = "|", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "CTRL", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
}

return config
