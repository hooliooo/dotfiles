local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
require("conform").setup({
  formatters_by_ft = {
    cs = { "csharpier" },
    lua = { "stylua" },
    -- This merges your previous setup:
    rust = { "rustfmt", lsp_format = "fallback" },
  },
  formatters = {
    csharpier = {
      command = vim.fs.joinpath(mason_bin, "csharpier"),
      args = {
        "format",
        "--write-stdout",
      },
      to_stdin = true,
    },
  },

  -- Replicating LazyVim's Format on Save
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

-- Keymap for manual formatting (LazyVim: <leader>cf)
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Format Code" })
