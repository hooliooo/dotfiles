require("snacks").setup({
  -- The picker settings from your opts
  picker = {
    enabled = true, -- Must be enabled to use it
    hidden = true,
    ignored = true,
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
