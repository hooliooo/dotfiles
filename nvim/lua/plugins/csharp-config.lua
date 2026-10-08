require("roslyn").setup()

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
  test_runner = {
    -- Buffer-local maps in test files. The defaults (<leader>r/d/t/p) would
    -- shadow the debug group and LSP restart, so move them under <leader>nt
    mappings = {
      run_test_from_buffer = { lhs = "<leader>ntt", desc = "Run test under cursor" },
      run_all_tests_from_buffer = { lhs = "<leader>ntf", desc = "Run all tests in file" },
      debug_test_from_buffer = { lhs = "<leader>ntd", desc = "Debug test under cursor" },
      peek_stack_trace_from_buffer = { lhs = "<leader>ntp", desc = "Peek test stacktrace" },
    },
  },
})

-- *_default functions prompt for a project once and remember it
-- (`:Dotnet reset` clears the choice)
local function dotnet(fn, ...)
  local args = { ... }
  return function()
    require("easy-dotnet")[fn](unpack(args))
  end
end

-- stylua: ignore start
local map = vim.keymap.set
-- Run / debug
map("n", "<leader>nr", dotnet("run_default"), { desc = "Run project" })
map("n", "<leader>nR", dotnet("run_profile_default"), { desc = "Run project with launch profile" })
map("n", "<leader>nd", dotnet("debug_default"), { desc = "Debug project" })
map("n", "<leader>nD", dotnet("debug_profile_default"), { desc = "Debug project with launch profile" })
map("n", "<leader>na", dotnet("debug_attach"), { desc = "Attach debugger to process" })
map("n", "<leader>nw", dotnet("watch_default"), { desc = "Watch project" })
map("n", "<leader>nx", dotnet("stop"), { desc = "Stop running sessions" })
-- Build
map("n", "<leader>nb", dotnet("build_default_quickfix"), { desc = "Build project (quickfix)" })
map("n", "<leader>nB", dotnet("build_solution_quickfix"), { desc = "Build solution (quickfix)" })
map("n", "<leader>nc", dotnet("clean"), { desc = "Clean" })
map("n", "<leader>nC", dotnet("restore"), { desc = "Restore" })
map("n", "<leader>ne", function() require("easy-dotnet").diagnostics.get_workspace_diagnostics("error") end, { desc = "Workspace errors" })
-- Test (buffer maps for the test under cursor are set via test_runner.mappings above)
map("n", "<leader>nto", dotnet("testrunner"), { desc = "Toggle test runner" })
map("n", "<leader>nts", dotnet("test_solution"), { desc = "Test solution" })
-- Packages / project
map("n", "<leader>np", dotnet("add_package"), { desc = "Add NuGet package" })
map("n", "<leader>nP", dotnet("remove_package"), { desc = "Remove NuGet package" })
map("n", "<leader>no", dotnet("outdated"), { desc = "Show outdated packages" })
map("n", "<leader>ns", dotnet("secrets"), { desc = "User secrets" })
map("n", "<leader>nn", dotnet("new"), { desc = "New project from template" })
-- stylua: ignore end
