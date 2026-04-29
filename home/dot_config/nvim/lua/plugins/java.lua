return {
  -- Install Java toolchain via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-debug-adapter",
        "java-test",
      })
    end,
  },

  -- Increase jdtls heap to prevent OutOfMemoryError during indexing
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.cmd = opts.cmd or {}
      -- Bump JVM heap: 512MB initial, 2GB max
      opts.jvm_args = { "-Xms512m", "-Xmx2048m" }
    end,
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
