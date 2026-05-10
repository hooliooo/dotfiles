-- Plugins
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },

  -- Color Scheme
  { src = "https://github.com/folke/tokyonight.nvim" },

  -- UI
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },

  -- Search
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/magicduck/grug-far.nvim" },

  -- Formatting
  { src = "https://github.com/stevearc/conform.nvim" },

  -- Text Editing
  { src = "https://github.com/nvim-mini/mini.nvim" },

  -- Git
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Auto Complete
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  { src = "https://github.com/L3MON4D3/LuaSnip", version = "v2.4.1" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- Noice
  { src = "https://github.com/folke/noice.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },

  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },

  -- To Do
  { src = "https://github.com/folke/todo-comments.nvim" }, --enabled
  { src = "https://github.com/folke/trouble.nvim" }, --enabled

  -- Icons
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- Keymap guide
  { src = "https://github.com/folke/which-key.nvim" },

  -- Debugging/Diagnostics
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/NicholasMata/nvim-dap-cs" },
  { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },

  -- LSP
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  ---- CSharp
  { src = "https://github.com/seblyng/roslyn.nvim.git" },
  ---- Rust
  {
    src = "https://github.com/mrcjkb/rustaceanvim",
    version = vim.version.range("^9"),
  },
  { src = "https://github.com/saecki/crates.nvim" },
})
-- Syntax & Highlighting
require("plugins.treesitter")

-- UI
require("plugins.mini")
require("plugins.snacks")
require("plugins.lualine")
require("plugins.noice")

-- File Management
require("plugins.bufferline")
require("plugins.telescope")
require("plugins.grug-far")

-- Formatting
require("plugins.conform")

-- Debugging/Diagnostics
require("plugins.nvim-dap")
require("plugins.tiny-inline-diagnostic")

-- Editing Helpers
require("plugins.render-markdown")

-- Git
require("plugins.git-config")

-- Completion
require("plugins.blink")

-- LSP
require("lsp.mason")
require("lsp.lspconfig")

require("plugins.csharp-config")
require("plugins.rust-config")

require("plugins.trouble")
require("plugins.todo-comments")

-- Which key
require("plugins.which-key")
