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
      -- Icon heading H1..H6 (đậm dần), thay cho dấu # thô.
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
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
}
