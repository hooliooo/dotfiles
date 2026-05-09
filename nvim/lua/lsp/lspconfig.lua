vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings
    local opts = { buffer = ev.buf, silent = true }
    -- Keymaps
    opts.desc = "Goto Definition"
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

    opts.desc = "Goto Declaration"
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

    opts.desc = "References"
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

    opts.desc = "Goto Implementation"
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)

    opts.desc = "Goto Type Definition"
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

    opts.desc = "See available code actions"
    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
      vim.lsp.buf.code_action()
    end, opts)

    opts.desc = "Rename"
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

    opts.desc = "Show buffer diagnostics"
    vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

    opts.desc = "Show line diagnostics"
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

    opts.desc = "Show documentation for what is under cursor"
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    opts.desc = "Restart LSP"
    vim.keymap.set("n", "<leader>rs", ":lsp restart<CR>", opts)

    vim.keymap.set("i", "<C-h>", function()
      vim.lsp.buf.signature_help()
    end, opts)
  end,
})
-- Configure and enable LSP servers
-- lua_ls
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      completion = {
        callSnippet = "Replace",
      },
    },
  },
})

vim.lsp.enable({
  "lua_ls",
})
