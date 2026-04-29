return {
  -- Install toolchains via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        -- Java
        "jdtls",
        "java-debug-adapter",
        "java-test",
        -- Kubernetes & Helm
        "helm-ls",
        "yaml-language-server",
        -- Formatters
        "prettier",
        "google-java-format",
      })
    end,
  },

  -- Auto-generate Java class template on new file
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    init = function()
      vim.api.nvim_create_autocmd("BufNewFile", {
        pattern = "*.java",
        callback = function()
          local filepath = vim.fn.expand("%:p")
          local classname = vim.fn.expand("%:t:r")
          -- Extract package from path (everything after /java/)
          local pkg = filepath:match(".*/java/(.+)/[^/]+%.java$")
          if pkg then
            pkg = pkg:gsub("/", ".")
          else
            pkg = "com.example"
          end
          local lines = {
            "package " .. pkg .. ";",
            "",
            "public class " .. classname .. " {",
            "  ",
            "}",
          }
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          -- Place cursor inside class body
          vim.api.nvim_win_set_cursor(0, { 4, 2 })
          vim.cmd("startinsert")
        end,
      })
    end,
  },

  -- Increase jdtls heap to prevent OutOfMemoryError during indexing
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.cmd = opts.cmd or {}
      opts.jvm_args = { "-Xms512m", "-Xmx2048m" }
    end,
  },

  -- Override <leader>cr to bypass inc-rename (incompatible with jdtls)
  {
    "smjonas/inc-rename.nvim",
    optional = true,
    keys = {
      {
        "<leader>cr",
        function()
          local ft = vim.bo.filetype
          if ft == "java" then
            vim.lsp.buf.rename()
          else
            return ":IncRename " .. vim.fn.expand("<cword>")
          end
        end,
        expr = true,
        desc = "Rename",
      },
    },
  },

  -- DAP: Java debugger keybinds
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      { "<leader>dT", function() require("jdtls").test_class() end, desc = "Debug Test Class" },
      { "<leader>dt", function() require("jdtls").test_nearest_method() end, desc = "Debug Nearest Test" },
    },
  },
}
