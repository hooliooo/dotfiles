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
  -- Highlight other references to the symbol under the cursor (]] / [[ to jump)
  words = { enabled = true },
  indent = { enabled = true },
  -- Nicer vim.ui.input (e.g. LSP rename prompt)
  input = { enabled = true },
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
vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Find LSP symbols in workspace" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Grep word/selection" })
vim.keymap.set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume last picker" })
vim.keymap.set("n", "<leader>gf", function() Snacks.picker.git_status() end, { desc = "Git status (changed files)" })
vim.keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git log" })
vim.keymap.set("n", "<leader>gL", function() Snacks.lazygit() end, { desc = "Lazygit" })
vim.keymap.set("n", "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next reference" })
vim.keymap.set("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev reference" })
-- stylua: ignore end
