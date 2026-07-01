-- Markdown UI trong nvim (không dùng browser preview).
-- render-markdown.nvim vẽ đẹp ngay trong buffer: heading có icon + nền theo cấp,
-- code block bo viền, bullet/checkbox icon, table căn chỉnh. Cần Nerd Font —
-- WezTerm đang dùng JetBrainsMono Nerd Font nên icon hiện đầy đủ.
--
-- glow.nvim đã gỡ bỏ: khi render-markdown chạy, buffer đã đẹp nên :Glow thành thừa.
-- Gỡ khỏi spec này -> chạy :Lazy clean để xoá plugin.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx" },
    opts = {
      -- Heading: icon H1..H6 + thanh bar trên/dưới (border) để tách section
      -- rõ ràng như Obsidian. KHÔNG hardcode màu -> để render-markdown lấy màu
      -- theo colorscheme nên tự đổi đúng khi toggle light/dark theme.
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        border = true,
        width = "full",
      },
      -- Code block: nền kín cả khối, viền dày, chừa lề trái/phải cho dễ đọc.
      code = {
        width = "block",
        border = "thick",
        left_pad = 2,
        right_pad = 2,
      },
      -- Bullet list phân cấp bằng icon tròn/thoi thay cho dấu -.
      bullet = {
        icons = { "● ", "○ ", "◆ ", "◇ " },
      },
      -- Checkbox có icon rõ ràng cho done / chưa done.
      checkbox = {
        checked = { icon = "󰄲 " },
        unchecked = { icon = "󰄱 " },
      },
    },
  },

  -- Ép markdownlint-cli2 dùng config global ~/.markdownlint-cli2.yaml.
  -- nvim-lint pipe buffer qua stdin (args mặc định {"-"}) nên cli2 không có
  -- đường dẫn file để tự dò config, lại dừng ở git-root -> phải truyền --config
  -- tường minh, nếu không MD013/MD060... vẫn spam virtual-text vàng.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "-" },
        },
      },
    },
  },
}
