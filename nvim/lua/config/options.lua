vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

-- search
vim.opt.inccommand = "split"

-- UI
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 0
vim.opt.termguicolors = true

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.laststatus = 3
vim.opt.updatetime = 50
vim.opt.colorcolumn = "0"
vim.opt.clipboard:append("unnamedplus")
vim.opt.isfname:append("@-@")
vim.opt.mouse = "a"
vim.opt.confirm = true
vim.opt.autowrite = true
