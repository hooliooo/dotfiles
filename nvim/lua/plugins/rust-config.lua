-- Rustaceanvim Setup
-- The DAP adapter is not configured here: rustaceanvim auto-detects
-- Mason's codelldb (and falls back to codelldb/lldb-dap on PATH).

-- This global variable IS the configuration for rustaceanvim
vim.g.rustaceanvim = {
  tools = {
    -- Run tests in the background; failures show up as diagnostics on the
    -- failing test (with the assertion message) instead of a terminal split
    test_executor = "background",
  },
  server = {
    on_attach = function(_, bufnr)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      local function rust(...)
        local args = { ... }
        return function()
          vim.cmd.RustLsp(args)
        end
      end
      -- stylua: ignore start
      -- Rust-aware versions of the generic LSP keys
      map("n", "<leader>ca", rust("codeAction"), "Code action (grouped)")
      map("x", "<leader>ca", ":RustLsp codeAction<CR>", "Code action (grouped)")
      map("n", "K", rust("hover", "actions"), "Hover (with actions)")
      map("n", "J", rust("joinLines"), "Join lines (Rust-aware)")
      map("x", "J", ":RustLsp joinLines<CR>", "Join lines (Rust-aware)")
      -- Run / test / debug (rerun the last debug session with <leader>dl)
      map("n", "<leader>rr", rust("runnables"), "Runnables")
      map("n", "<leader>rR", function() vim.cmd.RustLsp({ "runnables", bang = true }) end, "Rerun last runnable")
      map("n", "<leader>rt", rust("testables"), "Testables")
      map("n", "<leader>rT", function() vim.cmd.RustLsp({ "testables", bang = true }) end, "Rerun last test")
      map("n", "<leader>rD", rust("debuggables"), "Debuggables")
      map("n", "<leader>rx", rust("debug"), "Debug target under cursor")
      -- Diagnostics / navigation / tools
      map("n", "<leader>re", rust("explainError"), "Explain error")
      map("n", "<leader>rd", rust("renderDiagnostic"), "Render diagnostic")
      map("n", "<leader>rm", rust("expandMacro"), "Expand macro")
      map("n", "<leader>rc", rust("openCargo"), "Open Cargo.toml")
      map("n", "<leader>ro", rust("openDocs"), "Open docs.rs for symbol")
      map("n", "<leader>rp", rust("parentModule"), "Parent module")
      map("n", "<leader>rk", rust("moveItem", "up"), "Move item up")
      map("n", "<leader>rj", rust("moveItem", "down"), "Move item down")
      -- stylua: ignore end
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = false,
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

-- Cargo.toml keymaps (crates.nvim), also under <leader>r
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("UserCratesKeymaps", {}),
  pattern = "Cargo.toml",
  callback = function(ev)
    local crates = require("crates")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "<leader>rv", crates.show_versions_popup, "Crate versions")
    map("n", "<leader>rf", crates.show_features_popup, "Crate features")
    map("n", "<leader>ru", crates.upgrade_crate, "Upgrade crate")
    map("x", "<leader>ru", crates.upgrade_crates, "Upgrade selected crates")
    map("n", "<leader>rU", crates.upgrade_all_crates, "Upgrade all crates")
    map("n", "<leader>ro", crates.open_documentation, "Open docs.rs")
    map("n", "<leader>ri", crates.open_crates_io, "Open crates.io")
    map("n", "<leader>rg", crates.open_repository, "Open repository")
  end,
})
