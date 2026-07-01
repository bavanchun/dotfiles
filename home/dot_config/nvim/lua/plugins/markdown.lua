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
  -- Điểm mấu chốt: cli2 đọc buffer qua stdin nhưng VẪN dò config theo cwd của
  -- tiến trình rồi merge/đè lên --config. nvim mở trong vault Obsidian (cwd =
  -- thư mục vault có .markdownlint.yaml line_length=120) -> config vault thắng,
  -- MD013/MD022/MD032 bật lại. Ép cwd = $HOME (chỉ thấy config global của user)
  -- để mọi file markdown lint theo đúng 1 config, sạch bất kể mở từ thư mục nào.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          cwd = vim.fn.expand("~"),
          args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "-" },
        },
      },
    },
  },

  -- Tắt diagnostics của marksman (LSP) nhưng GIỮ goto/hover/rename.
  -- Marksman báo wikilink [[...]] "ambiguous" gây nhiễu trong vault Obsidian
  -- (nơi [[...]] dùng khắp nơi). Cho handler publishDiagnostics thành no-op
  -- => marksman không đẩy diagnostic nào, các tính năng khác vẫn chạy.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
        },
      },
    },
  },
}
