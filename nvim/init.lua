vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim ui2
require("vim._core.ui2").enable({
  enable = true,
  msg = {
    target = "cmd",
    pager = { height = 0.5 },
    dialog = { height = 0.5 },
    cmd = { height = 0.5 },
    msg = { height = 0.5, timeout = 4500 },
  },
})

require("config.options")
require("config.keymaps")
require("pack")

vim.cmd.colorscheme("tokyonight-night")

-- -- rust-analyzer marks symbols it can't resolve with the `unresolvedReference`
-- -- semantic token, which Neovim renders as a red undercurl. This is a false
-- -- positive in proc-macro/sqlx-heavy code, so strip the styling.
-- local function clear_rust_unresolved_hl()
--   vim.api.nvim_set_hl(0, "@lsp.type.unresolvedReference.rust", {})
-- end
-- clear_rust_unresolved_hl()
-- vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_rust_unresolved_hl })
