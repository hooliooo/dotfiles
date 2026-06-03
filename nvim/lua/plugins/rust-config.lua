-- Rustaceanvim Setup
local extension_path = vim.env.HOME .. "/.local/share/nvim/mason/packages/codelldb/extension"
local codelldb_path = extension_path .. "/adapter/codelldb"
local liblldb_path = extension_path .. "/lldb/lib/liblldb"
local this_os = vim.uv.os_uname().sysname

if this_os:find("Windows") then
  codelldb_path = extension_path .. "adapter\\codelldb.exe"
  liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
else
  liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
end

-- This global variable IS the configuration for rustaceanvim
vim.g.rustaceanvim = {
  dap = {
    adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
  },
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set("n", "<leader>dRd", function()
        vim.cmd.RustLsp("debug")
      end, { buffer = bufnr, desc = "Debug cursor" })
      vim.keymap.set("n", "<leader>dRD", function()
        vim.cmd.RustLsp("debuggables")
      end, { buffer = bufnr, desc = "Debuggables" })
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        check = { command = "clippy", allTargets = true },
        procMacro = { enable = true },
        diagnostics = { experimental = { enable = true } },
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
