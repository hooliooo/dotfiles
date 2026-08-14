require("roslyn").setup({
  ft = { "cs" },
})

require("easy-dotnet").setup({
  -- Roslyn is handled by roslyn.nvim above; don't let easy-dotnet
  -- spawn a second language server
  lsp = { enabled = false },
  picker = "snacks",
  debugger = {
    -- Registers dap.configurations.cs with build-before-debug and
    -- launchSettings.json launch-profile env vars
    auto_register_dap = true,
    bin_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "netcoredbg"),
  },
})
