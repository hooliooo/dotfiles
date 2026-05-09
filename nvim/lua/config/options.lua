vim.o.termguicolors = true
vim.o.nu = true
vim.o.relativenumber = true

vim.o.shiftwidth = 2

-- backup and undo
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.o.undofile = true

-- search
vim.o.inccommand = "split"

-- UI
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"

-- window splits
vim.o.splitright = true
vim.o.splitbelow = true

-- misc
vim.o.updatetime = 50
vim.o.colorcolumn = "0"
vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.cmdheight = 1
vim.o.confirm = true
vim.o.autowrite = true
