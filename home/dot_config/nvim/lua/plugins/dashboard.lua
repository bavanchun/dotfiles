-- Target colors for VCHUN header gradient (tokyonight palette)
local header_colors = {
  { 0x7a, 0xa2, 0xf7 }, -- line 1: blue
  { 0x7d, 0xcf, 0xff }, -- line 2: cyan
  { 0x73, 0xda, 0xca }, -- line 3: teal
  { 0x9e, 0xce, 0x6a }, -- line 4: green
  { 0xbb, 0x9a, 0xf7 }, -- line 5: purple
  { 0xc0, 0xca, 0xf5 }, -- line 6: light
}
local horse_color = { 0xe0, 0xaf, 0x68 } -- tokyonight yellow/gold

local function rgb(c)
  return string.format("#%02x%02x%02x", c[1], c[2], c[3])
end

local function set_hl()
  for i, c in ipairs(header_colors) do
    vim.api.nvim_set_hl(0, "VchunLine" .. i, { fg = rgb(c), bold = true })
  end
  vim.api.nvim_set_hl(0, "VchunHorse", { fg = rgb(horse_color) })
  vim.api.nvim_set_hl(0, "VchunFooter", { fg = "#565f89", italic = true })
end

local function animate_header()
  local bg = { 0x1a, 0x1b, 0x26 }
  -- Horse fades in first
  Snacks.animate(0, 100, function(value)
    local r = math.floor(bg[1] + (horse_color[1] - bg[1]) * value / 100)
    local g = math.floor(bg[2] + (horse_color[2] - bg[2]) * value / 100)
    local b = math.floor(bg[3] + (horse_color[3] - bg[3]) * value / 100)
    vim.api.nvim_set_hl(0, "VchunHorse", { fg = string.format("#%02x%02x%02x", r, g, b) })
  end, { duration = 20, easing = "outQuad" })
  -- VCHUN lines cascade after horse finishes (~200ms)
  for i, target in ipairs(header_colors) do
    vim.defer_fn(function()
      Snacks.animate(0, 100, function(value)
        local r = math.floor(bg[1] + (target[1] - bg[1]) * value / 100)
        local g = math.floor(bg[2] + (target[2] - bg[2]) * value / 100)
        local b = math.floor(bg[3] + (target[3] - bg[3]) * value / 100)
        vim.api.nvim_set_hl(0, "VchunLine" .. i, {
          fg = string.format("#%02x%02x%02x", r, g, b),
          bold = true,
        })
      end, { duration = 20, easing = "outQuad" })
    end, 200 + (i - 1) * 80)
  end
end

local horse_lines = {
  [[⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⠀⠀⢱⠐⠄⠙⠽⡲⣤⡀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⠀⠀⡾⠃⠀⠀⢀⠈⠻⣿⣿⣶⡶⢃⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⠀⡼⣧⣀⣠⡴⠀⢂⠀⠙⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⢸⣅⣩⠟⠁⢰⠀⠸⡄⠀⠐⢻⣿⣿⡿⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⠈⠙⠁⠀⠀⢀⠀⠀⡇⠀⠀⠄⠻⠿⢷⣋⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⠀⠀⠀⠀⠀⣸⠀⢠⠇⢀⡜⠀⠀⠐⡄⠀⠀⠈⠈⠐⢤⡀⠀⠀⠀⠀⠀]],
  [[⠀⠀⠀⠀⠀⢠⡏⠀⢈⡴⠋⠀⠀⠀⠀⡗⠀⠀⠀⠀⠀⠀⢻⣿⣶⣦⣄⠀]],
  [[⠀⠀⠀⠀⠀⡾⠀⡄⡎⠀⠀⠀⠀⠀⡰⠃⠀⠀⠀⠀⡠⠀⢀⡇⠙⣿⣿⡷]],
  [[⠀⠀⠀⠀⡠⠣⠀⠇⡄⠀⠀⠀⢠⠔⠁⠀⠀⠀⣠⠞⠀⢀⡜⣠⣾⢿⠟⠀]],
  [[⠀⠀⢀⡴⠁⣀⠤⠊⠘⡆⠀⣠⠣⢤⠤⠴⢲⠋⠙⠀⣰⠋⠘⡝⠁⠘⠄⠀]],
  [[⠀⣰⡿⠖⠉⠀⠀⢀⠊⡀⠚⠁⠀⠈⠀⡰⠁⠀⡆⡜⠁⠀⠀⠁⠀⠀⠀⠀]],
  [[⢀⡿⠁⠀⠀⠀⢰⣿⠏⠀⠀⠀⠀⡀⢰⠁⢀⣼⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⣾⡇⠀⠀⠀⠀⠀⢻⣧⣶⡄⠀⠀⣇⠎⣠⡾⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⣿⣷⠀⠀⠀⠀⠀⠀⠉⠉⠁⠀⣼⢏⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣾⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
  [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠏⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
}

local vchun_lines = {
  "██╗   ██╗   ██████╗   ██╗  ██╗  ██╗   ██╗  ███╗   ██╗",
  "██║   ██║  ██╔════╝   ██║  ██║  ██║   ██║  ████╗  ██║",
  "██║   ██║  ██║        ███████║  ██║   ██║  ██╔██╗ ██║",
  "╚██╗ ██╔╝  ██║        ██╔══██║  ██║   ██║  ██║╚██╗██║",
  " ╚████╔╝   ╚██████╗   ██║  ██║  ╚██████╔╝  ██║ ╚████║",
  "  ╚═══╝     ╚═════╝   ╚═╝  ╚═╝   ╚═════╝   ╚═╝  ╚═══╝",
}

-- Build header: VCHUN gradient only
local header_text = {}
for i, line in ipairs(vchun_lines) do
  local nl = i < #vchun_lines and "\n" or ""
  table.insert(header_text, { line .. nl, hl = "VchunLine" .. i })
end

-- Build horse text block for pane 2
local horse_text = {}
for i, line in ipairs(horse_lines) do
  local nl = i < #horse_lines and "\n" or ""
  table.insert(horse_text, { line .. nl, hl = "VchunHorse" })
end

return {
  "folke/snacks.nvim",
  config = function(_, opts)
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
    vim.api.nvim_create_autocmd("User", {
      pattern = "SnacksDashboardOpened",
      callback = animate_header,
    })
    require("snacks").setup(opts)
  end,
  opts = {
    dashboard = {
      sections = {
        {
          text = header_text,
          align = "center",
          padding = 2,
        },
        { section = "keys", gap = 1, padding = 1 },
        {
          section = "terminal",
          cmd = "fortune -s | cowsay -f $(ls /usr/share/cowsay/cows/ | shuf -n1)",
          height = 12,
          padding = 1,
          indent = 4,
          ttl = 0,
          enabled = vim.fn.executable("cowsay") == 1 and vim.fn.executable("fortune") == 1,
        },
        { section = "startup" },
        {
          text = { { "─── 🐧 Code is poetry ───", hl = "VchunFooter" } },
          align = "center",
          padding = { 1, 0 },
        },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 5 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, limit = 3 },
        { pane = 2, text = horse_text, align = "center", padding = { 1, 0 } },
      },
    },
  },
}
