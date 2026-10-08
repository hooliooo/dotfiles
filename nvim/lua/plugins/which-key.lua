local wk = require("which-key")

wk.setup({
  preset = "helix", -- options: "classic", "modern", "helix"
  delay = 300,
})

wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>d", group = "debug" },
  { "<leader>dR", group = "rust-debug" },
  { "<leader>f", group = "file/find" },
  { "<leader>g", group = "git" },
  { "<leader>n", group = ".NET" },
  { "<leader>nt", group = "test" },
  { "<leader>r", group = "rust/restart" },
  { "<leader>s", group = "search" },
  { "<leader>u", group = "ui" },
  { "<leader>x", group = "diagnostics/quickfix" },
})

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer Keymaps (which-key:)" })
