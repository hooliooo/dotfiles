vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- No remote plugins use these; skip the provider lookups (and checkhealth warnings)
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

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
vim.opt.showcmd = false -- avoids flicker from filler-begone with ui2
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"
vim.opt.foldlevelstart = 99 -- open files unfolded; treesitter folds via foldexpr

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.laststatus = 3
vim.opt.updatetime = 250
vim.opt.colorcolumn = ""
vim.opt.clipboard:append("unnamedplus")
vim.opt.isfname:append("@-@")
vim.opt.mouse = "a"
vim.opt.confirm = true
-- Sessions: skip empty/help/terminal windows, which do not restore cleanly
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize" }
vim.opt.autowrite = true
