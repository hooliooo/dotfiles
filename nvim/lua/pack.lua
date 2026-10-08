-- Post-install/update hooks. Registered before vim.pack.add() so they also
-- fire for installs from the lockfile
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("UserPackHooks", {}),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    -- Keep compiled parsers in step with nvim-treesitter's queries
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

-- Plugins
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },

  -- Color Scheme
  { src = "https://github.com/folke/tokyonight.nvim" },

  -- UI
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
  { src = "https://github.com/saghen/filler-begone.nvim" },

  -- Search
  { src = "https://github.com/magicduck/grug-far.nvim" },

  -- Formatting
  { src = "https://github.com/stevearc/conform.nvim" },

  -- Text Editing
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },

  -- Git
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Auto Complete
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

  -- Keymap guide
  { src = "https://github.com/folke/which-key.nvim" },

  -- Debugging
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },

  -- LSP
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- Queries only; used by mini.ai for function/class text objects
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  ---- CSharp
  { src = "https://github.com/seblyng/roslyn.nvim.git" },
  { src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },
  ---- Kotlin
  { src = "https://github.com/AlexandrosAlexiou/kotlin.nvim" },
  ---- Rust
  {
    src = "https://github.com/mrcjkb/rustaceanvim",
    version = vim.version.range("^9"),
  },
  { src = "https://github.com/saecki/crates.nvim" },

  -- PlantUML
  { src = "https://github.com/charlesnicholson/plantuml.nvim" },

  -- Live Preview (Markdown/HTML/AsciiDoc/SVG in a browser)
  { src = "https://github.com/brianhuster/live-preview.nvim" },
})
-- Syntax & Highlighting
require("plugins.treesitter")

-- UI
require("plugins.snacks")
require("plugins.bufferline")
require("plugins.lualine")

-- File Management
require("plugins.grug-far")

-- Formatting
require("plugins.conform")

-- Debugging/Diagnostics
require("plugins.nvim-dap")
require("plugins.tiny-inline-diagnostic")

-- Editing Helpers
require("plugins.mini")
require("plugins.render-markdown")

-- Git
require("plugins.git-config")

-- Completion
require("plugins.blink")

-- LSP
require("lsp.mason")
require("lsp.lspconfig")

require("plugins.csharp-config")
require("plugins.kotlin-config")
require("plugins.rust-config")
require("plugins.swift-config")

require("plugins.trouble")
require("plugins.todo-comments")

require("plugins.plantuml")
require("plugins.live-preview")

-- Which key
require("plugins.which-key")
