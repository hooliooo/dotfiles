require("tiny-inline-diagnostic").setup({
  preset = "modern", -- Other options: "classic", "minimal", "ghost"
  options = {
    -- Show the diagnostic on the same line as the cursor
    show_all_diags_on_cmdline = false,
    -- Enable multi-line diagnostics
    multilinediagnostic_enabled = true,
    -- Show ghost text (the grayed out text until you move to the line)
    show_ghost_text = false,
  },
})

-- IMPORTANT: You must disable Neovim's default diagnostic text
-- or they will clash/double-up on your screen.
vim.diagnostic.config({ virtual_text = false })
