return {
  -- Install Java toolchain via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-debug-adapter",
        "java-test",
        "google-java-format",
      })
    end,
  },

  -- nvim-jdtls: fine-tuned for Spring Boot projects
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          format = {
            enabled = true,
            settings = {
              -- Use Google Java Style as default (closest to IntelliJ default)
              url = vim.fn.stdpath("data") .. "/mason/packages/google-java-format/google-java-format.jar",
            },
          },
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          completion = {
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
              "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
              "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            hashCodeEquals = { useJava7Objects = true },
            useBlocks = true,
          },
          -- Spring Boot annotation processing
          autobuild = { enabled = true },
        },
      })
    end,
  },

  -- DAP: Java debugger (works with Spring Boot remote debug)
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      { "<leader>dT", function() require("jdtls").test_class() end, desc = "Debug Test Class (Java)" },
      { "<leader>dt", function() require("jdtls").test_nearest_method() end, desc = "Debug Nearest Test (Java)" },
    },
  },

  -- neotest: run Maven/Gradle tests inline like IntelliJ's test runner
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "rcasia/neotest-java" },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, {
        require("neotest-java")({
          -- auto-detect maven or gradle
          ignore_wrapper = false,
        }),
      })
    end,
  },

  -- Trouble: Problems panel equivalent (like IntelliJ's Problems view)
  {
    "folke/trouble.nvim",
    optional = true,
    keys = {
      { "<leader>xj", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    },
  },
}
