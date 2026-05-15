return {
  {
    "nvim-flutter/flutter-tools.nvim",
    opts = {
      flutter_path = vim.fn.exepath("flutter"),
      decorations = { statusline = { app_version = true, device = true } },
      dev_log = { enabled = true, open_cmd = "botright 15split" },
      closing_tags = { enabled = true, prefix = "// " },
      lsp = {
        color = { enabled = true },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "prompt",
          lineLength = 100,
        },
      },
      debugger = {
        enabled = true,
        run_via_dap = true,
        register_configurations = function(_)
          require("dap").configurations.dart = {
            { type = "dart", request = "launch", name = "Launch", program = "lib/main.dart" },
          }
        end,
      },
    },
  },
}
