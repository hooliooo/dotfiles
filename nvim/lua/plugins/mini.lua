local ai = require("mini.ai")
ai.setup({
  -- Function/class definitions from nvim-treesitter-textobjects queries
  -- (e.g. daF / vic). Lowercase f stays mini.ai's function-call object.
  custom_textobjects = {
    F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
  },
})
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

-- Sessions: one per working directory, stored in stdpath("data")/session.
-- The active session is rewritten on exit.
require("mini.sessions").setup({ autowrite = true })

local function session_name()
  return (vim.fn.getcwd():gsub("[/\\:]", "%%"))
end

-- stylua: ignore start
vim.keymap.set("n", "<leader>qs", function() MiniSessions.write(session_name()) end, { desc = "Save session (cwd)" })
vim.keymap.set("n", "<leader>qr", function() MiniSessions.read(session_name()) end, { desc = "Restore session (cwd)" })
vim.keymap.set("n", "<leader>ql", function() MiniSessions.select("read") end, { desc = "Pick session" })
vim.keymap.set("n", "<leader>qd", function() MiniSessions.select("delete") end, { desc = "Delete session" })
-- stylua: ignore end
