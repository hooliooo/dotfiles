-- Rustaceanvim Setup
-- The DAP adapter is not configured here: rustaceanvim auto-detects
-- Mason's codelldb (and falls back to codelldb/lldb-dap on PATH).

-- This global variable IS the configuration for rustaceanvim
vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
      end
      -- stylua: ignore start
      -- Debugging
      map("<leader>dRd", function() vim.cmd.RustLsp("debug") end, "Debug cursor")
      map("<leader>dRD", function() vim.cmd.RustLsp("debuggables") end, "Debuggables")
      map("<leader>dRl", function() vim.cmd.RustLsp({ "debuggables", bang = true }) end, "Rerun last debuggable")
      -- Running / Testing
      map("<leader>dRr", function() vim.cmd.RustLsp("runnables") end, "Runnables")
      map("<leader>dRt", function() vim.cmd.RustLsp("testables") end, "Testables")
      -- Diagnostics / Tools
      map("<leader>re", function() vim.cmd.RustLsp("explainError") end, "Explain error")
      map("<leader>rd", function() vim.cmd.RustLsp("renderDiagnostic") end, "Render diagnostic")
      map("<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "Expand macro")
      map("<leader>rc", function() vim.cmd.RustLsp("openCargo") end, "Open Cargo.toml")
      -- stylua: ignore end
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          -- Separate target dir so cargo build/run/debug never block on
          -- rust-analyzer's check lock (and vice versa)
          targetDir = true,
        },
        check = { command = "clippy", allTargets = true },
        procMacro = { enable = true },
        -- diagnostics = { experimental = { enable = true } },
        inlayHints = {
          lifetimeElisionHints = { enable = "skip_trivial" },
        },
      },
    },
  },
}

-- Crates.nvim Setup
require("crates").setup({
  completion = { crates = { enabled = true } },
  lsp = { enabled = true, actions = true, completion = true, hover = true },
})
