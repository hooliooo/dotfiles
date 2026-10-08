require("snacks").setup({
  -- The picker settings from your opts
  picker = {
    enabled = true, -- Must be enabled to use it
    -- Search pickers skip hidden/gitignored files (toggle with <A-h>/<A-i>);
    -- the explorer shows everything (toggle with H/I)
    sources = {
      explorer = { hidden = true, ignored = true },
    },
    exclude = {
      ".DS_Store",
    },
    -- This section defines the icons for ALL snacks pickers, including the explorer
    icons = {
      files = {
        enabled = true,
      },
      git = {
        staged = "●", -- Green dot
        added = "A", -- Added file
        deleted = "D", -- Deleted file
        ignored = "◌", -- Ignored file
        modified = "M", -- Modified file
        renamed = "R", -- Renamed file
        untracked = "U", -- Untracked file
      },
    },
  },
  -- Enable the explorer since you want to use it
  explorer = { enabled = true },
})
---@diagnostic disable: undefined-global
vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "File Explorer" })
-- Delete current buffer
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })

-- Delete other buffers (The Snacks way)
vim.keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- Pickers
-- stylua: ignore start
vim.keymap.set("n", "<leader><leader>", function() Snacks.picker.files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Find help tags" })
vim.keymap.set("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, { desc = "Find LSP symbols in current buffer" })
vim.keymap.set("n", "<leader>D", function() Snacks.picker.diagnostics_buffer() end, { desc = "Show buffer diagnostics" })
vim.keymap.set("n", "<leader>sT", function()
  Snacks.picker.pick(vim.tbl_extend("force", require("todo-comments.snacks").source, { title = "Todos" }))
end, { desc = "Todo (Snacks)" })
-- stylua: ignore end
