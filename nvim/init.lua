vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim ui2
require('vim._core.ui2').enable({
    enable = true,
    msg = {
        target = "cmd",
        pager = { height = 0.5 },
        dialog = { height = 0.5 },
        cmd    = { height = 0.5 },
        msg   = { height = 0.5, timeout = 4500 },
    },
})

require("config.options")
require("config.keymaps")
require("pack")

vim.cmd.colorscheme('tokyonight-night')


