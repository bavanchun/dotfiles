-- Markdown preview trong nvim.
-- LazyVim extra `lang.markdown` đã cung cấp render-markdown.nvim (render trong buffer),
-- marksman LSP, markdownlint, prettier. Plugin dưới đây bổ sung glow.nvim để đọc
-- markdown ở chế độ float "read mode" đầy đủ bằng lệnh :Glow (không map phím).
return {
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    ft = "markdown",
    opts = {},
  },
}
