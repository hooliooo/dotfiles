require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- This merges your previous setup:
    rust = { "rustfmt", lsp_format = "fallback" },
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

