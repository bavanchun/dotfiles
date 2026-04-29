return {
  -- Task runner - great for building projects
  {
    "stevearc/overseer.nvim",
    opts = {},
    keys = {
      { "<leader>ow", "<cmd>OverseerToggle<cr>", desc = "Toggle Overseer" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run Task" },
      { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Overseer Quick Action" },
    },
    config = function(_, opts)
      require("overseer").setup(opts)

      -- Create custom build tasks
      vim.api.nvim_create_user_command("Build", function()
        require("overseer").run_template({ name = "build" })
      end, {})

      vim.api.nvim_create_user_command("BuildRun", function()
        require("overseer").run_template({ name = "build_and_run" })
      end, {})
    end,
  },

  -- Toggleterm - terminal in Neovim (alternative/complement to Overseer)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float Terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical Terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal Terminal" },
    },
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "vertical",
      close_on_exit = true,
      shell = vim.o.shell,
    },
  },
}
