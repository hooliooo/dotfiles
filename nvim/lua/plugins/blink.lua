require("blink.cmp").setup({
  fuzzy = {
    implementation = "rust",
    prebuilt_binaries = {
      download = true,
    },
  },
  -- keymaps
  keymap = {
    preset = "super-tab",
    ["<C-y>"] = { "select_and_accept" },
    -- If you want Enter to ALWAYS be a new line and NEVER accept:
    ["<CR>"] = { "fallback" },
  },

  -- editor insert mode completions
  completion = {
    menu = {
      auto_show = true, -- show on type
    },
    documentation = {
      auto_show = true, -- show function signature/docs
    },
    ghost_text = {
      enabled = false,
      show_with_menu = false,
    },
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
  },

  -- cmdline completions
  cmdline = {
    enabled = true,
    keymap = { preset = "cmdline" },
    completion = {
      menu = { auto_show = true },
    },
  },

  sources = {
    default = { "lsp", "path", "buffer", "snippets" },
    providers = {
      lsp = {
        opts = {
          tailwind_color_icon = "󱓻",
        },
      },
    },
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },

  snippets = {
    preset = "luasnip",
  },
})

require("luasnip.loaders.from_vscode").lazy_load()
