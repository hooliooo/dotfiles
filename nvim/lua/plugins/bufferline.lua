require("bufferline").setup({
  options = {
    offsets = {
      {
        filetype = "snacks_layout_box", -- Essential for Snacks Explorer integration
        text = "File Explorer",
        text_align = "left",
        separator = true,
      },
    },
  },
})

vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
