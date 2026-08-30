# Scout Report — markdownlint warnings vẫn spam trong nvim (Obsidian vault)

**Date:** 2026-07-01 18:17
**Trigger:** User thấy nhiều warning vàng (MD013/MD022/MD032) khi mở note trong Obsidian vault, dù đã cấu hình tắt rule + restart nvim.

## Triệu chứng
- File `~/Codes/Docs/Obsidian/vchun-note/AI/AI MOC.md` hiện nhiều `error MD013/line-length [Expected: 120; ...]`, `MD022/blanks-around-headings`, `MD032/blanks-around-lists`.
- Số `Expected: 120` = dấu hiệu config vault đang được dùng, KHÔNG phải config global đã tắt các rule này.

## Root cause (đã chứng minh bằng lệnh)
1. Vault có config riêng: `~/Codes/Docs/Obsidian/vchun-note/.markdownlint.yaml` với `MD013.line_length: 120`.
2. nvim-lint gọi `markdownlint-cli2` qua **stdin** (`args = {"-"}` mặc định; đã override thêm `--config ~/.markdownlint-cli2.yaml`).
3. markdownlint-cli2 (v0.22) khi đọc stdin **vẫn dò config theo cwd của tiến trình**, rồi **merge/đè** lên `--config`.
4. nvim chạy với **cwd = thư mục vault** → cli2 nhặt `.markdownlint.yaml` (line 120) → bật lại MD013/MD022/MD032.

### Bằng chứng
| cwd khi chạy cli2 (stdin) | Kết quả |
|---|---|
| `~/Codes/Docs/Obsidian/vchun-note` (có `.markdownlint.yaml`) | **17 error** (MD013 Expected 120...) |
| `/tmp` (không config) + `--config` global | **0 error** |
| `$HOME` (cli2 tự dò `~/.markdownlint-cli2.yaml`) | **0 error** |

→ `--config` KHÔNG đủ mạnh để bỏ qua config dò theo cwd. Restart nvim vô ích vì cwd vẫn là vault.

## Fix đề xuất (đã verify cơ chế)
Ép **cwd của linter markdownlint-cli2** về `~` (thư mục config-neutral, chỉ thấy `~/.markdownlint-cli2.yaml`). nvim-lint hỗ trợ field `cwd` (lint.lua:43,104,281).

Sửa spec `mfussenegger/nvim-lint` trong `dot_config/nvim/lua/plugins/markdown.lua`:
```lua
["markdownlint-cli2"] = {
  cwd = vim.fn.expand("~"),                 -- luôn chạy từ HOME -> chỉ dùng config global
  args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "-" },
},
```

### Đánh đổi
- Mọi file markdown sẽ dùng config markdownlint **global** của user, **bỏ qua** config riêng từng project/vault. Đúng nhu cầu (đọc note sạch), nhưng project nào muốn rule riêng sẽ không được tôn trọng.
- Phương án thay thế (nuclear): tắt hẳn markdownlint cho markdown (`linters_by_ft.markdown = {}`) — sạch tuyệt đối nhưng mất luôn lint.

## Files liên quan
- `dot_config/nvim/lua/plugins/markdown.lua` — nơi override nvim-lint (SẼ sửa).
- `~/.markdownlint-cli2.yaml` (source `dot_markdownlint-cli2.yaml`) — config global, đã tắt MD013/022/032/040/060/031/012/026/033/041.
- `~/Codes/Docs/Obsidian/vchun-note/.markdownlint.yaml` — config vault gây xung đột (ngoài chezmoi, KHÔNG sửa).

## Unresolved / cần user quyết
1. Chọn fix: **ép cw=~ (giữ lint, global)** hay **tắt hẳn markdownlint cho markdown**?
2. Marksman diagnostics đã tắt ở commit trước — giữ nguyên?
