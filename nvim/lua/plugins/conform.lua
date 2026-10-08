local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
require("conform").setup({
  formatters_by_ft = {
    cs = { "csharpier" },
    lua = { "stylua" },
    kotlin = { "ktlint" },
    rust = { "rustfmt", lsp_format = "fallback" },
    swift = { "swift" }, -- Apple's swift-format, via `swift format`
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

  -- Format on save, unless turned off globally (<leader>uF) or per buffer (<leader>uf)
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 2500, lsp_format = "fallback" }
  end,
})

-- Keymap for manual formatting (LazyVim: <leader>cf)
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({
    lsp_format = "fallback",
    async = false,
    timeout_ms = 2500,
  })
end, { desc = "Format Code" })

vim.keymap.set("n", "<leader>uf", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("Format on save (buffer): " .. (vim.b.disable_autoformat and "off" or "on"))
end, { desc = "Toggle format on save (buffer)" })
vim.keymap.set("n", "<leader>uF", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("Format on save (global): " .. (vim.g.disable_autoformat and "off" or "on"))
end, { desc = "Toggle format on save (global)" })
